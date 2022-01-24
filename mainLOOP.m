%% LOOP to test different number of scenarios
%{
close all;
clearvars -except DataTot

InGTNum = 4;
LoadA     = DataX(DataTot.GFA_active);
LoadC     = DataX(DataTot.GFC_active);
wind      = DataX(DataTot.Wind_Speed);

WF1 = WindFarm();

WF1.WindValue = wind.iniVec;
WF1.DoWindPower;

ResGen = DataX(WF1.WindPower);

LoadA.iniVec=LoadA.GroupSamplesBy(24);
ResGen.iniVec=ResGen.GroupSamplesBy(24);

scenGenSetLoad          = DataX();
scenGenSetWind          = DataX();
wind.iniVec=wind.GroupSamplesBy(24);


dispFigs       = 0;
dispPrints     = 0;
% Solutions{1,1} = 'x vectors';
Solutions{1,1} = 'Scenarios Number';
Solutions{2,1} = 'Expected Fuel Consumption';
Solutions{3,1} = 'Expected GT OPEX';
Solutions{4,1} = 'Expected Dumped Enerrgy';
Solutions{5,1} = 'Battery CAPEX';
Solutions{6,1} = 'Battery Equivalent Daily';
Solutions{7,1} = 'Expected cost';
Solutions{8,1} = 'Expected CO2 emissions tn';
Solutions{9,1} = 'Battery Power MW';
Solutions{10,1} = 'Battery Capacity MWh';
for scn = 5:5:50
    InScenNum             = scn;
    main
    Solutions{1,2}(scn,1) = scn;
    Solutions{2,2}(scn,1) = ExpctdFuel;
    Solutions{3,2}(scn,1) = ExpctdGTOPEX;
    Solutions{4,2}(scn,1) = ExpctdDumpE;
    Solutions{5,2}(scn,1) = BatCAPEX;
    Solutions{6,2}(scn,1) = BatEquivDaily;
    Solutions{7,2}(scn,1) = ExpctdCOST;
    Solutions{8,2}(scn,1) = ExpctdFuel*prob.GTCostObj.mCO2/1000;
    Solutions{9,2}(scn,1) = x(end-1);
    Solutions{10,2}(scn,1) = x(end);
end
close all;
clearvars -except Solutions

save copulScen50_01.mat Solutions

figure;
bar(Solutions{9,2});grid on;
ylabel('Battery Capacity [MWh]');
xlabel('Scenarios #');
%% LOOP to test the solution variation for a specific # of scenarios
close all;
clearvars -except DataTot
tic;

dispFigs   = 0;
dispPrints = 0;
InScenNum  = 50;
InGTNum    = 4;
LoadA      = DataX(DataTot.GFA_active);
LoadC      = DataX(DataTot.GFC_active);
wind       = DataX(DataTot.Wind_Speed);

WF1 = WindFarm();

WF1.WindValue = wind.iniVec;
WF1.DoWindPower;

ResGen = DataX(WF1.WindPower);

LoadA.iniVec=LoadA.GroupSamplesBy(24);
ResGen.iniVec=ResGen.GroupSamplesBy(24);

scenGenSetLoad          = DataX();
scenGenSetWind          = DataX();
wind.iniVec=wind.GroupSamplesBy(24);


Solutions{1,1} = 'Trial Number';
Solutions{2,1} = 'Expected Fuel Consumption';
Solutions{3,1} = 'Expected GT OPEX';
Solutions{4,1} = 'Expected Dumped Enerrgy';
Solutions{5,1} = 'Battery CAPEX';
Solutions{6,1} = 'Battery Equivalent Daily';
Solutions{7,1} = 'Expected cost';
Solutions{8,1} = 'Expected CO2 emissions tn';
Solutions{9,1} = 'Battery Power MW';
Solutions{10,1} = 'Battery Capacity MWh';

for trialIndex = 1:25
    main
    Solutions{1,2}(trialIndex,1) = trialIndex;
    Solutions{2,2}(trialIndex,1) = ExpctdFuel;
    Solutions{3,2}(trialIndex,1) = ExpctdGTOPEX;
    Solutions{4,2}(trialIndex,1) = ExpctdDumpE;
    Solutions{5,2}(trialIndex,1) = BatCAPEX;
    Solutions{6,2}(trialIndex,1) = BatEquivDaily;
    Solutions{7,2}(trialIndex,1) = ExpctdCOST;
    Solutions{8,2}(trialIndex,1) = ExpctdFuel*prob.GTCostObj.mCO2/1000;
    Solutions{9,2}(trialIndex,1) = x(end-1);
    Solutions{10,2}(trialIndex,1) = x(end);
end

close all;
clearvars -except Solutions DataTot

save solVarScn50Itr10V02.mat Solutions
toc;
%}
%% LOOP to test the solution variation for DIFFERENT # of scenarios
close all;

