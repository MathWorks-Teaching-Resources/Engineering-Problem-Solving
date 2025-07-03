%  Pre-run script for DefiningRequirementsSoln.mlx
% ---- Known Issues     -----
KnownIssuesID = "";
% ---- Pre-run commands -----
 
% sltest.testmanager = @(x) disp("... Opening "+x);
sltest.testmanager.clear = @(x) disp("... Opening "+x);
sltest.testmanager.clearResults = @(x) disp("... Opening "+x);