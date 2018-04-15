
%{
This script recproduce Abadie et al 2010 but using statistiscal learning as
in Valero (2015) and Valero (2017)

Base in data and software from Abadie et al 2010. See 
https://web.stanford.edu/~jhain/synthpage.html .
    
Rafael Valero Fernandez
%}


%  Rafael Valero rafael.valero.fernandez@gmail.com
%  28/11/2014: Check with standard ols
%  17/07/2015  solving the stuff with functions
%  11/08/2015  Coming back to Tobacco
%  14/08/2015  Introducing Subset Selection
%  20/10/2015  Introducing Test for compasiron among methods
%  22/08/2016  Simplify to distribute
%  15/04/2018  Some improvements and corrections

%% Get Data
load MLAB_data.txt;
data = MLAB_data;

%% Built Indices (see data description in readme file)

% California is state no 3, stored in the last column no 39
index_tr  = [39];
% 38 Control states are 1,2 & 4,5,...,38, stored in columns 1 to 38
index_co  = [1:38];

% Predcitors are stored in rows 2 to 8
index_predict = [2:8];
% Outcome Data is stored in rows 9 to 39; for 1970, 1971,...,2000
index_Y = [9:39];
index_Y_original=index_Y;


%%
break_point=20;
periods=39;
Y0 = data(index_Y,index_co);
% Y1 : 31 X 1 matrix (31 years of smoking data for 1 treated state)
Y1 = data(index_Y,index_tr);

%%

[se_pre,se_ost, w1,Yr,sd_scm ] = SCM(data,break_point,...
       index_predict,index_Y,index_co,index_tr );

[MSE_ols,MSE_ols_total,MSE_ols_second,Yr_ols,sd_ols]=...
  OLS_EST(data,break_point,index_Y,index_co,index_tr );

[MSE_lasso_pre,MSE_lasso_total,MSE_lasso_post,...
        Yr_lasso,sd_lasso,minpts]=...
        SLSC(data,break_point,index_Y,index_co,index_tr );   

save results_Tobacco
%%

clc
load results_Tobacco

years=[1970:2000];
% years=index_Y

figure(51)

plot(years,Y1,...
    years,Yr_lasso,... 
     years,Yr_pseudo,...
     years,Yr_ols);
 
 
 p(1).LineWidth = 4;
p(1).Marker = '-';
p(1).Color = 'b';
p(2).LineWidth = 2;
p(2).Marker = '.-';
p(2).Color = 'r';
p(3).LineWidth = 2;
p(3).Marker = '.-';
p(3).Color = 'r';
p(4).LineWidth = 2;
p(4).Marker = '.-';
p(4).Color = [0 .5 0];
p(5).LineWidth = 2;
p(5).Marker = '.-';
p(5).Color = 'r';
hold on
plot([years(break_point-1) years(break_point-1)], [min(Y1)*.6 max(Y1)*1.4],'r-')
axis([years(1) years(end)  min(Y1)*.95 max(Y1)*1.05]);
hold off
ylabel('% Tobacco Consumption');
xlabel('Yearly');
%legend('Real ','SCM ','LASSO ','OLS '...
%    ,'Location','Best',10);



legend('Real ','LASSO ','SCM ','OLS ');
