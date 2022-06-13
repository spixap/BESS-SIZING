%-----CREATE GUROBI MODEL & CALL SOLVER-----

%--- DESCRIPTION:{
% Create the optimization problem to input at GUROBI optimizer and return
% the optimal solution, if the problem is feasible
%..................................................................}
% ------- Uncomment to run stability test with mainnLOOP.m -------------
clearvars -except DataTot dispFigs dispPrints Solutions InScenNum InGTNum...
    LoadA ResGen scn wind scenGenSetLoad scenGenSetWind WF1 trialIndex riskA riskB ...
    scenCounter trialCounter corr_load_ResGen

%% ---------- Keep as comments for multiple runs (mainLOOP.m) -------------
%
tic;toc;
tic;
close all;
clearvars -except DataTot 
dispFigs    = 0;            % 1: YES | 0: NO
dispPrints  = 1;            % 1: YES | 0: NO
InScenNum   = 50;
InGTNum     = 4;
riskA       = 0.8;         % Risk control parameter alpha
riskB       = 0;           % Risk control parameter beta

LoadA = DataX(DataTot.GFA_active);      % LOAD OF PLATFROM A timeseries
LoadC = DataX(DataTot.GFC_active);      % LOAD OF PLATFROM B timeseries
wind  = DataX(DataTot.Wind_Speed);      % WIND timeseries
WF1   = WindFarm();                     % Define a WIND FARM

LoadA.iniVec    = LoadA.GroupSamplesBy(24);
scenGenSetLoad  = DataX();

%----------------- USE IF I HAVE DIRECTLY WIND POWER DATA -----------------
%{
% WF1.WindValue = wind.iniVec;
% WF1.DoWindPower;
% ResGen = DataX(WF1.WindPower);
% ResGen.iniVec=ResGen.GroupSamplesBy(24);
% scenGenSetResGen        = DataX();
%}
%--------------------------------------------------------------------------

scenGenSetWind  = DataX();
wind.iniVec     = wind.GroupSamplesBy(24);
%}
%% ----------------- Universal code (1 or many runs) ----------------------
% ------- Uncomment if i want to use the PROPOSED METHODOLOGY -------------
%
% ///STEP 1: Generate scenarios from estimated Copula
rng(trialIndex);
scenGenSetLoad.iniVec   = LoadA.DoCopula(1000,2);
scenGenSetWind.iniVec   = wind.DoCopula(1000,2);
% scenGenSetResGen.iniVec = ResGen.DoCopula(1000,1);
scenGenSetWind.iniVec   = scenGenSetWind.UnGroupSamples;
WF1.WindValue           = scenGenSetWind.iniVec;
WF1.DoWindPower;
scenGenSetResGen        = DataX(WF1.WindPower);
scenGenSetResGen.iniVec = scenGenSetResGen.GroupSamplesBy(24);

%-----------------------------(NOT USED) ----------------------------------
% ///STEP 2: Reduce scenario set 
% [LredScens,~,z3]=scenGenSetLoad.ReduceScenariosBy(0,999);
% [ResredScens,~,z6]=scenGenSetResGen.ReduceScenariosBy(0,999);
% 
% LredScensX = DataX(LredScens);
% LredScensX.iniVec=LredScensX.GroupSamplesBy(24);
% 
% ResredScensX = DataX(ResredScens);
% ResredScensX.iniVec=ResredScensX.GroupSamplesBy(24);
%--------------------------------------------------------------------------

% ///STEP 3: Perform ranking, mapping and clustering of the scenario data points
% [coords,points,ResselScens,LselScens,LscensProbVec,MapData]=KantorMap2D(scenGenSetResGen,scenGenSetLoad,InScenNum);
%}
%% Calculate Load vs Wind profiles correlation and find the closes to 0.28
iCorr = zeros(length(scenGenSetLoad.iniVec),1);
% LscensProbVec = zeros(InScenNum,1);
weights = zeros(InScenNum,1);
tempLoadX   = DataX();
tempResGenX = DataX();
for iSample = 1 : length(scenGenSetLoad.iniVec)
    iCorr(iSample) = corr(scenGenSetLoad.iniVec(:,iSample),scenGenSetResGen.iniVec(:,iSample));
