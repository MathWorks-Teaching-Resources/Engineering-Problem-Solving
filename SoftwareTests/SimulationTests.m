classdef SimulationTests < sltest.TestCase

    properties
        RootFolder
    end % properties

    properties (ClassSetupParameter)
        Project = {currentProject()};
    end

    properties (TestParameter)
        Model
    end

    methods (TestParameterDefinition,Static)

        function Model = RetrieveModel(Project)
            RootFolder = Project.RootFolder;
            Model = dir(fullfile(RootFolder,"Models","*.slx"));
            Model = {Model.name};
        end

    end

    methods (TestClassSetup)

        function SetUpSmokeTest(testCase,Project)
            testCase.RootFolder = Project.RootFolder;
            cd(testCase.RootFolder);
        end

    end

    methods (Test)

        function SmokeTest(testCase,Model)

            % Navigate to project root folder
            cd(testCase.RootFolder)
            ModelToRun = string(Model);
            SimIn = testCase.createSimulationInput(Model);

            % Pre-test:
            PreFiles = CheckPreFile(testCase,ModelToRun);
            run(PreFiles);  

            % Run Smoke test
            if exist('AddParams','var')
                for IdxParams = 1:size(AddParams,1)
                    SimIn = setModelParameter(SimIn,AddParams{IdxParams,1},AddParams{IdxParams,2});
                end
            end
            try
                testCase.simulate(SimIn);
            catch ME
            end

            % Post-test:
            PostFiles = CheckPostFile(testCase,ModelToRun);
            run(PostFiles)

            % Rethrow error if any
            if exist("ME","var")
                if ~any(strcmp(ME.identifier,KnownIssuesID))
                    rethrow(ME)
                end
            end

        end

    end


   methods (Access = private)

       function Path = CheckPreFile(testCase,Filename)
            PreFile = "Pre"+replace(Filename,".slx","SLX.m");
            PreFilePath = fullfile(testCase.RootFolder,"SoftwareTests","PreFiles",PreFile);
            if ~isfolder(fullfile(testCase.RootFolder,"SoftwareTests/PreFiles"))
                mkdir(fullfile(testCase.RootFolder,"SoftwareTests/PreFiles"))
            end
            if ~isfile(PreFilePath)
                writelines("%  Pre-run script for "+Filename,PreFilePath)
                writelines("% ---- Known Issues     -----",PreFilePath,'WriteMode','append');
                writelines("KnownIssuesID = "+char(34)+char(34)+";",PreFilePath,'WriteMode','append');
                writelines("% ---- Pre-run commands -----",PreFilePath,'WriteMode','append');
                writelines(" ",PreFilePath,'WriteMode','append');
            end
            Path = PreFilePath;
       end
        
       function Path = CheckPostFile(testCase,Filename)
            PostFile = "Post"+replace(Filename,".slx","SLX.m");
            PostFilePath = fullfile(testCase.RootFolder,"SoftwareTests","PostFiles",PostFile);
            if ~isfolder(fullfile(testCase.RootFolder,"SoftwareTests/PostFiles"))
                mkdir(fullfile(testCase.RootFolder,"SoftwareTests/PostFiles"))
            end
            if ~isfile(PostFilePath)
                writelines("%  Post-run script for "+Filename,PostFilePath)
                writelines("% ---- Post-run commands -----",PostFilePath,'WriteMode','append');
                writelines(" ",PostFilePath,'WriteMode','append');
            end
            Path = PostFilePath;
        end

   end
end