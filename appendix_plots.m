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
%% PLOT DATASETS - sampling methods i) and ii)
% Run Equinor.m --> need DataTot.mat
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m'); % to execute the file
% Run 1st section of main.m
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');

figWidth = 6; figHeight = 5;
figBottomLeftX0 = 2; figBottomLeftY0 =2;
fontSize = 20;
fig01Name = 'res_sampling_ii'; % data_res, res_sampling_i, res_sampling_ii, res_sampling_iii_50, res_sampling_iii_10, res_sampling_iii_10_red, res_sampling_iii
fig02Name = 'load_sampling_iii'; % data_load, load_sampling_i, load_sampling_ii, load_sampling_iii_50, load_sampling_iii_10, load_sampling_iii_10_red, load_sampling_iii

% Data - RES
figure('Name',fig01Name,'NumberTitle','off','Units','inches',...
    'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
    'PaperPositionMode','auto');


% rnd_idx_1 = 100;
% rnd_idx_2 = 150;
% rnd_idx_3 = 300;

% rnd_idx_1 = 54;
% rnd_idx_2 = 187;
% rnd_idx_3 = 329;

% rnd_idx_1 = 28;
% rnd_idx_2 = 187;
% rnd_idx_3 = 310;


rnd_idx_1 = 28;
rnd_idx_2 = 187;
rnd_idx_3 = 340;

rnd_idx_iii_1 = z3(1);
rnd_idx_iii_2 = z3(25);
rnd_idx_iii_3 = z3(50);



ax1=gca;


for iScen = 1:size(wind.iniVec,2)
    
    if iScen == rnd_idx_1
        plot(wind.iniVec(:,iScen),'Color' ,'r','LineWidth',3);
    elseif iScen == rnd_idx_2
        plot(wind.iniVec(:,iScen),'Color' ,'g','LineWidth',3);
    elseif iScen == rnd_idx_3
        plot(wind.iniVec(:,iScen),'Color' ,'b','LineWidth',3);
    else
        plot(wind.iniVec(:,iScen),'Color' ,'#bdbdbd','LineWidth',0.1);
    end
%     


%     plot(wind.iniVec(:,iScen),'Color' ,'#bdbdbd','LineWidth',0.1);
    
% 
%     if ismember(iScen,z3)
%         plot(wind.iniVec(:,iScen),'Color' ,'r','LineWidth',3);
%     else
%         plot(wind.iniVec(:,iScen),'Color' ,'#bdbdbd','LineWidth',0.1);
%     end
    

%     if ismember(iScen,z3)
%         if iScen == rnd_idx_iii_1
%             plot(wind.iniVec(:,iScen),'Color' ,'r','LineWidth',3);
%         elseif iScen == rnd_idx_iii_2
%             plot(wind.iniVec(:,iScen),'Color' ,'g','LineWidth',3);
%         elseif iScen == rnd_idx_iii_3
%             plot(wind.iniVec(:,iScen),'Color' ,'b','LineWidth',3);
%         else
%             plot(wind.iniVec(:,iScen),'Color' ,'#737373','LineWidth',1);
%         end
%     else
%         plot(wind.iniVec(:,iScen),'Color' ,'#bdbdbd','LineWidth',0.1);
%     end
    
    hold on;
end
% grid on;
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$t\:[h]$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = fontSize;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [1,24];
xticks(4:4:24);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$\xi^{w}\:[\frac{m}{s}]$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = fontSize;
ax1.YAxis.FontName = 'Times New Roman';

ax1.Box = 'off';

hold off;

% Data - load
figure('Name',fig02Name,'NumberTitle','off','Units','inches',...
    'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
    'PaperPositionMode','auto');

peakLoad = max(LoadA.UnGroupSamples);
ax1=gca;

for iScen = 1:size(LoadA.iniVec,2)
    
%     if iScen == rnd_idx_1
%         plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'r','LineWidth',3);
%     elseif iScen == rnd_idx_2
%         plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'g','LineWidth',3);
%     elseif iScen == rnd_idx_3
%         plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'b','LineWidth',3);
%     else
%         plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'#bdbdbd','LineWidth',0.1);
%     end

    if iScen == rnd_idx_1
        plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'g','LineWidth',3);
    elseif iScen == rnd_idx_2
        plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'b','LineWidth',3);
    elseif iScen == rnd_idx_3
        plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'r','LineWidth',3);
    else
        plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'#bdbdbd','LineWidth',0.1);
    end
    


%     plot(1:24,LoadA.iniVec(:,iScen)/peakLoad,'Color' ,'#bdbdbd','LineWidth',0.1);
    

%     if ismember(iScen,z3)
%         plot(LoadA.iniVec(:,iScen),'Color' ,'r','LineWidth',3);
%     else
%         plot(LoadA.iniVec(:,iScen),'Color' ,'#bdbdbd','LineWidth',0.1);
%     end
    
    
    