end
iCorr_dist = abs(iCorr - corr_load_ResGen);
[iCorr_dist_sorted, iCorr_dist_sorted_IDX ] = sort(iCorr_dist);
for s = 1 : InScenNum
    tempLoadX.iniVec(:,s)   = scenGenSetLoad.iniVec(:,iCorr_dist_sorted_IDX(s));
    tempResGenX.iniVec(:,s) = scenGenSetResGen.iniVec(:,iCorr_dist_sorted_IDX(s));
%     LscensProbVec(s,1) = 1/InScenNum;
    weights(s,1) = 1/iCorr_dist_sorted(s);

end
weightTotal = sum(weights);
LscensProbVec = weights./weightTotal;
LselScens   = tempLoadX.UnGroupSamples;
ResselScens = tempResGenX.UnGroupSamples;
%% ------ Uncomment if i want to use the random direct DATA samples --------
%{
% rng('default')
rng(trialIndex);
scenGenSetResGen = DataX();
% r = randi([1,size(LoadA.iniVec,2)],InScenNum,1);
rL = randi([1,size(LoadA.iniVec,2)],InScenNum,1);
rW = randperm(size(LoadA.iniVec,2),InScenNum)';
for s = 1 : InScenNum
%     scenGenSetLoad.iniVec(:,s)   = LoadA.iniVec(:,r(s));
%     scenGenSetResGen.iniVec(:,s) = ResGen.iniVec(:,r(s));
    scenGenSetLoad.iniVec(:,s)   = LoadA.iniVec(:,rL(s));
    scenGenSetResGen.iniVec(:,s) = ResGen.iniVec(:,rW(s));
    LscensProbVec(s,1) = 1/InScenNum;
end
LselScens   = scenGenSetLoad.UnGroupSamples;
ResselScens = scenGenSetResGen.UnGroupSamples;
%}
%% ///STEP 4: Save the .mat file containting the scenarios to be used in the optimization problem
%{
FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\OOP_trial_3\OutputFiles';   % Your destination folder
outFileName01     = ['Generated',num2str(InScenNum),'Scenarios_',date,'-',datestr(now,'HHMMSS')];
matFileName01     = fullfile(FolderDestination,outFileName01);  
save(matFileName01,'ResselScens','LselScens','LscensProbVec','MapData');
%}
%% -------- Uncomment if i want to reduce scenarios from a set ------------
%{
[LredScens,LRedScensProbVec,z3]=LoadA.ReduceScenariosBy(0,InScenNum);
[ResredScens,ResRedScensProbVec,z6]=ResGen.ReduceScenariosBy(0,InScenNum);

scenGenSetLoad = DataX(LredScens);
scenGenSetLoad.iniVec = scenGenSetLoad.GroupSamplesBy(24);

scenGenSetResGen = DataX(ResredScens);
scenGenSetResGen.iniVec = scenGenSetResGen.GroupSamplesBy(24);

rng(trialIndex);
rL = randi([1,InScenNum],InScenNum,1);
rW = randperm(InScenNum,InScenNum)';
for s = 1 : InScenNum
    scenGenSetLoad.iniVec(:,s)   = scenGenSetLoad.iniVec(:,rL(s));
    scenGenSetResGen.iniVec(:,s) = scenGenSetResGen.iniVec(:,rW(s));
    LscensProbVec(s,1) = LRedScensProbVec(rL(s))*ResRedScensProbVec(rW(s));
end
LselScens   = scenGenSetLoad.UnGroupSamples;
ResselScens = scenGenSetResGen.UnGroupSamples;

LscensProbVec = LscensProbVec./sum(LscensProbVec);
%}
%% ---------- Uncomment if i want to perform self-clustering --------------
%{
[clusterdLoad,centroidScensL,centroidProbsL]    = LoadA.SelfClusterData(InScenNum,2);
[clusterdRes,centroidScensRes,centroidProbsRes] = ResGen.SelfClusterData(InScenNum,2);

centroidScensLX = DataX(centroidScensL);
centroidScensResX = DataX(centroidScensRes);

rng(trialIndex);
rL = randi([1,InScenNum],InScenNum,1);
rW = randperm(InScenNum,InScenNum)';
for s = 1 : InScenNum
    centroidScensLX.iniVec(:,s)   = centroidScensLX.iniVec(:,rL(s));
    centroidScensResX.iniVec(:,s) = centroidScensResX.iniVec(:,rW(s));
    LscensProbVec(s,1) = centroidProbsL(rL(s))*centroidProbsRes(rW(s));
end
LselScens   = centroidScensLX.UnGroupSamples;
ResselScens = centroidScensResX.UnGroupSamples;

LscensProbVec = LscensProbVec./sum(LscensProbVec);
%}
%% -------------- Uncomment to define mean scenario -----------------------
%{
%  LoadAveT   = zeros(size(LoadA.iniVec,1),1);
%  ResGenAveT = zeros(size(ResGen.iniVec,1),1);
% for i=1:size(LoadA.iniVec,1)
%     LoadAveT(i,1)   = mean(LoadA.iniVec(i,:));
%     ResGenAveT(i,1) = mean(ResGen.iniVec(i,:));
% end

pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(24);
resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(24);

figure;


LoadAveT   = zeros(size(pltLoad.iniVec,1),1);
ResGenAveT = zeros(size(resG.iniVec,1),1);
for i=1:size(pltLoad.iniVec,1)
    LoadAveT(i,1)   = mean(pltLoad.iniVec(i,:));
    ResGenAveT(i,1) = mean(resG.iniVec(i,:));
end
LselScens     = LoadAveT;
ResselScens   = ResGenAveT;
LscensProbVec = 1;
%}
%% Optimization Problem for the whole scenarios set
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

