function [MSE_ols,MSE_ols_total,MSE_ols_second,Yr,standard_deviation]=...
    ols_est_1(data,break_point,index_Y,index_co,index_tr )

%% Define Matrices for Outcome Data
% Y0 : 31 X 38 matrix (31 years of smoking data for 38 control states)
Y0 = data(index_Y,index_co);
% Y1 : 31 X 1 matrix (31 years of smoking data for 1 treated state)
Y1 = data(index_Y,index_tr);

% Now pick Z matrices, i.e. the pretreatment period
% over which the loss function should be minmized
% Here we pick Z to go from (break_point-1)70 to (break_point-1)88 
 
% Z0 : (break_point-1) X 38 matrix (31 years of pre-treatment smoking data for 38 control states)
Z0 = Y0([1:(break_point-1)],:);
% Z1 : (break_point-1) X 1 matrix (31 years of pre-treatment smoking data for 1 treated state)
Z1 = Y1([1:(break_point-1)],1);

Z1_post=Y1([break_point:end],1);
Z0_post=Y0(break_point:end,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Xo=[ones(break_point-1,1) Z0];
XoF=[ones(length(index_Y),1) Y0];
Xosecond=[ones(size(Z0_post,1),1) Z0_post];

B_ols=(Xo\Z1);
B_ols_total=(XoF\Y1);
B_ols_second=(Xosecond\Z1_post);

MSE_ols=(Z1-Xo*B_ols)'*(Z1-Xo*B_ols);
MSE_ols_total=(Y1-XoF*B_ols_total)'*(Y1-XoF*B_ols_total);
MSE_ols_second=(Z1_post-Xosecond*B_ols_second)'*(Z1_post-Xosecond*B_ols_second);



%%
% Real series
Yr=XoF*B_ols;

degrees_of_freedom=(size(Z0,1)-sum(B_ols>=0.001));
standard_deviation=(MSE_ols/degrees_of_freedom)^.5;
