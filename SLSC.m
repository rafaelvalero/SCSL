function [MSE_lasso_pre,MSE_lasso_total,MSE_lasso_post,...
    Yr,standard_deviation,minpts]=...
    SLSC(data,break_point,index_Y,index_co,index_tr )
%{
This function use lasso with cross-validation as in Valero 2015 and 2017.
 
* Valero, R. (2015). Synthetic control method versus standard statistic techniques a comparison for labor market reforms. 
https://www.researchgate.net/publication/283715367_Synthetic_Control_Method_versus_Standard_Statistical_Techniques_a_Comparison_for_Labor_Market_Reforms
* Valero, R. (2017). Essays on Sparse-Grids and Statistical-Learning Methods in Economics. https://rua.ua.es/dspace/bitstream/10045/71368/1/tesis_rafael_valero_fernandez.pdf 

%}
%% Define Matrices for Outcome Data
% Y0 : 31 X 38 matrix (31 years of smoking data for 38 control states)
Y0 = data(index_Y,index_co);
% Y1 : 31 X 1 matrix (31 years of smoking data for 1 treated state)
Y1 = data(index_Y,index_tr);


 
% Z0 : (break_point-1) X 38 matrix (31 years of pre-treatment smoking data for 38 control states)
Z0 = Y0(1:(break_point-1),:);
% Z1 : (break_point-1) X 1 matrix (31 years of pre-treatment smoking data for 1 treated state)
Z1 = Y1(1:(break_point-1),1);

Z1_post=Y1(break_point:end,1);
Z0_post=Y0(break_point:end,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



[MSE_lasso_pre,~,B_lasso,minpts]=lasso_simple(Z0,Z1);
[MSE_lasso_total,~,~,~]=lasso_simple(Y0,Y1);
[MSE_lasso_post,~,~,~]=lasso_simple(Z0_post,Z1_post);

%%
% Real series
XoF=[ones(length(index_Y),1) Y0(:,minpts)];
Yr=XoF*B_lasso';



degrees_of_freedom=(size(Z0,1)-(1+size(XoF,2)));
standard_deviation=(MSE_lasso_pre/degrees_of_freedom)^.5;



