function [se_pre,se_ost, w, Yr,standard_deviation] = ...
    SCM(data,break_point, index_predict,index_Y,index_co,index_tr )
%{
This function implements SCM.
    
Rafael Valero Fernandez
%}

%% Define Matrices for Predictors
% X0 : 7 X 38 matrix (7 smoking predictors for 38 control states)
X0 = data(index_predict,index_co);

% X1 : 10 X 1 matrix (10 crime predictors for 1 treated states)
X1 = data(index_predict,index_tr);

% Normalization (probably could be done more elegantly)
bigdata = [X0,X1];
divisor = std(bigdata');
scamatrix = (bigdata' * diag(( 1./(divisor) * eye(size(bigdata,1))) ))';
X0sca = scamatrix([1:size(X0,1)],[1:size(X0,2)]);
X1sca = scamatrix(1:size(X1,1),[size(scamatrix,2)]);
X0 = X0sca;
X1 = X1sca;
clear divisor X0sca X1sca scamatrix bigdata;

%% Define Matrices for Outcome Data
% Y0 : 31 X 38 matrix (31 years of smoking data for 38 control states)
Y0 = data(index_Y,index_co);
% Y1 : 31 X 1 matrix (31 years of smoking data for 1 treated state)
Y1 = data(index_Y,index_tr);

% Now pick Z matrices, i.e. the pretreatment period
% over which the loss function should be minmized
% Here we pick Z to go from (break_point-1)70 to (break_point-1)88 
 
% Z0 : (break_point-1) X 38 matrix (31 years of pre-treatment smoking data for 38 control states)
Z0 = Y0(1:(break_point-1),:);
% Z1 : (break_point-1) X 1 matrix (31 years of pre-treatment smoking data for 1 treated state)
Z1 = Y1(1:(break_point-1),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we implement Optimization

% Check and maybe adjust optimization settings if necessary
options = optimset('fmincon');
warning('off','all');
% Get Starting Values 
s = std([X1 X0]')';
s2 = s; s2(1)=[];
s1 = s(1);
v20 =((s1./s2).^2);

[v2,fminv,exitflag] = fmincon('loss_function',v20,[],[],[],[],...
   zeros(size(X1)),[],[],options,X1,X0,Z1,Z0);
display(sprintf('%15.4f',fminv));
v = [1;v2];
% V-weights
% v

% Now recover W-weights
D = diag(v);
H = X0'*D*X0;
f = - X1'*D*X0;
options = optimset('quadprog');
[w,fval,e]=quadprog(H,f,[],[],ones(1,length(f)),1,zeros(length(f),1),ones(length(f),1),[],options);
w = abs(w); 

% W-weights
% w
%%
se_pre = sum((Z1 - Z0*w).^2);
se_ost = sum((Y1([break_point:end],1)-Y0(break_point:end,:)*w).^2);
%%
% Real series
Yr=Y0*w;
% end
degrees_of_freedom=(size(Z0,1)-sum(w>=0.001));
standard_deviation=(se_pre/degrees_of_freedom)^.5;