% LscensProbVec(1:InScenNum,1) =1/InScenNum;
prob.defineAineqANDbineq(LscensProbVec);
A       = prob.Aineq;
bineq   = prob.bineq;

prob.defineObjFun(LscensProbVec);
f       = prob.costCoef;

intcon  = prob.intDeclare;
% ------------------------------ GURBOI SOLVER ----------------------------
str1(1:size(A,1))         = '<';
str2(1:size(Aeq,1))       = '=';
str                       = strcat(str1,str2);
% A = single(A);
% Aeq = single(Aeq);
% A_gur = zeros(size(A,1)+size(Aeq,1),size(A,2));

% for i=1:(size(A,1)+size(Aeq,1))
%     for j=1:size(A,2)
%         if i<=(size(A,1))
%             A_gur(i,j)=A(i,j);
%         else
%             A_gur(i,j)=Aeq(i-size(A,1),j);
%         end
%     end
% end

A_gur                     = cat(1,A,Aeq);
% A_gur                     = [A;Aeq];
cost_gur                  = f;
b_gur                     = cat(1,bineq,beq);
% b_gur                     = [bineq;beq];
vartypes_gur(1:size(A,2)) = 'C';
vartypes_gur(intcon)      = 'B';

model.A          = sparse(A_gur);
% model.A          = A_gur;
model.rhs        = b_gur;
model.lb         = lb;
model.ub         = ub;
model.obj        = cost_gur;
model.modelsense = 'Min';
model.vtype      = vartypes_gur;

model.sense      = str;

% params.resultfile = 'SPI1.lp';

% params.MIPFocus  = 3;

params.MIPGap=0.0017;

params.TimeLimit = 5*60;


% params.Method=-1;
% params.SolutionLimit = 100000;
% params.NodeLimit = 100000;
% params.Cutoff=11200;
% params.MIPGap=0.0005;

