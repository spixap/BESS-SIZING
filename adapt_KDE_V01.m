% DoCopula Estimates a copula pdf from the input grouped data and samples from this Nsamples random scenarios
% copulMethod ([1]: T-copula| [2]: Gaussian)
% Example: z4=test1.DoCopula(10,2);
% (test1 is the object)
close all;
clc
clearvars -except DataTot GFA_15_min
tic;

% GFA_15_min.Properties.VariableNames{'Var1'} = 'P_GFA';
% GFA_15_min.Properties.VariableUnits = {'MW'};

%%
lagsN = 6; % 6
obsN = length(GFA_15_min.P_GFA);
predHorK = 12; % 8
X = zeros(obsN,lagsN);
Y = NaN(obsN,predHorK);
for j=1:lagsN
    i=1;
    while i < j
        X(i,j) = NaN;
        i=i+1;
    end
    X(i:length(GFA_15_min.P_GFA),i) = GFA_15_min.P_GFA(1:end-(i-1));
end

for j=1:predHorK
    Y(1:length(GFA_15_min.P_GFA)-j,j) = GFA_15_min.P_GFA(j+1:end);
end

varNames{1} = ['t-',num2str(0)];
Xtab = table(X(:,1),'VariableNames',varNames);

for j= 1:predHorK
    Ytab.T{j} = table(Y(:,j),'VariableNames',{['t+',num2str(j)]});
end

% Ytab = table(Y,'VariableNames',{'t+1'});
for j= 1:lagsN-1
    varNames{end+1} = ['t-',num2str(j)];
    Xtab = addvars(Xtab,X(:,j+1),'After',['t-',num2str(j-1)]);
    Xtab.Properties.VariableNames = varNames;
end

% Build prediction models for each ahead time (t+1, t+2, t+3...)
options = statset('UseParallel',true);
rng(1945,'twister')

leaf = [1 2 3 4 5];
col = 'rbcmy';
for j= 1:predHorK
    for l=1:length(leaf)
        Mdl.M{j,l} = TreeBagger(20,Xtab,Ytab.T{1,j},'Method','regression',...
            'OOBPrediction','On','OOBPredictorImportance','On','MinLeafSize',leaf(l),'Options',options);
        plot(oobError(Mdl.M{j,l}),col(l))
        hold on;
    end
end
xlabel('Number of Grown Trees')
ylabel('Mean Squared Error') 
legend({'5' '10' '20' '50' '100'},'Location','NorthEast')
hold off

view(Mdl.M{1,1}.Trees{1},'Mode','graph')
view(Mdl.M{1,1}.Trees{1})

%% To calculate the number of trees
leafSize = 1;
figure;
hold on;
for j = 1:predHorK
    plot(oobError(Mdl.M{j,leafSize}),'DisplayName',['j=',num2str(j)])
end
xlabel('Number of Grown Trees')
ylabel('Out-of-Bag Mean Squared Error')
legend;
hold off;
%% To calculate important predictors
for j=1:predHorK
    
    imp = Mdl.M{j,leafSize}.OOBPermutedPredictorDeltaError;
    
    figure('Name',['j=',num2str(j)],'NumberTitle','off');
    bar(imp);
    title('Curvature Test');
    ylabel('Predictor importance estimates');
    xlabel('Predictors');
    h = gca;
    h.XTickLabel = Mdl.M{j,leafSize}.PredictorNames;
    h.XTickLabelRotation = 45;
    h.TickLabelInterpreter = 'none';
end
%% Rolling Horizon Prediction Animation
figure;
% myFigs.boxPlt.figWidth = 20; myFigs.boxPlt.figHeight = 10;
% myFigs.boxPlt.figBottomLeftX0 = 2; myFigs.boxPlt.figBottomLeftY0 =2;

% figure('Name','Predictions','NumberTitle','off','Units','inches',...
% 'Position',[myFigs.boxPlt.figBottomLeftX0 myFigs.boxPlt.figBottomLeftY0 myFigs.boxPlt.figWidth myFigs.boxPlt.figHeight],...
% 'PaperPositionMode','auto');

i_start = 10000;
leafSize = 1;
% for j = 1:predHorK
%     [quantiles.Q{j},quantWeights.yw{j}] = oobQuantilePredict(Mdl.M{j,leafSize},'Quantile',tau);
%     quant005Y(1,j) = quantiles.Q{j}(1);
%     quant095Y(1,j) = quantiles.Q{j}(2);
% end

