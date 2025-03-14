function Plan = buildfile

import matlab.buildtool.tasks.*

%% ----- Default plan -----
Plan = buildplan;
Plan("clean") = CleanTask;

%% ----- Check code -----
Plan("check") = CodeIssuesTask(Results=fullfile("public","code-issues","results.mat"));

%% ---- Test stage -----
% ----- Test:Scripts -----
Name = "TestScripts";
Tags = [string(computer("arch")) string(version("-release"))];
Folder = join([Name Tags],"_");
% Select the files
TestFiles = fullfile("SoftwareTests","SmokeTests.m");
if isfile(fullfile("SoftwareTests","SolnSmokeTests.m"))
    TestFiles(end+1) = fullfile("SoftwareTests","SolnSmokeTests.m");
end
if isfile(fullfile("SoftwareTests","FunctionTests.m"))
    TestFiles(end+1) = fullfile("SoftwareTests","FunctionTests.m");
end
TestFiles = matlab.buildtool.io.FileCollection.fromPaths(TestFiles);
% Select the source file for code coverage
SourceFiles = matlab.buildtool.io.FileCollection.fromPaths(...
    [fullfile("Scripts",["*.mlx";"*.m"]);...
    fullfile("FunctionLibrary",["*.mlx";"*.m"]);...
    fullfile("InstructorResources","Solutions",["*.mlx";"*.m"])]);
% Define the test stage
Plan("test-scripts") = TestTask(...
    TestFiles, ...
    SourceFiles=SourceFiles,...
    TestResults=fullfile("public",Folder,["results.html" "results.mat" "results.xml"]),...
    CodeCoverageResults=fullfile("public",Folder,"code-coverage.html"))
% ----- Test:Models -----
% Check that there is model and test exist:
if ~isempty(dir("**/*.slx")) || isfile(fullfile("SoftwareTests","SimulationTests.m"))
    % Define the reporting folder:
    Name = "SimulationTests";
    Tags = [string(computer("arch")) string(version("-release"))];
    Folder = join([Name Tags],"_");
    % Select the test to run
    TestFiles = matlab.buildtool.io.FileCollection.fromPaths(fullfile("SoftwareTests","SimulationTests.m"));
    % Define the test stage
    Plan("test-models") = TestTask(...
        TestFiles,...
        TestResults=fullfile("public",Folder,["results.html" "results.mat" "results.xml"]));
end
% ----- Test:Internal -----
if isfile(which("CMTests.m"))
    Folder = "Internal";
    Plan("test-internal") = TestTask(...
        "CMTests",...
        TestResults=fullfile("public",Folder,["results.html" "results.mat"]));
end
% ----- Test -----
% Plan("test").Description = "Run collection of tests designed for this module.";

%% ----- Deploy stage -----
% ----- Deploy:generate -----
Plan("deploy-generate") = TestTask(fullfile("SoftwareTests","CheckTestResults.m"),...
            TestResults=fullfile("public","index.html"));
% ----- Deploy:edit -----
Plan("deploy-edit") = matlab.buildtool.Task(Actions=@(~) EditReport);
    function EditReport
        % Read the report:
        FileContent = fileread(fullfile("public","index.html"));
        % Add test report link:
        TestReport = string(extractBetween(FileContent,"TestReport=","<"));
        TestReport(endsWith(TestReport,")")) = [];
        for TestIdx = 1:length(TestReport)
            OldString = TestReport(TestIdx);
            NewString = OldString+"</br>";
            if isfile(fullfile("public",OldString,"results.html"))
                NewString = NewString + "<a href='"+OldString+"/results.html'>Test Report</a>";
            end
            if isfile(fullfile("public",OldString,"code-coverage.html"))
                NewString = NewString + "  <a href='"+OldString+"/code-coverage.html'>Code Coverage</a>";
            end
            FileContent = replace(FileContent,OldString,NewString);
        end
        writelines(FileContent,fullfile("public","index.html"))
    end
% ----- Deploy -----
% Plan("deploy").Description = "Deploy final report.";
end