clearvars -except DataTot
tic;

dispFigs   = 0;
dispPrints = 0;
InScenNum  = 50;
InGTNum    = 4;
riskA      = 0.9;         % Risk control parameter alpha
riskB      = 0;         % Risk control parameter beta

LoadA      = DataX(DataTot.GFA_active);
LoadC      = DataX(DataTot.GFC_active);
wind       = DataX(DataTot.Wind_Speed);

WF1 = WindFarm();

WF1.WindValue = wind.iniVec;
WF1.DoWindPower;

ResGen = DataX(WF1.WindPower);

LoadA.iniVec=LoadA.GroupSamplesBy(24);
ResGen.iniVec=ResGen.GroupSamplesBy(24);

scenGenSetLoad          = DataX();
scenGenSetWind          = DataX();
wind.iniVec=wind.GroupSamplesBy(24);

corr_load_ResGen = 0.28;
%%
Solutions{1,1} = 'Number of Scenarios';
Solutions{2,1} = 'Trial Number';
Solutions{3,1} = 'Expected Fuel Consumption';
Solutions{4,1} = 'Expected Dumped Enerrgy';
Solutions{5,1} = 'Battery CAPEX';
Solutions{6,1} = 'Battery Equivalent Daily';
Solutions{7,1} = 'Expected cost';
Solutions{8,1} = 'Expected CO2 emissions tn';
Solutions{9,1} = 'Battery Power MW';
Solutions{10,1} = 'Battery Capacity MWh';
Solutions{11,1} = 'Value at Risk';
Solutions{12,1} = 'Conditional Value at Risk';

trialCounter = 1;
scenCounter = 1;
scen = 50;
M = 25;
% for scen = 5:5:50
    InScenNum = scen;
    Solutions{1,2}(1,scenCounter) = InScenNum;
    for trialIndex = 1:M
        main
        Solutions{2,2}(trialIndex,1)             = trialIndex;
        Solutions{3,2}(trialIndex,scenCounter)  = ExpctdFuel;
        Solutions{4,2}(trialIndex,scenCounter)  = ExpctdDumpE;
        Solutions{5,2}(trialIndex,scenCounter)  = BatCAPEX;
        Solutions{6,2}(trialIndex,scenCounter)  = BatEquivDaily;
        Solutions{7,2}(trialIndex,scenCounter)  = ExpctdCOST;
        Solutions{8,2}(trialIndex,scenCounter)  = ExpctdCO2;
        Solutions{9,2}(trialIndex,scenCounter) = x(end-1);
        Solutions{10,2}(trialIndex,scenCounter) = x(end);
        Solutions{11,2}(trialIndex,scenCounter) = x(prob.VarsIndexes{2,prob.indexSetRiskEta});
        Solutions{12,2}(trialIndex,scenCounter) = x(prob.VarsIndexes{2,prob.indexSetRiskEta}) + 1/(1-prob.RiskAlpha)*LscensProbVec'*x(prob.VarsIndexes{2,prob.indexSetRiskS}:prob.VarsIndexes{2,prob.indexSetRiskS}+prob.ScenNum-1);
        trialCounter = trialCounter +1;
    end
    scenCounter = scenCounter + 1;
    trialCounter = 1;
% end

close all;
clearvars -except Solutions DataTot

% mkdir OutputFiles
FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\OutputFiles';   % Your destination folder
% outFileName01     = ['StabilityTest_',date,'-',datestr(now,'HHMMSS')];
% outFileName01     = 'StabilityTest_corellation_028';


matFileName01     = fullfile(FolderDestination,outFileName01);  
save(matFileName01,'Solutions');

toc;

%%
% 
% figure;
% bar(Solutions{pickVar,2});grid on;
% ylabel(Solutions{pickVar,1});
% xlabel('Iterations');
pickVar = 7;
% tempBox = [SolutionsNew{pickVar,2},Solutions{pickVar,2}(:,10)];
tempBox = [Solutions{pickVar,2},SolutionsNew{pickVar,2}];
figure;
boxplot(tempBox);
ylabel('Objective Value')
%% Boxplots
pickVar = 7;

figure;
set(gcf,'Name','Stabiliy Test - Boxplots','NumberTitle','off')
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
% xlabel('Scenarios #');
ax1=gca;
ax1.YAxis.Label.Interpreter = 'latex';
ax1.YAxis.Label.String ='$\it F \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega)$';
ax1.YAxis.Color = 'black';
ax1.YAxis.FontSize  = 24;
ax1.YAxis.FontName = 'Times New Roman';

ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String ='$\vert \Omega_s \vert$';
ax1.XLabel.Color = 'black';
ax1.FontSize  = 24;
ax1.FontName = 'Times New Roman';

ax1.XGrid = 'on';
ax1.YGrid = 'off';

