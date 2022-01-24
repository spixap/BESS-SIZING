classdef OptProbX < handle
    %OptProbX Create optimization constraints matrices
    %   Example: prob=OptProbX(); (prob is the object)
    %
    % OptProbX class can perform the following operations on its objects:
    % 1)--Assign variables indexes
    % 2)--Define variables bounds
    % 3)--Define Aeq and beq 
    % 4)--Define Aineq and bineq
    % 5)--Define objective function 
    % 6)--Calculate the case of NO BESS
    %
    %
    % OptProbX Properties:
    %   figControl
    %   dispControl
    %   dt
    %   PBMax 
    %   CMax
    %   IniSoC (SoC(0))
    %   LimSoC (SoC(end))
    %   RRb  
    %   PgtMax
    %   PgtMin
    %   RR        
    %   UP          
    %   DOWN        
    %   PdumpMin     
    %   PdumpMax
    %   Aeq (Aeq * x = beq) 
    %   beq (Aeq * x = beq) 
    %   Aineq (Aineq * x < bineq) 
    %   bineq (Aineq * x < bineq) 
    %   lb (lb < x)  
    %   ub (x < ub)  
    %   ScenNum
    %   FirsStageVarsNum [x(end-1), x(end)]
    %   ScenTimeComp
    %   PhysicVarsNum
    %   TotalPhysVarsNum
    %   TotalVarsNum
    %   indexStep
    %   indexEnd
    %   VarsIndexes
    %   Ngt
    %   batCostObj
    %   GTCostObj
    %   costCoef
    %   intDeclare
    %   fuelConsumptionGTA
    %   fuelConsumptionGTB
    %   fuelConsumptionGTC
    %   fuelConsumptionGTD
    %   dumpedEnergy
    %   fuelConsuptionTotalScen
    %   costGTsTotalScen
    %   dumpedTotalEnergyScen
    %   batteryPower
    %   batteryEnergy
    %   batterySOC
    %   powerGTA
    %   powerGTB
    %   powerGTC
    %   powerGTD
    %   costOfEachScen
    %     
    % OptProbX Methods:
    %   setIndexesSet
    %   AddBounds2VarsV2
    %   defineAeqANDbeqV2
    %   defineAineqANDbineq
    %   defineObjFun
    %   retrieveOptResults
    %   NoBESSCase

    
    properties (Constant)
        
        dt        = 1       % Time step of time components (For hourly data this corresponds to 1 hour)
        
        % Battery
        PBMax     = 5;      % Max Battery Power 5
        CMax      = 10;     % Max Battery Capacity 10
        IniSoC    = 0       % Initial State-of-Charge
        LimSoC    = 1       % Limit for Depth-of-Discharge
        RRb       = 5;      % Max Battery Ramping Rate
        
        % GT A (Consider all the GT to be identical)
        PgtMax    = 20.2            % Max GT Power
        PgtMin    = 4.04            % Min GT Power 4.04
        RR        = 20.2            % Max GT Ramping Rate
        UP        = 0               % Min GT ON time
        DOWN      = 4               % Min GT OFF time 4
        
        % GT A
        PgtMaxA   = 20.2            % Max GT Power
        PgtMinA   = 4.04            % Min GT Power 4.04
        RRA       = 20.2
        % GT B
        PgtMaxB   = 20.2
        PgtMinB   = 4.04           % Min GT Power 4.04
        RRB       = 20.2
        % GT C
        PgtMaxC   = 20.2
        PgtMinC   = 4.04            % Min GT Power 4.04
        RRC       = 20.2
        % GT D
        PgtMaxD   = 20.2
        PgtMinD   = 4.04            % Min GT Power 4.04
        RRD       = 20.2
       
        % Dump Load
        PdumpMin  = 0       % Min Dump Power
        PdumpMax  = Inf     % Max Dump Power
      
    end
   
    properties
        
        Aeq                 % Equalities Matrix
        beq                 % Equalities Vector
        Aineq               % Inequalities Matrix
        bineq               % Inequalities Vector
        lb                  % Lower boundary
        ub                  % Upper boundary
        
        ScenNum {mustBePositive, mustBeInteger}
        FirsStageVarsNum {mustBePositive, mustBeInteger}  % This coresponds to the decision for the battery size ( 2 elements - power & capacity)
        ScenTimeComp {mustBePositive, mustBeInteger} = 24 % This coresponds to time components (comp) - For hourly data = 24
        PhysicVarsNum                                     % This coresponds to the number of different types of physical variables (num_vars)
        TotalPhysVarsNum                                  % All x physical variables number (for all time components and all scenarios)
        TotalVarsNum                                      % Total optimization variables x
        indexStep                                         % Step to the next scenario-same-time-component-and-type variable 
        indexEnd                                          % End of the objData.indexStep
        VarsIndexes                                       % Cell array with the indexes of x variables
        Ngt                                               % Number of GTs for the system under consideration
        figControl
        dispControl
        
        batCostObj
        GTCostObj
        costCoef
        intDeclare
        fuelConsumptionGTA
        fuelConsumptionGTB
        fuelConsumptionGTC
        fuelConsumptionGTD
        dumpedEnergy
        fuelConsuptionTotalScen
        costGTsTotalScen
        dumpedTotalEnergyScen
        batteryPower
        batteryEnergy
        batterySOC
        powerGTA
        powerGTB
        powerGTC
        powerGTD
        
        indexSetBat
        indexSetGTAPow
        indexSetGTABin
        indexSetGTAStr
        indexSetDumpPow
        indexSetGTBPow
        indexSetGTBBin
        indexSetGTBStr
        indexSetGTCPow
        indexSetGTCBin
        indexSetGTCStr
        indexSetGTDPow
        indexSetGTDBin
        indexSetGTDStr
        indexSetRiskS
        indexSetRiskEta
        
        costOfEachScen
        costMoneyCoef
        RiskVars
        RiskAlpha
        RiskBeta
%         RiskAlpha = 0.9
%         RiskBeta = 0.9
                      
    end
    
%     properties (SetObservable = true)
%         Ngt {mustBePositive, mustBeInteger} =4
%     end
    events
        physicalVarsSet
    end
    % ---------------------------------------------------------------------
    methods
        
         % standard constructor
        function objData = OptProbX(inputScenNum,inputGTNum,inputRiskA,inputRiskB,figCtrl,dispCtrl)
            % The standard constructor assign some basic intiial values to
            % many of the problem's aprameters
                %
                objData.SetAsDefault(inputScenNum,inputGTNum,inputRiskA,inputRiskB,figCtrl,dispCtrl);
%                 objData.TotalPhysVarsNum = objData.ScenTimeComp*objData.ScenNum*objData.PhysicVarsNum; % For the 5 scenarios (baseline)
%                 objData.TotalVarsNum     = objData.TotalPhysVarsNum+objData.FirsStageVarsNum; % Total optimization variables
        end % standard constructor
        
        
        function set.Ngt(objData,Val)
            % The standard constructor assign some basic intiial values to
            % many of the problem's aprameters
            %
            if Val==1 || Val==2 || Val==3 || Val==4
                objData.Ngt=Val;
                
                %                 objData.PhysicVarsNum       = objData.Ngt*2+2; % This coresponds to num_vars
                %                 objData.FirsStageVarsNum    = 2;
                %                 objData.TotalPhysVarsNum    = objData.ScenTimeComp*objData.ScenNum*objData.PhysicVarsNum; % For the 5 scenarios (baseline)
                %                 objData.TotalVarsNum        = objData.TotalPhysVarsNum+objData.FirsStageVarsNum; % Total optimization variables
                %                 objData.indexStep           = objData.ScenTimeComp*objData.PhysicVarsNum;  % explain
                %                 objData.indexEnd            = objData.TotalPhysVarsNum;  % explain
                notify(objData,'physicalVarsSet')
                
%                 addlistener(objData,'Ngt','PostSet',...
%                 @(src,e)iniPhysicVars(objData,src,evnt));
            else
                objData.Ngt=[];
                error('Not a good choiche for Ngt');
            end
        end
%         addlistener(objData,'Ngt','PostSet',@OptConstraints.iniPhysicVars);
        function attachListener(objData)
            %Attach a listener to a PropListener object
            addlistener(objData,'Ngt','PostSet',@OptConstraints.iniPhysicVars);
        end
        
%         function assignPhysicVars(objData)
%             addlistener(objData,'Ngt','PostSet',...
%                 @(src,e)iniPhysicVars(objData,src,evnt));
%         end     
        %
    end % constructor methods
    %
    %
    % ---------------------------------------------------------------------
    methods(Static = true)
        % static methods
        % Callback for PostSet event
        % Inputs: meta.property object, event.PropertyEvent
        function iniPhysicVars()
