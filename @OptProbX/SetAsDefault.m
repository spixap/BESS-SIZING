function SetAsDefault(objData,inputScenNum,inputGTNum,inputRiskAlpha,inputRiskBeta,inputfigCtrl,inputdispCtrl)
    %SetAsDefault This assigns the default values for the OptProbX
    %class based on the input # of scenarios
    % Inputs:
    %  1) objData       --> The object of class OptprobX
    %  2) inputScenNum  --> Selected # of scenarios
    %  3) inputGTNum    --> Selected # of GTs
    %  4) inputfigCtrl  --> Display figures ? [0:NO | 1:YES]
    %  5) inputdispCtrl --> Display prints ?  [0:NO | 1:YES]
    
    objData.figControl          = inputfigCtrl;
    objData.dispControl         = inputdispCtrl;
    objData.ScenNum             = inputScenNum;
    objData.Ngt                 = inputGTNum;
    objData.PhysicVarsNum       = objData.Ngt*3+2; % This coresponds to the number of different types of physical variables (num_vars): (Pgt + GTbin + GTstart) * 3 + Pbat + Pdump
    objData.FirsStageVarsNum    = 2;    % This coresponds to the decision for the battery size ( 2 elements - power & capacity) (first stage variables - x[end], x[end-1])
    objData.ScenTimeComp        = 24;   % This coresponds to time components of a scenario (comp)
    objData.TotalPhysVarsNum    = objData.ScenTimeComp*objData.ScenNum*objData.PhysicVarsNum; % # of all physical variables - y (for all time components and all scenarios)
    objData.RiskVars            = objData.ScenNum+1; % # of variables for risk management - S * ScenNum + Eta (= VaR at optimal point)
    objData.RiskAlpha           = inputRiskAlpha; % risk control parameter alpha
    objData.RiskBeta            = inputRiskBeta; % risk control parameter beta
    objData.TotalVarsNum        = objData.TotalPhysVarsNum+objData.FirsStageVarsNum+objData.RiskVars; % # of ALL optimization problem variables
%     objData.TotalVarsNumWithRisk = objData.TotalPhysVarsNum+objData.FirsStageVarsNum+objData.ScenNum+1 ; % Total optimization variables considering Risk Management
        
    objData.Aeq                 = [];   % Equalities Matrix
    objData.Aineq               = [];   % Inequalities Matrix
    objData.beq                 = [];   % Equalities Vector
    objData.bineq               = [];   % Inequalities Vector
    objData.lb                  = [];   % Lower boundary
    objData.ub                  = [];   % Upper boundary
    objData.indexStep           = objData.ScenTimeComp*objData.PhysicVarsNum;  % Step through the next scenario for-same-time-component-and-variable-type  
    objData.indexEnd            = objData.TotalPhysVarsNum;  % Finish index of the objData.indexStep
    objData.VarsIndexes         = {};
    objData.batCostObj          = CostsX();
    objData.GTCostObj           = CostsX();

    %
end % function

