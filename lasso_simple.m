function [MSE_lasso,Number_terms_lasso,B_lasso,minpts]=lasso_simple(X,Y)

%{
This function use lasso with cross-validation as in Valero 2015 and 2017.
 
* Valero, R. (2015). Synthetic control method versus standard statistic techniques a comparison for labor market reforms. 
https://www.researchgate.net/publication/283715367_Synthetic_Control_Method_versus_Standard_Statistical_Techniques_a_Comparison_for_Labor_Market_Reforms
* Valero, R. (2017). Essays on Sparse-Grids and Statistical-Learning Methods in Economics. https://rua.ua.es/dspace/bitstream/10045/71368/1/tesis_rafael_valero_fernandez.pdf 


Rafael Valero Fernandez
%}


[a,b]=size(X);
aux5=min(a,b);
if aux5<12
    aux4=aux5-1;
else
    aux4=10;
end

[B FitInfo] =lasso(X,Y,'CV',aux4);

minpts = find(B(:,FitInfo.IndexMinMSE));


B_lasso=[FitInfo.Intercept(FitInfo.IndexMinMSE) B(minpts,FitInfo.IndexMinMSE)'];
Xo=[ones(a,1) X(:,minpts)];


MSE_lasso=(Y-Xo*B_lasso')'*(Y-Xo*B_lasso');
Number_terms_lasso=size(minpts,1);
