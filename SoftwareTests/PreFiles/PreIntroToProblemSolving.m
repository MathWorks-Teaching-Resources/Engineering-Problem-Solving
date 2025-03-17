%  Pre-run script for IntroToProblemSolving.mlx
% ---- Known Issues     -----
KnownIssuesID = "";
% ---- Pre-run commands -----
 
out1.logsout{1}.Values.Data = zeros(51,1);
out1.logsout{1}.Values.Time = (0:1:50)';
web = @(x) disp("... Opening "+x);
% simData = zeros(50,1);