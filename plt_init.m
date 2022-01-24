%% --------------- NEEDED FOR PRODUCING FIGURE FILES ----------------------
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