%             src.PhysicVarsNum       = Val*2+2; % This coresponds to num_vars
%             src.ScenTimeComp        = 24; % This coresponds to comp
%             src.TotalPhysVarsNum    = src.ScenTimeComp*src.ScenNum*src.PhysicVarsNum; % For the 5 scenarios (baseline)
%             src.TotalVarsNum        = src.TotalPhysVarsNum+src.FirsStageVarsNum; % Total optimization variables
%             src.indexStep           = src.ScenTimeComp*src.PhysicVarsNum;  % explain
%             src.indexEnd            = src.TotalPhysVarsNum;  % explain
            disp('The physical variables have been set');
        end
    end	% static methods
        % -----------------------------------------------------------------
    methods
        
        
        % ---Method 1:
        function setIndexesSet(objData)
            %setIndexesSet Define x variables indixes
            %   This creates a cell matrix including the
            %   optimization variables and the corresponding indexes at the
            %   decision vector
            %   Example: prob.setIndexesSet;
            %            indexes=prob.VarsIndexes;
            % (prob is the object)
            
            indexesSets={1,objData.PhysicVarsNum+objData.FirsStageVarsNum+2};
            for iSet=1:objData.PhysicVarsNum
                
                switch objData.Ngt
                    case 1
                        if iSet==1
                            indexesSets{1,iSet}='Battery';
                            objData.indexSetBat = iSet;
                        elseif iSet==2
                            indexesSets{1,iSet}='GT_A_Power';
                            objData.indexSetGTAPow = iSet;
                        elseif iSet==3
                            indexesSets{1,iSet}='GT_A_Binary';
                            objData.indexSetGTABin = iSet;
                        elseif iSet==4
                            indexesSets{1,iSet}='GT_A_Startup';
                            objData.indexSetGTAStr = iSet;
                        else
                            indexesSets{1,iSet}='Dump_Power';
                            objData.indexSetDumpPow = iSet;
                            objData.indexSetRiskS = iSet+1;
                            objData.indexSetRiskEta = iSet+2;
                        end
                    case 2
                        if iSet==1
                            indexesSets{1,iSet}='Battery';
                            objData.indexSetBat = iSet;
                        elseif iSet==2
                            indexesSets{1,iSet}='GT_A_Power';
                            objData.indexSetGTAPow = iSet;
                        elseif iSet==3
                            indexesSets{1,iSet}='GT_A_Binary';
                             objData.indexSetGTABin = iSet;
                        elseif iSet==4
                            indexesSets{1,iSet}='GT_A_Startup';
                            objData.indexSetGTAStr = iSet;
                        elseif iSet==5
                            indexesSets{1,iSet}='GT_B_Power';
                            objData.indexSetGTBPow = iSet;
                        elseif iSet==6
                            indexesSets{1,iSet}='GT_B_Binary';
                            objData.indexSetGTBBin = iSet;
                        elseif iSet==7
                            indexesSets{1,iSet}='GT_B_Startup';
                            objData.indexSetGTBStr = iSet;
                        else
                            indexesSets{1,iSet}='Dump_Power';
                            objData.indexSetDumpPow = iSet;
                            objData.indexSetRiskS = iSet+1;
                            objData.indexSetRiskEta = iSet+2;
                        end
                    case 3
                        if iSet==1
                            indexesSets{1,iSet}='Battery';
                            objData.indexSetBat = iSet;
                        elseif iSet==2
                            indexesSets{1,iSet}='GT_A_Power';
                            objData.indexSetGTAPow = iSet;
                        elseif iSet==3
                            indexesSets{1,iSet}='GT_A_Binary';
                            objData.indexSetGTABin = iSet;
                        elseif iSet==4
                            indexesSets{1,iSet}='GT_A_Startup';
                            objData.indexSetGTAStr = iSet;
                        elseif iSet==5
                            indexesSets{1,iSet}='GT_B_Power';
                            objData.indexSetGTBPow = iSet;
                        elseif iSet==6
                            indexesSets{1,iSet}='GT_B_Binary';
                            objData.indexSetGTBBin = iSet;
                        elseif iSet==7
                            indexesSets{1,iSet}='GT_B_Startup';
                            objData.indexSetGTBStr = iSet;
                        elseif iSet==8
                            indexesSets{1,iSet}='GT_C_Power';
                            objData.indexSetGTCPow = iSet;
                        elseif iSet==9
                            indexesSets{1,iSet}='GT_C_Binary';
                            objData.indexSetGTCBin = iSet;
                        elseif iSet==10
                            indexesSets{1,iSet}='GT_C_Startup';
                            objData.indexSetGTCStr = iSet;
                        else
                            indexesSets{1,iSet}='Dump_Power';
                            objData.indexSetDumpPow = iSet;
                            objData.indexSetRiskS = iSet+1;
                            objData.indexSetRiskEta = iSet+2;
                        end
                    case 4
                        if iSet==1
                            indexesSets{1,iSet}='Battery';
                            objData.indexSetBat = iSet;
                        elseif iSet==2
                            indexesSets{1,iSet}='GT_A_Power';
                            objData.indexSetGTAPow = iSet;
                        elseif iSet==3
                            indexesSets{1,iSet}='GT_A_Binary';
                            objData.indexSetGTABin = iSet;
                        elseif iSet==4
                            indexesSets{1,iSet}='GT_A_Startup';
                            objData.indexSetGTAStr = iSet;
                        elseif iSet==5
                            indexesSets{1,iSet}='GT_B_Power';
                            objData.indexSetGTBPow = iSet;
                        elseif iSet==6
                            indexesSets{1,iSet}='GT_B_Binary';
                            objData.indexSetGTBBin = iSet;
                        elseif iSet==7
                            indexesSets{1,iSet}='GT_B_Startup';
                            objData.indexSetGTBStr = iSet;
                        elseif iSet==8
                            indexesSets{1,iSet}='GT_C_Power';
                            objData.indexSetGTCPow = iSet;
                        elseif iSet==9
                            indexesSets{1,iSet}='GT_C_Binary';
                            objData.indexSetGTCBin = iSet;
                        elseif iSet==10
                            indexesSets{1,iSet}='GT_C_Startup';
                            objData.indexSetGTCStr = iSet;
                        elseif iSet==11
                            indexesSets{1,iSet}='GT_D_Power';
                            objData.indexSetGTDPow = iSet;
                        elseif iSet==12
                            indexesSets{1,iSet}='GT_D_Binary';
                            objData.indexSetGTDBin = iSet;
                        elseif iSet==13
                            indexesSets{1,iSet}='GT_D_Startup';
                            objData.indexSetGTDStr = iSet;
                        else
                            indexesSets{1,iSet}='Dump_Power';
                            objData.indexSetDumpPow = iSet;
                            objData.indexSetRiskS = iSet+1;
                            objData.indexSetRiskEta = iSet+2;
                        end
                end
         
                indexesSets{2,iSet} = ((iSet-1)*objData.ScenTimeComp+1):objData.indexStep:objData.indexEnd;
            end
            indexesSets{1,objData.PhysicVarsNum+1}='risk_S';
            indexesSets{2,objData.PhysicVarsNum+1}=indexesSets{2,iSet}(end)+objData.ScenTimeComp;
            indexesSets{1,objData.PhysicVarsNum+2}='risk_Eta';
            indexesSets{2,objData.PhysicVarsNum+2}=indexesSets{2,objData.PhysicVarsNum+1}+objData.ScenNum;

            
            indexesSets{1,objData.PhysicVarsNum+3}='Power rating';
            indexesSets{2,objData.PhysicVarsNum+3}=indexesSets{2,objData.PhysicVarsNum+2}+1;
            indexesSets{1,objData.PhysicVarsNum+4}='Capacity rating';
            indexesSets{2,objData.PhysicVarsNum+4}=indexesSets{2,objData.PhysicVarsNum+2}+2;
            objData.VarsIndexes = indexesSets;
        end
        % -----------------------------------------------------------------
        % ---Method 2:
        function AddBounds2VarsV2(objData)
            %AddBounds2VarsV2 Define ub & lb
            %   This method applies the lower and upper bounds for the
            %   optimization variables
            %   Example: prob.AddBounds2VarsV2; (prob is the object)
            
            for indexScen=1:objData.ScenNum
                for iSet=1:objData.PhysicVarsNum
                    
                    switch objData.Ngt
                        case 1
                            if iSet == objData.indexSetBat
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=-objData.PBMax;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PBMax;
                            elseif iSet == objData.indexSetGTAPow
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PgtMaxA;
                            elseif iSet == objData.indexSetGTABin
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            elseif iSet == objData.indexSetGTAStr
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            else
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMin;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMax;
                            end
                        case 2
                            if iSet == objData.indexSetBat
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=-objData.PBMax;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PBMax;
                            elseif iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PgtMax;
                            elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            else
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMin;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMax;
                            end
                        case 3
                            if iSet == objData.indexSetBat
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=-objData.PBMax;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PBMax;
                            elseif iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow || iSet == objData.indexSetGTCPow
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PgtMax;
                            elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin || iSet == objData.indexSetGTCBin
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr || iSet == objData.indexSetGTCStr
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            else
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMin;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMax;
                            end
                        case 4
                            if iSet == objData.indexSetBat
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=-objData.PBMax;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PBMax;
                            elseif iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow || iSet == objData.indexSetGTCPow || iSet == objData.indexSetGTDPow
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PgtMax;
                            elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin || iSet == objData.indexSetGTCBin || iSet == objData.indexSetGTDBin
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr || iSet == objData.indexSetGTCStr || iSet == objData.indexSetGTDStr
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=0;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=1;
                            else
                                objData.lb(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMin;
                                objData.ub(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=objData.PdumpMax;
                            end
                    end      
                end
            end
            objData.lb(objData.VarsIndexes{2,objData.indexSetRiskS}:objData.VarsIndexes{2,objData.indexSetRiskS}+objData.ScenNum-1,1)=0; % s(w) min
            objData.ub(objData.VarsIndexes{2,objData.indexSetRiskS}:objData.VarsIndexes{2,objData.indexSetRiskS}+objData.ScenNum-1,1)=Inf; % s(w) max
            
            objData.lb(objData.VarsIndexes{2,objData.indexSetRiskEta},1)=0; % eta min 
            objData.ub(objData.VarsIndexes{2,objData.indexSetRiskEta},1)=Inf; % eta max
            
            objData.lb(objData.TotalVarsNum-1,1)    = 0;    % PBMin;
            objData.lb(objData.TotalVarsNum,1)      = 0;    % Cmin;
            objData.ub(objData.TotalVarsNum-1,1)    = objData.PBMax;  % PBMax;
            objData.ub(objData.TotalVarsNum,1)      = objData.CMax;  % Cmax;
        end
        % -----------------------------------------------------------------
        % ---Method 3:
        function defineAeqANDbeqV2(objData,LOAD,RESGEN)
            %defineAeqANDbeqV2 Define Aeq & beq
            %   This method defines the equalities constraint matrix and
            %   the constraint vector beq
            %   Example: prob.defineAeqANDbeqV2; (prob is the object)
            
            %---Aeq & beq---
            shftScen = 1;
            if (size(LOAD,2)< 2 || size(RESGEN,2)< 2) && (size(LOAD,1)>objData.ScenTimeComp || size(RESGEN,1)>objData.ScenTimeComp)
                error('This method required grouped data');
            end
            objData.Aeq=zeros((objData.ScenTimeComp+1)*objData.ScenNum,objData.TotalVarsNum,'double');
            objData.beq=zeros((objData.ScenTimeComp+1)*objData.ScenNum,1,'double');
            for indexScen=1:objData.ScenNum
                for iSet=1:objData.PhysicVarsNum
                    for tcomp=0:objData.ScenTimeComp-1
                        
                        switch objData.Ngt
                            case 1
                                if iSet == objData.indexSetBat         % Battery
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                    objData.Aeq((objData.ScenTimeComp+1)*indexScen,objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1)=objData.dt;
                                elseif iSet == objData.indexSetGTAPow  % GT A
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                    
                                elseif iSet == objData.indexSetDumpPow % Dumper
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=-1;
                                end
                                objData.beq(tcomp+shftScen,1)=LOAD(tcomp+1,indexScen)-RESGEN(tcomp+1,indexScen);
                                objData.beq((objData.ScenTimeComp+1)*indexScen,1)=0;
                            case 2
                                if iSet == objData.indexSetBat         % Battery
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                    objData.Aeq((objData.ScenTimeComp+1)*indexScen,objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1)=objData.dt;
                                elseif iSet == objData.indexSetGTAPow  % GT A
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetGTBPow  % GT B
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetDumpPow % Dumper
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=-1;
                                end
                                objData.beq(tcomp+shftScen,1)=LOAD(tcomp+1,indexScen)-RESGEN(tcomp+1,indexScen);
                                objData.beq((objData.ScenTimeComp+1)*indexScen,1)=0;
                            case 3
                                if iSet == objData.indexSetBat         % Battery
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                    objData.Aeq((objData.ScenTimeComp+1)*indexScen,objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1)=objData.dt;
                                elseif iSet == objData.indexSetGTAPow  % GT A
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetGTBPow  % GT B
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetGTCPow  % GT C
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetDumpPow % Dumper
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=-1;
                                end
                                objData.beq(tcomp+shftScen,1)=LOAD(tcomp+1,indexScen)-RESGEN(tcomp+1,indexScen);
                                objData.beq((objData.ScenTimeComp+1)*indexScen,1)=0;
                            case 4
                                if iSet == objData.indexSetBat         % Battery
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                    objData.Aeq((objData.ScenTimeComp+1)*indexScen,objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1)=objData.dt;
                                elseif iSet == objData.indexSetGTAPow  % GT A
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetGTBPow  % GT B
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetGTCPow  % GT C
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetGTDPow  % GT D
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=1;
                                elseif iSet == objData.indexSetDumpPow % Dumper
                                    objData.Aeq(tcomp+shftScen,tcomp+objData.VarsIndexes{2,iSet}(indexScen))=-1;
                                end
                                
                                objData.beq(tcomp+shftScen,1)=LOAD(tcomp+1,indexScen)-RESGEN(tcomp+1,indexScen);
                                objData.beq((objData.ScenTimeComp+1)*indexScen,1)=0;
                        end
                        objData.Aeq(:,objData.indexEnd+1)=0;
                        objData.Aeq(:,objData.indexEnd+2)=0;
                    end
                end
                shftScen = shftScen + objData.ScenTimeComp +1;
            end
        end
        % -----------------------------------------------------------------
        % ---Method 4:
        function defineAineqANDbineq(objData,scenProbabilities)
            %defineAineqANDbineq Define Aineq and bineq
            %   This method defines the inequalities constraint matrix
            %   Aineq and the inequalities vector bineq
            
            switch objData.Ngt
                case 1
                    %---Aineq---
                    cnstrINum   = 11;               % # of different Constraints TYPE (I)
                    cnstrIINum  = objData.UP*objData.Ngt;       % # of constraints for min GT ON time TYPE (II)
                    cnstrIIINum = objData.DOWN*objData.Ngt;   % # of constraints for min GT OFF time TYPE (III)
                    cnstrIVNum  = objData.ScenNum; % # of constraints for Risk variables TYPE (IV)
                    cnstrTotNum = cnstrINum + cnstrIINum + cnstrIIINum; % (I+II+III)
                    objData.Aineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,objData.TotalVarsNum,'double');
                    
                    %---Indixes for physical variables---
                    b       = 1;
                    gA      = (objData.ScenTimeComp+1);
                    binGA   = (2*objData.ScenTimeComp+1);
                    strUPGA = (3*objData.ScenTimeComp+1);
                    
                    objData.bineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,1,'double');
                    for scn=1:objData.ScenTimeComp*cnstrTotNum:cnstrTotNum*objData.ScenTimeComp*objData.ScenNum % Scan through the rows (constraints) of A per Scenario (Indicates the row at which the constraints for a new scenario are placed)
                        shfBat1=0; shfBat2=0; % Constraint shifter index (Shift collumn by one - one time step) when adding a constraint (a row to A) for battery
                        shfBat3=0; shfBat4=0;
                        
                        shfGTA1=0; shfGTA2=0;
                        shfGTA3=0; shfGTA4=0;
                        shfGTA5=0;
                        
                        
                        % Constraints Type (I)
                        for rI=0:cnstrINum*objData.ScenTimeComp-1 % Scan through the rows of A corresponding to TYPE (I) (and does that for each scenario indicated by scn)
                            if rI<=1*objData.ScenTimeComp-1                            % 1st P(t)<=PBMax
                                objData.Aineq(scn+rI,b+rI)=1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+objData.ScenTimeComp   % 2nd MIN<=P(t) -> -P(t)<=PBMin
                                objData.Aineq(scn+rI,b+rI-objData.ScenTimeComp)=-1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+2*objData.ScenTimeComp % 3rd E(t)<=Cmax, for each t
                                objData.Aineq(scn+rI,b:b+shfBat1)=-objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=objData.IniSoC-objData.LimSoC;
                                shfBat1=shfBat1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+3*objData.ScenTimeComp % 4th Cmin<=E(t), for each t
                                objData.Aineq(scn+rI,b:b+shfBat2)=objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=1-objData.LimSoC-objData.IniSoC;
                                shfBat2=shfBat2+1;
                                
                                % GTA Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+4*objData.ScenTimeComp % 5th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gA+shfGTA1)=1;
                                objData.Aineq(scn+rI,binGA+shfGTA1)=-objData.PgtMax;
                                shfGTA1=shfGTA1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+5*objData.ScenTimeComp % 6th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gA+shfGTA2)=-1;
                                objData.Aineq(scn+rI,binGA+shfGTA2)=objData.PgtMin;
                                shfGTA2=shfGTA2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+6*objData.ScenTimeComp % 7th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTA3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA3-1)= -1;
                                    objData.Aineq(scn+rI,gA+shfGTA3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTA3=shfGTA3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+7*objData.ScenTimeComp % 8th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTA4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA4-1)= 1;
                                    objData.Aineq(scn+rI,gA+shfGTA4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTA4=shfGTA4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+8*objData.ScenTimeComp  % 9th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTA5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5)=1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)=-1;
%                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5-1)= -1;
                                    objData.Aineq(scn+rI,binGA+shfGTA5)  = 1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)= -1;
