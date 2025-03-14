classdef CheckTestResults < matlab.unittest.TestCase

    properties (SetAccess = protected)
    end

    properties (ClassSetupParameter)
        Project = {currentProject()};
    end

    properties (TestParameter)
        TestReport
    end


    methods (TestParameterDefinition,Static)

        function TestReport = GetResults(Project)
            RootFolder = Project.RootFolder;
            TestReport = dir(fullfile(RootFolder,"public","**/results.mat"));
            TestReport = {TestReport.folder};
            TestReport = cellfun(@(x) extractAfter(x,"public"+filesep),TestReport,'UniformOutput',false);
        end

    end

    methods (TestClassSetup)

        function SetUpSmokeTest(testCase,Project)
            try
               currentProject;   
            catch
                testCase.assertFail("Project is not loaded.")
            end
        end

    end

    methods(Test)

        function CheckResults(testCase,TestReport)
            load(fullfile(currentProject().RootFolder,"public",TestReport,"results.mat"),"-mat","result");
            if ~all([result.Passed])
                testCase.assertFail;
            end
        end

    end

end