%     if ismember(iScen,z3)
%         if iScen == rnd_idx_iii_2
%             plot(LoadA.iniVec(:,iScen),'Color' ,'r','LineWidth',3);
%         elseif iScen == rnd_idx_iii_3
%             plot(LoadA.iniVec(:,iScen),'Color' ,'g','LineWidth',3);
%         elseif iScen == rnd_idx_iii_1
%             plot(LoadA.iniVec(:,iScen),'Color' ,'b','LineWidth',3);
%         else
%             plot(LoadA.iniVec(:,iScen),'Color' ,'#737373','LineWidth',1);
%         end
%     else
%         plot(LoadA.iniVec(:,iScen),'Color' ,'#bdbdbd','LineWidth',0.1);
%     end
    
    hold on;
end
% grid on;
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$t\:[h]$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = fontSize;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [1,24];
xticks(4:4:24);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$\xi^{\ell}\:[pu]$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = fontSize;
ax1.YAxis.FontName = 'Times New Roman';
ax1.YTick = (0:0.25:1);

ax1.Box = 'off';

hold off;
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
ax1.XAxis.FontSize  = 20;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [0,1];

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$t_i(\tilde{\xi^{w}})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 20;
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

% figure;
% ax1=gca;
% set(gcf,'Name','Obtained Map Version 3','NumberTitle','off')

figWidth = 7; figHeight = 5;
figBottomLeftX0 = 2; figBottomLeftY0 = 2;

figure('Name','Obtained Map Version 3','NumberTitle','off','Units','inches',...
'Position',[figBottomLeftX0 figBottomLeftY0 figWidth figHeight],...
'PaperPositionMode','auto');

ax1=gca;


for i=1:size(resG.iniVec,2)
    plot(MapData.points(MapData.clusterID==i,1),MapData.points(MapData.clusterID==i,2),'.','Color',mapFigures.clr(i,:),'MarkerSize',12)
    hold on
end

plot(MapData.centroids(:,1),MapData.centroids(:,2),'kx','MarkerSize',15,'LineWidth',3)

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$t_i(\tilde{\xi^{\ell}})$';
ax1.XLabel.Color = 'black';
ax1.XAxis.FontSize  = 20;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [0,1];
xticks(0:0.25:1);

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$t_i(\tilde{\xi^{w}})$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 20;
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
ax1.XAxis.FontSize  = 20;
ax1.XAxis.FontName = 'Times New Roman';
ax1.XLim = [1,30];

ax1.YLabel.Interpreter = 'latex';
ax1.YLabel.String ='$J_I$';
ax1.XLabel.Color = 'black';
ax1.YAxis.FontSize  = 20;
ax1.YAxis.FontName = 'Times New Roman';
%% PLOT SCENARIO SELECTION PROCESS
% Run Equinor.m --> need DataTot.mat
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m'); % to execute the file
% % Run 1st section of main.m
% run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');
% 
% % Load: Scns4Figs_02-Oct-2020-110735.mat, Ref50Scens.mat
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\Scns4Figs_02-Oct-2020-110735.mat');
% load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat');


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
% LOAD
% 100 scenarios
[LredScens,~,z3]=scenGenSetLoad.ReduceScenariosBy(0,3);
[LredScens,~,z3]=scenGenSetLoad.ReduceScenariosBy(1,95);
% all data
[LredScens,~,z3]=LoadA.ReduceScenariosBy(0,50);
[LredScens,~,z3]=LoadA.ReduceScenariosBy(1,365-10);

% WIND
% 100 scenarios

% all data
[LredScens,~,z3]=wind.ReduceScenariosBy(0,50);
[LredScens,~,z3]=wind.ReduceScenariosBy(1,365-10);




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

%% PLOT OF DATASETS TOGETHER WITH SAMPLED PROFILES

% Run Equinor.m --> need DataTot.mat
load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m'); % to execute the file
% Run 1st section of main.m
run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');
% 
% Load: Scns4Figs_02-Oct-2020-110735.mat
load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\Scns4Figs_02-Oct-2020-110735.mat');




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
% grid on;
myFigs.dataVSgen.ax1.XLabel.Interpreter = 'latex';
myFigs.dataVSgen.ax1.XLabel.String ='$t\:[h]$';
myFigs.dataVSgen.ax1.XLabel.Color = 'black';
myFigs.dataVSgen.ax1.XAxis.FontSize  = 20;
myFigs.dataVSgen.ax1.XAxis.FontName = 'Times New Roman';
myFigs.dataVSgen.ax1.XLim = [1,24];
myFigs.dataVSgen.ax1.XTick = [4:4:24];

myFigs.dataVSgen.ax1.Box = 'off';


myFigs.dataVSgen.ax1.YLabel.Interpreter = 'latex';
myFigs.dataVSgen.ax1.YLabel.String ='$\bf \xi^{\ell}\: \rm [pu]$';
myFigs.dataVSgen.ax1.XLabel.Color = 'black';
myFigs.dataVSgen.ax1.YAxis.FontSize  = 20;
myFigs.dataVSgen.ax1.YAxis.FontName = 'Times New Roman';
myFigs.dataVSgen.ax1.YTick = (0:0.25:1);

legend(myFigs.dataVSgen.h,{'$ \left \{  \xi^{\ell} \right \}_N $','$\bf \tilde{\xi}^{\ell} \rm \; \in \; \Omega$'},'FontSize',18,'Box', 'off','color','none',...
    'Fontname','Times New Roman','interpreter','latex','NumColumns',2,'Location','northeast');
