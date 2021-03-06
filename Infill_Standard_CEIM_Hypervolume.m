function obj = Infill_Standard_CEIM_Hypervolume(x, kriging_obj, kriging_con, f)
%-----------------------------------------------------
% [1]  D. Zhan, Y. Cheng, J. Liu, Expected Improvement Matrix-based Infill
% Criteria for Expensive Multiobjective Optimization, IEEE Transactions
% on Evolutionary Computation, DOI: 10.1109/TEVC.2017.2697503
%-----------------------------------------------------
% number of objectives
[num_pareto,num_obj] = size(f);
% number of input designs
num_x = size(x,1);
r = 1.1*ones(1, num_obj);
y = zeros(num_x,1);
%-----------------------------------------------------
% the kriging prediction and varince
u = zeros(num_x,num_obj);
mse = zeros(num_x,num_obj);
for ii = 1:num_obj
    [u(:, ii),mse(:, ii)] = predictor(x, kriging_obj{ii});
end
s = sqrt(max(0,mse));
%-----------------------------------------------------
r_matrix = repmat(r,num_pareto,1);
for ii = 1 : num_x
    u_matrix = repmat(u(ii,:),num_pareto,1);
    s_matrix = repmat(s(ii,:),num_pareto,1);    
    EIM = (f - u_matrix).*Gaussian_CDF((f - u_matrix)./s_matrix) + s_matrix.*Gaussian_PDF((f - u_matrix)./s_matrix);
    y(ii) =  min(prod(r_matrix - f + EIM,2) - prod(r_matrix - f,2));
end
%---------------------------------------------------
% the number of constraints
num_con = length(kriging_con);
% the kriging prediction and varince
u_g = zeros(size(x,1), num_con);
mse_g = zeros(size(x,1), num_con);
for ii = 1: num_con
    [u_g(:, ii), mse_g(:, ii)] = predictor(x, kriging_con{ii});
end
s_g = sqrt(max(0,mse_g));
% the PoF value
PoF = prod(Gaussian_CDF((0-u_g)./s_g), 2);
%-----------------------------------------------------
% the objective is maximized
obj = -y.*PoF;
end