for k = i_start:obsN

    window_width = 2*predHorK;
    t_slide_start = k - window_width;
    t_slide_end   = k + window_width;
    
    plot(t_slide_start:t_slide_end,GFA_15_min.P_GFA(t_slide_start:t_slide_end),':k','LineWidth',0.1); hold on;
    ylim([min(GFA_15_min.P_GFA) max(GFA_15_min.P_GFA)])
    grid on;
    scatter(k,GFA_15_min.P_GFA(k),100,'+b','LineWidth',3);


    predX = zeros(1,lagsN);
    for j= 1:lagsN
        predX(1,j) = GFA_15_min.P_GFA(k-j);
    end
    
    predY = zeros(1,predHorK);
    trueY = zeros(1,predHorK);
    for j=1:predHorK
        predY(1,j) = predict(Mdl.M{j,leafSize},predX);
        trueY(1,j) = GFA_15_min.P_GFA(k+j);
    end

    trueYwindow(1:window_width + 1,1) = NaN;
    trueYwindow(window_width + 2 : window_width + predHorK +1 ,1) = trueY;
    trueYwindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;
    
    predYwindow(1:window_width + 1,1) = NaN;
    predYwindow(window_width + 2 : window_width + predHorK + 1,1) = predY;
    predYwindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

    plot(t_slide_start:t_slide_end,trueYwindow,'-k*','LineWidth',2); hold on; 
    plot(t_slide_start:t_slide_end,predYwindow,'--r*','LineWidth',2); 
    
    % Quantile Regression Forests
tau = [0.05 0.95];
for j = 1:predHorK
    quantiles.Q{j} = quantilePredict(Mdl.M{j,leafSize},predX,'Quantile',tau);
%     [quantiles.Q{j},quantWeights.yw{j}] = oobQuantilePredict(Mdl.M{j,leafSize},'Quantile',tau);
    quant005Y(1,j) = quantiles.Q{j}(1);
    quant095Y(1,j) = quantiles.Q{j}(2);
end

    quant005Ywindow(1:window_width + 1,1) = NaN;
    quant005Ywindow(window_width + 2 : window_width + predHorK + 1,1) = quant005Y;
    quant005Ywindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

    quant095Ywindow(1:window_width + 1,1) = NaN;
    quant095Ywindow(window_width + 2 : window_width + predHorK + 1,1) = quant095Y;
    quant095Ywindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

    plot(t_slide_start:t_slide_end,quant005Ywindow,'-g','LineWidth',0.5);
    plot(t_slide_start:t_slide_end,quant095Ywindow,'-g','LineWidth',0.5);
    
    legend('data','issue','true','mean forecast','quantile005','quantile095','NumColumns',4);
    pause(0.01);
    
    hold off;
end
%% Single Forecast

figure;
% myFigs.boxPlt.figWidth = 20; myFigs.boxPlt.figHeight = 10;
% myFigs.boxPlt.figBottomLeftX0 = 2; myFigs.boxPlt.figBottomLeftY0 =2;

% figure('Name','Predictions','NumberTitle','off','Units','inches',...
% 'Position',[myFigs.boxPlt.figBottomLeftX0 myFigs.boxPlt.figBottomLeftY0 myFigs.boxPlt.figWidth myFigs.boxPlt.figHeight],...
% 'PaperPositionMode','auto');
% tic;
i_start = 1450; %9930
leafSize = 1;

window_width = 2*predHorK;
t_slide_start = i_start - window_width;
t_slide_end   = i_start + window_width;

plot(t_slide_start:t_slide_end,GFA_15_min.P_GFA(t_slide_start:t_slide_end),'-k','LineWidth',0.1); hold on;
grid on;
scatter(i_start,GFA_15_min.P_GFA(i_start),100,'+b','LineWidth',3);

predX = zeros(1,lagsN);
for j= 1:lagsN
    predX(1,j) = GFA_15_min.P_GFA(i_start-j);
end

predY = zeros(1,predHorK);
trueY = zeros(1,predHorK);
for j=1:predHorK
    predY(1,j) = predict(Mdl.M{j,leafSize},predX);
    trueY(1,j) = GFA_15_min.P_GFA(i_start+j);
end