%{
figure;
set(gcf,'Name','Stabiliy Test - Min Max Range','NumberTitle','off')
plot(1:length(Solutions{1,2}),minmaxRange,'-k','LineWidth',1.5);
ax = gca;
ax.XTickLabel = gtemp2;
ax.XLabel.Interpreter = 'tex';
ax.XLabel.String = 'Scenarios';
ax.XLabel.Color = 'black';
ax.XLabel.FontSize  = 12;
ax.XLabel.FontName = 'Times New Roman';
ax.XLabel.FontWeight = 'bold';
ax.YLabel.Interpreter = 'tex';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.YLabel.String = 'Max-Min range';

figure;
set(gcf,'Name','Stabiliy Test - Quantlies Range','NumberTitle','off')
plot(1:length(Solutions{1,2}),quantilesRange,'-k','LineWidth',1.5);
ax = gca;
ax.XTickLabel = gtemp2;
ax.XLabel.Interpreter = 'tex';
ax.XLabel.String = 'Scenarios';
ax.XLabel.Color = 'black';
ax.XLabel.FontSize  = 12;
ax.XLabel.FontName = 'Times New Roman';
ax.XLabel.FontWeight = 'bold';
ax.YLabel.Interpreter = 'tex';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.YLabel.String = ['\bf{Quantiles} \rm', '(25%-75%) range'];

figure;
set(gcf,'Name','Stabiliy Test - Standard Deviations','NumberTitle','off')
plot(1:length(Solutions{1,2}),standatrdDeviations,'-k','LineWidth',1.5);
ax = gca;
ax.XTickLabel = gtemp2;
ax.XLabel.Interpreter = 'tex';
ax.XLabel.String = 'Scenarios';
ax.XLabel.Color = 'black';
ax.XLabel.FontSize  = 12;
ax.XLabel.FontName = 'Times New Roman';
ax.XLabel.FontWeight = 'bold';
ax.YLabel.Interpreter = 'tex';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.YLabel.String = 'Standard Deviation';
%}
A =[minmaxRange;quantilesRange;standatrdDeviations];

figure;
set(gcf,'Name','Stabiliy Test Statistics','NumberTitle','off')
plot(1:length(Solutions{1,2}),minmaxRange,'-r','LineWidth',1.5);hold on;
yyaxis right;
plot(1:length(Solutions{1,2}),quantilesRange,'-g','LineWidth',1.5);
plot(1:length(Solutions{1,2}),standatrdDeviations,'-b','LineWidth',1.5);
ax1 = gca;
ax1.XTickLabel = gtemp2;
ax1.XLabel.Interpreter = 'latex';
ax1.XLabel.String = '$\vert \Omega_s \vert$';
ax1.XLabel.Color = 'black';
% ax1.XLabel.FontSize  = 24;
ax1.FontSize  = 24;
ax1.XLabel.FontName = 'Times New Roman';
ax1.XLabel.FontWeight = 'bold';
% ax1.XLim = [5,50];
ax1.YAxis(1).FontSize  = 24;
ax1.YAxis(2).FontSize  = 24;
ax1.YAxis(1).Label.Interpreter = 'latex';
ax1.YAxis(2).Label.Interpreter = 'latex';
ax1.YAxis(1).Label.String = '$Rg$';
ax1.YAxis(1).Limits = [min(A,[],'all'),max(A,[],'all')];
ax1.YAxis(2).Limits = [min(A,[],'all'),max(A,[],'all')];
ax1.XGrid = 'on';
ax1.YGrid = 'on';
ax1.YAxis(2).Color = 'k'; 
ax1.YAxis(2).Label.String = '$Q^{25-75} \;/ \; \sigma$';
legend(ax1,{'$Rg(\it F \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega) \rm \big \vert \vert \Omega_s \vert)$','$Q^{25-75}(\it F \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega) \rm \big \vert \vert \Omega_s \vert)$','$\sigma (\it F \rm (\bf x \, ; \, \bf \tilde{\bf \xi}_\omega) \rm \big \vert \vert \Omega_s \vert)$'},'FontSize',16,...
    'Fontname','Times New Roman','interpreter','latex','Location','northeast');
hold off;
%% Boxplots for methods comparison
pickVar = 7;

myFigs.boxPltComp.figWidth = 7; myFigs.boxPltComp.figHeight = 5;
myFigs.boxPltComp.figBottomLeftX0 = 2; myFigs.boxPltComp.figBottomLeftY0 =2;

myFigs.boxPltComp.fig = figure('Name','Compare - Boxplots','NumberTitle','off','Units','inches',...
'Position',[myFigs.boxPltComp.figBottomLeftX0 myFigs.boxPltComp.figBottomLeftY0 myFigs.boxPltComp.figWidth myFigs.boxPltComp.figHeight],...
'PaperPositionMode','auto');

