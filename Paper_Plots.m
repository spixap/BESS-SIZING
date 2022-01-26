%% PLOT GENERATED SCENARIOS
% Load: Ref50Scens.mat

% GROUP THE SELECTED SCENARIOS PROFILES
pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(24);
resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(24);
% PLOT SELECTED PROFILES
figure;
for iScen = 1:size(resG.iniVec,2)
    resG.PickScenario(iScen);
    hold on;
end
title('Clustered picked scenarios for RES generation');
hold off;
figure;
for iScen = 1:size(pltLoad.iniVec,2)
    pltLoad.PickScenario(iScen);
    hold on;
end
title('Clustered picked scenarios for LOAD generation');
hold off;
%% PLOT HISTORICAL DATASETS
% Run Equinor.m --> need DataTot.mat
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m'); % to execute the file
% Run 1st section of main.m
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');


% Data - RES
figure;
ax1=gca;
set(gcf,'Name','Data-res','NumberTitle','off')
for iScen = 1:size(wind.iniVec,2)
    plot(wind.iniVec(:,iScen),'-k','LineWidth',0.1);
    hold on;
end
grid on;
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$t\:[h]$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [1,24];
xticks(4:4:24);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$\xi^{w}\:[\frac{m}{s}]$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';
hold off;

% Data - load
figure;
peakLoad = max(LoadA.UnGroupSamples);
ax1=gca;
set(gcf,'Name','Data-load','NumberTitle','off')
for iScen = 1:size(LoadA.iniVec,2)
    plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'-k','LineWidth',0.1);
    hold on;
end
grid on;
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$t\:[h]$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [1,24];
xticks(4:4:24);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$\xi^{\ell}\:[pu]$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';
ax1.YTick = (0:0.25:1);
%% PLOT MAP FIGURES
% Load: Ref50Scens.mat
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat');

% GROUP THE SELECTED SCENARIOS PROFILES
pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(24);
resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(24);

% PLOT MAP
mapFigures.a = [1:numel(MapData.x)]'; 
mapFigures.b = num2str(mapFigures.a); 
mapFigures.c = cellstr(mapFigures.b);
mapFigures.dx = 0.003; 
mapFigures.dy = 0.003; % displacement so the text does not overlay the data points

figure;
ax1=gca;
set(gcf,'Name','Obtained Map Version 1','NumberTitle','off')
mapFigures.clr = zeros(size(pltLoad.iniVec,2),3);
for i=1:size(resG.iniVec,2)
    mapFigures.s1 = {'Region'};
    mapFigures.s2 = {num2str(i)};
    mapFigures.lgd(i) = strcat(mapFigures.s1,mapFigures.s2);
    mapFigures.clr = jet(size(resG.iniVec,2));
end