trueYwindow(1:window_width + 1,1) = NaN;
trueYwindow(window_width + 2 : window_width + predHorK +1 ,1) = trueY;
trueYwindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

predYwindow(1:window_width + 1,1) = NaN;
predYwindow(window_width + 2 : window_width + predHorK + 1,1) = predY;
predYwindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

plot(t_slide_start:t_slide_end,trueYwindow,'-k*','LineWidth',2); hold on;
plot(t_slide_start:t_slide_end,predYwindow,'--r*','LineWidth',2);
plot(GFA_15_min.P_GFA,':k','LineWidth',1);

% Quantile Regression Forests
tau = [0.05 0.5 0.95];
for j = 1:predHorK
    quantiles.Q{j} = quantilePredict(Mdl.M{j,leafSize},predX,'Quantile',tau);
    quant005Y(1,j) = quantiles.Q{j}(1);
    quant05Y(1,j)  = quantiles.Q{j}(2);
    quant095Y(1,j) = quantiles.Q{j}(3);
end

quant005Ywindow(1:window_width + 1,1) = NaN;
quant005Ywindow(window_width + 2 : window_width + predHorK + 1,1) = quant005Y;
quant005Ywindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

quant05Ywindow(1:window_width + 1,1) = NaN;
quant05Ywindow(window_width + 2 : window_width + predHorK + 1,1) = quant05Y;
quant05Ywindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

quant095Ywindow(1:window_width + 1,1) = NaN;
quant095Ywindow(window_width + 2 : window_width + predHorK + 1,1) = quant095Y;
quant095Ywindow(window_width + predHorK +2 : length(t_slide_start:t_slide_end) ,1) = NaN;

plot(t_slide_start:t_slide_end,quant005Ywindow,'-g','LineWidth',0.5);
plot(t_slide_start:t_slide_end,quant05Ywindow,'-b','LineWidth',0.5);
plot(t_slide_start:t_slide_end,quant095Ywindow,'-g','LineWidth',0.5);


legend('data','issue','true','mean forecast','alldata','quantile005','quantile05','quantile095','NumColumns',4);
% toc;

%%
K = 10;
dataObsvN = 8760/K;
Load      = DataX(GFA_15_min);
% LoadC      = DataX(DataTot.GFC_active);
% wind       = DataX(DataTot.Wind_Speed);
% 
% WF1 = WindFarm();
% 
% WF1.WindValue = wind.iniVec;
% WF1.DoWindPower;
% 
% ResGen = DataX(WF1.WindPower);

Load.iniVecResol = 'Quarters';
quartersPerDay = 4*K;
Load.iniVec=Load.GroupSamplesBy(quartersPerDay);
t_sim_start = 20;
% ResGen.iniVec=ResGen.GroupSamplesBy(K);
% 
% scenGenSetLoad          = DataX();
% scenGenSetWind          = DataX();
% wind.iniVec=wind.GroupSamplesBy(K);
%%
dataFrame = Load.PickScenario(1);
if size(objData.iniVec,2) == 1 || size(objData.iniVec,1) == 1
    disp('You gave ungrouped data and clustering requires grouped data');
    sampledRandVarXcopul = objData.iniVec;