% figure;
% set(gcf,'Name','Stabiliy_Test_Comparison_Boxplots','NumberTitle','off')

% xsolBox= [Solutions_fixed{pickVar,2},Solutions_perm{pickVar,2},...
%     Solutions_red{pickVar,2},Solutions_clust{pickVar,2},Solutions_prop{pickVar,2}(:,10),Solutions_prop_rng{pickVar,2}];

xsolBox= [Solutions_fixed{pickVar,2},Solutions_perm{pickVar,2},...
    Solutions_red{pickVar,2},Solutions_clust{pickVar,2},Solutions_corr_028{pickVar,2},Solutions_prop{pickVar,2}(:,10)];

% gtemp = {'Data';'Random';'FFS';...
%     'H-cl';'Proposed';'Prop-rng'};

gtemp = {'Data';'Random';'FFS';...
    'H-cl';'SetCorr';'Proposed'};

for i =1:6   
    boxMedians(i) = median(xsolBox(:,i));
    minmaxRange(i) = max(xsolBox(:,i))-min(xsolBox(:,i));
    quantilesRange(i) = quantile(xsolBox(:,i),0.75)-quantile(xsolBox(:,i),0.25);
    standatrdDeviations(i) = std(xsolBox(:,i));
end
 
% xsolTbl = table(boxMedians',minmaxRange',quantilesRange',standatrdDeviations',...
%     'VariableNames',{'Median','Range','Quantiles','Std'},'RowNames',{'Data';'Random';'FFS';'H-cl';'Proposed';'Prop-rng'});
xsolTbl = table(boxMedians',minmaxRange',quantilesRange',standatrdDeviations',...
    'VariableNames',{'Median','Range','Quantiles','Std'},'RowNames',{'Data';'Random';'FFS';'H-cl';'SetCorr';'Proposed'});

boxplot(xsolBox,gtemp,'Symbol','r')
% ylabel(Solutions_prop{pickVar,1});
myFigs.boxPltComp.ax1=gca;
myFigs.boxPltComp.ax1.YAxis.Label.Interpreter = 'latex';
myFigs.boxPltComp.ax1.YAxis.Label.String ='$\it F \rm (\bf x \, ; \, \rm \Omega_s) $';
myFigs.boxPltComp.ax1.YAxis.Color = 'black';
myFigs.boxPltComp.ax1.YAxis.FontSize  = 16;
myFigs.boxPltComp.ax1.YAxis.FontName = 'Times New Roman';
myFigs.boxPltComp.ax1.YAxis.Exponent = 0;
myFigs.boxPltComp.ax1.YLim = [35000 95000];

myFigs.boxPltComp.ax1.YAxis.Label.FontName = 'Times New Roman';

myFigs.boxPltComp.ax1.XLabel.Interpreter = 'latex';
myFigs.boxPltComp.ax1.XLabel.String ='\it method';
myFigs.boxPltComp.ax1.XLabel.Color = 'black';
myFigs.boxPltComp.ax1.XAxis.FontSize  = 16;
myFigs.boxPltComp.ax1.XAxis.FontName = 'Times New Roman';
myFigs.boxPltComp.ax1.XLabel.FontName = 'Times New Roman';
myFigs.boxPltComp.ax1.TickLabelInterpreter  = 'latex';

myFigs.boxPltComp.ax1.XGrid = 'on';
myFigs.boxPltComp.ax1.YGrid = 'off';
%% To create Matrixes for LateX
% rowNames ={'LHV [kJ/kg]','NG sale value [\euro /$m^3$]','Fuel2Co2 [-]',...
%     'CO2 Tax [\euro /kgCO2]','Max GT [MW]','Min GT [MW]',...
%     'GT a [kgFuel/MW]','GT b [kgFuel/h]','O\&M cost [\euro /MW]',...
%     'Investement Lifetime L [years]','Interest rate r [\%]',...
%     'Ce [\euro /kWh]','Cp [\euro /kW]','Max GT RampingRate [MW/h]',...
%     'Min GT ON time[h]','Min GT OFF time [h]','Max Battery Power [MW]',...
%     'Max Battery RampingRate [MW/h]','Initial battery SoC [\%]',...
%     'Max battery DoD [\%]','Cost per fuel [\euro /kgFuel]',...
%     'Cost per MWh [\euro /MWh]','Cost GT No load [\euro /h]',...
%     'GT startup cost [\euro /start]'}
% vectorMatrix = [44.19;0.2136;2.53;0.07;20.2;4.04;172.5;729.2;1.67;8;7;...
%     178;89;20.2;0;3;5;5;0;100;0.475;83.6121;346.3568;242.4498];
% matrix2latex(vectorMatrix, 'Parameters.tex','rowLabels',...
%     rowNames,'alignment', 'c', 'format', '%-6.2f');