gscatter(MapData.gridPoints(:,1),MapData.gridPoints(:,2),MapData.gridPointsCluster,mapFigures.clr,'..');
hold on;
plot(MapData.points(:,1),MapData.points(:,2),'k*','MarkerSize',5);
plot(MapData.centroids(:,1),MapData.centroids(:,2),'d','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10)

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$t_i(\tilde{\xi^{\ell}})$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [0,1];

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$t_i(\tilde{\xi^{w}})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';

legend(mapFigures.lgd);
hold off;
                
figure;
set(gcf,'Name','Obtained Map Version 2','NumberTitle','off')
for i=1:size(resG.iniVec,2)
    plot(MapData.points(MapData.clusterID==i,1),MapData.points(MapData.clusterID==i,2),'.','Color',mapFigures.clr(i,:),'MarkerSize',12)
    hold on
end

plot(MapData.centroids(:,1),MapData.centroids(:,2),'kx','MarkerSize',15,'LineWidth',3)
text(MapData.x + mapFigures.dx, MapData.y + mapFigures.dy, mapFigures.c);
xlabel('Load Score');ylabel('Wind Power Score');
legend(mapFigures.lgd);
hold off

figure;
ax1=gca;
set(gcf,'Name','Obtained Map Version 3','NumberTitle','off')
for i=1:size(resG.iniVec,2)
    plot(MapData.points(MapData.clusterID==i,1),MapData.points(MapData.clusterID==i,2),'.','Color',mapFigures.clr(i,:),'MarkerSize',12)
    hold on
end

plot(MapData.centroids(:,1),MapData.centroids(:,2),'kx','MarkerSize',15,'LineWidth',3)

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$t_i(\tilde{\xi^{\ell}})$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [0,1];
xticks(0:0.25:1);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$t_i(\tilde{\xi^{w}})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';
yticks(0:0.25:1);

hold off

figure;
ax1=gca;
set(gcf,'Name','Elbow Plot','NumberTitle','off')

scatter(MapData.elbowPlotX,MapData.elbowPlotY,10,'MarkerEdgeColor','k','MarkerFaceColor','k');
grid on;
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$\vert \Omega_s \vert$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [1,30];

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$J_I$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';
%% DENSITIES FIGURES - to check BW
%{
% RES
wind.iniVec = wind.UnGroupSamples;
% Plot cdf vs ecdf
[Yci,Xci,BWc] = ksdensity(wind.iniVec,'Function','cdf');
BWc
BWdef = 2;
figure;
set(gcf,'Name','Kernel cdf estimations - RES','NumberTitle','off')
ecdf(wind.iniVec);hold on;plot(Xci,Yci);hold on;
[Yci,Xci,BWc] = ksdensity(wind.iniVec,'Function','cdf','Bandwidth',BWdef);
plot(Xci,Yci,'--r','LineWidth',2)
% legend('empirical cdf','kernel-bw:default','kernel-bw:1',...
% 	'Location','northwest')
legend('empirical cdf','kernel-bw:default',['kernel-bw: ' num2str(BWc)],...
	'Location','northwest');
hold off

% Plot pdf vs histogram
[Yi,Xi,BW] = ksdensity(wind.iniVec,'Function','pdf','Bandwidth',BWdef);
figure;
set(gcf,'Name','Kernel pdf - Histogram','NumberTitle','off')
histogram(wind.iniVec,'Normalization','pdf');hold on;plot(Xi,Yi);
legend('Data Histogram',['kernel based pdf -bw: ' num2str(BWc)],...
	'Location','northeast');
hold off;

% LOAD
LoadA.iniVec = LoadA.UnGroupSamples;
% Plot cdf vs ecdf
[Yci,Xci,BWc] = ksdensity(LoadA.iniVec,'Function','cdf');
BWc
BWdef = 2;
figure;
set(gcf,'Name','Kernel cdf estimations - LOAD','NumberTitle','off')
ecdf(LoadA.iniVec);hold on;plot(Xci,Yci);hold on;
[Yci,Xci,BWc] = ksdensity(LoadA.iniVec,'Function','cdf','Bandwidth',BWdef);
plot(Xci,Yci,'--r','LineWidth',2)
% legend('empirical cdf','kernel-bw:default','kernel-bw:1',...
% 	'Location','northwest')
legend('empirical cdf','kernel-bw:default',['kernel-bw: ' num2str(BWc)],...
	'Location','northwest');
hold off

% Plot pdf vs histogram
[Yi,Xi,BW] = ksdensity(LoadA.iniVec,'Function','pdf','Bandwidth',BWdef);
figure;
set(gcf,'Name','Kernel pdf - Histogram','NumberTitle','off')
histogram(LoadA.iniVec,'Normalization','pdf');hold on;plot(Xi,Yi);
legend('Data Histogram',['kernel based pdf -bw: ' num2str(BWc)],...
	'Location','northeast');
hold off;
%}
%% PLOT DENSITIES FIGURES
% Run Equinor.m --> need DataTot.mat
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m'); % to execute the file
% Run 1st section of main.m
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');


% # 1: RES cdf
wind.iniVec = wind.UnGroupSamples;
[Yci,Xci,BWc] = ksdensity(wind.iniVec,'Function','cdf');
figure;
ax1=gca;
set(gcf,'Name','CDF-RES','NumberTitle','off')
ecdf(wind.iniVec);hold on;plot(Xci,Yci,'--r','LineWidth',2);
legend(ax1,{'$F^w_e$','$\hat{F}_h^w$'},'FontSize',20,...
    'Fontname','Times New Roman','interpreter','latex','Location','northwest');
grid on;
hold off;

ax1.XLim = [0,35];

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$\xi^{w}$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$F^{w}(\xi^{w})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';
ax1.YTick = (0:0.25:1);

% # 2: LOAD cdf
LoadA.iniVec = LoadA.UnGroupSamples;

figure;
set(gcf,'Name','CDF-LOAD','NumberTitle','off')
ax1=gca;
BWdef = 2;
ecdf(LoadA.iniVec/max(LoadA.iniVec));hold on;
[Yci,Xci,BWc] = ksdensity(LoadA.iniVec,'Function','cdf','Bandwidth',BWdef);
plot(Xci/max(LoadA.iniVec),Yci,'--r','LineWidth',2)
legend(ax1,{'$F^{\ell}_e$','$\hat{F}_h^{\ell}$'},'FontSize',20,...
    'Fontname','Times New Roman','interpreter','latex','Location','northwest');
grid on;
hold off

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$\xi^{\ell}$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
% ax1.XLim = [0,90];
ax1.XLim = [0,1];
ax1.XTick = (0:0.25:1);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$F^{\ell}(\xi^{\ell})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';
ax1.YTick = (0:0.25:1);


% # 3: RES pdf
[Yi,Xi,BW] = ksdensity(wind.iniVec,'Function','pdf');
figure;
ax1=gca;
set(gcf,'Name','PDF-RES','NumberTitle','off')
histogram(wind.iniVec,'Normalization','pdf');hold on;
plot(Xi,Yi,'--r','LineWidth',2);
legend(ax1,{'$\{ \xi^{w} \}_i$','$\hat{f}_h^w$'},'FontSize',20,...
    'Fontname','Times New Roman','interpreter','latex','Location','northeast');
grid on;
hold off;

ax1.XLim = [0,35];

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$\xi^{w}$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$f(\xi^{w})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';

% # 4: LOAD pdf
[Yi,Xi,BW] = ksdensity(LoadA.iniVec,'Function','pdf','Bandwidth',BWdef);
figure;
ax1=gca;
set(gcf,'Name','PDF - LOAD','NumberTitle','off')
histL=histogram(LoadA.iniVec,'Normalization','pdf');hold on;
% histL.BinLimits = [0,1];
plot(Xi,Yi,'--r','LineWidth',2);
legend(ax1,{'$\{ \xi^{\ell} \}_i$','$\hat{f}_h^{\ell}$'},'FontSize',20,...
    'Fontname','Times New Roman','interpreter','latex','Location','northeast');
grid on;
hold off

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$\xi^{\ell}$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [0,90];
% ax1.XLim = [0,1];

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$f(\xi^{\ell})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';


%% PLOT COST CDF COMPARISON -  beta=1 | alpha = 0.9 or 0.96
% Load: 
% Risk_b1_a090.mat --> riskPlot01, allScensResults01 
% Risk_b1_a096.mat --> riskPlot02, allScensResults02
load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\RiskAnalysis\Risk_b1_a09.mat','riskPlot','allScensResults','LscensProbVec');
riskPlot01 = riskPlot;
allScensResults01 = allScensResults;
load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\RiskAnalysis\Risk_b1_a096.mat','riskPlot','allScensResults');
riskPlot02 = riskPlot;
allScensResults02 = allScensResults;

figure;
% figBottomLeftX0 = 2;
% figBottomLeftY0 = 2;
% figWidth = 7.16;
% figHeight = 6.5;
% set(gcf,'Name','Cost CDF','NumberTitle','off','Units','inches',...
% 'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
% 'PaperPositionMode','auto');

set(gcf,'Name','Cost CDF','NumberTitle','off');

hold on;
grid on;
done = 0;
for i=1:length(riskPlot01.sortedCosts)
    
    riskPlot01.tempSum(i) = sum(LscensProbVec(riskPlot01.I(1:i)));
    
    if sum(LscensProbVec(riskPlot01.I(1:i))) >= 0.90 && done == 0
        riskPlot01.scat(i) = stem(riskPlot01.sortedCosts(i),riskPlot01.tempSum(i),'LineStyle','-.','Color','g',...
            'Marker','s','MarkerFaceColor','g','MarkerEdgeColor','k','Marker','none');
        done = 1;
    end
end

riskPlot.plot(1)=stairs(riskPlot01.sortedCosts,riskPlot01.tempSum,'g','LineWidth',1.5);
riskPlots.rplot(2)=scatter(allScensResults01.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','g');
riskPlots.rplot(3)=scatter(allScensResults01.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.8);
riskPlots.rplot(4)=scatter(allScensResults01.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','g');

done = 0;
for i=1:length(riskPlot02.sortedCosts)
    
    riskPlot02.tempSum(i) = sum(LscensProbVec(1:i));
    
    if sum(LscensProbVec(riskPlot02.I(1:i))) >= 0.96 && done == 0 
        riskPlot02.scat(i) = stem(riskPlot02.sortedCosts(i),riskPlot02.tempSum(i),'LineStyle','-.','Color','r',...
            'Marker','s','MarkerFaceColor','r','MarkerEdgeColor','k','Marker','none');
        done = 1;
    end
end

riskPlot.plot(5)=stairs(riskPlot02.sortedCosts,riskPlot02.tempSum,'r','LineWidth',1.5);
riskPlots.rplot(6)=scatter(allScensResults02.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','r','DisplayName','Expected Solution');
riskPlots.rplot(7)=scatter(allScensResults02.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1.8,'DisplayName','VaR');
riskPlots.rplot(8)=scatter(allScensResults02.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','r','DisplayName','CVaR');

grid on
ax = gca;
ax.XLabel.Interpreter = 'latex';
ax.XLabel.String ='$\it F \rm (\bf x \, ; \, \rm \Omega_s^*)$';
ax.XLabel.Color = 'black';
ax.XLabel.FontSize  = 20;
ax.XLabel.FontName = 'Times New Roman';
ax.XColor = 'k';
ax.XAxis.TickLabelFormat = '\x20AC%,.0f';
ax.XAxis.Exponent = 0;

ax.YLabel.Interpreter = 'latex';
ax.YLabel.String ='$cdf(\it F \rm (\bf x \, ; \, \rm \Omega_s^*)$';
ax.YLabel.Color = 'black';
ax.YLabel.FontSize  = 20;
ax.YLabel.FontName = 'Times New Roman';
ax.YColor = 'k';

legend([riskPlots.rplot(2) riskPlots.rplot(3) riskPlots.rplot(4) riskPlots.rplot(6)...
    riskPlots.rplot(7) riskPlots.rplot(8)],{'$E[\it F]_{\alpha = 0.9}$','$VaR_{\alpha = 0.9}$','$CVaR_{\alpha = 0.9}$',...
'$E[\it F]_{\alpha = 0.95}$','$VaR_{\alpha = 0.95}$','$CVaR_{\alpha = 0.95}$',},'FontSize',14,...
    'Fontname','Times New Roman','interpreter','latex','Location','northwest','NumColumns',2);

hold off;
%% PLOT COST CDF COMPARISON alpha=0.8 | beta = 0 or 1
% Load: 
% Risk_a08_b0_gap017.mat --> riskPlot01, allScensResults01 
% Risk_a08_b1_gap017.mat --> riskPlot02, allScensResults02
load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\RiskAnalysis\Risk_a08_b0_gap017.mat','riskPlot','allScensResults','LscensProbVec');
riskPlot01 = riskPlot;
allScensResults01 = allScensResults;
load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\RiskAnalysis\Risk_a08_b1_gap017.mat','riskPlot','allScensResults');
riskPlot02 = riskPlot;
allScensResults02 = allScensResults;

figure;
figBottomLeftX0 = 2;
figBottomLeftY0 = 2;
figWidth = 7;
figHeight = 6;
set(gcf,'Name','Cost CDF','NumberTitle','off','Units','inches',...
'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight]);

% set(gcf,'Name','Cost CDF','NumberTitle','off');
hold on;
% grid on;
done = 0;
for i=1:length(riskPlot01.sortedCosts)
    
    riskPlot01.tempSum(i) = sum(LscensProbVec(riskPlot01.I(1:i)));
    
    if sum(LscensProbVec(riskPlot01.I(1:i))) >= 0.80 && done == 0
        riskPlot01.scat(i) = stem(riskPlot01.sortedCosts(i),riskPlot01.tempSum(i),'LineStyle','-.','Color','g',...
            'Marker','s','MarkerFaceColor','g','MarkerEdgeColor','k','Marker','none');
        done = 1;
    end
end

riskPlot.plot(1)=stairs(riskPlot01.sortedCosts,riskPlot01.tempSum,'g','LineWidth',1.5);
riskPlots.rplot(2)=scatter(allScensResults01.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','g');
riskPlots.rplot(3)=scatter(allScensResults01.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.8);
riskPlots.rplot(4)=scatter(allScensResults01.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','g');

done = 0;
for i=1:length(riskPlot02.sortedCosts)
    
    riskPlot02.tempSum(i) = sum(LscensProbVec(1:i));
    
    if sum(LscensProbVec(riskPlot02.I(1:i))) >= 0.8 && done == 0 % 0.96 for a analysisi, 0.8 for b analysis
        riskPlot02.scat(i) = stem(riskPlot02.sortedCosts(i),riskPlot02.tempSum(i),'LineStyle','-.','Color','r',...
            'Marker','s','MarkerFaceColor','r','MarkerEdgeColor','k','Marker','none');
        done = 1;
    end
end

riskPlot.plot(5)=stairs(riskPlot02.sortedCosts,riskPlot02.tempSum,'r','LineWidth',1.5);
riskPlots.rplot(6)=scatter(allScensResults02.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','r','DisplayName','Expected Solution');
riskPlots.rplot(7)=scatter(allScensResults02.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1.8,'DisplayName','VaR');
riskPlots.rplot(8)=scatter(allScensResults02.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','r','DisplayName','CVaR');


ax = gca;

ax.XGrid = 'on';
ax.YGrid = 'on';

ax.XLabel.Interpreter = 'latex';
ax.XLabel.String ='$\it F \rm (\bf x \, ; \, \rm \Omega_s^*)$';
ax.XLabel.Color = 'black';
ax.XLabel.FontName = 'Times New Roman';
ax.XAxis.FontSize  = 16;
ax.XAxis.FontName = 'Times New Roman';
ax.XColor = 'k';
ax.XAxis.TickLabelFormat = '\x20AC%,.0f';
ax.XAxis.Exponent = 0;
ax.XTickLabelRotation = 30;
ax.XLabel.FontSize  = 20;



ax.YLabel.Interpreter = 'latex';
ax.YLabel.String ='$cdf(\it F \rm (\bf x \, ; \, \rm \Omega_s^*)$';
ax.YLabel.Color = 'black';
ax.YLabel.FontName = 'Times New Roman';
ax.YColor = 'k';
ax.YAxis.FontSize  = 16;
ax.YAxis.FontName = 'Times New Roman';
ax.YLabel.FontSize  = 20;


legend([riskPlots.rplot(2) riskPlots.rplot(3) riskPlots.rplot(4) riskPlots.rplot(6)...
    riskPlots.rplot(7) riskPlots.rplot(8)],{'$E[\it F ]_{\beta = 0}$','$VaR_{\beta = 0}$','$CVaR_{\beta = 0}$',...
'$E[\it F ]_{\beta = 1}$','$VaR_{\beta = 1}$','$CVaR_{\beta = 1}$',},'FontSize',16,'Box', 'off','color','none',...
    'Fontname','Times New Roman','interpreter','latex','Location','northwest','NumColumns',2);
hold off;
%% COST CDF FIGURES (4 plots)
%{
figure;
set(gcf,'Name','Comparison of cost cdf','NumberTitle','off')
hold on;
grid on;
for i=1:length(riskPlot01.sortedCosts)
    riskPlot01.tempSum(i) = sum(LscensProbVec(riskPlot01.I(1:i)));
end

riskPlot.plot(1)=stairs(riskPlot01.sortedCosts,riskPlot01.tempSum,'g','LineWidth',1.5);

riskPlots.rplot(2)=scatter(allScensResults01.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','g');
% text(allScensResults01.totalCost,0.1,num2str(allScensResults01.totalCost),'Fontsize', 12);

riskPlots.rplot(3)=scatter(allScensResults01.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.8);
riskPlots.rplot(4)=scatter(allScensResults01.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','g');
% text(allScensResults01.CVaR,0.1,num2str(allScensResults01.CVaR),'Fontsize', 12);


for i=1:length(riskPlot02.sortedCosts)
    riskPlot02.tempSum(i) = sum(LscensProbVec(riskPlot02.I(1:i)));
end

riskPlot.plot(5)=stairs(riskPlot02.sortedCosts,riskPlot02.tempSum,'r','LineWidth',1.5);


riskPlots.rplot(6)=scatter(allScensResults02.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','r','DisplayName','Expected Solution');
% text(allScensResults02.totalCost,0.1,num2str(allScensResults02.totalCost),'Fontsize', 12);

riskPlots.rplot(7)=scatter(allScensResults02.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1.8,'DisplayName','VaR');
riskPlots.rplot(8)=scatter(allScensResults02.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','r','DisplayName','CVaR');
% text(allScensResults02.CVaR,0.1,num2str(allScensResults02.CVaR),'Fontsize', 12);

for i=1:length(riskPlot03.sortedCosts)
    riskPlot03.tempSum(i) = sum(LscensProbVec(riskPlot03.I(1:i)));
end

riskPlot.plot(9)=stairs(riskPlot03.sortedCosts,riskPlot03.tempSum,'c','LineWidth',1.5);


riskPlots.rplot(10)=scatter(allScensResults03.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','c','DisplayName','Expected Solution');
% text(allScensResults02.totalCost,0.1,num2str(allScensResults02.totalCost),'Fontsize', 12);

riskPlots.rplot(11)=scatter(allScensResults03.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','c','LineWidth',1.8,'DisplayName','VaR');
riskPlots.rplot(12)=scatter(allScensResults03.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','c','DisplayName','CVaR');
% text(allScensResults02.CVaR,0.1,num2str(allScensResults02.CVaR),'Fontsize', 12);

for i=1:length(riskPlot04.sortedCosts)
    riskPlot04.tempSum(i) = sum(LscensProbVec(riskPlot04.I(1:i)));
end

riskPlot.plot(13)=stairs(riskPlot04.sortedCosts,riskPlot04.tempSum,'m','LineWidth',1.5);


riskPlots.rplot(14)=scatter(allScensResults04.totalCost,0,150,'p','MarkerEdgeColor','k','MarkerFaceColor','m','DisplayName','Expected Solution');
% text(allScensResults02.totalCost,0.1,num2str(allScensResults02.totalCost),'Fontsize', 12);

riskPlots.rplot(15)=scatter(allScensResults04.VaR,0,40,'o','MarkerEdgeColor','k','MarkerFaceColor','m','LineWidth',1.8,'DisplayName','VaR');
riskPlots.rplot(16)=scatter(allScensResults04.CVaR,0,100,'s','MarkerEdgeColor','k','MarkerFaceColor','m','DisplayName','CVaR');
% text(allScensResults02.CVaR,0.1,num2str(allScensResults02.CVaR),'Fontsize', 12);

grid on
ax = gca;

ax.XLabel.Interpreter = 'latex';
ax.XLabel.String ='Cost of each scenario $J_i$';
ax.XLabel.Color = 'black';
ax.XLabel.FontSize  = 12;
ax.XLabel.FontName = 'Times New Roman';
ax.XColor = 'k';

% xlabel('Cost of each scenario');ylabel('Cumulative distribtion');
xtickformat('eur');
ax.XAxis.Exponent = 0;

ax.YLabel.Interpreter = 'latex';
ax.YLabel.String ='Cumulative distribtion';
ax.YLabel.Color = 'black';
ax.YLabel.FontSize  = 12;
ax.YLabel.FontName = 'Times New Roman';
ax.YColor = 'k';

legend(ax,{'$CDF_{\alpha = 0.8}$','$E[J]_{\alpha = 0.8}$','$VaR_{\alpha = 0.8}$','$CVaR_{\alpha = 0.8}$',...
'$CDF_{\alpha = 0.85}$','$E[J]_{\alpha = 0.85}$','$VaR_{\alpha = 0.85}$','$CVaR_{\alpha = 0.85}$',...
'$CDF_{\alpha = 0.9}$','$E[J]_{\alpha = 0.9}$','$VaR_{\alpha = 0.9}$','$CVaR_{\alpha = 0.9}$',...
'$CDF_{\alpha = 0.95}$','$E[J]_{\alpha = 0.95}$','$VaR_{\alpha = 0.95}$','$CVaR_{\alpha = 0.95}$'},...
'FontSize',10,'Fontname','Times New Roman','interpreter','latex','Location','southeast');

hold off;
%}
%% PLOT SENSITIVITY RESULT
% Load: SensitivityResult.mat
load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\SensitivityAnalysis\SensitivityResult.mat');

figure;
% figBottomLeftX0 = 2;
% figBottomLeftY0 = 2;
% figWidth = 4.8;
% figHeight = 8.2;
% set(gcf,'Name','Sensitivity Analysis','NumberTitle','off', 'Units','inches',...
% 'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
% 'PaperPositionMode','auto');

set(gcf,'Name','Sensitivity Analysis','NumberTitle','off',...
'PaperPositionMode','auto');

t = tiledlayout(3,1);

ax1 = nexttile;
plot(ax1,Ce,Cost,'-bs','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','b','LineWidth',1.5);
hold on; yyaxis right; 
plot(Ce,Capacity,'-rs','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1.5)
ax2 = nexttile;
plot(ax2,Ce,CO2,'-ks','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','k','LineWidth',1.5);
ax3 = nexttile;
plot(ax3,Ce,dump,'-ks','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','k','LineWidth',1.5);

legend(ax1,{'$\mathrm{E} [\it F \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega)]$','$\hat{E}_{B}$'},'FontSize',12,...
    'Fontname','Times New Roman','interpreter','latex','Location','south');

linkaxes([ax1,ax2,ax3],'x');

set(ax1,'xticklabel',{[]})
set(ax2,'xticklabel',{[]})

ax3.XLim = [120,450];
ax3.XLabel.Interpreter = 'latex';
ax3.XLabel.String ='$C_{B,E}$';
ax3.XLabel.Color = 'black';
ax3.FontSize  = 12;
ax3.FontName = 'Times New Roman';
ax3.XLim = [120,450];

ax1.YAxis(1).Label.Interpreter = 'latex';
ax1.YAxis(1).Label.String ='$ \mathrm{E} [\it F \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega)]$';
ax1.YAxis(1).Color = 'black';
ax1.YAxis(1).FontSize  = 12;
ax1.YAxis(1).FontName = 'Times New Roman';
ax1.YAxis(1).Exponent = 0;
ax1.YAxis(1).TickLabelFormat = '\x20AC%,.0f';

ax1.YAxis(2).Label.Interpreter = 'latex';
ax1.YAxis(2).Label.String ='$\hat{E}_{B}\;[kWh]$';
ax1.YAxis(2).Color = 'black';
ax1.YAxis(2).FontSize  = 12;
ax1.YAxis(2).FontName = 'Times New Roman';
ax1.YAxis(2).TickLabelFormat = '%.2f';


ax2.YAxis.Label.Interpreter = 'latex';
ax2.YAxis.Label.String ='$ \mathrm{E} [\it V_{CO_2} \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega)] \rm \it [tn]$';
ax2.YAxis.Color = 'black';
ax2.YAxis.FontSize  = 12;
ax2.YAxis.FontName = 'Times New Roman';
ax2.YAxis.Exponent = 0;
ax2.YAxis.TickLabelFormat = '%.0f';
% ax2.YAxis.TickLabelFormat = '%g tn';


ax3.YAxis.Label.Interpreter = 'latex';
ax3.YAxis.Label.String ='$ \mathrm{E} [\it E_{D} \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega)]  \rm \it [MWh]$';
ax3.YAxis.Color = 'black';
ax3.YAxis.FontSize  = 12;
ax3.YAxis.FontName = 'Times New Roman';
ax3.YAxis.Exponent = 0;
ax3.YAxis.TickLabelFormat = '%.1f';
% ax3.YAxis.TickLabelFormat = '%g MWh';

ax1.XGrid = 'on';
ax1.YGrid = 'on';
ax2.XGrid = 'on';
ax2.YGrid = 'on';
ax3.XGrid = 'on';
ax3.YGrid = 'on';

t.TileSpacing = 'compact';

%% Seperate plots
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\SensitivityAnalysis\SensitivityResult.mat');

figure;
figBottomLeftX0 = 2;
figBottomLeftY0 = 2;
figWidth = 7;
figHeight = 5;

set(gcf,'Name','sensAnalCost','NumberTitle','off', 'Units','inches',...
'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
'PaperPositionMode','auto');

% figure;
% set(gcf,'Name','sensAnalCost','NumberTitle','off',...
% 'PaperPositionMode','auto');

ax1 = gca;
plot(Ce,Cost,'-bs','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','b','LineWidth',1.5);
hold on; yyaxis right; 
plot(Ce,Capacity,'-rs','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1.5)

ax1.XLim = [120,450];
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$C_{B,E}$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 16;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [120,450];
ax1.XLabel.FontSize = 20;


legend(ax1,{'$\mathrm{E} [\it F \rm (\bf x \, ; \, \Omega_s^*)]$','$E_{B}$'},'FontSize',16,'Box', 'off','color','none',...
    'Fontname','Times New Roman','interpreter','latex','Location','south');

ax1.YAxis(1).Label.Interpreter = 'latex';
ax1.YAxis(1).Label.String ='$ \mathrm{E} [\it F \rm (\bf x \rm \, ; \, \Omega_s^*)]$';
ax1.YAxis(1).Color = 'black';
ax1.YAxis(1).FontSize  = 16;
ax1.YAxis(1).FontName = 'Times New Roman';
ax1.YAxis(1).Exponent = 0;
ax1.YAxis(1).TickLabelFormat = '\x20AC%,.0f';
ax1.YAxis(1).Label.FontSize  = 20;


ax1.YAxis(2).Label.Interpreter = 'latex';
ax1.YAxis(2).Label.String ='$E_{B}\;[MWh]$';
ax1.YAxis(2).Color = 'black';
ax1.YAxis(2).FontSize  = 16;
ax1.YAxis(2).FontName = 'Times New Roman';
ax1.YAxis(2).TickLabelFormat = '%.2f';
ax1.YAxis(2).Label.FontSize  = 20;


% ax1.XLim = [120,450];
% ax1.XLabel.Interpreter = 'latex';
% ax1.XLabel.String ='$C_{B,E}$';
% ax1.XLabel.Color = 'black';
% ax1.FontSize  = 14;
% ax1.FontName = 'Times New Roman';
% ax1.XLim = [120,450];
% ax1.XLabel.FontSize = 16;

% ax1.XGrid = 'on';
% ax1.YGrid = 'on';



% figure;
% set(gcf,'Name','sensAnalCO2','NumberTitle','off', 'Units','inches',...
% 'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
% 'PaperPositionMode','auto');
% 
% % set(gcf,'Name','sensAnalCO2','NumberTitle','off',...
% % 'PaperPositionMode','auto');
% 
% 
% ax1 = gca;
% plot(Ce,CO2,'-ks','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','k','LineWidth',1.5);
% 
% ax1.YAxis.Label.Interpreter = 'latex';
% ax1.YAxis.Label.String ='$ \mathrm{E} [\it V_{CO_2} \rm (\bf x \rm \, ; \, \Omega_s^*)] \rm \it [tn]$';
% ax1.YAxis.Color = 'black';
% ax1.YAxis.FontSize  = 20;
% ax1.YAxis.FontName = 'Times New Roman';
% ax1.YAxis.Exponent = 0;
% ax1.YAxis.TickLabelFormat = '%.0f';
% % ax2.YAxis.TickLabelFormat = '%g tn';
% 
% ax1.XLim = [120,450];
% ax1.XLabel.Interpreter = 'latex';
% ax1.XLabel.String ='$C_{B,E}$';
% ax1.XLabel.Color = 'black';
% ax1.FontSize  = 20;
% ax1.FontName = 'Times New Roman';
% ax1.XLim = [120,450];
% 
% % ax1.XGrid = 'on';
% % ax1.YGrid = 'on';
% 
% figure;
% 
% set(gcf,'Name','sensAnalD','NumberTitle','off', 'Units','inches',...
% 'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
% 'PaperPositionMode','auto');
% 
% % set(gcf,'Name','sensAnalD','NumberTitle','off',...
% % 'PaperPositionMode','auto');
% ax1 = gca;
% plot(Ce,dump,'-ks','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','k','LineWidth',1.5);
% 
% ax1.YAxis.Label.Interpreter = 'latex';
% ax1.YAxis.Label.String ='$ \mathrm{E} [\it E_{D} \rm (\bf x \rm \, ; \, \Omega_s^*)]  \rm \it [MWh]$';
% ax1.YAxis.Color = 'black';
% ax1.YAxis.FontSize  = 20;
% ax1.YAxis.FontName = 'Times New Roman';
% ax1.YAxis.Exponent = 0;
% ax1.YAxis.TickLabelFormat = '%.1f';
% % ax3.YAxis.TickLabelFormat = '%g MWh';
% 
% ax1.XLim = [120,450];
% ax1.XLabel.Interpreter = 'latex';
% ax1.XLabel.String ='$C_{B,E}$';
% ax1.XLabel.Color = 'black';
% ax1.FontSize  = 20;
% ax1.FontName = 'Times New Roman';
% ax1.XLim = [120,450];
% 
% % ax1.XGrid = 'on';
% % ax1.YGrid = 'on';

figure;

set(gcf,'Name','sensAnalCO2D','NumberTitle','off', 'Units','inches',...
'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
'PaperPositionMode','auto');

% set(gcf,'Name','sensAnalCO2D','NumberTitle','off',...
% 'PaperPositionMode','auto');

ax1 = gca;
plot(Ce,CO2,'-bs','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','b','LineWidth',1.5);
hold on; yyaxis right; 
plot(Ce,dump,'-rs','MarkerSize',8,'MarkerEdgeColor','k','MarkerFaceColor','r','LineWidth',1.5)

ax1.XLim = [120,450];
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$C_{B,E}$';
ax1.XLabel.Color = 'black';
ax1.FontSize  = 16;
ax1.FontName = 'Times New Roman';
ax1.XLim = [120,450];
ax1.XLabel.FontSize = 20;


legend(ax1,{'$\mathrm{E} [\it V_{CO_2} \rm (\bf x \rm \, ; \, \Omega_s^*)]$','$\mathrm{E} [\it E_{D} \rm (\bf x \rm \, ; \, \Omega_s^*)]$'},'FontSize',16,'Box', 'off','color','none',...
    'Fontname','Times New Roman','interpreter','latex','Location','northwest');

ax1.YAxis(1).Label.Interpreter = 'latex';
ax1.YAxis(1).Label.String ='$ \mathrm{E} [\it V_{CO_2} \rm (\bf x \rm \, ; \, \Omega_s^*)] \rm \it [tn]$';
ax1.YAxis(1).Color = 'black';
ax1.YAxis(1).FontSize  = 16;
ax1.YAxis(1).FontName = 'Times New Roman';
ax1.YAxis(1).Exponent = 0;
ax1.YAxis(1).TickLabelFormat = '%.1f';
ax1.YAxis(1).TickValues  = (238:0.5:241);
ax1.YAxis(1).Label.FontSize  = 20;


ax1.YAxis(2).Label.Interpreter = 'latex';
ax1.YAxis(2).Label.String ='$\mathrm{E} [\it E_{D} \rm (\bf x \rm \, ; \, \Omega_s^*)]  \rm \it [MWh]$';
ax1.YAxis(2).Color = 'black';
ax1.YAxis(2).FontSize  = 16;
ax1.YAxis(2).FontName = 'Times New Roman';
ax1.YAxis(2).TickLabelFormat = '%.1f';
ax1.YAxis(2).Label.FontSize  = 20;


% ax1.XLim = [120,450];
% ax1.XLabel.Interpreter = 'latex';
% ax1.XLabel.String ='$C_{B,E}$';
% ax1.XLabel.Color = 'black';
% ax1.FontSize  = 16;
% ax1.FontName = 'Times New Roman';
% ax1.XLabel.FontSize = 16;


% ax1.XGrid = 'on';
% ax1.YGrid = 'on';
%% 3D plots to identify the scenarios with high cost
% Load:: Ref50Scens.mat + ReferenceCase.mat
%{
pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(24);
resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(24);
wi= 1;

figure;
figBottomLeftX0 = 2;
figBottomLeftY0 = 2;
figWidth = 4.8; % 4.8
figHeight = 8.2;
set(gcf,'Name','Identification of worst cases','NumberTitle','off', 'Units','inches',...
'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
'PaperPositionMode','auto');

t = tiledlayout(2,1);

ax1 = nexttile;
hold on;
a = linspace(0.001,2,size(pltLoad.iniVec,2));
for i = wi:size(pltLoad.iniVec,2)
    % Unranked Scenarios
%     plot3((1:24)',i*ones(24),pltLoad.iniVec(:,i),'-r','LineWidth',1.8);hold on;
%     plot3((1:24)',i*ones(24),resG.iniVec(:,i),'-g','LineWidth',1.8);
    
% Ranked Scenarios
    plot3(ax1,(1:24)',i*ones(24),pltLoad.iniVec(:,riskPlot.I(i)),'-r','LineWidth',a(i));
%     bload(:,i) = pltLoad.iniVec(:,riskPlot.I(i));
%     bwind(:,i) = resG.iniVec(:,riskPlot.I(i));
    
    
%     plot3(ax1,(1:24)',i*ones(24),pltLoad.iniVec(:,riskPlot.I(i)),'LineWidth',a(i));

    hold on;
%     plot3((1:24)',i*ones(24),resG.iniVec(:,riskPlot.I(i)),'-g','LineWidth',1.8);
    
% Net Loads
%     plot3((1:24)',i*ones(24),pltLoad.iniVec(:,i)-resG.iniVec(:,i),'-b','LineWidth',1.8);
%     plot3((1:24)',i*ones(24),pltLoad.iniVec(:,riskPlot.I(i))-resG.iniVec(:,riskPlot.I(i)),'-b','LineWidth',1.8);
end

view(3)
title(ax1,'Ranked Load Profiles')

ax2 = nexttile;
hold on;
for i = wi:size(resG.iniVec,2)
    % Unranked Scenarios
%     plot3((1:24)',i*ones(24),pltLoad.iniVec(:,i),'-r','LineWidth',1.8);hold on;
%     plot3((1:24)',i*ones(24),resG.iniVec(:,i),'-g','LineWidth',1.8);
    
% Ranked Scenarios
%     plot3((1:24)',i*ones(24),pltLoad.iniVec(:,riskPlot.I(i)),'-r','LineWidth',1.8);hold on;
    plot3(ax2,(1:24)',i*ones(24),resG.iniVec(:,riskPlot.I(i)),'-g','LineWidth',a(i));
    
% Net Loads
%     plot3((1:24)',i*ones(24),pltLoad.iniVec(:,i)-resG.iniVec(:,i),'-b','LineWidth',1.8);
%     plot3((1:24)',i*ones(24),pltLoad.iniVec(:,riskPlot.I(i))-resG.iniVec(:,riskPlot.I(i)),'-b','LineWidth',1.8);
end
view(3)
title(ax2,'Ranked RES Profiles')

ax1.XLim = [1,24];
ax1.YLim = [1,50];

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='\it t';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 12;
ax1.XAxis.FontName = 'Times New Roman';

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$\omega$';
ax1.YLabel.Color = 'black';
ax1.YAxis.FontSize  = 12;
ax1.YAxis.FontName = 'Times New Roman';
ax1.YLim = [1,50];

ax1.ZLabel.Interpreter = 'latex';
ax1.ZLabel.String ='$\bf \tilde{\xi}^l(\omega)$';
ax1.ZLabel.Color = 'black';
ax1.ZAxis.FontSize  = 12;
ax1.ZAxis.FontName = 'Times New Roman';

ax2.XLim = [1,24];
ax2.YLim = [1,50];

ax2.XLabel.Interpreter = 'latex';
ax2.XLabel.String ='\it t';
ax2.XLabel.Color = 'black';
ax2.XAxis.FontSize  = 12;
ax2.XAxis.FontName = 'Times New Roman';

ax2.YLabel.Interpreter = 'latex';
ax2.YLabel.String ='$\omega$';
ax2.YLabel.Color = 'black';
ax2.YAxis.FontSize  = 12;
ax2.YAxis.FontName = 'Times New Roman';
ax2.YLim = [1,50];

ax2.ZLabel.Interpreter = 'latex';
ax2.ZLabel.String ='$\bf \tilde{\xi}^w(\omega)$';
ax2.ZLabel.Color = 'black';
ax2.ZAxis.FontSize  = 12;
ax2.ZAxis.FontName = 'Times New Roman';

ax1.XGrid = 'on';
ax1.YGrid = 'on';
% 
ax2.XGrid = 'on';
ax2.YGrid = 'on';

t.TileSpacing = 'compact';




figure;
figBottomLeftX0 = 2;
figBottomLeftY0 = 2;
figWidth = 4.8; % 4.8
figHeight = 8.2;
set(gcf,'Name','Ranked scenarios bars','NumberTitle','off', 'Units','inches',...
'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
'PaperPositionMode','auto');

t = tiledlayout(2,1);

ax1 = nexttile;
hold on;
a = linspace(0.001,2,size(pltLoad.iniVec,2));
for i = wi:size(pltLoad.iniVec,2)
    bload(:,i) = pltLoad.iniVec(:,riskPlot.I(i));
end

b = bar3(bload');
colorbar;
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end

view(2)
title(ax1,'Ranked Load Profiles')

ax2 = nexttile;
hold on;
for i = wi:size(resG.iniVec,2)
    bwind(:,i) = resG.iniVec(:,riskPlot.I(i));
end

b = bar3(bwind');
colorbar;
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end

view(2)
title(ax2,'Ranked RES Profiles')

ax1.XLim = [1,24];
ax1.YLim = [1,50];

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='\it t';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 12;
ax1.XAxis.FontName = 'Times New Roman';

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$\omega$';
ax1.YLabel.Color = 'black';
ax1.YAxis.FontSize  = 12;
ax1.YAxis.FontName = 'Times New Roman';
ax1.YLim = [1,50];

ax1.ZLabel.Interpreter = 'latex';
ax1.ZLabel.String ='$\bf \tilde{\xi}^l(\omega)$';
ax1.ZLabel.Color = 'black';
ax1.ZAxis.FontSize  = 12;
ax1.ZAxis.FontName = 'Times New Roman';

ax2.XLim = [1,24];
ax2.YLim = [1,50];

ax2.XLabel.Interpreter = 'latex';
ax2.XLabel.String ='\it t';
ax2.XLabel.Color = 'black';
ax2.XAxis.FontSize  = 12;
ax2.XAxis.FontName = 'Times New Roman';

ax2.YLabel.Interpreter = 'latex';
ax2.YLabel.String ='$\omega$';
ax2.XLabel.Color = 'black';
ax2.YAxis.FontSize  = 12;
ax2.YAxis.FontName = 'Times New Roman';
ax2.YLim = [1,50];

ax2.ZLabel.Interpreter = 'latex';
ax2.ZLabel.String ='$\bf \tilde{\xi}^w(\omega)$';
ax2.ZLabel.Color = 'black';
ax2.ZAxis.FontSize  = 12;
ax2.ZAxis.FontName = 'Times New Roman';

ax1.XGrid = 'on';
ax1.YGrid = 'on';
% 
ax2.XGrid = 'on';
ax2.YGrid = 'on';

t.TileSpacing = 'compact';
%}
%% 3D -SEPARATE PLOTS
% Load: Ref50Scens.mat + ReferenceCase.mat

pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(24);
resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(24);
wi= 1;

% ////// #1: RANKED LOAD CONTOUR
figure;
set(gcf,'Name','Ranked scenarios bars - LOAD','NumberTitle','off');
% figBottomLeftX0 = 2;
% figBottomLeftY0 = 2;
% figWidth = 4.8; % 4.8
% figHeight = 8.2;
% set(gcf,'Name','Ranked scenarios bars - LOAD','NumberTitle','off', 'Units','inches',...
% 'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
% 'PaperPositionMode','auto');


ax1 = gca;
hold on;
a = linspace(0.001,2,size(pltLoad.iniVec,2));
for i = wi:size(pltLoad.iniVec,2)
    bload(:,i) = pltLoad.iniVec(:,riskPlot.I(i))/peakLoad;
end

b = bar3(bload');
c=colorbar;
c.Label.Interpreter = 'latex';
% c.Label.String = '$\it \bf \tilde{\xi}^{\ell}(\omega)$';
c.Label.String = '$\it \bf \widehat{\xi}^{\ell}_t(\omega)$';
c.Label.FontSize = 24;
c.Label.FontName = 'Times New Roman';
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end

view(2)
ax1.XLim = [0,25];
ax1.YLim = [0,51];

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$\it t \; [h]$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 24;
ax1.XAxis.FontName = 'Times New Roman';
xticks(4:4:24);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$\omega$';
ax1.YLabel.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';
yticks(10:10:50);

ax1.XGrid = 'on';
ax1.YGrid = 'on';

% ////// #2: RANKED RES CONTOUR
figure;
set(gcf,'Name','Ranked scenarios bars - RES','NumberTitle','off');
ax2 = gca;
hold on;
for i = wi:size(resG.iniVec,2)
    bwind(:,i) = resG.iniVec(:,riskPlot.I(i))/max(ResselScens);
end

b = bar3(bwind');
c=colorbar;
c.Label.Interpreter = 'latex';
c.Label.String = '$\it W(\bf \widehat{\xi}^w_t(\omega))$';
c.Label.FontSize = 24;
c.Label.FontName = 'Times New Roman';
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end

view(2)
ax2.XLim = [0,25];
ax2.YLim = [0,51];

ax2.XLabel.Interpreter = 'latex';
ax2.XLabel.String ='$\it t\; [h]$';
ax2.XLabel.Color = 'black';
ax2.XAxis.FontSize  = 24;
ax2.XAxis.FontName = 'Times New Roman';
xticks(4:4:24);

ax2.YLabel.Interpreter = 'latex';
ax2.YLabel.String ='$\omega$';
ax2.XLabel.Color = 'black';
ax2.YAxis.FontSize  = 24;
ax2.YAxis.FontName = 'Times New Roman';
yticks(10:10:50);

ax2.XGrid = 'on';
ax2.YGrid = 'on';
%% PLOT SCEDULE OF PARTICULAR SCENARIO FIGURE
% Run 1st section of main.m
% Load: Ref50Scens.mat + ReferenceCase.mat

scnSlct = 37; %37
peakLoad = max(LoadA.UnGroupSamples);
%------------------------- Define prob object------------------------------
prob    = OptProbX(InScenNum,InGTNum,riskA,riskB,dispFigs,dispPrints);

prob.setIndexesSet;
indexes = prob.VarsIndexes;

prob.AddBounds2VarsV2;
lb      = prob.lb;
ub      = prob.ub;

pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(24);
resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(24);

prob.defineAeqANDbeqV2(pltLoad.iniVec,resG.iniVec);
Aeq     = prob.Aeq;
beq     = prob.beq;

prob.defineAineqANDbineq(LscensProbVec);
A       = prob.Aineq;
bineq   = prob.bineq;
prob.defineObjFun(LscensProbVec);
f       = prob.costCoef;
intcon  = prob.intDeclare;
str1(1:size(A,1))         = '<';
str2(1:size(Aeq,1))       = '=';
str                       = strcat(str1,str2);

A_gur                     = cat(1,A,Aeq);
cost_gur                  = f;
b_gur                     = cat(1,bineq,beq);
vartypes_gur(1:size(A,2)) = 'C';
vartypes_gur(intcon)      = 'B';

model.A          = sparse(A_gur);
model.rhs        = b_gur;
model.lb         = lb;
model.ub         = ub;
model.obj        = cost_gur;
model.modelsense = 'Min';
model.vtype      = vartypes_gur;

model.sense      = str;
%--------------------------------------------------------------------------

pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(24);
resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(24);

[PgtTot,Pdump]=prob.NoBESSCase(LselScens,ResselScens);

% ////// #1: Load vs RES
figure;
set(gcf,'Name',['Load-RES Power',num2str(scnSlct)],'NumberTitle','off')
plot(pltLoad.iniVec(:,scnSlct)./peakLoad,'-r','LineWidth',1.8);hold on;
plot(resG.iniVec(:,scnSlct)./peakLoad,'-g','LineWidth',1.8);ylabel('P_{load}  /  P_{res}  [MW]');
legend('Load','Wind Power');
xlim([1 24]);
xlabel(['Scenario',num2str(scnSlct)],'FontWeight','bold');
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'off';

% ////// #2: GT Schedule (bars)
figure;
set(gcf,'Name','GT Schedule','NumberTitle','off')
xbar = [1:24];
ybar= [x(prob.VarsIndexes{2,prob.indexSetGTAPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTAPow}(scnSlct)+23),...
    x(prob.VarsIndexes{2,prob.indexSetGTBPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTBPow}(scnSlct)+23),...
    x(prob.VarsIndexes{2,prob.indexSetGTCPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTCPow}(scnSlct)+23),...
    x(prob.VarsIndexes{2,prob.indexSetGTDPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTDPow}(scnSlct)+23)]';
bplotobj = bar(xbar,ybar./peakLoad,'stacked'); hold on;

xlabel('Scenarios','FontWeight','bold');
xlim([1 24]);
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'off';
colormap(summer(size(ybar,2)));
grid on
l = cell(1,4);
l{1}='GT A'; l{2}='GT B'; l{3}='GT C'; l{4}='GT D';
legend(bplotobj,l);
plot(PgtTot((scnSlct-1)*prob.ScenTimeComp+1:(scnSlct-1)*prob.ScenTimeComp+1+(prob.ScenTimeComp-1))./peakLoad,'-k','LineWidth',1.5,'DisplayName','P_{GT}^{No BESS}');hold off;

% ////// #3: Power Scheduling
figure;
set(gcf,'Name','Power Scheduling','NumberTitle','off')

xbar = (1:24);
ybar= [x(prob.VarsIndexes{2,prob.indexSetGTAPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTAPow}(scnSlct)+23)+...
    x(prob.VarsIndexes{2,prob.indexSetGTBPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTBPow}(scnSlct)+23)+...
    x(prob.VarsIndexes{2,prob.indexSetGTCPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTCPow}(scnSlct)+23)+...
    x(prob.VarsIndexes{2,prob.indexSetGTDPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetGTDPow}(scnSlct)+23),resG.iniVec(:,scnSlct),x(prob.VarsIndexes{2,prob.indexSetBat}(scnSlct):prob.VarsIndexes{2,prob.indexSetBat}(scnSlct)+23),x(prob.VarsIndexes{2,prob.indexSetDumpPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetDumpPow}(scnSlct)+23)]';
bplotobj = bar(xbar,ybar./peakLoad,'stacked'); hold on;
xticks(4:4:24)

ax = gca;
ax.XLabel.Interpreter = 'latex';
ax.XLabel.String ='$\it t\;[h]$';
ax.XLabel.Color = 'black';
ax.XAxis.FontSize  = 24;
ax.XAxis.FontName = 'Times New Roman';
ax.XLim = [1 24];

ax.YAxis(1).Label.Interpreter = 'latex';
ax.YAxis(1).Label.String ='$P\;[pu]$';
ax.YAxis(1).Color = 'black';
ax.YAxis(1).FontSize  = 24;
ax.YAxis(1).FontName = 'Times New Roman';
% ax.YAxis(1).Limits = [-6,60];
ax.YAxis(1).Limits = [-0.1,1];
ax.YTick = (0:0.25:1);

ax.XGrid = 'on';
ax.YGrid = 'on';

bplotobj(1).FaceColor = [0.4940 0.1840 0.5560];
bplotobj(2).FaceColor = [0.3010 0.7450 0.9330];

bplotobj(3).FaceColor = [0.4660 0.6740 0.1880];
bplotobj(4).FaceColor = [0.6350 0.0780 0.1840];

grid on
hold on;
l = cell(1,4);
l{1}='$P_{GT}$'; l{2}='$W(\widehat{\bf \xi}^w(\omega))$'; l{3}='$P_{B}$'; l{4}='$P_{D}$';
legend(bplotobj,l,'NumColumns',3,'FontSize',14,'Interpreter','latex');
stemObj = stem(xbar,PgtTot((scnSlct-1)*prob.ScenTimeComp+1:(scnSlct-1)*prob.ScenTimeComp+1+(prob.ScenTimeComp-1))./peakLoad,'--k','LineWidth',1.5,'DisplayName','$P_{GT}^{d}$');
stemObj.MarkerFaceColor = 'k';
plot(xbar,pltLoad.iniVec(:,scnSlct)'./peakLoad,'-r','LineWidth',2,'DisplayName','$ \widehat{\bf \xi}^{\ell}(\omega)$');
plot(x(prob.VarsIndexes{2,prob.indexSetDumpPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetDumpPow}(scnSlct)+23)./peakLoad,...
    '-b','LineWidth',1.3,'DisplayName','$P_D$');
plot(Pdump((scnSlct-1)*prob.ScenTimeComp+1:(scnSlct-1)*prob.ScenTimeComp+1+(prob.ScenTimeComp-1))./peakLoad,'--k','LineWidth',1.5,'DisplayName','$P_D^{d}$');
hold off;

% ////// #4: BESS-Dump Energy 
for tcomp=0:prob.ScenTimeComp-1
    if tcomp == 0
        batteryEnergy(1+tcomp) =...
            0-prob.dt*x(prob.VarsIndexes{2,prob.indexSetBat}(scnSlct)+tcomp);
    else
        batteryEnergy(1+tcomp) = batteryEnergy(tcomp)-prob.dt*x(prob.VarsIndexes{2,prob.indexSetBat}(scnSlct)+tcomp);
    end
end
batterySOC=batteryEnergy./x(prob.TotalVarsNum);

figure;
set(gcf,'Name','BESS-Dump Energy','NumberTitle','off')
plot(x(prob.VarsIndexes{2,prob.indexSetDumpPow}(scnSlct):prob.VarsIndexes{2,prob.indexSetDumpPow}(scnSlct)+23),...
    '-b','LineWidth',1.3);hold on;
plot(Pdump((scnSlct-1)*prob.ScenTimeComp+1:(scnSlct-1)*prob.ScenTimeComp+1+(prob.ScenTimeComp-1))./peakLoad,'--k','LineWidth',1.5);
% Plot BESS Power as follows: Charge --> Green | Discharge --> Red
xpoints=1:24;
ypoints=x(prob.VarsIndexes{2,prob.indexSetBat}(scnSlct):prob.VarsIndexes{2,prob.indexSetBat}(scnSlct)+23)./peakLoad;
stem(xpoints,ypoints,'-k','LineWidth',1.8);
hold on
for k=1:length(ypoints)
    if ypoints(k)<0      % Charge (Load for the system)
        p1=plot(xpoints(k),ypoints(k),'o','MarkerEdgeColor','k','MarkerFaceColor',[0.4660 0.6740 0.1880],'MarkerSize',6);
        set( get( get( p1, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );
    elseif ypoints(k)>0  % Discharge (Generator for the system)
        p2=plot(xpoints(k),ypoints(k),'o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',6);
        set( get( get( p2, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );
    else                 % Idle
        p3=plot(xpoints(k),ypoints(k),'o','MarkerEdgeColor','k','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerSize',6);
        set( get( get( p3, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );
    end
end

ax = gca;
dim = [.15 .6 .3 .3];
str = {'\color[rgb]{0.4660,0.6740,0.1880} \fontsize{12} \it \bf Charging Mode',...
    '\color{red} \fontsize{12} \it \bf Discharging Mode',...
    '\color[rgb]{0.9290,0.6940,0.1250} \fontsize{12} \it \bf Idling Mode'};
annotation('textbox',dim,'String',str,'FitBoxToText','on',...
    'Margin',1,'FontSize',10,'Interpreter','tex');

ax.XLabel.Interpreter = 'tex';
ax.XLabel.String = 'Scenarios';
ax.XLabel.Color = 'black';
ax.XLabel.FontSize  = 12;
ax.XLabel.FontName = 'Times New Roman';
ax.XLabel.FontWeight = 'bold';
ax.XGrid = 'on';
ax.YGrid = 'off';

ax.TickLabelInterpreter = 'tex';
ax.XLim = [1 24];
ax.YAxis(1).Label.Interpreter = 'tex';
ax.YAxis(1).Label.String = 'P_{dump}  /  P_{bat}  [MW]';
ax.YAxis(1).Label.FontWeight = 'normal';
ax.YAxis(1).Color = 'black';
ax.YAxis(1).FontName = 'Times New Roman';
ax.YAxis(1).FontSize  = 12;

ax.Title.String = ['Scenarios #: ' num2str(prob.ScenNum)];
ax.Title.FontWeight = 'normal';

yyaxis right;
barObj1=bar(xpoints,batterySOC,'FaceColor',[.5 .5 .5],'EdgeColor','none'); hold on;
barObj2=bar(xpoints,ones(1,length(batterySOC)),'FaceColor','none','EdgeColor',[0 0 0],'LineWidth',1.1); hold on;
set( get( get( barObj2, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );

ax.YAxis(2).Label.Interpreter = 'tex';
ax.YAxis(2).Label.String = 'State of Charge [-]';
ax.YAxis(2).FontWeight = 'normal';
ax.YAxis(2).Color = 'black';
ax.YAxis(2).FontName = 'Times New Roman';
ax.YAxis(2).Limits = [-0.1 1.1];

hold off;
alpha(barObj1,.3);
legend(ax,{'P_{dump}^{BESS}','P_{dump}^{NO BESS}','P_{bat}','SoC'},'FontSize',12,'Fontname','Times New Roman','interpreter','tex','Location','northeast');
%% PLOT SCENARIO SELECTION PROCESS
% Run Equinor.m --> need DataTot.mat
% Run 1st section of main.m
% Load: Scns4Figs_02-Oct-2020-110735.mat, Ref50Scens.mat

%{
[scenGenSetLoad.iniVec,uniformRandVarU,EnSc,R24]   = LoadA.DoCopula(100,2);
[scenGenSetWind.iniVec,uniformRandVarUw,EnScw,R24w]   = wind.DoCopula(100,2);

% ///Save the .mat file containting the scenarios to be used for figures
% FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\OOP_trial_3\OutputFiles';   % Your destination folder
% outFileName01     = ['Scns4Figs_',date,'-',datestr(now,'HHMMSS')];
% matFileName01     = fullfile(FolderDestination,outFileName01);  
% save(matFileName01,'scenGenSetLoad','scenGenSetWind','uniformRandVarU',...
%     'EnSc','R24','uniformRandVarUw','EnScw','R24w');
%}
peakLoad = max(LoadA.UnGroupSamples);

% ////// #1 FAST FORWARD SELECTION
[LredScens,~,z3]=scenGenSetLoad.ReduceScenariosBy(0,5);
[LredScens,~,z3]=scenGenSetLoad.ReduceScenariosBy(1,95);


% ////// #2: HEATMAP
figure;
hm=gca;
set(gcf,'Name','Correlation Matrix - wind','NumberTitle','off')
axHeat=heatmap(R24,'ColorScaling','scaledcolumns','Colormap',summer,'FontSize',12);

% HeatLabels=cell(1,24);
% xticks(1:24)
% xticklabels(HeatLabels)
% 
% yticks(1:24)
% yticklabels(HeatLabels)

% axHeat.XLabel.Interpreter = 'latex';
axHeat.XLabel = ' \it \xi^{w}_i';
% axHeat.XLabel.Color = 'black';
% axHeat.XAxis.FontSize  = 12;
% axHeat.XAxis.FontName = 'Times New Roman';

% axHeat.YLabel.Interpreter = 'latex';
axHeat.YLabel = ' \it \xi^{w}_i';
% axHeat.YLabel.Color = 'black';
% axHeat.YAxis.FontSize  = 12;
% axHeat.YAxis.FontName = 'Times New Roman';

% ////// #3 - KDE LOAD
randVarX = LoadA.iniVec';
figure; hold on;
for i=1:size(LoadA.iniVec,1)
    uniformRandVarU(:,i)=ksdensity(randVarX(:,i),randVarX(:,i),'function','cdf','Bandwidth',2);
    [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
    plot(xi,f);grid on;
    axpdf=gca;
    set(gcf,'Name','Kernel pdf Histogram - LOAD','NumberTitle','off')
    
    axpdf.XLabel.Interpreter = 'latex';
    axpdf.XLabel.String ='$\xi^{l}$';
    axpdf.XLabel.Color = 'black';
    axpdf.XAxis.FontSize  = 24;
    axpdf.XAxis.FontName = 'Times New Roman';
    axpdf.XLim = [0 90];
    
    axpdf.YLabel.Interpreter = 'latex';
    axpdf.YLabel.String ='$f(\xi^{l})$';
    axpdf.YLabel.Color = 'black';
    axpdf.YAxis.FontSize  = 24;
    axpdf.YAxis.FontName = 'Times New Roman';
    axpdf.YLim = [0 0.045];
end
hold off;

% ////// #4 - Generated Scenario Set LOAD
figure;
axGen=gca;
set(gcf,'Name','Gen-load','NumberTitle','off')
plot(scenGenSetLoad.iniVec./peakLoad,'-b','LineWidth',0.1);
grid on;
axGen.XLabel.Interpreter = 'latex';
axGen.XLabel.String ='$t\:[h]$';
axGen.XLabel.Color = 'black';
axGen.XAxis.FontSize  = 24;
axGen.XAxis.FontName = 'Times New Roman';
axGen.XLim = [1 24];
xticks(4:4:24);


axGen.YLabel.Interpreter = 'latex';
axGen.YLabel.String ='$\widehat{ \bf \xi}^{\ell}\:[pu]$';
axGen.YLabel.Color = 'black';
axGen.YAxis.FontSize  = 24;
axGen.YAxis.FontName = 'Times New Roman';
% axGen.YLim = [8 82];
axGen.YLim = [0 1];
yticks(0:0.25:1);

% ////// #5 - KDE WIND
randVarX = wind.iniVec';
figure; hold on;
for i=1:size(wind.iniVec,1)
    uniformRandVarU(:,i)=ksdensity(randVarX(:,i),randVarX(:,i),'function','cdf','Bandwidth',2);
    [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
    plot(xi,f);grid on;
    axpdf=gca;
    set(gcf,'Name','Kernel pdf Histogram - LOAD','NumberTitle','off')
    
    axpdf.XLabel.Interpreter = 'latex';
    axpdf.XLabel.String ='$\xi^{w}$';
    axpdf.XLabel.Color = 'black';
    axpdf.XAxis.FontSize  = 12;
    axpdf.XAxis.FontName = 'Times New Roman';
    
    axpdf.YLabel.Interpreter = 'latex';
    axpdf.YLabel.String ='$f(\xi^{w})$';
    axpdf.YLabel.Color = 'black';
    axpdf.YAxis.FontSize  = 12;
    axpdf.YAxis.FontName = 'Times New Roman';
end
hold off;

% ////// #6 - Generated Scenario Set WIND (be careful for negative speed)
figure;
axGen=gca;
set(gcf,'Name','Gen-wind','NumberTitle','off')
plot(scenGenSetWind.iniVec,'-b','LineWidth',0.1);
grid on;
axGen.XLabel.Interpreter = 'latex';
axGen.XLabel.String ='$t\:[h]$';
axGen.XLabel.Color = 'black';
axGen.XAxis.FontSize  = 24;
axGen.XAxis.FontName = 'Times New Roman';
axGen.XLim = [1 24];
xticks(4:4:24);

axGen.YLabel.Interpreter = 'latex';
axGen.YLabel.String ='$\widehat{ \bf \xi}^{w}\:[\frac{m}{s}]$';
axGen.YLabel.Color = 'black';
axGen.YAxis.FontSize  = 24;
axGen.YAxis.FontName = 'Times New Roman';
axGen.YLim = [0 30];
%% PLOT STABILITY RESULTS
% Load: StabilityTest_10-Sep-2020-161628.mat

pickVar = 7;
% ////// #1: BOXPLOTS
% figure;
myFigs.boxPlt.figWidth = 7; myFigs.boxPlt.figHeight = 5;
myFigs.boxPlt.figBottomLeftX0 = 2; myFigs.boxPlt.figBottomLeftY0 =2;

myFigs.boxPlt.fig = figure('Name','Stabiliy Test - Boxplots','NumberTitle','off','Units','inches',...
'Position',[myFigs.boxPlt.figBottomLeftX0 myFigs.boxPlt.figBottomLeftY0 myFigs.boxPlt.figWidth myFigs.boxPlt.figHeight],...
'PaperPositionMode','auto');

% set(gcf,'Name','Stabiliy Test - Boxplots','NumberTitle','off','Units','inches')

xsolBox=Solutions{pickVar,2};
gtemp = {num2str(Solutions{1,2}(1)) ' Scenarios';num2str(Solutions{1,2}(2)) ' Scenarios';num2str(Solutions{1,2}(3)) ' Scenarios';...
    num2str(Solutions{1,2}(4)) ' Scenarios' ; num2str(Solutions{1,2}(5)) ' Scenarios'};
for i =1:length(Solutions{1,2})
    gtemp3{i,1} = num2str(Solutions{1,2}(i),'%d');
    gtemp2{i,1} = Solutions{1,2}(i);
    
    boxMedians(i) = median(xsolBox(:,i));
    minmaxRange(i) = max(xsolBox(:,i))-min(xsolBox(:,i));
    quantilesRange(i) = quantile(xsolBox(:,i),0.75)-quantile(xsolBox(:,i),0.25);
    standatrdDeviations(i) = std(xsolBox(:,i));
end
  
gsolBox=categorical(gtemp3);

valueset = {'5','10','15','20','25','30','35','40','45','50'};
gsolBox2 = categorical(gsolBox,valueset,'Ordinal',true);

boxplot(xsolBox,gsolBox2,'Symbol','r')
ylabel(Solutions{pickVar,1});

myFigs.boxPlt.ax1=gca;
myFigs.boxPlt.ax1.YAxis.Label.Interpreter = 'latex';
% ax1.YAxis.Label.String ='$\it F \rm (\bf x \, ; \, \bf \widehat{ \xi} \rm (\omega))$';
myFigs.boxPlt.ax1.YAxis.Label.String ='$\it F \rm (\bf x \, ; \, \rm \Omega_s) $';
myFigs.boxPlt.ax1.YAxis.Color = 'black';
myFigs.boxPlt.ax1.YAxis.FontSize  = 24;
myFigs.boxPlt.ax1.YAxis.FontName = 'Times New Roman';

myFigs.boxPlt.ax1.XLabel.Interpreter = 'latex';
myFigs.boxPlt.ax1.XLabel.String ='$\vert \Omega_s \vert$';
myFigs.boxPlt.ax1.XLabel.Color = 'black';
myFigs.boxPlt.ax1.XAxis.FontSize  = 24;
myFigs.boxPlt.ax1.XAxis.FontName = 'Times New Roman';
myFigs.boxPlt.ax1.TickLabelInterpreter  = 'latex';


myFigs.boxPlt.ax1.XGrid = 'on';
myFigs.boxPlt.ax1.YGrid = 'off';

% ////// #2: STATISTICS
A =[minmaxRange;quantilesRange;standatrdDeviations];

% figure;
% set(gcf,'Name','Stabiliy Test Statistics','NumberTitle','off')

% myFigs.stabPlt.figWidth = 6; myFigs.stabPlt.figHeight = 4;
% myFigs.stabPlt.figBottomLeftX0 = 2; myFigs.stabPlt.figBottomLeftY0 =2;
% myFigs.stabPlt.fig = figure('Name','Stabiliy Test Statistics','NumberTitle','off','Units','inches',...
% 'Position',[myFigs.stabPlt.figBottomLeftX0 myFigs.stabPlt.figBottomLeftY0 myFigs.stabPlt.figWidth myFigs.stabPlt.figHeight],...
% 'PaperPositionMode','auto');


% myFigs.stabPlt.fig = figure('Name','Stabiliy Test Statistics','NumberTitle','off','Units','inches','PaperPositionMode','auto');

myFigs.stabPlt.figWidth = 7; myFigs.stabPlt.figHeight = 5;
myFigs.stabPlt.figBottomLeftX0 = 2; myFigs.stabPlt.figBottomLeftY0 =2;

myFigs.stabPlt.fig = figure('Name','Stabiliy Test Statistics','NumberTitle','off','Units','inches',...
'Position',[myFigs.stabPlt.figBottomLeftX0 myFigs.stabPlt.figBottomLeftY0 myFigs.stabPlt.figWidth myFigs.stabPlt.figHeight],...
'PaperPositionMode','auto');

plot(1:length(Solutions{1,2}),minmaxRange,'-r','LineWidth',2);hold on;
yyaxis right;
plot(1:length(Solutions{1,2}),quantilesRange,'-g','LineWidth',2);
plot(1:length(Solutions{1,2}),standatrdDeviations,'-b','LineWidth',2);

myFigs.stabPlt.ax1 = gca;
myFigs.stabPlt.ax1.XTickLabel = gtemp2;
myFigs.stabPlt.ax1.XLabel.Interpreter = 'latex';
myFigs.stabPlt.ax1.TickLabelInterpreter  = 'latex';
myFigs.stabPlt.ax1.XLabel.String = '$\vert \Omega_s \vert$';
myFigs.stabPlt.ax1.XLabel.Color = 'black';
myFigs.stabPlt.ax1.FontSize  = 24;
myFigs.stabPlt.ax1.XLabel.FontName = 'Times New Roman';
myFigs.stabPlt.ax1.FontName = 'Times New Roman';
myFigs.stabPlt.ax1.XLabel.FontWeight = 'bold';
myFigs.stabPlt.ax1.XLim = [1,length(Solutions{1,2})];
myFigs.stabPlt.ax1.XTick = (1:1:50);

myFigs.stabPlt.ax1.YAxis(1).Label.Interpreter = 'latex';
myFigs.stabPlt.ax1.YAxis(1).FontSize  = 24;
myFigs.stabPlt.ax1.YAxis(1).FontName = 'Times New Roman';
myFigs.stabPlt.ax1.YAxis(1).Label.String = '$Rg$';
myFigs.stabPlt.ax1.YAxis(1).Limits = [min(A,[],'all')-5000,max(A,[],'all')];


myFigs.stabPlt.ax1.YAxis(2).Label.Interpreter = 'latex';
myFigs.stabPlt.ax1.YAxis(2).FontSize  = 24;
myFigs.stabPlt.ax1.YAxis(2).FontName = 'Times New Roman';
myFigs.stabPlt.ax1.YAxis(2).Limits = [min(A,[],'all')-5000,max(A,[],'all')];

myFigs.stabPlt.ax1.XGrid = 'on';
myFigs.stabPlt.ax1.YGrid = 'on';
myFigs.stabPlt.ax1.YAxis(2).Color = 'k'; 
% myFigs.stabPlt.ax1.YAxis(2).Label.String = '$Q^{25-75} \;/ \; \sigma$';
myFigs.stabPlt.ax1.YAxis(2).Label.String = '$IQR \;/ \; s$';


% legend(myFigs.stabPlt.ax1,{'$Rg(\it F \rm (\bf x \, ; \, \bf \widehat{\xi}(\omega)) \rm \big \vert \vert \Omega_s \vert)$','$Q^{25-75}(\it F \rm (\bf x \, ; \, \bf \widehat{\xi}(\omega) \rm \big \vert \vert \Omega_s \vert)$','$\sigma (\it F \rm (\bf x \, ; \, \bf \widehat{\xi}(\omega) \rm \big \vert \vert \Omega_s \vert)$'},'FontSize',16,...
%     'Fontname','Times New Roman','interpreter','latex','Location','northeast');

legend(myFigs.stabPlt.ax1,{'$Rg \left ( \left \{ \it F \rm (\bf x \, ; \rm \Omega_s)\right\}_M \right ) $',...
    '$IQR\left ( \left \{ \it F \rm (\bf x \, ; \rm \Omega_s)\right\}_M \right )$',...
    '$s \left ( \left \{ \it F \rm (\bf x \, ; \rm \Omega_s)\right\}_M \right )$'},'FontSize',16,...
    'Fontname','Times New Roman','interpreter','latex','Location','northeast');
hold off;
%% PLOT OF DATASETS TOGETHER WITH SAMPLED PROFILES
% Run Equinor.m --> need DataTot.mat
% Run 1st section of main.m
% Load: Scns4Figs_02-Oct-2020-110735.mat

% Data - RES
% figure;
% ax1=gca;
% set(gcf,'Name','Data-res','NumberTitle','off')
% for iScen = 1:size(wind.iniVec,2)
%     plot(wind.iniVec(:,iScen),'-b','LineWidth',0.1);
%     hold on;
% end
% grid on;
% ax1.XLabel.Interpreter = 'latex';
% ax1.XLabel.String ='$t\:[h]$';
% ax1.XLabel.Color = 'black';
% ax1.XAxis.FontSize  = 24;
% ax1.XAxis.FontName = 'Times New Roman';
% ax1.XLim = [1,24];
% xticks(4:4:24);
% 
% ax1.YLabel.Interpreter = 'latex';
% ax1.YLabel.String ='$\xi^{w}\:[\frac{m}{s}]$';
% ax1.XLabel.Color = 'black';
% ax1.YAxis.FontSize  = 24;
% ax1.YAxis.FontName = 'Times New Roman';
% hold off;

% ////// #6 - Generated Scenario Set WIND (be careful for negative speed)
% figure;
% axGen=gca;
% set(gcf,'Name','Gen-wind','NumberTitle','off')
% plot(scenGenSetWind.iniVec,'-b','LineWidth',0.1);
% grid on;
% axGen.XLabel.Interpreter = 'latex';
% axGen.XLabel.String ='$t\:[h]$';
% axGen.XLabel.Color = 'black';
% axGen.XAxis.FontSize  = 24;
% axGen.XAxis.FontName = 'Times New Roman';
% axGen.XLim = [1 24];
% xticks(4:4:24);
% axGen.YLabel.Interpreter = 'latex';
% axGen.YLabel.String ='$\widehat{ \bf \xi}^{w}\:[\frac{m}{s}]$';
% axGen.YLabel.Color = 'black';
% axGen.YAxis.FontSize  = 24;
% axGen.YAxis.FontName = 'Times New Roman';
% axGen.YLim = [0 30];

% Data - load

myFigs.dataVSgen.figWidth = 7; myFigs.dataVSgen.figHeight = 5;
myFigs.dataVSgen.figBottomLeftX0 = 2; myFigs.dataVSgen.figBottomLeftY0 =2;

myFigs.dataVSgen.fig = figure('Name','Load-data-gen','NumberTitle','off','Units','inches',...
'Position',[myFigs.dataVSgen.figBottomLeftX0 myFigs.dataVSgen.figBottomLeftY0 myFigs.dataVSgen.figWidth myFigs.dataVSgen.figHeight],...
'PaperPositionMode','auto');

peakLoad = max(LoadA.UnGroupSamples);
myFigs.dataVSgen.ax1=gca;
for iScen = 1:size(LoadA.iniVec,2)
    p1=plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'-b','LineWidth',1);
    hold on;
end
p2=plot(scenGenSetLoad.iniVec./peakLoad,'-r','LineWidth',0.5);
hold off;
myFigs.dataVSgen.h=[p1(1);p2(1)];
grid on;
myFigs.dataVSgen.ax1.XLabel.Interpreter = 'latex';
myFigs.dataVSgen.ax1.XLabel.String ='$t\:[h]$';
myFigs.dataVSgen.ax1.XLabel.Color = 'black';
myFigs.dataVSgen.ax1.XAxis.FontSize  = 24;
myFigs.dataVSgen.ax1.XAxis.FontName = 'Times New Roman';
myFigs.dataVSgen.ax1.XLim = [1,24];
myFigs.dataVSgen.ax1.XTick = [4:4:24];

myFigs.dataVSgen.ax1.YLabel.Interpreter = 'latex';
myFigs.dataVSgen.ax1.YLabel.String ='$\bf \xi^{\ell}\: \rm [pu]$';
myFigs.dataVSgen.ax1.XLabel.Color = 'black';
myFigs.dataVSgen.ax1.YAxis.FontSize  = 24;
myFigs.dataVSgen.ax1.YAxis.FontName = 'Times New Roman';
myFigs.dataVSgen.ax1.YTick = (0:0.25:1);

legend(myFigs.dataVSgen.h,{'$ \left \{  \xi^{\ell} \right \}_N $','$\bf \tilde{\xi}^{\ell} \rm \; \in \; \Omega$'},'FontSize',16,...
    'Fontname','Times New Roman','interpreter','latex','NumColumns',2,'Location','northeast');
%% PLOT 3D SAMPLING DENSITIES (FOR 2 DIMENSIONS)
% ////// #3 - KDE LOAD

% Run Equinor.m --> need DataTot.mat
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m'); % to execute the file
% Run 1st section of main.m
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');

close all;

randVarX = LoadA.iniVec';
figure; hold on;
for i=1:size(LoadA.iniVec,1)
    uniformRandVarU(:,i)=ksdensity(randVarX(:,i),randVarX(:,i),'function','cdf','Bandwidth',2);
    [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
    plot(xi,f);grid on;
    axpdf=gca;
    set(gcf,'Name','Kernel pdf Histogram - LOAD','NumberTitle','off')
    
    axpdf.XLabel.Interpreter = 'latex';
    axpdf.XLabel.String ='$\xi^{l}$';
    axpdf.XLabel.Color = 'black';
    axpdf.XAxis.FontSize  = 24;
    axpdf.XAxis.FontName = 'Times New Roman';
    axpdf.XLim = [0 90];
    
    axpdf.YLabel.Interpreter = 'latex';
    axpdf.YLabel.String ='$f(\xi^{l})$';
    axpdf.YLabel.Color = 'black';
    axpdf.YAxis.FontSize  = 24;
    axpdf.YAxis.FontName = 'Times New Roman';
    axpdf.YLim = [0 0.045];
end
hold off;

figure; hold on;
for i=1:2
    [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
    X(i,:) = xi;
    F(i,:) = f;
end

% figure; hold on;
%     [f1,xi1] = ksdensity(randVarX(:,1),'function','pdf','Bandwidth',2);
%     X(1,:) = xi1;
%     F(1,:) = f1;
%     
%     [f24,xi24] = ksdensity(randVarX(:,24),'function','pdf','Bandwidth',2);
%     X(2,:) = xi24;
%     F(2,:) = f24;
    
z = F(1,:).*F(2,:)';
[Xi,Yi] = meshgrid(X(1,:),X(2,:));
scL = meshc(Xi, Yi, z);
% scL = surf(Xi, Yi, z);
% shading 'interp';
set(gcf,'Name','Bivirate_LOAD_pdf','NumberTitle','off')



%     axpdf=gca;
%     set(gcf,'Name','Kernel pdf Histogram - LOAD','NumberTitle','off')
%     
%     axpdf.XLabel.Interpreter = 'latex';
%     axpdf.XLabel.String ='$\xi^{l}$';
%     axpdf.XLabel.Color = 'black';
%     axpdf.XAxis.FontSize  = 24;
%     axpdf.XAxis.FontName = 'Times New Roman';
%     axpdf.XLim = [0 90];
%     
%     axpdf.YLabel.Interpreter = 'latex';
%     axpdf.YLabel.String ='$f(\xi^{l})$';
%     axpdf.YLabel.Color = 'black';
%     axpdf.YAxis.FontSize  = 24;
%     axpdf.YAxis.FontName = 'Times New Roman';
%     axpdf.YLim = [0 0.045];
hold off;

randVarX = wind.iniVec';
% figure; hold on;
% for i=1:size(wind.iniVec,1)
%     uniformRandVarU(:,i)=ksdensity(randVarX(:,i),randVarX(:,i),'function','cdf','Bandwidth',2);
%     [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
%     plot(xi,f);grid on;
%     axpdf=gca;
%     set(gcf,'Name','Kernel pdf Histogram - LOAD','NumberTitle','off')
%     
%     axpdf.XLabel.Interpreter = 'latex';
%     axpdf.XLabel.String ='$\xi^{w}$';
%     axpdf.XLabel.Color = 'black';
%     axpdf.XAxis.FontSize  = 12;
%     axpdf.XAxis.FontName = 'Times New Roman';
%     
%     axpdf.YLabel.Interpreter = 'latex';
%     axpdf.YLabel.String ='$f(\xi^{w})$';
%     axpdf.YLabel.Color = 'black';
%     axpdf.YAxis.FontSize  = 12;
%     axpdf.YAxis.FontName = 'Times New Roman';
% end
% hold off;

figure; hold on;
for i=1:2
    [f,xi] = ksdensity(randVarX(:,i),'function','pdf','Bandwidth',2);
    X(i,:) = xi;
    F(i,:) = f;
end
z = F(1,:).*F(2,:)';
[Xi,Yi] = meshgrid(X(1,:),X(2,:));
scW = meshc(Xi, Yi, z);
% scW = surf(Xi, Yi, z);
% shading 'flat';

% scW = surf(Xi, Yi, z);
% scW.FaceAlpha = 'flat';
set(gcf,'Name','Bivirate_RES_pdf','NumberTitle','off')


%% ----------------------\\\ SAVING FIGURE \\\-----------------------------
%
% mkdir OutputFigures
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER\OutputFigures';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = get(FigHandle,'Name');
    print(FigHandle, fullfile(FolderName, [FigName '.png']), '-r300', '-dpng')
end
%}
%% ----------------------\\\ SAVING FIGURE \\\-----------------------------
%
% mkdir FigOutTest
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\EVENTS\JOURNAL_PAPERS\Paper_J1\Jrnl_Energy_Storage\Revision\Figures';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    %       FigName   = num2str(get(FigHandle, 'Number'));
    FigName   = get(FigHandle,'Name');
    
    % -----------------------TO PRINT THE FIGURE---------------------------
    
%     print(FigHandle, fullfile(FolderName, [FigName '.png']), '-r300', '-dpng')

%     print(FigHandle, fullfile(FolderName, [FigName '.pdf']),'-dpdf','-fillpage')

%     print(FigHandle, fullfile(FolderName, [FigName '.pdf']),'-dpdf','-bestfit')



pos = get(gcf,'Position');
set(gcf,'PaperSize',[pos(3) pos(4)],'PaperUnits','inches')
set(gcf,'renderer','painters');

% 
print(FigHandle, fullfile(FolderName, [FigName '.pdf']),'-dpdf')
    

end
%}