%                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTA5=shfGTA5+1;
                                
                                % END GT CONSTRAINTS TYPE I -----------------------
                                
                            elseif rI<=(objData.ScenTimeComp-1)+9*objData.ScenTimeComp  % 10th Pb(t)-Pb(t-1)<=RRb
                                if shfBat3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat3)=0;
                                    %                 A(row+j-1,num_vars*N*comp+2-1)=-1;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat3-1)= -1;
                                    objData.Aineq(scn+rI,b+shfBat3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat3=shfBat3+1;
                            else                                                        % 11th Pb(t-1)-Pb(t)<=RRb
                                if shfBat4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat4-1)= 1;
                                    objData.Aineq(scn+rI,b+shfBat4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat4=shfBat4+1;
                            end
                        end
                        
                        
                        % -------------------------- IMPORTANT NOTE ---------------------------
                        % I can continue building A matrix at this point and leave
                        % the UP and DOWN constraints for the last section of the A matrix.
                        % Just remember to increase parameter: "cnstrINum" (Constraints of Type I).
                        % Then rI index scanning the A matrix will be updated automatically.
                        % ---------------------------- END NOTE -------------------------------
                        
                        
                        % Constraints Type (II)------------------------------------
                        % GTA MIN UP REQUIREMENTS
                        t=binGA;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                                     
                        % Constraints Type (III)-----------------------------------
                        % GTA MIN DOWN REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGA;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % End of inequality constraints, update the variables indexes by their
                        % step (objData.indexStep)
                        %----------------------------------------------------------------------
                        
                        b=b+objData.indexStep;
                        gA=gA+objData.indexStep;
                        binGA=binGA+objData.indexStep;
                        strUPGA=strUPGA+objData.indexStep;
                    end
                    
                    %----------------------------------------------------------------------
                    % Augment Aineq with RISK constraints
                    [Cbe,Cbp]=objData.batCostObj.CalcBESSCostperSize;
                    [CGTloaded,~,CGTNoloaded,CGTstartUP] = objData.GTCostObj.CalcGTvariableCost;
                    for scn=objData.ScenNum:-1:1
                        % Each additional Aineq row, represent an
                        % additional constraint for the CVaR problem
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTstartUP;

                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskS}+objData.ScenNum-scn)= -1; % s(w) cost coeeff
                        
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskEta})=-1; % eta min
                        
                        objData.Aineq(end-scn+1,objData.TotalVarsNum-1) = Cbp; % €/MW
                        objData.Aineq(end-scn+1,objData.TotalVarsNum)   = Cbe; % €/MWh
                    end
            
                case 2
                    %---Aineq---
                    cnstrINum = 16;               % # of different Constraints TYPE (I)
                    cnstrIINum  = objData.UP*objData.Ngt;       % # of constraints for min GT ON time TYPE (II)
                    cnstrIIINum  = objData.DOWN*objData.Ngt;   % # of constraints for min GT OFF time TYPE (III)
                    cnstrIVNum  = objData.ScenNum; % # of constraints for Risk variables TYPE (IV)
                    cnstrTotNum = cnstrINum + cnstrIINum + cnstrIIINum; % (I+II+III)
                    objData.Aineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,objData.TotalVarsNum,'double');
                    
                    
                    %---Indixes for physical variables---
                    b=1;
                    gA=(objData.ScenTimeComp+1);
                    binGA=(2*objData.ScenTimeComp+1);
                    strUPGA=(3*objData.ScenTimeComp+1);
                    gB=(4*objData.ScenTimeComp+1);
                    binGB=(5*objData.ScenTimeComp+1);
                    strUPGB=(6*objData.ScenTimeComp+1);
                    
                    
                    objData.bineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,1,'double');
                    for scn=1:objData.ScenTimeComp*cnstrTotNum:cnstrTotNum*objData.ScenTimeComp*objData.ScenNum % Scan through the rows (constraints) of A per Scenario (Indicates the row at which the constraints for a new scenario are placed)
                        shfBat1=0;  shfBat2=0; % Constraint shifter index (Shift collumn by one - one time step) when adding a constraint (a row to A) for battery
                        shfBat3=0; shfBat4=0;
                        
                        shfGTA1=0; shfGTA2=0;
                        shfGTA3=0; shfGTA4=0;
                        shfGTA5=0;
                        
                        shfGTB1=0; shfGTB2=0;
                        shfGTB3=0; shfGTB4=0;
                        shfGTB5=0;
                        
                        % Constraints Type (I)
                        for rI=0:cnstrINum*objData.ScenTimeComp-1 % Scan through the rows of A corresponding to TYPE (I) (and does that for each scenario indicated by scn)
                            if rI<=1*objData.ScenTimeComp-1                             % 1st P(t)<=PBMax
                                objData.Aineq(scn+rI,b+rI)=1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+objData.ScenTimeComp    % 2nd MIN<=P(t) -> -P(t)<=PBMin
                                objData.Aineq(scn+rI,b+rI-objData.ScenTimeComp)=-1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+2*objData.ScenTimeComp  % 3rd E(t)<=Cmax, for each t
                                objData.Aineq(scn+rI,b:b+shfBat1)=-objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=objData.IniSoC-objData.LimSoC;
                                shfBat1=shfBat1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+3*objData.ScenTimeComp  % 4th Cmin<=E(t), for each t
                                objData.Aineq(scn+rI,b:b+shfBat2)=objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=1-objData.LimSoC-objData.IniSoC;
                                shfBat2=shfBat2+1;
                                
                                % GTA Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+4*objData.ScenTimeComp  % 5th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gA+shfGTA1)=1;
                                objData.Aineq(scn+rI,binGA+shfGTA1)=-objData.PgtMax;
                                shfGTA1=shfGTA1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+5*objData.ScenTimeComp  % 6th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gA+shfGTA2)=-1;
                                objData.Aineq(scn+rI,binGA+shfGTA2)=objData.PgtMin;
                                shfGTA2=shfGTA2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+6*objData.ScenTimeComp  % 7th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTA3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA3-1)= -1;
                                    objData.Aineq(scn+rI,gA+shfGTA3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTA3=shfGTA3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+7*objData.ScenTimeComp   % 8th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTA4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA4-1)= 1;
                                    objData.Aineq(scn+rI,gA+shfGTA4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTA4=shfGTA4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+8*objData.ScenTimeComp  % 9th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTA5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5)=1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5-1)= -1;
                                    objData.Aineq(scn+rI,binGA+shfGTA5)  = 1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTA5=shfGTA5+1;
                                
                                % GTB Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+9*objData.ScenTimeComp % 10th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gB+shfGTB1)=1;
                                objData.Aineq(scn+rI,binGB+shfGTB1)=-objData.PgtMax;
                                shfGTB1=shfGTB1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+10*objData.ScenTimeComp % 11th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gB+shfGTB2)=-1;
                                objData.Aineq(scn+rI,binGB+shfGTB2)=objData.PgtMin;
                                shfGTB2=shfGTB2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+11*objData.ScenTimeComp % 12th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTB3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gB+shfGTB3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gB+shfGTB3-1)= -1;
                                    objData.Aineq(scn+rI,gB+shfGTB3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTB3=shfGTB3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+12*objData.ScenTimeComp  % 13th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTB4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gB+shfGTB4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gB+shfGTB4-1)= 1;
                                    objData.Aineq(scn+rI,gB+shfGTB4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTB4=shfGTB4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+13*objData.ScenTimeComp  % 14th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTB5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGB+shfGTB5)=1;
                                    objData.Aineq(scn+rI,strUPGB+shfGTB5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGB+shfGTB5-1)= -1;
                                    objData.Aineq(scn+rI,binGB+shfGTB5)  = 1;
                                    objData.Aineq(scn+rI,strUPGB+shfGTB5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTB5=shfGTB5+1;
                                % END GT CONSTRAINTS TYPE I -----------------------
                                
                            elseif rI<=(objData.ScenTimeComp-1)+14*objData.ScenTimeComp  % 15th Pb(t)-Pb(t-1)<=RRb
                                if shfBat3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat3)=0;
                                    %                 A(row+j-1,num_vars*N*comp+2-1)=-1;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat3-1)= -1;
                                    objData.Aineq(scn+rI,b+shfBat3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat3=shfBat3+1;
                            else                                                          % 16th Pb(t-1)-Pb(t)<=RRb
                                if shfBat4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat4-1)= 1;
                                    objData.Aineq(scn+rI,b+shfBat4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat4=shfBat4+1;
                            end
                        end
                        
                        % -------------------------- IMPORTANT NOTE ---------------------------
                        % I can continue building A matrix at this point and leave
                        % the UP and DOWN constraints for the last section of the A matrix.
                        % Just remember to increase parameter: "cnstrINum" (Constraints of Type I).
                        % Then rI index scanning the A matrix will be updated automatically.
                        % ---------------------------- END NOTE -------------------------------

                        % Constraints Type (II)------------------------------------
                        % GTA MIN UP REQUIREMENTS
                        t=binGA;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                        
                        % GTB MIN UP REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGB;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGB+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGB+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end                      
                        
                        % Constraints Type (III)-----------------------------------
                        % GTA MIN DOWN REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGA;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % GTB MIN DOWN REQUIREMENTS
                        rI=rI+objData.DOWN*objData.ScenTimeComp;
                        t=binGB;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGB+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGB+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        
                        % End of inequality constraints, update the variables indexes by their
                        % step (objData.indexStep)
                        %----------------------------------------------------------------------
                        
                        b=b+objData.indexStep;
                        gA=gA+objData.indexStep;
                        binGA=binGA+objData.indexStep;
                        strUPGA=strUPGA+objData.indexStep;
                        gB=gB+objData.indexStep;
                        binGB=binGB+objData.indexStep;
                        strUPGB=strUPGB+objData.indexStep;
                    end
                    
                    %----------------------------------------------------------------------
                    % Augment Aineq with RISK constraints
                    [Cbe,Cbp]=objData.batCostObj.CalcBESSCostperSize;
                    [CGTloaded,~,CGTNoloaded,CGTstartUP] = objData.GTCostObj.CalcGTvariableCost;
                    for scn=objData.ScenNum:-1:1
                        % Each additional Aineq row, represent an
                        % additional constraint for the CVaR problem
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTstartUP;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTBPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBBin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTBStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTstartUP;

                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskS}+objData.ScenNum-scn)= -1; % s(w) cost coeeff
                        
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskEta})=-1; % eta min
                        
                        objData.Aineq(end-scn+1,objData.TotalVarsNum-1) = Cbp; % €/MW
                        objData.Aineq(end-scn+1,objData.TotalVarsNum)   = Cbe; % €/MWh
                    end
                case 3
                    %---Aineq---
                    cnstrINum = 21;               % # of different Constraints TYPE (I)
                    cnstrIINum  = objData.UP*objData.Ngt;       % # of constraints for min GT ON time TYPE (II)
                    cnstrIIINum  = objData.DOWN*objData.Ngt;   % # of constraints for min GT OFF time TYPE (III)
                    cnstrIVNum  = objData.ScenNum; % # of constraints for Risk variables TYPE (IV)
                    cnstrTotNum = cnstrINum + cnstrIINum + cnstrIIINum; % (I+II+III)
                    objData.Aineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,objData.TotalVarsNum,'double');
                    
                    %---Indixes for physical variables---
                    b=1;
                    gA=(objData.ScenTimeComp+1);
                    binGA=(2*objData.ScenTimeComp+1);
                    strUPGA=(3*objData.ScenTimeComp+1);
                    gB=(4*objData.ScenTimeComp+1);
                    binGB=(5*objData.ScenTimeComp+1);
                    strUPGB=(6*objData.ScenTimeComp+1);
                    gC=(7*objData.ScenTimeComp+1);
                    binGC=(8*objData.ScenTimeComp+1);
                    strUPGC=(9*objData.ScenTimeComp+1);
                    
                    
                    objData.bineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,1,'double');
                    for scn=1:objData.ScenTimeComp*cnstrTotNum:cnstrTotNum*objData.ScenTimeComp*objData.ScenNum % Scan through the rows (constraints) of A per Scenario (Indicates the row at which the constraints for a new scenario are placed)
                        shfBat1=0;  shfBat2=0; % Constraint shifter index (Shift collumn by one - one time step) when adding a constraint (a row to A) for battery
                        shfBat3=0; shfBat4=0;
                        
                        shfGTA1=0; shfGTA2=0;
                        shfGTA3=0; shfGTA4=0;
                        shfGTA5=0;
                        
                        shfGTB1=0; shfGTB2=0;
                        shfGTB3=0; shfGTB4=0;
                        shfGTB5=0;
                        
                        shfGTC1=0; shfGTC2=0;
                        shfGTC3=0; shfGTC4=0;
                        shfGTC5=0;
                                                
                        
                        % Constraints Type (I)
                        for rI=0:cnstrINum*objData.ScenTimeComp-1 % Scan through the rows of A corresponding to TYPE (I) (and does that for each scenario indicated by scn)
                            if rI<=1*objData.ScenTimeComp-1                             % 1st P(t)<=PBMax
                                objData.Aineq(scn+rI,b+rI)=1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+objData.ScenTimeComp    % 2nd MIN<=P(t) -> -P(t)<=PBMin
                                objData.Aineq(scn+rI,b+rI-objData.ScenTimeComp)=-1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+2*objData.ScenTimeComp  % 3rd E(t)<=Cmax, for each t
                                objData.Aineq(scn+rI,b:b+shfBat1)=-objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=objData.IniSoC-objData.LimSoC;
                                shfBat1=shfBat1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+3*objData.ScenTimeComp  % 4th Cmin<=E(t), for each t
                                objData.Aineq(scn+rI,b:b+shfBat2)=objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=1-objData.LimSoC-objData.IniSoC;
                                shfBat2=shfBat2+1;
                                
                                % GTA Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+4*objData.ScenTimeComp % 5th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gA+shfGTA1)=1;
                                objData.Aineq(scn+rI,binGA+shfGTA1)=-objData.PgtMax;
                                shfGTA1=shfGTA1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+5*objData.ScenTimeComp % 6th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gA+shfGTA2)=-1;
                                objData.Aineq(scn+rI,binGA+shfGTA2)=objData.PgtMin;
                                shfGTA2=shfGTA2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+6*objData.ScenTimeComp % 7th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTA3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA3-1)= -1;
                                    objData.Aineq(scn+rI,gA+shfGTA3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTA3=shfGTA3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+7*objData.ScenTimeComp  % 8th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTA4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA4-1)= 1;
                                    objData.Aineq(scn+rI,gA+shfGTA4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTA4=shfGTA4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+8*objData.ScenTimeComp  % 9th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTA5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5)=1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5-1)= -1;
                                    objData.Aineq(scn+rI,binGA+shfGTA5)  = 1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTA5=shfGTA5+1;
                                
                                       % GTB Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+9*objData.ScenTimeComp % 10th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gB+shfGTB1)=1;
                                objData.Aineq(scn+rI,binGB+shfGTB1)=-objData.PgtMax;
                                shfGTB1=shfGTB1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+10*objData.ScenTimeComp % 11th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gB+shfGTB2)=-1;
                                objData.Aineq(scn+rI,binGB+shfGTB2)=objData.PgtMin;
                                shfGTB2=shfGTB2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+11*objData.ScenTimeComp % 12th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTB3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gB+shfGTB3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gB+shfGTB3-1)= -1;
                                    objData.Aineq(scn+rI,gB+shfGTB3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTB3=shfGTB3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+12*objData.ScenTimeComp  % 13th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTB4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gB+shfGTB4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gB+shfGTB4-1)= 1;
                                    objData.Aineq(scn+rI,gB+shfGTB4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTB4=shfGTB4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+13*objData.ScenTimeComp  % 14th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTB5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGB+shfGTB5)=1;
                                    objData.Aineq(scn+rI,strUPGB+shfGTB5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGB+shfGTB5-1)= -1;
                                    objData.Aineq(scn+rI,binGB+shfGTB5)  = 1;
                                    objData.Aineq(scn+rI,strUPGB+shfGTB5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTB5=shfGTB5+1;
                                
                                % GTC Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+14*objData.ScenTimeComp % 15th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gC+shfGTC1)=1;
                                objData.Aineq(scn+rI,binGC+shfGTC1)=-objData.PgtMax;
                                shfGTC1=shfGTC1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+15*objData.ScenTimeComp % 16th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gC+shfGTC2)=-1;
                                objData.Aineq(scn+rI,binGC+shfGTC2)=objData.PgtMin;
                                shfGTC2=shfGTC2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+16*objData.ScenTimeComp % 17th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTC3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gC+shfGTC3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gC+shfGTC3-1)= -1;
                                    objData.Aineq(scn+rI,gC+shfGTC3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTC3=shfGTC3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+17*objData.ScenTimeComp   % 18th Constraint-Pgt:Pgt(t-1)-Pgt(t)<=RR
                                if shfGTC4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gC+shfGTC4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gC+shfGTC4-1)= 1;
                                    objData.Aineq(scn+rI,gC+shfGTC4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RR;
                                end
                                shfGTC4=shfGTC4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+18*objData.ScenTimeComp  % 19th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTC5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGC+shfGTC5)=1;
                                    objData.Aineq(scn+rI,strUPGC+shfGTC5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGC+shfGTC5-1)= -1;
                                    objData.Aineq(scn+rI,binGC+shfGTC5)  = 1;
                                    objData.Aineq(scn+rI,strUPGC+shfGTC5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTC5=shfGTC5+1;
         
                                % END GT CONSTRAINTS TYPE I -----------------------
                                
                            elseif rI<=(objData.ScenTimeComp-1)+19*objData.ScenTimeComp  % 20th Pb(t)-Pb(t-1)<=RRb
                                if shfBat3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat3)=0;
                                    %                 A(row+j-1,num_vars*N*comp+2-1)=-1;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat3-1)= -1;
                                    objData.Aineq(scn+rI,b+shfBat3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat3=shfBat3+1;
                            else                                                        % 21th Pb(t-1)-Pb(t)<=RRb
                                if shfBat4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat4-1)= 1;
                                    objData.Aineq(scn+rI,b+shfBat4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat4=shfBat4+1;
                            end
                        end
                        
                        
                        % -------------------------- IMPORTANT NOTE ---------------------------
                        % I can continue building A matrix at this point and leave
                        % the UP and DOWN constraints for the last section of the A matrix.
                        % Just remember to increase parameter: "cnstrINum" (Constraints of Type I).
                        % Then rI index scanning the A matrix will be updated automatically.
                        % ---------------------------- END NOTE -------------------------------
                        
                        % Constraints Type (II)------------------------------------
                        % GTA MIN UP REQUIREMENTS
                        t=binGA;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                        
                        % GTB MIN UP REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGB;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGB+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGB+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                        
                        % GTC MIN UP REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGC;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGC+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGC+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                                                
                        % Constraints Type (III)-----------------------------------
                        % GTA MIN DOWN REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGA;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % GTB MIN DOWN REQUIREMENTS
                        rI=rI+objData.DOWN*objData.ScenTimeComp;
                        t=binGB;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGB+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGB+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % GTC MIN DOWN REQUIREMENTS
                        rI=rI+objData.DOWN*objData.ScenTimeComp;
                        t=binGC;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGC+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGC+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % End of inequality constraints, update the variables indexes by their
                        % step (objData.indexStep)
                        %----------------------------------------------------------------------
                        
                        b=b+objData.indexStep;
                        gA=gA+objData.indexStep;
                        binGA=binGA+objData.indexStep;
                        strUPGA=strUPGA+objData.indexStep;
                        gB=gB+objData.indexStep;
                        binGB=binGB+objData.indexStep;
                        strUPGB=strUPGB+objData.indexStep;
                        gC=gC+objData.indexStep;
                        binGC=binGC+objData.indexStep;
                        strUPGC=strUPGC+objData.indexStep;
                    end
                    
                    %----------------------------------------------------------------------
                    % Augment Aineq with RISK constraints
                    [Cbe,Cbp]=objData.batCostObj.CalcBESSCostperSize;
                    [CGTloaded,~,CGTNoloaded,CGTstartUP] = objData.GTCostObj.CalcGTvariableCost;
                    for scn=objData.ScenNum:-1:1
                        % Each additional Aineq row, represent an
                        % additional constraint for the CVaR problem
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTstartUP;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTBPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBBin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTBStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTstartUP;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTCPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTCPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTCBin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTCBin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTCStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTCStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            scenProbabilities(end-scn+1)*CGTstartUP;

                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskS}+objData.ScenNum-scn)= -1; % s(w) cost coeeff
                        
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskEta})=-1; % eta min
                        
                        objData.Aineq(end-scn+1,objData.TotalVarsNum-1) = Cbp; % €/MW
                        objData.Aineq(end-scn+1,objData.TotalVarsNum)   = Cbe; % €/MWh
                    end
                case 4
                    %---Aineq---
                    cnstrINum = 26;               % # of different Constraints TYPE (I)
                    cnstrIINum  = objData.UP*objData.Ngt;       % # of constraints for min GT ON time TYPE (II)
                    cnstrIIINum  = objData.DOWN*objData.Ngt;   % # of constraints for min GT OFF time TYPE (III)
                    cnstrIVNum  = objData.ScenNum; % # of constraints for Risk variables TYPE (IV)
                    cnstrTotNum = cnstrINum + cnstrIINum + cnstrIIINum; % (I+II+III)
                    objData.Aineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,objData.TotalVarsNum,'double');
                    
                    %---Indixes for physical variables---
                    b=1;
                    gA=(objData.ScenTimeComp+1);
                    binGA=(2*objData.ScenTimeComp+1);
                    strUPGA=(3*objData.ScenTimeComp+1);
                    gB=(4*objData.ScenTimeComp+1);
                    binGB=(5*objData.ScenTimeComp+1);
                    strUPGB=(6*objData.ScenTimeComp+1);
                    gC=(7*objData.ScenTimeComp+1);
                    binGC=(8*objData.ScenTimeComp+1);
                    strUPGC=(9*objData.ScenTimeComp+1);
                    gD=(10*objData.ScenTimeComp+1);
                    binGD=(11*objData.ScenTimeComp+1);
                    strUPGD=(12*objData.ScenTimeComp+1);
                    
                    
                    objData.bineq=zeros(cnstrTotNum*objData.ScenTimeComp*objData.ScenNum+cnstrIVNum,1,'double');
                    for scn=1:objData.ScenTimeComp*cnstrTotNum:cnstrTotNum*objData.ScenTimeComp*objData.ScenNum % Scan through the rows (constraints) of A per Scenario (Indicates the row at which the constraints for a new scenario are placed)
                        shfBat1=0; shfBat2=0; % Constraint shifter index (Shift collumn by one - one time step) when adding a constraint (a row to A) for battery
                        shfBat3=0; shfBat4=0;
                        
                        shfGTA1=0; shfGTA2=0;
                        shfGTA3=0; shfGTA4=0;
                        shfGTA5=0;
                        
                        shfGTB1=0; shfGTB2=0;
                        shfGTB3=0; shfGTB4=0;
                        shfGTB5=0;
                        
                        shfGTC1=0; shfGTC2=0;
                        shfGTC3=0; shfGTC4=0;
                        shfGTC5=0;
                        
                        shfGTD1=0; shfGTD2=0;
                        shfGTD3=0; shfGTD4=0;
                        shfGTD5=0;
                        
                        
                        % Constraints Type (I)
                        for rI=0:cnstrINum*objData.ScenTimeComp-1 % Scan through the rows of A corresponding to TYPE (I) (and does that for each scenario indicated by scn)
                            if rI<=1*objData.ScenTimeComp-1                             % 1st P(t)<=PBMax
                                objData.Aineq(scn+rI,b+rI)=1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+objData.ScenTimeComp    % 2nd MIN<=P(t) -> -P(t)<=PBMin
                                objData.Aineq(scn+rI,b+rI-objData.ScenTimeComp)=-1;
                                objData.Aineq(scn+rI,objData.TotalVarsNum-1)=-1;
                            elseif rI<=(objData.ScenTimeComp-1)+2*objData.ScenTimeComp  % 3rd E(t)<=Cmax, for each t
                                objData.Aineq(scn+rI,b:b+shfBat1)=-objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=objData.IniSoC-objData.LimSoC;
                                shfBat1=shfBat1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+3*objData.ScenTimeComp  % 4th Cmin<=E(t), for each t
                                objData.Aineq(scn+rI,b:b+shfBat2)=objData.dt;
                                objData.Aineq(scn+rI,objData.TotalVarsNum)=1-objData.LimSoC-objData.IniSoC;
                                shfBat2=shfBat2+1;
                                
                                % GTA Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+4*objData.ScenTimeComp  % 5th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gA+shfGTA1)=1;
                                objData.Aineq(scn+rI,binGA+shfGTA1)=-objData.PgtMaxA;
                                shfGTA1=shfGTA1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+5*objData.ScenTimeComp  % 6th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gA+shfGTA2)=-1;
                                objData.Aineq(scn+rI,binGA+shfGTA2)=objData.PgtMinA;
                                shfGTA2=shfGTA2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+6*objData.ScenTimeComp  % 7th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTA3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA3-1)= -1;
                                    objData.Aineq(scn+rI,gA+shfGTA3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRA;
                                end
                                shfGTA3=shfGTA3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+7*objData.ScenTimeComp  % 8th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTA4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gA+shfGTA4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gA+shfGTA4-1)= 1;
                                    objData.Aineq(scn+rI,gA+shfGTA4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRA;
                                end
                                shfGTA4=shfGTA4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+8*objData.ScenTimeComp  % 9th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTA5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5)=1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGA+shfGTA5-1)= -1;
                                    objData.Aineq(scn+rI,binGA+shfGTA5)  = 1;
                                    objData.Aineq(scn+rI,strUPGA+shfGTA5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTA5=shfGTA5+1;
                                
                                % GTB Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+9*objData.ScenTimeComp % 10th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gB+shfGTB1)=1;
                                objData.Aineq(scn+rI,binGB+shfGTB1)=-objData.PgtMaxB;
                                shfGTB1=shfGTB1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+10*objData.ScenTimeComp % 11th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gB+shfGTB2)=-1;
                                objData.Aineq(scn+rI,binGB+shfGTB2)=objData.PgtMinB;
                                shfGTB2=shfGTB2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+11*objData.ScenTimeComp % 12th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTB3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gB+shfGTB3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gB+shfGTB3-1)= -1;
                                    objData.Aineq(scn+rI,gB+shfGTB3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRB;
                                end
                                shfGTB3=shfGTB3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+12*objData.ScenTimeComp  % 13th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTB4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gB+shfGTB4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gB+shfGTB4-1)= 1;
                                    objData.Aineq(scn+rI,gB+shfGTB4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRB;
                                end
                                shfGTB4=shfGTB4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+13*objData.ScenTimeComp  % 14th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTB5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGB+shfGTB5)=1;
                                    objData.Aineq(scn+rI,strUPGB+shfGTB5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGB+shfGTB5-1)= -1;
                                    objData.Aineq(scn+rI,binGB+shfGTB5)  = 1;
                                    objData.Aineq(scn+rI,strUPGB+shfGTB5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTB5=shfGTB5+1;
                                
                                % GTC Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+14*objData.ScenTimeComp % 15th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gC+shfGTC1)=1;
                                objData.Aineq(scn+rI,binGC+shfGTC1)=-objData.PgtMaxC;
                                shfGTC1=shfGTC1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+15*objData.ScenTimeComp % 16th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gC+shfGTC2)=-1;
                                objData.Aineq(scn+rI,binGC+shfGTC2)=objData.PgtMinC;
                                shfGTC2=shfGTC2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+16*objData.ScenTimeComp % 17th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTC3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gC+shfGTC3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gC+shfGTC3-1)= -1;
                                    objData.Aineq(scn+rI,gC+shfGTC3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRC;
                                end
                                shfGTC3=shfGTC3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+17*objData.ScenTimeComp   % 18th Constraint-Pgt:Pgt(t-1)-Pgt(t)<=RR
                                if shfGTC4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gC+shfGTC4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gC+shfGTC4-1)= 1;
                                    objData.Aineq(scn+rI,gC+shfGTC4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRC;
                                end
                                shfGTC4=shfGTC4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+18*objData.ScenTimeComp  % 19th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTC5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGC+shfGTC5)=1;
                                    objData.Aineq(scn+rI,strUPGC+shfGTC5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGC+shfGTC5-1)= -1;
                                    objData.Aineq(scn+rI,binGC+shfGTC5)  = 1;
                                    objData.Aineq(scn+rI,strUPGC+shfGTC5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTC5=shfGTC5+1;
                                
                                % GTD Constraints
                            elseif rI<=(objData.ScenTimeComp-1)+19*objData.ScenTimeComp % 20th Pgt(t)-Ugt(t)*PgtMax<=0
                                objData.Aineq(scn+rI,gD+shfGTD1)=1;
                                objData.Aineq(scn+rI,binGD+shfGTD1)=-objData.PgtMaxD;
                                shfGTD1=shfGTD1+1;
                            elseif rI<=(objData.ScenTimeComp-1)+20*objData.ScenTimeComp % 21th Ugt(t)*PgtMin-Pgt(t)<=0
                                objData.Aineq(scn+rI,gD+shfGTD2)=-1;
                                objData.Aineq(scn+rI,binGD+shfGTD2)=objData.PgtMinD;
                                shfGTD2=shfGTD2+1;
                            elseif rI<=(objData.ScenTimeComp-1)+21*objData.ScenTimeComp % 22th Pgt(t)-Pgt(t-1)<=RR
                                if shfGTD3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gD+shfGTD3)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gD+shfGTD3-1)= -1;
                                    objData.Aineq(scn+rI,gD+shfGTD3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRD;
                                end
                                shfGTD3=shfGTD3+1;
                            elseif rI<=(objData.ScenTimeComp-1)+22*objData.ScenTimeComp % 23th Pgt(t-1)-Pgt(t)<=RR
                                if shfGTD4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,gD+shfGTD4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,gD+shfGTD4-1)= 1;
                                    objData.Aineq(scn+rI,gD+shfGTD4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRD;
                                end
                                shfGTD4=shfGTD4+1;
                            elseif rI<=(objData.ScenTimeComp-1)+23*objData.ScenTimeComp  % 24th -binGT(t-1)+binGT(t)-strUPGa(t)<=0
                                if shfGTD5==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,binGD+shfGTD5)=1;
                                    objData.Aineq(scn+rI,strUPGD+shfGTD5)=-1;
                                    %                                     objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,binGD+shfGTD5-1)= -1;
                                    objData.Aineq(scn+rI,binGD+shfGTD5)  = 1;
                                    objData.Aineq(scn+rI,strUPGD+shfGTD5)= -1;
                                    %                                     objData.bineq(scn+rI,1)      = 0;
                                end
                                shfGTD5=shfGTD5+1;
                                % END GT CONSTRAINTS TYPE I -----------------------
                                
                            elseif rI<=(objData.ScenTimeComp-1)+24*objData.ScenTimeComp  % 25th Pb(t)-Pb(t-1)<=RRb
                                if shfBat3==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat3)=0;
                                    %                 A(row+j-1,num_vars*N*comp+2-1)=-1;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat3-1)= -1;
                                    objData.Aineq(scn+rI,b+shfBat3)  = 1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat3=shfBat3+1;
                            else                                                        % 26th Pb(t-1)-Pb(t)<=RRb
                                if shfBat4==0           % Constraint if t = 1
                                    objData.Aineq(scn+rI,b+shfBat4)=0;
                                    objData.bineq(scn+rI,1)=0;
                                else                    % Constraint if t > 1
                                    objData.Aineq(scn+rI,b+shfBat4-1)= 1;
                                    objData.Aineq(scn+rI,b+shfBat4)  = -1;
                                    objData.bineq(scn+rI,1)      = objData.RRb;
                                end
                                shfBat4=shfBat4+1;
                            end
                        end
                        
                        
                        % -------------------------- IMPORTANT NOTE ---------------------------
                        % I can continue building A matrix at this point and leave
                        % the UP and DOWN constraints for the last section of the A matrix.
                        % Just remember to increase parameter: "cnstrINum" (Constraints of Type I).
                        % Then rI index scanning the A matrix will be updated automatically.
                        % ---------------------------- END NOTE -------------------------------
                        
                        
                        % Constraints from 22+1 to 22+UP*objData.Ngt -->
                        % -Ugt(t-1)+Ugt(t)-Ugt(k)<=0, t=1:24, k={(t+1),...min(t+objData.UP-1,24)} (1)
                        
                        % ---Indexes Notation:{
                        % scn    : index for different scenarios (i.e days)
                        % rI     : index for different time components of each scenario (i.e. daily components = 24)
                        % rII    : index for different rows of the cnstrIINum sections
                        % (each cnstrIINum section --> objData.UP rows for each time component of objData.ScenTimeComp) = Type II rows
                        % k      : index for the time component set described in equation (1)
                        % rII+k-1: Index for each additional row of the UP constraint for each single scenario (day)
                        % row+j  : Index for the current row of the whole A matrix rows
                        %---------------------------------------------------------------------}
                        
                        
                        % Constraints Type (II)------------------------------------
                        % GTA MIN UP REQUIREMENTS
                        t=binGA;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                        
                        % GTB MIN UP REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGB;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGB+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGB+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                        
                        % GTC MIN UP REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGC;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGC+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGC+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                        
                        % GTD MIN UP REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGD;
                        rII=1;
                        for k=1:objData.UP
                            objData.Aineq(rII+k-1+scn+rI,t)=1;
                            objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                        end
                        t=t+1;
                        for rII=1+objData.UP:objData.UP:objData.UP*objData.ScenTimeComp
                            for k=1:objData.UP
                                % Case where we have enough "time" to index all the steps until the end of
                                % the scenario period
                                if  t+objData.UP<=binGD+(objData.ScenTimeComp-1)
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                    objData.Aineq(rII+k-1+scn+rI,t+k)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                else
                                    % Case where the scenario period ends and have
                                    % to adjust our indexing
                                    col=min(t+k,binGD+(objData.ScenTimeComp-1));
                                    objData.Aineq(rII+k-1+scn+rI,col)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t-1)=-1;
                                    objData.Aineq(rII+k-1+scn+rI,t)=1;
                                end
                            end
                            t=t+1;
                        end
                        
                        
                        % Constraints from 22+UP*objData.Ngt+1 to 22+UP*objData.Ngt+DOWN*objData.Ngt -->
                        % Ugt(t-1)-Ugt(t)+Ugt(k)-1<=0, t=1:24,
                        % k={(t+1),...min(t+objData.DOWN-1,24)} (2)
                        
                        % Exactly the same as for the UP constraints, just change UP-->DOWN
                        %----------------------------------------------------------------------
                        
                        
                        % Constraints Type (III)-----------------------------------
                        % GTA MIN DOWN REQUIREMENTS
                        rI=rI+objData.UP*objData.ScenTimeComp;
                        t=binGA;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGA+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGA+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % GTB MIN DOWN REQUIREMENTS
                        rI=rI+objData.DOWN*objData.ScenTimeComp;
                        t=binGB;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGB+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGB+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % GTC MIN DOWN REQUIREMENTS
                        rI=rI+objData.DOWN*objData.ScenTimeComp;
                        t=binGC;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGC+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGC+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % GTD MIN DOWN REQUIREMENTS
                        rI=rI+objData.DOWN*objData.ScenTimeComp;
                        t=binGD;
                        rIII=1;
                        for k=1:objData.DOWN
                            objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                            objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                            objData.bineq(rIII+k-1+scn+rI,1)=1;
                        end
                        t=t+1;
                        for rIII=1+objData.DOWN:objData.DOWN:objData.DOWN*objData.ScenTimeComp
                            for k=1:objData.DOWN
                                if  t+objData.DOWN<=binGD+(objData.ScenTimeComp-1)
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                    objData.Aineq(rIII+k-1+scn+rI,t+k)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                else
                                    col=min(t+k,binGD+(objData.ScenTimeComp-1));
                                    objData.Aineq(rIII+k-1+scn+rI,col)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t-1)=1;
                                    objData.Aineq(rIII+k-1+scn+rI,t)=-1;
                                end
                                objData.bineq(rIII+k-1+scn+rI,1)=1;
                            end
                            t=t+1;
                        end
                        
                        % End of inequality constraints, update the variables indexes by their
                        % step (objData.indexStep)
                        %----------------------------------------------------------------------
                        
                        b=b+objData.indexStep;
                        gA=gA+objData.indexStep;
                        binGA=binGA+objData.indexStep;
                        strUPGA=strUPGA+objData.indexStep;
                        gB=gB+objData.indexStep;
                        binGB=binGB+objData.indexStep;
                        strUPGB=strUPGB+objData.indexStep;
                        gC=gC+objData.indexStep;
                        binGC=binGC+objData.indexStep;
                        strUPGC=strUPGC+objData.indexStep;
                        gD=gD+objData.indexStep;
                        binGD=binGD+objData.indexStep;
                        strUPGD=strUPGD+objData.indexStep;
                    end
                    
                    %----------------------------------------------------------------------
                    % Augment Aineq with RISK constraints
                    [Cbe,Cbp]=objData.batCostObj.CalcBESSCostperSize;
                    [CGTloaded,~,CGTNoloaded,CGTstartUP] = objData.GTCostObj.CalcGTvariableCost;
                    for scn=objData.ScenNum:-1:1
                        % Each additional Aineq row, represent an
                        % additional constraint for the CVaR problem
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTABin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTAStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTstartUP;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTBPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTBBin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBBin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTBStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTBStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTstartUP;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTCPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTCPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTCBin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTCBin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTCStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTCStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTstartUP;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTDPow}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTDPow}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTloaded;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTDBin}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTDBin}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTNoloaded*objData.dt;
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetGTDStr}(end-scn+1):objData.VarsIndexes{2,objData.indexSetGTDStr}(end-scn+1)+objData.ScenTimeComp-1)=...
                            CGTstartUP;

                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskS}+objData.ScenNum-scn)= -1; % s(w) cost coeeff
                        
                        objData.Aineq(end-scn+1,objData.VarsIndexes{2,objData.indexSetRiskEta})=-1; % eta min
                        
                        objData.Aineq(end-scn+1,objData.TotalVarsNum-1) = Cbp; % €/MW
                        objData.Aineq(end-scn+1,objData.TotalVarsNum)   = Cbe; % €/MWh
                    end
            end
        end
        % -----------------------------------------------------------------
        % ---Method 5:
        function defineObjFun(objData,scenProbabilities)
            %defineObjFun Define objective function
            %   This defines the linear objective function for the
            %   optimization problem
            %   Example: prob.defineObjFun(ProbabilitiesVector);
            %           (prob is the object)
                        
            if size(scenProbabilities,1)~=objData.ScenNum
                error('The dimension of the scenarios propabilities vector is not correct')
            elseif size(scenProbabilities,2)> 1
                error('The scenarios propabilities vector is not a vector')
            end
            
                        [Cbe,Cbp]=objData.batCostObj.CalcBESSCostperSize;                    
                        [CGTloaded,~,CGTNoloaded,CGTstartUP] = objData.GTCostObj.CalcGTvariableCost;
                        
                        objData.costCoef=zeros(objData.TotalVarsNum,1);
                        
                        for indexScen=1:objData.ScenNum
                            for iSet=1:objData.PhysicVarsNum
                                
                                switch objData.Ngt
                                    case 1
                                        if iSet == objData.indexSetGTAPow
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded*(1-objData.RiskBeta);
                                        elseif iSet == objData.indexSetGTABin
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt*(1-objData.RiskBeta);
                                            objData.intDeclare(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1;
                                        elseif iSet == objData.indexSetGTAStr
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP*(1-objData.RiskBeta);
                                        end
                                    case 2
                                        if iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded*(1-objData.RiskBeta);
                                        elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt*(1-objData.RiskBeta);
                                            objData.intDeclare(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1;
                                        elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr 
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP*(1-objData.RiskBeta);
                                        end
                                    case 3
                                        if iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow || iSet == objData.indexSetGTCPow
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded*(1-objData.RiskBeta);
                                        elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin || iSet == objData.indexSetGTCBin
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt*(1-objData.RiskBeta);
                                            objData.intDeclare(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1;
                                        elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr || iSet == objData.indexSetGTCStr
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP*(1-objData.RiskBeta);
                                        end
                                    case 4
                                        if iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow || iSet == objData.indexSetGTCPow || iSet == objData.indexSetGTDPow
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded*(1-objData.RiskBeta);
                                        elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin || iSet == objData.indexSetGTCBin || iSet == objData.indexSetGTDBin
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt*(1-objData.RiskBeta);
                                            objData.intDeclare(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1;
                                        elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr || iSet == objData.indexSetGTCStr || iSet == objData.indexSetGTDStr
                                            objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP*(1-objData.RiskBeta);
                                        end

%                                         if iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow || iSet == objData.indexSetGTCPow || iSet == objData.indexSetGTDPow
%                                             objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
%                                                 scenProbabilities(indexScen)*CGTloaded;
%                                         elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin || iSet == objData.indexSetGTCBin || iSet == objData.indexSetGTDBin
%                                             objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
%                                                 scenProbabilities(indexScen)*CGTNoloaded*objData.dt;
%                                             objData.intDeclare(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
%                                                 objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1;
%                                         elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr || iSet == objData.indexSetGTCStr || iSet == objData.indexSetGTDStr
%                                             objData.costCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
%                                                 scenProbabilities(indexScen)*CGTstartUP;
%                                         end
                                end
                            end
                        end
                        
                        objData.costCoef(objData.VarsIndexes{2,objData.indexSetRiskS}:objData.VarsIndexes{2,objData.indexSetRiskS}+objData.ScenNum-1,1)=...
                                                scenProbabilities*objData.RiskBeta/(1-objData.RiskAlpha); % s(w) cost coeeff (Aux variables to formulate CVaR)
                        
                        objData.costCoef(objData.VarsIndexes{2,objData.indexSetRiskEta},1)=objData.RiskBeta; % Eta min (Aux variable = Var @ optimality)
                        
                        objData.costCoef(objData.TotalVarsNum-1,1) = Cbp*(1-objData.RiskBeta); % €/MW
                        objData.costCoef(objData.TotalVarsNum,1)   = Cbe*(1-objData.RiskBeta); % €/MWh

%                         objData.costCoef(objData.TotalVarsNum-1,1) = Cbp; % €/MW
%                         objData.costCoef(objData.TotalVarsNum,1)   = Cbe; % €/MWh
                        
                        % Remove unecessary 0 from the declared integer
                        % positions
                        temp = objData.intDeclare;
                        tempnew=temp(temp~= 0);
                        objData.intDeclare=tempnew;
                        
                        % -------------------------------------------------
                        % CALCULATE EXPECTED ECONOMIC COST (VALUE f(x,w)*probabilities)
                        
                        objData.costMoneyCoef=zeros(objData.TotalVarsNum,1);
                        
                        for indexScen=1:objData.ScenNum
                            for iSet=1:objData.PhysicVarsNum
                                
                                switch objData.Ngt
                                    case 1
                                        if iSet == objData.indexSetGTAPow
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded;
                                        elseif iSet == objData.indexSetGTABin
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt;
                                        elseif iSet == objData.indexSetGTAStr
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP;
                                        end
                                    case 2
                                        if iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded;
                                        elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt;
                                        elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr 
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP;
                                        end
                                    case 3
                                        if iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow || iSet == objData.indexSetGTCPow
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded;
                                        elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin || iSet == objData.indexSetGTCBin
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt;
                                        elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr || iSet == objData.indexSetGTCStr
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP;
                                        end
                                    case 4
                                        if iSet == objData.indexSetGTAPow || iSet == objData.indexSetGTBPow || iSet == objData.indexSetGTCPow || iSet == objData.indexSetGTDPow
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTloaded;
                                        elseif iSet == objData.indexSetGTABin || iSet == objData.indexSetGTBBin || iSet == objData.indexSetGTCBin || iSet == objData.indexSetGTDBin
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTNoloaded*objData.dt;
                                        elseif iSet == objData.indexSetGTAStr || iSet == objData.indexSetGTBStr || iSet == objData.indexSetGTCStr || iSet == objData.indexSetGTDStr
                                            objData.costMoneyCoef(objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1,1)=...
                                                scenProbabilities(indexScen)*CGTstartUP;
                                        end
                                end
                            end
                        end
                        
                        objData.costMoneyCoef(objData.TotalVarsNum-1,1) = Cbp; % €/MW
                        objData.costMoneyCoef(objData.TotalVarsNum,1)   = Cbe; % €/MWh
        end
        % -----------------------------------------------------------------
        % ---Method 6:
        function [ExpctedTotalFuelConsumption,ExpectedTotalCO2emis,...
                ExpectedTotalDumpedEnergy,BESSCAPEX,BESSequivCostPerScen,...
                ExpectedTotalCost]=retrieveOptResults(objData,scenProbabilities,...
                optResult,LOAD,RESGEN,strcGurobi)
            %retrieveOptResults Summarize the results of optimization
            %                   Calculate the expexcted daily costs of the optimized
            %                   system, expected fuel consumption, expected energy dumping
            %                   (expectation operation over the diffrent
            %                   scenarios). Also print the basic results
            %                   and visualize with plots
            %   scenario
            %   Example: [ExpctdFuel,ExpctdGTOPEX,ExpctdDumpE,BatCAPEX,BatEquivDaily,ExpctdCOST] = prob.retrieveOptResults(Prop1',x,L,PW);
            %           (prob is the object)
            
            if size(scenProbabilities,1)~=objData.ScenNum
                error('The dimension of the scenarios propabilities vector is not correct')
            elseif size(scenProbabilities,2)> 1
                error('The scenarios propabilities vector is not a vector')
            end
            
            
            % -------------------- GET RESULTS FROM x ---------------------
            GTaa = objData.GTCostObj.aa;
            GTbb = objData.GTCostObj.bb;
%             [~,CGT,~,~] = objData.GTCostObj.CalcGTvariableCost;
%             [Cbe,Cbp]=objData.batCostObj.CalcBESSCostperSize;
            Eo=objData.IniSoC*optResult(objData.TotalVarsNum);
            ScenLabels=cell(1,objData.indexEnd);
            [PgtTot,Pdump]=objData.NoBESSCase(LOAD,RESGEN);
            
                        for indexScen=1:objData.ScenNum
                            for iSet=1:objData.PhysicVarsNum
                                
                                indexWholeScen = objData.VarsIndexes{2,iSet}(indexScen):objData.VarsIndexes{2,iSet}(indexScen)+objData.ScenTimeComp-1;
                                indexGlobal = (indexScen-1)*objData.ScenTimeComp+1:(indexScen-1)*objData.ScenTimeComp+1+(objData.ScenTimeComp-1);

                                if iSet<=objData.PhysicVarsNum-1
                                    indexWholeScenPlus1 = objData.VarsIndexes{2,iSet+1}(indexScen):objData.VarsIndexes{2,iSet+1}(indexScen)+objData.ScenTimeComp-1;
                                end
                                
                                conv=num2str(indexScen);
                                ScenLabels{1,indexScen}=conv;
                                
                                switch objData.Ngt
                                    case 1
                                        if iSet == objData.indexSetBat
                                            objData.batteryPower(indexGlobal) = optResult(indexWholeScen);
                                            for tcomp=0:objData.ScenTimeComp-1
                                                if tcomp == 0
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) =...
                                                        Eo-objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                else
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) = ...
                                                        objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+tcomp)-...
                                                        objData.dt*objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                end
                                            end
                                            objData.batterySOC(indexGlobal)=objData.batteryEnergy(indexGlobal)./optResult(objData.TotalVarsNum);
                                        elseif iSet == objData.indexSetGTAPow
                                            objData.powerGTA(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTA(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTA = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetDumpPow
                                            objData.dumpedEnergy(indexGlobal)=optResult(indexWholeScen);
                                        elseif iSet == objData.PhysicVarsNum-1
                                            objData.fuelConsuptionTotalScen(indexScen)= sum(objData.fuelConsumptionGTA(indexGlobal));
%                                             objData.costGTsTotalScen(indexScen) = objData.fuelConsuptionTotalScen(indexScen)*CGT + costOMGTA;
                                            objData.dumpedTotalEnergyScen(indexScen) = sum(objData.dumpedEnergy);
                                        end
                                    case 2
                                        if iSet == objData.indexSetBat
                                            objData.batteryPower(indexGlobal) = optResult(indexWholeScen);
                                            for tcomp=0:objData.ScenTimeComp-1
                                                if tcomp == 0
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) =...
                                                        Eo-objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                else
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) = ...
                                                        objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+tcomp)-...
                                                        objData.dt*objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                end
                                            end
                                            objData.batterySOC(indexGlobal)=objData.batteryEnergy(indexGlobal)./optResult(objData.TotalVarsNum);
                                        elseif iSet == objData.indexSetGTAPow
                                            objData.powerGTA(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTA(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTA = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetGTBPow
                                            objData.powerGTB(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTB(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTB = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetDumpPow
                                            objData.dumpedEnergy(indexGlobal)=optResult(indexWholeScen);
                                        elseif iSet == objData.PhysicVarsNum-1
                                            objData.fuelConsuptionTotalScen(indexScen)= sum(objData.fuelConsumptionGTA(indexGlobal))+...
                                                sum(objData.fuelConsumptionGTB(indexGlobal));
%                                             objData.costGTsTotalScen(indexScen) = objData.fuelConsuptionTotalScen(indexScen)*CGT + costOMGTA + costOMGTB;
                                            objData.dumpedTotalEnergyScen(indexScen) = sum(objData.dumpedEnergy);
                                        end
                                    case 3
                                        if iSet == objData.indexSetBat
                                            objData.batteryPower(indexGlobal) = optResult(indexWholeScen);
                                            for tcomp=0:objData.ScenTimeComp-1
                                                if tcomp == 0
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) =...
                                                        Eo-objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                else
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) = ...
                                                        objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+tcomp)-...
                                                        objData.dt*objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                end
                                            end
                                            objData.batterySOC(indexGlobal)=objData.batteryEnergy(indexGlobal)./optResult(objData.TotalVarsNum);
                                        elseif iSet == objData.indexSetGTAPow
                                            objData.powerGTA(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTA(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTA = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetGTBPow
                                            objData.powerGTB(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTB(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTB = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetGTCPow
                                            objData.powerGTC(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTC(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTC = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetDumpPow
                                            objData.dumpedEnergy(indexGlobal)=optResult(indexWholeScen);
                                        elseif iSet == objData.PhysicVarsNum-1
                                            objData.fuelConsuptionTotalScen(indexScen)=...
                                                sum(objData.fuelConsumptionGTA(indexGlobal))+sum(objData.fuelConsumptionGTB(indexGlobal))+...
                                                +sum(objData.fuelConsumptionGTC(indexGlobal));
%                                             objData.costGTsTotalScen(indexScen) = objData.fuelConsuptionTotalScen(indexScen)*CGT + costOMGTA +...
%                                                 costOMGTB + costOMGTC;
                                            objData.dumpedTotalEnergyScen(indexScen) = sum(objData.dumpedEnergy);
                                        end
                                    case 4
                                        if iSet == objData.indexSetBat
                                            objData.batteryPower(indexGlobal) = optResult(indexWholeScen);
                                            for tcomp=0:objData.ScenTimeComp-1
                                                if tcomp == 0
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) =...
                                                        Eo-objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                else
                                                    objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+1+tcomp) = ...
                                                        objData.batteryEnergy((indexScen-1)*objData.ScenTimeComp+tcomp)-...
                                                        objData.dt*objData.dt*optResult(objData.VarsIndexes{2,iSet}(indexScen)+tcomp);
                                                end
                                            end
                                            objData.batterySOC(indexGlobal)=objData.batteryEnergy(indexGlobal)./optResult(objData.TotalVarsNum);
                                        elseif iSet == objData.indexSetGTAPow
                                            objData.powerGTA(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTA(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTA = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetGTBPow
                                            objData.powerGTB(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTB(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTB = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetGTCPow
                                            objData.powerGTC(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTC(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTC = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetGTDPow
                                            objData.powerGTD(indexGlobal) = optResult(indexWholeScenPlus1).*optResult(indexWholeScen);
                                            objData.fuelConsumptionGTD(indexGlobal) =...
                                                optResult(indexWholeScenPlus1).*(optResult(indexWholeScen)*GTaa+GTbb);
%                                             costOMGTD = (optResult(indexWholeScenPlus1)'*optResult(indexWholeScen))*objData.GTCostObj.varOMcostGT;
                                        elseif iSet == objData.indexSetDumpPow
                                            objData.dumpedEnergy(indexGlobal)=optResult(indexWholeScen);
                                            objData.dumpedTotalEnergyScen(indexScen) = sum(optResult(indexWholeScen));
                                        elseif iSet == objData.PhysicVarsNum-1
                                            objData.fuelConsuptionTotalScen(indexScen)=...
                                                sum(objData.fuelConsumptionGTA(indexGlobal))+sum(objData.fuelConsumptionGTB(indexGlobal))+...
                                                +sum(objData.fuelConsumptionGTC(indexGlobal))+sum(objData.fuelConsumptionGTD(indexGlobal));
%                                             objData.costGTsTotalScen(indexScen) = objData.fuelConsuptionTotalScen(indexScen)*CGT + costOMGTA +...
%                                                 costOMGTB + costOMGTC + costOMGTD;
%                                             objData.dumpedTotalEnergyScen(indexScen) = sum(objData.dumpedEnergy(indexGlobal));
                                        end
                                end
                            end
                            switch objData.Ngt
                                case 1
                                    objData.costOfEachScen(indexScen) = (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1)...
                                + objData.batCostObj.CalcEquivDailyBESSCost(optResult(objData.TotalVarsNum),...
                                  optResult(objData.TotalVarsNum-1));
                                case 2
                                    objData.costOfEachScen(indexScen) = (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen)+objData.ScenTimeComp-1)...
                                + objData.batCostObj.CalcEquivDailyBESSCost(optResult(objData.TotalVarsNum),...
                                  optResult(objData.TotalVarsNum-1));
                                case 3
                                    objData.costOfEachScen(indexScen) = (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen)+objData.ScenTimeComp-1)...
                                + objData.batCostObj.CalcEquivDailyBESSCost(optResult(objData.TotalVarsNum),...
                                  optResult(objData.TotalVarsNum-1));
                                case 4
                                    objData.costOfEachScen(indexScen) = (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTABin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTAStr}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBBin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTBStr}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCBin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTCStr}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTDPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTDPow}(indexScen)+objData.ScenTimeComp-1))'*(optResult(objData.VarsIndexes{2,objData.indexSetGTDBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTDBin}(indexScen)+objData.ScenTimeComp-1).*optResult(objData.VarsIndexes{2,objData.indexSetGTDPow}(indexScen):objData.VarsIndexes{2,objData.indexSetGTDPow}(indexScen)+objData.ScenTimeComp-1))...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTDBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTDBin}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTDBin}(indexScen):objData.VarsIndexes{2,objData.indexSetGTDBin}(indexScen)+objData.ScenTimeComp-1)...
                                + (1/scenProbabilities(indexScen))*(objData.costMoneyCoef(objData.VarsIndexes{2,objData.indexSetGTDStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTDStr}(indexScen)+objData.ScenTimeComp-1))'*optResult(objData.VarsIndexes{2,objData.indexSetGTDStr}(indexScen):objData.VarsIndexes{2,objData.indexSetGTDStr}(indexScen)+objData.ScenTimeComp-1)...
                                + objData.batCostObj.CalcEquivDailyBESSCost(optResult(objData.TotalVarsNum),...
                                  optResult(objData.TotalVarsNum-1));
                            end
                        end
                        
                        % ------------------- EXPECTED --------------------
                        ExpctedTotalFuelConsumption = objData.fuelConsuptionTotalScen*scenProbabilities;
                        ExpectedTotalDumpedEnergy = objData.dumpedTotalEnergyScen*scenProbabilities; 
                        BESSequivCostPerScen =objData.batCostObj.CalcEquivDailyBESSCost(optResult(objData.TotalVarsNum),...
                            optResult(objData.TotalVarsNum-1));
                        BESSCAPEX = objData.batCostObj.BESS_CAPEX;
                        ExpectedTotalCost = objData.costMoneyCoef'*optResult;
                        ExpectedTotalCO2emis = ExpctedTotalFuelConsumption*objData.GTCostObj.mCO2/1000;
                        
                        
                        % -------------------- PRINTS ---------------------
                        if objData.dispControl == 1
                            toDisp1 = [' Capacity: ',num2str(optResult(objData.TotalVarsNum)),' MWh'];
                            disp(toDisp1)
                            toDisp2 = [' Power: ',num2str(optResult(objData.TotalVarsNum-1)),' MW'];
                            disp(toDisp2)
                            toDisp3 = [' Expected daily Total cost: ',num2str(ExpectedTotalCost),' €/Day '];
                            disp(toDisp3)
                            toDisp4=[' Expected daily CO2 emissions: ',num2str(ExpectedTotalCO2emis),' tn'];
                            disp(toDisp4)
                            toDisp5=[' Expected daily Dumped energy: ',num2str(ExpectedTotalDumpedEnergy),' MWh'];
                            disp(toDisp5)
%                             toDisp6=[' Expected daily Fuel consumption: ',num2str(ExpctedTotalFuelConsumption/1000),' tn'];
%                             disp(toDisp6)
                            %                         Z5=('-----------');
                            %                         disp(Z5)
                            %                         Z2=[' Expected daily HVDC cost: ',num2str(costPFS),' €/Day'];
                            %                         disp(Z2)
                            %                         Z3=[' Expected daily Wind-BESS-GT cost: ',num2str(E_costB),' €/Day'];
                            %                         disp(Z3)
                            %                         Z6=[' Expected daily Wind-GTs cost: ',num2str(E_costNoB),' €/Day'];
                            %                         disp(Z6)
                            toDisp6=('-----------');
                            disp(toDisp6)
                            toDisp7=[' BESS CAPEX: : ',num2str(BESSCAPEX),' €'];
                            disp(toDisp7)
                            disp(toDisp6)
                            disp(toDisp6)
                            %                         toDisp8=[' Objective Value : ',num2str(strcGurobi.objval),' €'];
                            %                         disp(toDisp8)
                            %                         toDisp9=[' Best Bound : ',num2str(strcGurobi.objbound),' €'];
                            %                         disp(toDisp9)
                        end

                        % -------------------- PLOTS ----------------------
                        
                        if objData.figControl == 1
                            
%                             % ////// PLOT 1: DUMP POWER + BESS POWER //////
%                             figure;
%                             plot(objData.dumpedEnergy,'-b','LineWidth',1.2);hold on;plot(Pdump,'-c','LineWidth',1.2);
%                             % Plot BESS Power as follows: Charge --> Green | Discharge --> Red
%                             xpoints=1:objData.ScenTimeComp*objData.ScenNum;
%                             ypoints=objData.batteryPower;
%                             stem(xpoints,ypoints,'-.k','LineWidth',1.3);
% %                             plot(xpoints,ypoints,'-.k','LineWidth',1.3);
%                             hold on
%                             for k=1:length(ypoints)
%                                 if ypoints(k)<0      % Charge (Load for the system)
%                                     plot(xpoints(k),ypoints(k),'o','MarkerEdgeColor','k','MarkerFaceColor',[0.4660 0.6740 0.1880],'MarkerSize',6);
%                                 elseif ypoints(k)>0  % Discharge (Generator for the system)
%                                     plot(xpoints(k),ypoints(k),'o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',6);
%                                 else                 % Idle
%                                     plot(xpoints(k),ypoints(k),'o','MarkerEdgeColor','k','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerSize',6);
%                                 end
%                             end
%                             ax = gca;
%                             legend(ax,{'P_{dump}^{BESS}','P_{dump}^{NO BESS}','P_{bat}'},'FontSize',12,'Fontname','Times New Roman','interpreter','tex','Location','northeast');
%                             dim = [.15 .6 .3 .3];
%                             str = {'\color[rgb]{0.4660,0.6740,0.1880} \fontsize{12} \it \bf Charging Mode',...
%                                 '\color{red} \fontsize{12} \it \bf Discharging Mode',...
%                                 '\color[rgb]{0.9290,0.6940,0.1250} \fontsize{12} \it \bf Idling Mode'};
%                             annotation('textbox',dim,'String',str,'FitBoxToText','on',...
%                                 'Margin',1,'FontSize',10,'Interpreter','tex');
%                             ax.XLabel.Interpreter = 'tex';
%                             ax.XLabel.String = 'Scenarios';
%                             ax.XLabel.Color = 'black';
%                             ax.XLabel.FontSize  = 12;
%                             ax.XLabel.FontName = 'Times New Roman';
%                             ax.XLabel.FontWeight = 'bold';
%                             ax.XGrid = 'on';
%                             ax.YGrid = 'off';
% 
%                             ax.XTick = 1:objData.ScenTimeComp:length(objData.batterySOC);
%                             ax.XTickLabel = ScenLabels;
%                             ax.TickLabelInterpreter = 'tex';
%                             ax.XLim = [1 objData.ScenTimeComp*objData.ScenNum];
%                             ax.YAxis(1).Label.Interpreter = 'tex';
%                             ax.YAxis(1).Label.String = 'P_{dump}  /  P_{bat}  [MW]';
%                             ax.YAxis(1).Label.FontWeight = 'normal';
%                             ax.YAxis(1).Color = 'black';
%                             ax.YAxis(1).FontName = 'Times New Roman';
%                             ax.YAxis(1).FontSize  = 12;
%                             
%                             ax.Title.String = ['P_{BESS} and P_{DUMP} (Scenarios #: ' num2str(objData.ScenNum) ')'];
%                             ax.Title.FontWeight = 'normal';
% 
%                             
%                             yyaxis right;
%                             
%                             plot(LOAD-RESGEN,'--m','LineWidth',1.8,'DisplayName','Net Load');hold on;
%                             
%                             ax.YAxis(2).Label.Interpreter = 'tex';
%                             ax.YAxis(2).Label.String = 'Net Load [MW]';
%                             ax.YAxis(2).FontWeight = 'normal';
%                             ax.YAxis(2).Color = 'black';
%                             ax.YAxis(2).FontName = 'Times New Roman';
% 
%                             hold off;
                            
                            
                            
%                             % ///////// PLOT 2: BESS POWER + SOC //////////
%                             figure;
%                             plot(objData.batteryPower,'--k','LineWidth',1);ylabel('P_{bat} [MW]','FontWeight','normal');
%                             yyaxis right;ylim([0 1]);plot(objData.batterySOC,'-.g','LineWidth',1);
%                             ylabel('State of Charge [-]','Color','g');
%                             legend('Battery Power','SoC');
%                             ax = gca;
%                             ax.XGrid = 'on';
%                             ax.YGrid = 'off';
%                             ax.YAxis(2).Color = 'black';
%                             xticks(0:objData.ScenTimeComp:length(objData.batterySOC)-1)
%                             xticklabels(ScenLabels)
%                             ylim([-0.1 1.2]);
%                             xlabel('Scenarios','FontWeight','bold');
%                             xlim([1 objData.ScenTimeComp*objData.ScenNum]);
%                             title(['P_{BESS} & SOC (Scenarios #: ' num2str(objData.ScenNum) ')']);
                            
                            
%                             % /////////////// PLOT 3: GT POWER ////////////
%                             figure;
%                             switch objData.Ngt
%                                 case 1
%                                     plot(objData.powerGTA,'-k','LineWidth',1.2);hold on;plot(PgtTot,'--r','LineWidth',1.5);
%                                     legend('P_{GTA}','NO BESS');
%                                     ax = gca;
%                                     ax.XGrid = 'on';
%                                     ax.YGrid = 'off';
%                                     xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
%                                     xticklabels(ScenLabels)
%                                     xlabel('Scenarios','FontWeight','bold');
%                                     xlim([1 objData.ScenTimeComp*objData.ScenNum]);
%                                     ylabel('P_{GT}  [MW]');
%                                     title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
%                                 case 2
%                                     plot(objData.powerGTA,'-k','LineWidth',1.2);hold on;
%                                     plot(objData.powerGTB,'--k','LineWidth',1.2);plot(PgtTot,'--r','LineWidth',1.5);
%                                     legend('P_{GTA}','P_{GTB}','NO BESS');
%                                     ax = gca;
%                                     ax.XGrid = 'on';
%                                     ax.YGrid = 'off';
%                                     xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
%                                     xticklabels(ScenLabels)
%                                     xlabel('Scenarios','FontWeight','bold');
%                                     xlim([1 objData.ScenTimeComp*objData.ScenNum]);
%                                     ylabel('P_{GT}  [MW]');
%                                     title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
%                                 case 3
%                                     plot(objData.powerGTA,'-k','LineWidth',1.2);hold on;
%                                     plot(objData.powerGTB,'--k','LineWidth',1.2);
%                                     plot(objData.powerGTC,':k','LineWidth',1.2);plot(PgtTot,'--r','LineWidth',1.5);
%                                     legend('P_{GTA}','P_{GTB}','P_{GTC}','NO BESS');
%                                     ax = gca;
%                                     ax.XGrid = 'on';
%                                     ax.YGrid = 'off';
%                                     xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
%                                     xticklabels(ScenLabels)
%                                     xlabel('Scenarios','FontWeight','bold');
%                                     xlim([1 objData.ScenTimeComp*objData.ScenNum]);
%                                     ylabel('P_{GT}  [MW]');
%                                     title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
%                                 case 4
% %                                     plot(objData.powerGTA,'-k','LineWidth',1.2);hold on;
% %                                     plot(objData.powerGTB,'--k','LineWidth',1.2);
% %                                     plot(objData.powerGTC,':k','LineWidth',1.2);
% %                                     plot(objData.powerGTD,'-.k','LineWidth',1.2);
% %                                     plot(PgtTot,'--r','LineWidth',1.5);
%                                     plot(objData.powerGTA,'LineWidth',1.2);hold on;
%                                     plot(objData.powerGTB,'LineWidth',1.2);
%                                     plot(objData.powerGTC,'LineWidth',1.2);
%                                     plot(objData.powerGTD,'LineWidth',1.2);
%                                     plot(PgtTot,'-k','LineWidth',1.5);
%                                     colormap(summer(objData.Ngt));
%                                     legend('P_{GTA}','P_{GTB}','P_{GTC}','P_{GTD}','GT_{A+B+C+D}^{ref}');
%                                     ax = gca;
%                                     ax.XGrid = 'on';
%                                     ax.YGrid = 'off';
%                                     xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
%                                     xticklabels(ScenLabels)
%                                     xlabel('Scenarios','FontWeight','bold');
%                                     xlim([1 objData.ScenTimeComp*objData.ScenNum]);
%                                     ylabel('P_{GT}  [MW]');
%                                     title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
%                             end
                            
                            % /// PLOT 4: Load-RES Power///
                            figure;
                            set(gcf,'Name','Load-RES Power','NumberTitle','off')
                            plot(LOAD,'-r','LineWidth',1.8);hold on;
                            plot(RESGEN,'-g','LineWidth',1.8);ylabel('P_{load}  /  P_{res}  [MW]');
%                             yyaxis right;plot(objData.batteryPower,'--k','LineWidth',1.1);
                            legend('Load','Wind Power');
%                             ylabel('P_{bat} [MW]','Color','k');
                            xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                            xlabel('Scenarios','FontWeight','bold');
                            ax = gca;
                            ax.XGrid = 'on';
                            ax.YGrid = 'off';
%                             ax.YAxis(2).Color = 'black';
                            xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                            xticklabels(ScenLabels)
                            title(['Scenarios: ' num2str(objData.ScenNum)]);
                            
                            % ///////// PLOT 1: GT Schedule (bars) ///////////
                            figure;
                            set(gcf,'Name','GT Schedule','NumberTitle','off')
                            switch objData.Ngt
                                case 1
                                    xbar = [1:length(objData.batterySOC)];
                                    ybar= [objData.powerGTA]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    colormap(summer(size(ybar,2)));
                                    grid on
                                    l = cell(1,1);
                                    l{1}='GT A';
                                    legend(bplotobj,l);
                                    plot(PgtTot,'-k','LineWidth',1.5,'DisplayName','GT_{A}^{ref}');hold off;
                                    title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
                                case 2
                                    xbar = [1:length(objData.batterySOC)];
                                    ybar= [objData.powerGTA;objData.powerGTB]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    colormap(summer(size(ybar,2)));
                                    grid on
                                    l = cell(1,2);
                                    l{1}='GT A'; l{2}='GT B'; 
                                    legend(bplotobj,l);
                                    plot(PgtTot,'-k','LineWidth',1.5,'DisplayName','GT_{A+B}^{ref}');hold off;
                                    title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
                                case 3
                                    xbar = [1:length(objData.batterySOC)];
                                    ybar= [objData.powerGTA;objData.powerGTB;objData.powerGTC]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    colormap(summer(size(ybar,2)));
                                    grid on
                                    l = cell(1,3);
                                    l{1}='GT A'; l{2}='GT B'; l{3}='GT C'; 
                                    legend(bplotobj,l);
                                    plot(PgtTot,'-k','LineWidth',1.5,'DisplayName','GT_{A+B+C}^{ref}');hold off;
                                    title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
                                case 4
                                    xbar = [1:length(objData.batterySOC)];
                                    ybar= [objData.powerGTA;objData.powerGTB;objData.powerGTC;objData.powerGTD]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    colormap(summer(size(ybar,2)));
                                    grid on
                                    l = cell(1,4);
                                    l{1}='GT A'; l{2}='GT B'; l{3}='GT C'; l{4}='GT D';
                                    legend(bplotobj,l);
                                    plot(PgtTot,'-k','LineWidth',1.5,'DisplayName','P_{GT}^{No BESS}');hold off;
                                    title(['Scenarios: ' num2str(objData.ScenNum)]);
                            end
                            
                            
                            % /////////// PLOT 6: Power Scheduling //////////////
                            figure;
                            set(gcf,'Name','Power Scheduling','NumberTitle','off')
                            switch objData.Ngt
                                %{
                                case 1
                                    xbar = [1:length(objData.batterySOC)];
                                    ybar= [objData.powerGTA]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    colormap(summer(size(ybar,2)));
                                    grid on
                                    l = cell(1,1);
                                    l{1}='GT A';
                                    legend(bplotobj,l);
                                    plot(PgtTot,'-k','LineWidth',1.5,'DisplayName','GT_{A}^{ref}');hold off;
                                    title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
                                case 2
                                    xbar = [1:length(objData.batterySOC)];
                                    ybar= [objData.powerGTA;objData.powerGTB]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    colormap(summer(size(ybar,2)));
                                    grid on
                                    l = cell(1,2);
                                    l{1}='GT A'; l{2}='GT B'; 
                                    legend(bplotobj,l);
                                    plot(PgtTot,'-k','LineWidth',1.5,'DisplayName','GT_{A+B}^{ref}');hold off;
                                    title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
                                case 3
                                    xbar = [1:length(objData.batterySOC)];
                                    ybar= [objData.powerGTA;objData.powerGTB;objData.powerGTC]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    colormap(summer(size(ybar,2)));
                                    grid on
                                    l = cell(1,3);
                                    l{1}='GT A'; l{2}='GT B'; l{3}='GT C'; 
                                    legend(bplotobj,l);
                                    plot(PgtTot,'-k','LineWidth',1.5,'DisplayName','GT_{A+B+C}^{ref}');hold off;
                                    title(['GT POWER (Scenarios: ' num2str(objData.ScenNum) ')']);
                                %}
                                case 4
                                    xbar = (1:length(objData.batterySOC));
                                    ybar= [objData.powerGTA+objData.powerGTB+objData.powerGTC+objData.powerGTD;RESGEN';...
                                        objData.batteryPower;objData.dumpedEnergy]';
                                    bplotobj = bar(xbar,ybar,'stacked'); hold on;
                                    xticks(1:objData.ScenTimeComp:length(objData.batterySOC))
                                    xticklabels(ScenLabels)
                                    xlabel('Scenarios','FontWeight','bold');
                                    xlim([1 objData.ScenTimeComp*objData.ScenNum]);
                                    ax = gca;
                                    ax.XGrid = 'on';
                                    ax.YGrid = 'off';
                                    
                                    bplotobj(1).FaceColor = [0.4940 0.1840 0.5560];
                                    bplotobj(2).FaceColor = [0.3010 0.7450 0.9330];
                                    
                                    bplotobj(3).FaceColor = [0.4660 0.6740 0.1880];
                                    bplotobj(4).FaceColor = [0.6350 0.0780 0.1840];
                                    
                                    grid on
                                    l = cell(1,4);
                                    l{1}='P_{GT}'; l{2}='P_{Wind}'; l{3}='P_{BESS}'; l{4}='P_{Dump}';
                                    legend(bplotobj,l);
                                    stemObj = stem(xbar,PgtTot,'--k','LineWidth',1.5,'DisplayName','P_{GT}^{No BESS}');
                                    stemObj.MarkerFaceColor = 'k';
                                    plot(xbar,LOAD','-r','LineWidth',2,'DisplayName','Load');hold off;
                                    title(['Scenarios: ' num2str(objData.ScenNum)]);
                            end
                            
                            % ////// PLOT 7: BESS-Dump Energy //////
                            figure;
                            set(gcf,'Name','BESS-Dump Energy','NumberTitle','off')
                            plot(objData.dumpedEnergy,'-b','LineWidth',1.3);hold on;plot(Pdump,'--k','LineWidth',1.5);
                            % Plot BESS Power as follows: Charge --> Green | Discharge --> Red
                            xpoints=1:objData.ScenTimeComp*objData.ScenNum;
                            ypoints=objData.batteryPower;
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
%                             hold off
                            
                            ax = gca;
%                             legend(ax,{'P_{dump}^{BESS}','P_{dump}^{NO BESS}','P_{bat}','SoC'},'FontSize',12,'Fontname','Times New Roman','interpreter','tex','Location','northeast');
                            
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


                            ax.XTick = 1:objData.ScenTimeComp:length(objData.batterySOC);
                            ax.XTickLabel = ScenLabels;
                            ax.TickLabelInterpreter = 'tex';
                            ax.XLim = [1 objData.ScenTimeComp*objData.ScenNum];
                            ax.YAxis(1).Label.Interpreter = 'tex';
                            ax.YAxis(1).Label.String = 'P_{dump}  /  P_{bat}  [MW]';
                            ax.YAxis(1).Label.FontWeight = 'normal';
                            ax.YAxis(1).Color = 'black';
                            ax.YAxis(1).FontName = 'Times New Roman';
                            ax.YAxis(1).FontSize  = 12;
                            
                            ax.Title.String = ['Scenarios #: ' num2str(objData.ScenNum)];
                            ax.Title.FontWeight = 'normal';

                            
                            yyaxis right;
                            
                            barObj1=bar(xpoints,objData.batterySOC,'FaceColor',[.5 .5 .5],'EdgeColor','none'); hold on;
                            barObj2=bar(xpoints,ones(1,length(objData.batterySOC)),'FaceColor','none','EdgeColor',[0 0 0],'LineWidth',1.1); hold on;
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

                        end

        end
        % -----------------------------------------------------------------
         % ---Method 7:
        function [powerGTTotCapped,dumpingPower] = NoBESSCase(objData,LOAD,RESGEN)
            %NoBESSCase Calculate the reference case (No BESS)
            %   Example: [PgtTot,Pdump]=prob.NoBESSCase(LOAD,RESGEN);
            %            (prob is the object)
            
            
            if size(LOAD,2)>= 2 || size(RESGEN,2)>= 2
                error('This method required vectorized (ungrouped) data');
            end
            
            netLoad = LOAD-RESGEN;
            powerGTTotCapped=zeros(1,objData.ScenTimeComp*objData.ScenNum);
            powerGTEachCapped=zeros(1,objData.ScenTimeComp*objData.ScenNum);
            switch objData.Ngt
                case 1
%                     for scn=1:objData.ScnNum
                        for i=1:length(LOAD)
                            if netLoad(i)<= 0
                                powerGTTotCapped(i) = 0;
                            elseif netLoad(i)<= objData.PgtMin
                                powerGTTotCapped(i)=objData.PgtMin;
                            else
                                powerGTTotCapped(i)=netLoad(i);
                                powerGTEachCapped(i)=powerGTTotCapped(i);
                            end
                        end
                        dumpingPower = powerGTTotCapped'-netLoad;
%                     end
                case 2
                    for i=1:length(LOAD)
                        if netLoad(i)<= 0
                            powerGTTotCapped(i) = 0;
                        elseif netLoad(i)<= objData.PgtMin
                            powerGTTotCapped(i)=objData.PgtMin;
                        elseif netLoad(i)<= 2*objData.PgtMin
                            powerGTTotCapped(i)=2*objData.PgtMin;
                        else
                            powerGTTotCapped(i)=netLoad(i);
                            powerGTEachCapped(i)=powerGTTotCapped(i)/2;
                        end
                    end
                    dumpingPower = powerGTTotCapped'-netLoad;
                case 3
                    for i=1:length(LOAD)
                        if netLoad(i)<= 0
                            powerGTTotCapped(i) = 0;
                        elseif netLoad(i)<= objData.PgtMin
                            powerGTTotCapped(i)=objData.PgtMin;
                        elseif netLoad(i)<= 2*objData.PgtMin
                            powerGTTotCapped(i)=2*objData.PgtMin;
                        elseif netLoad(i)<= 3*objData.PgtMin
                            powerGTTotCapped(i)=3*objData.PgtMin;
                        else
                            powerGTTotCapped(i)=netLoad(i);
                            powerGTEachCapped(i)=powerGTTotCapped(i)/3;
                        end
                    end
                    dumpingPower = powerGTTotCapped'-netLoad;
                case 4

                    
%                     for i=1:length(LOAD)
%                         if netLoad(i)<= 0
%                             powerGTTotCapped(i) = 0;
%                         elseif netLoad(i)<= objData.PgtMin
%                             powerGTTotCapped(i)=objData.PgtMin;
%                         elseif netLoad(i)<= objData.PgtMax
%                             powerGTTotCapped(i)= netLoad(i);
%                         elseif netLoad(i)<= objData.PgtMax + objData.PgtMin
%                             powerGTTotCapped(i)= objData.PgtMax + objData.PgtMin;
% %                             powerGTTotCapped(i)= netLoad(i);
%                         elseif netLoad(i)<= 2*objData.PgtMax
%                             powerGTTotCapped(i) = netLoad(i);
%                         elseif netLoad(i)<= 2*objData.PgtMax + objData.PgtMin
%                             powerGTTotCapped(i)= 2*objData.PgtMax + objData.PgtMin;
%                         elseif netLoad(i) <= 3*objData.PgtMax
%                             powerGTTotCapped(i) = netLoad(i);
%                         elseif netLoad(i)<= 3*objData.PgtMax + objData.PgtMin
%                             powerGTTotCapped(i)= 3*objData.PgtMax + objData.PgtMin;
%                         else
%                             powerGTTotCapped(i)=netLoad(i);
%                             powerGTEachCapped(i)=powerGTTotCapped(i)/4;
%                         end
%                     end

                    for i=1:length(LOAD)
                        if netLoad(i)<= 0
                            powerGTTotCapped(i) = 0;
                        elseif netLoad(i)<= objData.PgtMin
                            powerGTTotCapped(i)=objData.PgtMin;
                        else 
                            powerGTTotCapped(i)= netLoad(i);
                        end
                    end
                    
                    dumpingPower = powerGTTotCapped'-netLoad;
            end
            powerGTTotCapped = powerGTTotCapped';
        end
        % -----------------------------------------------------------------
        
        
                

        
    end % normal methods
    
end % classdef

