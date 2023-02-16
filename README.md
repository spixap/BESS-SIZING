# BESS-SIZING
This repository contains the scripts :scroll: and data :open_file_folder: used for the [paper](https://www.sciencedirect.com/science/article/pii/S2352152X2200336X/ "Named link title"). :page_facing_up:.
 
 - README under construction :wrench: :heavy_exclamation_mark:
 
 ## DataX package :package: (TODO) ## 
 
 1. ### PROPERTIES ###
    - `parPlaceholder` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; placeholder for parameters

    
 2. ### METHODS ###
    - `funPlaceholder.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; placeholder for methods
 
 ## MANUSCRIPT FIGURES  :notebook_with_decorative_cover: ## 
  
   * `Paper_Plots.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; generate _Figure 1_ and _Figures 3-8_ of the paper
   
   __Datasets required for plots__
    
   1. Plot generated scenarios 
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat')`
        
   2. Plot historical datasets
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat')`
        `run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m')`
        
   3. Plot map figures
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat')`
        
   4. Plot densities figures
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat')`
        `run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m')`
        
   5. Plot cost cdf comparison - beta=1 | alpha = 0.9 or 0.96
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-      SIZING\DataFiles\RiskAnalysis\Risk_b1_a09.mat','riskPlot01','allScensResults01','LscensProbVec');
         riskPlot01 = riskPlot;
         allScensResults01 = allScensResults;
         load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\RiskAnalysis\Risk_b1_a096.mat','riskPlot02','allScensResults02');
         riskPlot02 = riskPlot;
         allScensResults02 = allScensResults;`
        
   6. Plot cost cdf comparison - alpha=0.8 | beta = 0 or 1
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-   SIZING\DataFiles\RiskAnalysis\Risk_a08_b0_gap017.mat','riskPlot','allScensResults','LscensProbVec');
        riskPlot01 = riskPlot;
        allScensResults01 = allScensResults;
        load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\RiskAnalysis\Risk_a08_b1_gap017.mat','riskPlot','allScensResults');
        riskPlot02 = riskPlot;
        allScensResults02 = allScensResults;`
        
   7. Plot sensitivity result
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\SensitivityAnalysis\SensitivityResult.mat')`
        
   8. seperate plots
        as in 7 but figures are independened, not subfigures
        
   9. Plot scenario selection process
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
         run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m');
         run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');
         load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat');`

   10. Plot datasets with sampled profiles
         `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat');
         run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m');
         run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\plt_init.m');
         load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat');`

   11. Plot stability results
         `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\StabilityTest\StabilityTest_10-Sep-2020-161628.mat')`
         
   12. Boxplots for methods comparison
         `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\StabilityTest\Stability_Compared.mat')`
         
   13. 3D - seperate plots
         `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceCase.mat')`
         `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat')`

