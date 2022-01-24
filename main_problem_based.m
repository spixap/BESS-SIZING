%-----CREATE GUROBI MODEL & CALL SOLVER-----

%--- DESCRIPTION:{
% Create the optimization problem to input at GUROBI optimizer and return
% the optimal solution, if the problem is feasible
%..................................................................}
% clearvars -except DataTot dispFigs dispPrints Solutions InScenNum InGTNum...
%     LoadA ResGen scn wind scenGenSetLoad scenGenSetWind WF1 trialIndex

%% ---------- Keep as comments for multiple runs (mainLOOP.m) -------------
%
tic;toc;
tic;
close all;
clearvars -except DataTot spi
dispFigs    = 1;            % 1: YES | 0: NO
dispPrints  = 1;            % 1: YES | 0: NO
InScenNum   = 5;
InGTNum     = 4;
riskA       = 0.8;         % Risk control parameter alpha
riskB       = 0;           % Risk control parameter beta
MIPGap      = 0.0017;

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
% ------- Uncomment if i want to use the combined methodology -------------

% ///STEP 1: Generate scenarios from estimated Copula
scenGenSetLoad.iniVec   = LoadA.DoCopula(1000,2);
scenGenSetWind.iniVec   = wind.DoCopula(1000,2);
% scenGenSetResGen.iniVec = ResGen.DoCopula(1000,1);
scenGenSetWind.iniVec   = scenGenSetWind.UnGroupSamples;
WF1.WindValue           = scenGenSetWind.iniVec;
WF1.DoWindPower;
scenGenSetResGen        = DataX(WF1.WindPower);
scenGenSetResGen.iniVec = scenGenSetResGen.GroupSamplesBy(24);
%% --------------------\\ Optimization Problem \\--------------------------
prob = optimproblem('ObjectiveSense','minimize');
% Sets
Toff = 4;
T    = 24;
W    = InScenNum;
N_G  = InGTNum;
% -------------------\\ Optimization Parameters \\-------------------------
% Parameters
P_g_max  = 20.20;
P_g_min  = 0.2*P_g_max;
R        = P_g_max;
C_gt_p   = 89;
C_gt_on  = 354;
C_gt_srt = 1217;
C_b_P    = 30;
C_b_E    = 2*C_b_P;
C_b      = [C_b_P C_b_E];
C_gt     = [C_gt_p C_gt_on C_gt_srt];

E_B_0    = 0;
P_B_max  = 5;
E_B_max  = 10;
E_B_min  = 0;

cvar_a   = riskA;
cvar_b   = riskB;

% Scenario Propabilities
pr_w = 1/W;

% Stochastic parameters (data)
pltLoad  = DataX(LselScens);
pltLoad.iniVec=pltLoad.GroupSamplesBy(T);

resG     = DataX(ResselScens);
resG.iniVec=resG.GroupSamplesBy(T);

xi.L = pltLoad.iniVec;
xi.W = resG.iniVec;

% -------------------\\ Optimization Variables \\--------------------------
% First stage
x_b_P = optimvar('x_b_P','LowerBound',0,'UpperBound',P_B_max);
x_b_E = optimvar('x_b_E','LowerBound',E_B_min,'UpperBound',E_B_max);
% Second stage
P_gt = optimvar('P_gt',T,W,N_G,'LowerBound',0,'UpperBound',P_g_max);
u_gt = optimvar('u_gt',T,W,N_G,'Type','integer','LowerBound',0,'UpperBound',1);
z_gt = optimvar('z_gt',T,W,N_G,'Type','integer','LowerBound',0,'UpperBound',1);

P_b = optimvar('P_b',T,W,'LowerBound',-P_B_max,'UpperBound',P_B_max);
P_d = optimvar('P_d',T,W,'LowerBound',0);
% Risk related
cvar_s = optimvar('cvar_s',W,'LowerBound',0);
cvar_zeta = optimvar('cvar_zeta','LowerBound',0);

indexNames_t = cell(T,1,1);
indexNames_w = cell(1,W,1);
indexNames_g = cell(1,1,N_G);
for t=1:T
    indexNames_t{t,1,1} = append('hour_',int2str(t));
end
for w=1:W
    indexNames_w{1,w,1} = append('scen_',int2str(w));
end
for g=1:N_G
    indexNames_g{1,1,g} = append('gen_',int2str(g));
end
P_gt.IndexNames{1}   = indexNames_t;P_gt.IndexNames{2} = indexNames_w;P_gt.IndexNames{3} = indexNames_g;
u_gt.IndexNames{1}   = indexNames_t;u_gt.IndexNames{2} = indexNames_w;u_gt.IndexNames{3} = indexNames_g;
z_gt.IndexNames{1}   = indexNames_t;z_gt.IndexNames{2} = indexNames_w;z_gt.IndexNames{3} = indexNames_g;
P_b.IndexNames{1}    = indexNames_t;P_b.IndexNames{2} = indexNames_w;
P_d.IndexNames{1}    = indexNames_t;P_d.IndexNames{2} = indexNames_w;
cvar_s.IndexNames{1} = indexNames_w;

% -------------------\\ Optimization Objective \\--------------------------
% f    = C_b*[x_b_P;x_b_E]+sum(pr_w*sum(sum(C_gt_p*P_gt+C_gt_on*u_gt+C_gt_srt*z_gt)));
% cvar = cvar_zeta + (1/(1-cvar_a))*sum(pr_w*cvar_s);
for w = 1:W
    index_w = append('scen_',int2str(w));
    y_w(w)  = LscensProbVec(w)*C_gt*[sum(sum(P_gt(:,index_w,:)));sum(sum(u_gt(:,index_w,:)));sum(sum(z_gt(:,index_w,:)))];
