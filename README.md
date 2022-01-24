# BESS-SIZING
This repository contains the scripts :scroll: and data :open_file_folder: used for the BESS-SIZING paper :page_facing_up:.
 
 ## DataX package :package: ## 
 
 _Specialized properties and methods offered for DataX objects :arrow_down:_
 
 1. ### PROPERTIES :bar_chart: ###
    `preamble.m` assigns :paperclip: parameter values to variable <code>par</code>.

    <details>
     <summary> Default <code>par</code> values  :1234:</summary>
 
     <br/>
 
     __Geenric__ 
     * `par.Ts = 15`                                     % Timestep (minutes)
     * `par.dol2eur    = 0.89`                           % dollars to euros conversion
     * `par.rhoGas     = 0.717`                          % Natural Gas density [kg/m^3]
 
     <br/>
 
      __Sets__
     * `par.N_pwl = 11`      % # of discretization points for PieceWise Linear approx.
     * `par.N_gt  = 4`       % # of Gas Turbines
     * `par.N_scn = 10`      % # of scenarios
 
     <br/>
 
      __Random forests__
     * `par.leafSizeIdx = 1`
     * `par.lamda       = 0.5`
     * `par.tau         = linspace(0,1,21)`
     * `par.lagsNum     = 6`
 

   </details>
       
    
 2. ### METHODS :crystal_ball: ###
   - `funScenGenQRF1.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; issue  K steps ahead scenarios forecasts at time _t_
   - `funScenGenQRF.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; issue K steps ahead scenarios forecasts itteratively for _t>1_ (_used with_ `funAnimateQRF.m`)
   - `funScenFrcstFig1step.m` &nbsp; plot K steps ahead scenario forecasts for selected time _t_
   - `funProbFrcstFig1step.m` &nbsp; plot K steps ahead quantile forecasts for selected time _t_
   - `funFrcstFig1step.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; plot both scenario and quantile K steps ahead forecasts for selected time _t_
   - `funAnimateQRF.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; produce forecasting animation (_.gif_) for itterative forecasts (_t>1_)              
 
 ## MAIN RESULTS  :notebook_with_decorative_cover: ## 

 1. __PAPER FIGURES__  
    * `Paper_Plots.m` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; generate _Figure 1_ and _Figures 3-8_ of the paper

     1. Plot generated scenarios 
    
        `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J1_PAPER_V02\BESS-SIZING\DataFiles\ReferenceScenarioSets\Ref50Scens.mat')`
        
     2. bLA bLA `load('\DataTot.mat')`


 <details>
  <summary> Default <code>input</code> values :1234:</summary>

  * `input.startingDay  = 100`
  * `input.durationDays = 1`
  * `input.giveStartingTime = 0`              % {0, 1}
  * `inut.startingTime = 7630`
  * `input.doAnimation = 0`                   % {0, 1}
  * `input.animationVar = 'load'`             % {'load', 'wind'}
  * `input.randomSeed = 24`
  * `input.method = 'scn_frcst'`              % {'point_frcst', 'scn_frcst'}
  * `input.degradWeight = 'noWeight'`         % {'noWeight','none', 'normal', 'low', 'medium', 'high'}
  * `input.N_steps = 300`
  * `input.N_prd = 6`                         % {_MPC simulation_, _CRPS calculation_} = {6, 12}
  * `input.lgdLocationDstrb = 'southwest'`
  * `input.lgdLocationIgtOn = 'southeast'`
  * `input.lgdLocationSoC = 'southeast'`

</details>
   


## NUMERICAL EXPERIMENTS :hourglass: ##

  1.  ___PREQUISITES___
    
      1. _Load data:_
    
          `load('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\DataTot.mat')`

          - `DataTot.mat` &nbsp;&nbsp;(_All required data_)
    
      2. _Pre-process data:_
 
         `run('\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\EQUINOR\EquiData.m')`

<details>
  <summary>Cases studies (Section 4.2) :date:</summary>
  
 
  <code>input.durationDays</code> = 1 and <code>input.giveStartingTime</code> = 0          
 
  * <code>input.startingDay</code>=100 (10 April)
  * <code>input.startingDay</code>=118 (27 April)
  * <code>input.startingDay</code>=226 (14 August)
  * <code>input.startingDay</code>=61 (02 March)
  * <code>input.startingDay</code>=166 (15 June)
  * <code>input.startingDay</code>=160 (09 June)

</details>


<details>
  <summary>Irregular events (Section 4.1.2) :date:</summary>
  
 
  <code>input.durationDays</code> = 0 and <code>input.giveStartingTime</code> = 1 and <code>par.N_scn</code> = 25 (for scenarios visualization) 
 
  __Load__ 
  * <code>inut.startingTime</code>= 7630
  * <code>inut.startingTime</code>= 7635
  * <code>inut.startingTime</code>= 7636
  * <code>inut.startingTime</code>= 7709
 
   __Wind__ 
  * <code>inut.startingTime</code>= 7646
  * <code>inut.startingTime</code>= 7647
  * <code>inut.startingTime</code>= 7648
  * <code>inut.startingTime</code>= 7649
 
  * <code>inut.startingTime</code>= 7760
  * <code>inut.startingTime</code>= 7761
  * <code>inut.startingTime</code>= 7762
  * <code>inut.startingTime</code>= 7763

</details>

## DATA FILES :open_file_folder: ##
- [ ] To upload the data