% Set poolsearch parameters
% params.PoolSolutions  = 1024*100;
% params.PoolGap        = 0.001;
% params.PoolSearchMode = 2;

% params.NumStart = 100000;
% params.StartNodeLimit = 1000000;
% params.StartNumber = 10000;

% params.Presolve = 0;
% params.SubMIPNodes = 10;






% params.Heuristics = 0;
% params.SubMIPNodes = 300;
% params.Threads = 1;

%----------------- Provide Initial Feasible Solution ----------------------
% g        = (comp+1);
% u1       = (2*comp+1);
% jgt      = 1;
% jdum     = 1;
% dayCheck = 1;
% 
% for b=1:comp*num_vars:num_vars*N*comp
%     g=(comp+1)+(dayCheck-1)*comp*num_vars;
%     u1=(2*comp+1)+(dayCheck-1)*comp*num_vars;                    % 1st index of Ugt for each scenario (day)
%     d=(3*comp+1)+(dayCheck-1)*comp*num_vars;
%     
%     model.start(b:b+(comp-1))   = 0;
%     model.start(g:g+(comp-1))   = PgtNoBatLim(jgt:jgt+(comp-1));
%     model.start(u1:u1+(comp-1)) = 1;
%     model.start(d:d+(comp-1))   = Residual(jdum:jdum+(comp-1));
%     
%     jgt=jgt+24;
%     jdum=jdum+24;
%     dayCheck=dayCheck+1; % Next Scenario (Day)
% end
% 
% model.start(num_vars*N*comp+2-1) = 0;
% model.start(num_vars*N*comp+2)   = 0;
%----------------- End Initial Feasible Solution --------------------------

%---------------------------SOLVER-----------------------------------------
res_gur = gurobi(model,params);
% res_gur = gurobi(model);

%-----CHECK FOR FEASBILITY OF SOLUTION-----
checkfeasi = res_gur.status;
feas       = isequal(checkfeasi, 'INFEASIBLE');
if feas == 1
    disp('EXECUTION STOPPED! : The problem is infeasible.');
    return
end
%-----END CHECK-----

x = res_gur.x;

[ExpctdFuel,ExpctdCO2,ExpctdDumpE,BatCAPEX,BatEquivDaily,ExpctdCOST] =...
    prob.retrieveOptResults(LscensProbVec,x,LselScens,ResselScens);

% Results
allScensResults.Name          = ['Results for ',num2str(InScenNum),' scenarios'];
allScensResults.BESScapex     = BatCAPEX;
allScensResults.CostXdecision = BatEquivDaily;
allScensResults.yCosts        = prob.costOfEachScen;
allScensResults.yFuel         = prob.fuelConsuptionTotalScen;
allScensResults.yDump         = prob.dumpedTotalEnergyScen;
allScensResults.totalCost     = ExpctdCOST;
allScensResults.CO2emissions  = ExpctdCO2;
allScensResults.DumpedEn      = ExpctdDumpE;
allScensResults.VaR           = x(prob.VarsIndexes{2,prob.indexSetRiskEta});
allScensResults.CVaR          = allScensResults.VaR + 1/(1-prob.RiskAlpha)*LscensProbVec'*x(prob.VarsIndexes{2,prob.indexSetRiskS}:prob.VarsIndexes{2,prob.indexSetRiskS}+prob.ScenNum-1);

