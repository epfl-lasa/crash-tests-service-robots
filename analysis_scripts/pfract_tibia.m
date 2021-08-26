% % Computing probability of bone fracture at the tibia
% Based on the latest data fitting provided by [Mildon 2018]
% This metric uses the internral tibia compression proximal forces to
% estimate the probaility of the tibia bone fracture with age, gender and
% weight distribution corrections.

% Author: Diego F. Paez G.
% Date: 18 Mar 2021
%% pAIS v1.01
% Inputs:
%           TibiaForcez: [REQ'D] scalar{double}; Proximal Tibia Force
%           Gender: [REQ'D] {char}; 'F' or 'M'
%           Mass: [REQ'D] scalar{doule}; Whole body weigth
%           Age: [REQ'D] scalar{doule}; Age range receives any age value
%                                       but it reality uses only the actual value for older than 40 y-o
%           ShowPlots:  [OPTIONAL]  {logical}    ;    Plot AIS scales and results (DEFAULT = FALSE)
%           figPath:  [OPTIONAL]  {char} ; path to save plots
%           nfig:  [OPTIONAL]  {scalar} ; figure number

%           
% Outputs:
%           AIS_p :     scalar {double} Prbability of Injury in the given scale [0-1]

% Examples:

% Copyright 2020, Dr. Diego Paez-G.
%%%

function [pFract] = pfract_tibia(TibiaForcez,Gender,Age,Mass,...
                                varargin)
    %        Parse User Inputs/Outputs                                        
    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x);
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
%     chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'TibiaForcez',chkscalar);
    addRequired(p,'Gender' , chkchar)
    addRequired(p,'Age', chkscalar)
    addRequired(p,'Mass', chkscalar)
    
    % Optional Inputs
    addOptional(p,'ShowPlots'   ,false      ,@islogical);
    addOptional(p,'nfig',1,chkscalar);
    
    parse(p,TibiaForcez,Gender,Age,Mass,varargin{:});
    
    %% =============== Plots setup ===================% 
    AxisPlots = [0 2000 0 1];
    PicSize = [10 10 800 800];
    FigureFile = 'png';
    FaceALphas = 0.18;
    FontSizes = 28;
    MarkersSizes = 14;
    LinesWidths = 2.8;
    figureFormat = 'epsc'; %'png'
    Fonts = 'Times New Roman';
    
    %% Adapting the probabilities of injury accordingly to Gender
    % These values were taken from the biomechanical results in [Mildon 2018]
    tiFactorsM = [17.6
                 7650
                 350
                 80
                 9250];
    tiFactorsF = [66
                 6750
                 8
                 80
                 8350];
    switch (Gender)
        case {'M'}
            GFact = tiFactorsM;
        otherwise
            % case {'F'}
            GFact = tiFactorsF;
    end
    
    %%  Creating the functions depending on age and mass
    % Ref: [Mildon 2018]s
    RamgY = @(Fz,GFactors)((Fz./GFactors(1)).*(GFactors(2)/(Mass+GFactors(3))));
    Ramg40 = (@(Fz,GFactors)(Fz./GFactors(1)).* ...
                (((Age^2)- Age*GFactors(4)+ GFactors(5))./(Mass+GFactors(3)) ));
    Ramg75 = (@(Fz,GFactors)(Fz./GFactors(1)).* ...
                (((75^2)- 75*GFactors(4)+ GFactors(5))./(Mass+GFactors(3)) ));
    if Age<=40
        Ramg = RamgY;
    else
        Ramg = Ramg40;
    end
    
    %% Computing the actual probability 
    pFTI = @(Famg)(1 - exp(- (Famg./9.8617).^4.277));
    
    presult = pFTI(Ramg(abs(TibiaForcez),GFact));
    
    if p.Results.ShowPlots
        xFz=[0:0.1:16]';
        AxisPlots = [0 xFz(end) 0 1];
%                 yHIC=AISpH15(coefsHIC15_H3(3,:),xHIC);
        figName = 'pTibia-fracture-Age-Mass-Gender';
        plegends={'Male <40' 'Female <40' 'Male 75' 'Female 75'};
        hold on;
        plotNpairedData(p.Results.nfig,[xFz xFz xFz xFz],...
                             [...
                             pFTI(RamgY(xFz,tiFactorsM)),...
                             pFTI(RamgY(xFz,tiFactorsF)),...
                             pFTI(Ramg75(xFz,tiFactorsM)),...
                             pFTI(Ramg75(xFz,tiFactorsF)),...
                             ],...
                        '-',figName,plegends,...
                        'Proximal Tibia Force (kN)','Tibia Fracture Probability',...
                        false,pwd,figureFormat,AxisPlots,1);
        hold on;
            plot([0 abs(TibiaForcez)],[presult presult],...
                    '-.k','linewidth',2);
        hold on;
            plot([abs(TibiaForcez) abs(TibiaForcez)],[0 presult],...
                '-.k','linewidth',2);
        hLegend = legend( ...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'vertical',...
                  'location', 'SouthEast' );
        set(gcf, 'Position', PicSize);
        set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
    end

    pFract = presult;

end

    