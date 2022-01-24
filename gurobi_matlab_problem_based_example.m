%% Example: 1 LP
clearvars;
% Create empty Model
prob = optimproblem('ObjectiveSense','maximize');
% Add variables
x = optimvar('x', 'LowerBound', 0);
y = optimvar('y', 'LowerBound', 0);
z = optimvar('z', 'LowerBound', 0);
% Set objective function
prob.Objective = x + 2 * y + 3 * z;
% Add constraints
prob.Constraints.cons1 = x + y <= 1;
prob.Constraints.cons2 = y + z <= 1;
% Solve model
options = optimoptions('linprog');
sol = solve(prob,'Options', options);
%% Example: 2 IP
clearvars -except spi f;
T = 10;
prob = optimproblem('ObjectiveSense','maximize');
x = optimvar('x',T,1,'Type','integer','LowerBound',0,'UpperBound',1);
% f = randn(numVars,1)';
ObjExpr = sum(f*x);
prob.Objective = ObjExpr;

prob.Constraints.cons1 = x <= 1;
% prob.Constraints.cons2 = x(1) + x(2) >= 1;

options = optimoptions('intlinprog');
sol = solve(prob,'Options', options);
%% Example: 3 MIP
clearvars -except spi f;
T = 10;
prob = optimproblem('ObjectiveSense','maximize');
x = optimvar('x',T,1,'Type','integer','LowerBound',0,'UpperBound',1);
y = optimvar('y', 'LowerBound',0.7,'UpperBound',10);
% f = randn(numVars,1)';
ObjExpr = sum(f*x)-(y-0.5);
prob.Objective = ObjExpr;

prob.Constraints.cons1 = x <= 1;

options = optimoptions('intlinprog');
sol = solve(prob,'Options', options);
%% Example: 4 Minimum OFF time constraint: Scen = 1, Ngt = 1
clearvars
Toff = 4;
T    = 24;
% W    = 2;
prob = optimproblem('ObjectiveSense','maximize');
u_gt = optimvar('u_gt',T,1,'Type','integer','LowerBound',0,'UpperBound',1);
indexNames_t = cell(T,1);
for t=1:T
    indexNames_t{t,1} = append('hour_',int2str(t));
end
u_gt.IndexNames{1} = indexNames_t;
% Minimum OFF time constraints
for t = 2:T
    k = (t+1:min(t+Toff-1,T));
    for k = t+1:min(t+Toff-1,T)
        index_k = append('hour_',int2str(k));
        index_t = append('hour_',int2str(t));
        index_t_prev = append('hour_',int2str(t-1));
        minOffTimeCnstr(k,t) = u_gt(index_t_prev) - u_gt(index_t) <= 1 - u_gt(index_k);
    end
end
prob.Constraints = minOffTimeCnstr;
%% Example: 4 Minimum OFF time constraint: Scen = W, Ngt = 1
clearvars
Toff = 4;
T    = 24;
W    = 2;
prob = optimproblem('ObjectiveSense','maximize');
u_gt = optimvar('u_gt',T,W,'Type','integer','LowerBound',0,'UpperBound',1);
indexNames_t = cell(T,1);
indexNames_w = cell(1,W);
for t=1:T
    indexNames_t{t,1} = append('hour_',int2str(t));
end
for w=1:W
    indexNames_w{1,w} = append('scen_',int2str(w));
end
u_gt.IndexNames{1} = indexNames_t;
u_gt.IndexNames{2} = indexNames_w;
% Minimum OFF time constraints
for w = 1:W
    for t = 2:T
        k = (t+1:min(t+Toff-1,T));
        for k = t+1:min(t+Toff-1,T)
            index_w = append('scen_',int2str(w));
            index_k = append('hour_',int2str(k));
            index_t = append('hour_',int2str(t));
            index_t_prev = append('hour_',int2str(t-1));
            minOffTimeCnstr(k,t,w) = u_gt(index_t_prev,index_w) - u_gt(index_t,index_w) <= 1 - u_gt(index_k,index_w);
        end
    end
end
prob.Constraints = minOffTimeCnstr;
%% Example: 4 Minimum OFF time constraint: Scen = W, Ngt = N_G
clearvars
Toff = 4;
T    = 24;
W    = 2;
N_G  = 2;
prob = optimproblem('ObjectiveSense','minimize');
u_gt = optimvar('u_gt',T,W,N_G,'Type','integer','LowerBound',0,'UpperBound',1);
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
u_gt.IndexNames{1} = indexNames_t;
u_gt.IndexNames{2} = indexNames_w;
u_gt.IndexNames{3} = indexNames_g;
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
prob.Constraints = minOffTimeCnstr;

%% Example: 5 Cost function formulation
clearvars

% Sets
Toff = 4;
T    = 5;
W    = 2;
N_G  = 1;

% Parameters
P_g_max  = 20.20;
P_g_min  = 0.2*P_g_max;
R        = P_g_max;
C_gt_p   = 2;
C_gt_on  = 3;
C_gt_srt = 4;

E_B_0    = 0;
P_B_max  = 5;
E_B_max  = 10;
E_B_min  = 0;

% Scenario Propabilities
pr_w = 1/W;

prob = optimproblem('ObjectiveSense','minimize');

% Optimization Variables
P_gt = optimvar('P_gt',T,W,N_G,'LowerBound',P_g_min,'UpperBound',P_g_max);
u_gt = optimvar('u_gt',T,W,N_G,'Type','integer','LowerBound',0,'UpperBound',1);
z_gt = optimvar('z_gt',T,W,N_G,'Type','integer','LowerBound',0,'UpperBound',1);

P_b = optimvar('P_b',T,W,'LowerBound',-P_B_max,'UpperBound',P_B_max);
P_d = optimvar('P_d',T,W,'LowerBound',0);

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
P_gt.IndexNames{1} = indexNames_t;P_gt.IndexNames{2} = indexNames_w;P_gt.IndexNames{3} = indexNames_g;
u_gt.IndexNames{1} = indexNames_t;u_gt.IndexNames{2} = indexNames_w;u_gt.IndexNames{3} = indexNames_g;
z_gt.IndexNames{1} = indexNames_t;z_gt.IndexNames{2} = indexNames_w;z_gt.IndexNames{3} = indexNames_g;
P_b.IndexNames{1} = indexNames_t;P_b.IndexNames{2} = indexNames_w;


prob.Objective = sum(pr_w*sum(sum(C_gt_p*P_gt+C_gt_on*u_gt+C_gt_srt*z_gt)));

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
        maxSOCCnstr(t,w) = E_B_0 + sum(P_b(1:t,index_w)) <= E_B_max;
        minSOCCnstr(t,w) = E_B_0 + sum(P_b(1:t,index_w)) >= E_B_min;
    end
end
prob.Constraints.maxSOCCnstr = maxSOCCnstr;
prob.Constraints.minSOCCnstr = minSOCCnstr;

% Battery cycling constraints
for w = 1:W
        batCycleCnstr(w) = sum(P_b(:,index_w)) == 0;
end
prob.Constraints.batCycleCnstr = batCycleCnstr;