toc;
%% ---------- Uncomment if i want to create Risk-cdf plot -----------------
%{
clearvars -except DataTot LselScens ResselScens LscensProbVec InGTNum...
allScensResults prob x InScenNum
dispFigs    = 0;
dispPrints  = 0;
LselScensX = DataX(LselScens);
LselScensX.iniVec = LselScensX.GroupSamplesBy(24);
ResselScensX = DataX(ResselScens);
ResselScensX.iniVec = ResselScensX.GroupSamplesBy(24);
LselScensX.figControl = 0;ResselScensX.figControl = 0;
% clear LselScens ResselScens
% LscensProbVec = 1;
% scenCost = zeros(size(LselScensX,2),1);
scenResult.scenName = 'Cost of each scenario';
for picedkScen = 1:size(LselScensX.iniVec,2)
    scenResult.scenProb(picedkScen) = LscensProbVec(picedkScen);
    LselScens1   = LselScensX.PickScenario(picedkScen);
    ResselScens1 = ResselScensX.PickScenario(picedkScen);
    
%     Run1ScenOptim;
% 
%     scenResult.scenCost(picedkScen)= ExpctdCOST;
%     scenResult.scenCost(picedkScen)= ExpctdCOST-BatEquivDaily+allScensResults.CostXdecision;
    scenResult.scenCostTrue(picedkScen)= allScensResults.yCosts(picedkScen);
end
[riskPlot.sortedCosts,riskPlot.I] = sort(scenResult.scenCostTrue);
riskPlot.tempSum = zeros(length(riskPlot.sortedCosts),1);
riskPlot.scat = zeros(1,length(riskPlot.sortedCosts)+1);

figure;
set(gcf,'Name','Cumulative Distribution Function of Cost','NumberTitle','off')
hold on;
grid on;
for i=1:length(riskPlot.sortedCosts)
%     riskPlot.tempSum(i) = sum(LscensProbVec(1:i));
    riskPlot.tempSum(i) = sum(LscensProbVec(riskPlot.I(1:i)));
    riskPlot.scat(i) = stem(riskPlot.sortedCosts(i),riskPlot.tempSum(i),'filled','--s',...
        'DisplayName',['Scenario # ',num2str(riskPlot.I(i))]);

%         riskPlot.scat(i) = stem(riskPlot.sortedCosts(i),LscensProbVec(i),'filled','--s',...
%         'DisplayName',['Scenario # ',num2str(riskPlot.I(i))]);
end
riskPlot.scat(i+1)=scatter(allScensResults.totalCost,0,130,'pk','filled','DisplayName','Expected Solution');
text(allScensResults.totalCost,0.1,num2str(allScensResults.totalCost),'Fontsize', 12);

riskPlot.scat(i+2)=scatter(allScensResults.VaR,0,130,'+','MarkerEdgeColor','k','LineWidth',1.8,'DisplayName','VaR');
riskPlot.scat(i+3)=scatter(allScensResults.CVaR,0,130,'sk','filled','DisplayName','CVaR');
text(allScensResults.CVaR,0.1,num2str(allScensResults.CVaR),'Fontsize', 12);

stairs(riskPlot.sortedCosts,riskPlot.tempSum,'k');

scatter(riskPlot.sortedCosts,zeros(1,length(riskPlot.sortedCosts)),'*k');
ax = gca;
xlabel(scenResult.scenName);ylabel('CDF of scenarios');
xtickformat('eur');
ax.XAxis.Exponent = 0;
title(['$\beta$=' num2str(prob.RiskBeta)],'Interpreter','latex');
legend(riskPlot.scat(1:length(riskPlot.sortedCosts)+3),'Location','northwest');
hold off;

%/// Save the .mat file containting the risk plot
FolderDestination = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\OOP_trial_3\OutputFiles';   % Your destination folder
outFileName02     = ['Scens',num2str(InScenNum),'a08','b0','_',date,'-',datestr(now,'HHMMSS')];
% outFileName02     = ['ESSlife12_',date,'-',datestr(now,'HHMMSS')];
matFileName02     = fullfile(FolderDestination,outFileName02);  
save(matFileName02,'riskPlot','LscensProbVec','allScensResults','x');

%}
%..................................................................}
%% Appendix-1: Save produced figures
%{
% mkdir FigOutTest
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\OutputFigures';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
%       FigName   = num2str(get(FigHandle, 'Number'));
    FigName   = get(FigHandle,'Name');
%     set(0, 'CurrentFigure', FigHandle);
%     savefig(fullfile(FolderName, [FigName '.fig']));
    print(FigHandle, fullfile(FolderName, [FigName '.png']), '-r300', '-dpng')
end
%}