end
cvar = cvar_zeta + (1/(1-cvar_a))*sum(pr_w*cvar_s);
f = C_b*[x_b_P;x_b_E]+sum(y_w);
F    = (1-cvar_b)*f+cvar_b*cvar;
prob.Objective = F;
% -------------------\\ Optimization Constraints \\------------------------
% Power Balance constraints
for w = 1:W
    for t = 1:T
        index_w = append('scen_',int2str(w));
        index_t = append('hour_',int2str(t));
        powBalanceCnstr(t,w) = sum(P_gt(index_t,index_w,:)) + P_b(t,w) - P_d(t,w) == xi.L(t,w) - xi.W(t,w);       
    end
end
prob.Constraints.powBalanceCnstr = powBalanceCnstr;

% Minimum OFF time constraints
for g = 1:N_G
    for w = 1:W
        for t = 2:T
            k = (t+1:min(t+Toff-1,T));
            for k = t+1:min(t+Toff-1,T)
                index_g = append('gen_',int2str(g));
                index_w = append('scen_',int2str(w));
                index_k = append('hour_',int2str(k));
                index_t = append('hour_',int2str(t));
                index_t_prev = append('hour_',int2str(t-1));
                minOffTimeCnstr(k,t,w,g) = u_gt(index_t_prev,index_w,index_g) - u_gt(index_t,index_w,index_g) <= 1 - u_gt(index_k,index_w,index_g);
            end
        end
    end
end
prob.Constraints.minOffTimeCnstr = minOffTimeCnstr;

% StartUP constraints
for g = 1:N_G
    for w = 1:W
        for t = 2:T
            index_g = append('gen_',int2str(g));
            index_w = append('scen_',int2str(w));
            index_t = append('hour_',int2str(t));
            index_t_prev = append('hour_',int2str(t-1));
            strtUPCnstr(t,w,g) = u_gt(index_t,index_w,index_g) - u_gt(index_t_prev,index_w,index_g) <= z_gt(index_t,index_w,index_g);
        end
    end
end
prob.Constraints.strtUPCnstr = strtUPCnstr;

% GT power constraints
for g = 1:N_G
    for w = 1:W
        for t = 1:T
            index_g = append('gen_',int2str(g));
            index_w = append('scen_',int2str(w));
            index_t = append('hour_',int2str(t));
            maxPowGTCnstr(t,w,g) = P_gt(index_t,index_w,index_g) <= u_gt(index_t,index_w,index_g)*P_g_max;
            minPowGTCnstr(t,w,g) = P_gt(index_t,index_w,index_g) >= u_gt(index_t,index_w,index_g)*P_g_min;
        end
    end
end
prob.Constraints.maxPowGTCnstr = maxPowGTCnstr;
prob.Constraints.minPowGTCnstr = minPowGTCnstr;

% GT ramp rate constraints
for g = 1:N_G
    for w = 1:W
        for t = 2:T
            index_g = append('gen_',int2str(g));
            index_w = append('scen_',int2str(w));
            index_t = append('hour_',int2str(t));
            index_t_prev = append('hour_',int2str(t-1));
            rampUpPowGTCnstr(t,w,g) = P_gt(index_t,index_w,index_g)-P_gt(index_t_prev,index_w,index_g) <= R;
            rampDownPowGTCnstr(t,w,g) = P_gt(index_t,index_w,index_g)-P_gt(index_t_prev,index_w,index_g) >= -R;
        end
    end
end
prob.Constraints.rampUpPowGTCnstr = rampUpPowGTCnstr;
prob.Constraints.rampDownPowGTCnstr = rampDownPowGTCnstr;

% Battery capacity constraints
for w = 1:W
    index_w = append('scen_',int2str(w));
    for t = 1:T
        index_t = append('hour_',int2str(t));
        maxSOCCnstr(t,w) = E_B_0 + sum(P_b(1:t,index_w)) <= x_b_E;
        minSOCCnstr(t,w) = E_B_0 + sum(P_b(1:t,index_w)) >= E_B_min;
    end
end
prob.Constraints.maxSOCCnstr = maxSOCCnstr;
prob.Constraints.minSOCCnstr = minSOCCnstr;

% Battery power constraints
for w = 1:W
    index_w = append('scen_',int2str(w));
    for t = 1:T
        index_w = append('scen_',int2str(w));
        index_t = append('hour_',int2str(t));
        batUpPowCnstr(t,w) = P_b(index_t,index_w) <= x_b_P;
        batLowPowCnstr(t,w)= P_b(index_t,index_w) >= -x_b_P;
    end
end
prob.Constraints.batUpPowCnstr = batUpPowCnstr;
prob.Constraints.batLowPowCnstr = batLowPowCnstr;


% Battery cycling constraints
for w = 1:W
    index_w = append('scen_',int2str(w));
    batCycleCnstr(w) = sum(P_b(:,index_w)) == 0;
end
prob.Constraints.batCycleCnstr = batCycleCnstr;

% cvar constraints
for w = 1:W
    index_w = append('scen_',int2str(w));
    cvarCnstr(w) = C_b*[x_b_P;x_b_E] + sum(sum(C_gt_p*P_gt(:,index_w,:)+...
        C_gt_on*u_gt(:,index_w,:)+C_gt_srt*z_gt(:,index_w,:))) - cvar_zeta <= cvar_s(index_w);
end
prob.Constraints.cvarCnstr = cvarCnstr;

%% --------------------\\ Optimization Solution \\-------------------------
% options = optimoptions('intlinprog','RelativeGapTolerance',MIPGap,'MaxTime',5*60);
options = optimoptions('intlinprog','ConstraintTolerance',1e-9,'RelativeGapTolerance',1e-6,'Heuristics','none');
% options = optimoptions('intlinprog');
sol = solve(prob,'Options',options);