else
    % ---Estimate pdf of my multivariate input grouped data
    if objData.figControl == 1
        figure;plot(objData.iniVec);title('Initial Grouped data'); grid on;
        xlabel('Time');ylabel('Variable');xlim([1 size(objData.iniVec,1)]);
        ytickformat('%4.0f')
    end
    randVarX = objData.iniVec';
    % Transform the data to the copula scale (unit square) using a kernel estimator of the cumulative distribution function.
    uniformRandVarU = zeros(size(objData.iniVec,2),size(objData.iniVec,1));
    %                     if objData.figControl == 1
    %                         figure; hold on;
    for i=1:size(objData.iniVec,1)
        uniformRandVarU(:,i)=ksdensity(randVarX(:,i),randVarX(:,i),'function','cdf','Bandwidth',2);
        [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
        %                             plot(xi,f);grid on;
        %                             axpdf=gca;
        %                             set(gcf,'Name','Kernel pdf Histogram - LOAD','NumberTitle','off')
        %                             histogram(LoadA.iniVec,'Normalization','pdf');hold on;
        %                             plot(Xi,Yi,'--r','LineWidth',2);
        %                             legend(axpdf,{'$\{ \xi^{l} \}_i$','$\hat{f}_h^l$'},'FontSize',12,...
        %                                 'Fontname','Times New Roman','interpreter','latex','Location','northeast');
        %                             hold off
        
        axpdf.XLabel.Interpreter = 'latex';
        axpdf.XLabel.String ='$\xi^{l}$';
        axpdf.XLabel.Color = 'black';
        axpdf.XAxis.FontSize  = 12;
        axpdf.XAxis.FontName = 'Times New Roman';
        
        axpdf.YLabel.Interpreter = 'latex';
        axpdf.YLabel.String ='$f(\xi^{l})$';
        axpdf.XLabel.Color = 'black';
        axpdf.YAxis.FontSize  = 12;
        axpdf.YAxis.FontName = 'Times New Roman';
        %                             title({'Esimated predictive densities';'based on Kernel probability densities for Grouped data'});
        %                                                 xlim([1 size(objData.iniVec,1)]);
        %                             ylabel('Density (pdf)');xlabel(['Units of random variable X: ','[',objData.iniVecUnits,']']);
    end
    hold off;
    %                     end
    %%
    if copulMethod == 1
        %-----T-COPULA
        [Rho1,nu] = copulafit('t',uniformRandVarU,'Method','ApproximateML');
        copulTRandU = copularnd('t',Rho1,nu,Nsamples);
        % Transform the random sample back to the original scale of the data.
        for i=1:size(objData.iniVec,1)
            sampledRandVarXcopulT(:,i)=ksdensity(randVarX(:,i),copulTRandU(:,i),'function','icdf','Support','positive','Bandwidth',2);
        end
        if objData.figControl == 1
            figure;plot(sampledRandVarXcopulT');title('T Copula scenarios');xlim([1 size(objData.iniVec,1)]);
            ylabel(['Stochastic variable: ','[',objData.iniVecUnits,']']);xlabel('Time');
            
            disp('T copula Rho & T copula nu ')
            disp(num2str(Rho1))
            disp(num2str(nu))
        end
        sampledRandVarXcopul = sampledRandVarXcopulT';
        R24 = Rho1;
        
    else
        %-----GAUSSIAN COPULA-----
        Rho2 = copulafit('Gaussian',uniformRandVarU);
        copulGRandU = copularnd('Gaussian',Rho2,Nsamples);
        % Transform the random sample back to the original scale of the data.
        for i=1:size(objData.iniVec,1)
            sampledRandVarXcopulG(:,i)=ksdensity(randVarX(:,i),copulGRandU(:,i),'function','icdf','Bandwidth',2);
        end
        if objData.figControl == 1
            figure;
            axGen=gca;
            set(gcf,'Name','Gen-load','NumberTitle','off')
            plot(sampledRandVarXcopulG','-b','LineWidth',0.1);
            %                         title('Gaussian Copula scenarios');
            grid on;
            axGen.XLabel.Interpreter = 'latex';
            axGen.XLabel.String ='$t\:[h]$';
            axGen.XLabel.Color = 'black';
            axGen.XAxis.FontSize  = 12;
            axGen.XAxis.FontName = 'Times New Roman';
            axGen.XLim = [1 size(objData.iniVec,1)];
            xticks(2:2:24);
            
            axGen.YLabel.Interpreter = 'latex';
            axGen.YLabel.String ='$\xi^{l}\:[MW]$';
            axGen.XLabel.Color = 'black';
            axGen.YAxis.FontSize  = 12;
            axGen.YAxis.FontName = 'Times New Roman';
            axGen.YLim = [10 80];
            %                         ylabel(['Stochastic variable: ','[',objData.iniVecUnits,']']);xlabel('Time');
            %                         xlim([1 size(objData.iniVec,1)]);
            
            disp('Gaussian copula parameter (Correlation matrix): ')
            disp(num2str(Rho2))
        end
        sampledRandVarXcopul = sampledRandVarXcopulG';
        R24 = Rho2;
        
    end
    %-----ENERGY SCORE-----
    if max(objData.iniVec,[],'all')>1
        NormFact = max(objData.iniVec,[],'all');
    else
        NormFact=1;
    end
    traj = sampledRandVarXcopul./NormFact;
    obs = objData.iniVec./NormFact;
    EnSc = DataX.EnSco(obs,traj);
    disp(['Energy Score for the scenarios generated based on the estimated multivariate pdf (copula): ', num2str(EnSc)])
end