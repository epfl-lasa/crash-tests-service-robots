% % Computing the Revised Tibia Index Criteria
% Based on the latest data fitting provided by [Kuppa-2001]
% This metric uses the internral tibia compression proximal forces to
% estimate an index between 0-2

% Author: Diego F. Paez G.
% Date: 18 Mar 2021
%% RTI_criteria
% Inputs:
%           TibiaForcez: [REQ'D] vector{{'double'},{'column'}}; 
%                               Proximal Tibia Force [N]
%           TibiaMomentX: [REQ'D] vector{{'double'},{'column'}}; Tibia Moment Medial-lateral
%           TibiaMomentY: [REQ'D] vector{{'double'},{'column'}}; Tibia Moment santerior-posterior

%           ShowPlots:  [OPTIONAL]  {logical}    ;    Plot AIS scales and results (DEFAULT = FALSE)
%           figPath:  [OPTIONAL]  {char} ; path to save plots
%           nfig:  [OPTIONAL]  {scalar} ; figure number
%           
% Outputs:
%           RTI :     scalar {double} index between 0-2

% Examples:

% Copyright 2020, Dr. Diego Paez-G.
%%%

function [RTI_value, RTI_indx] = RTI_criteria(TibiaForcez,TibiaMomentX,TibiaMomentY,...
                                varargin)
    %        Parse User Inputs/Outputs                                        
    p = inputParser;
    chkVector     = @(x) validateattributes(x ,{'double'},{'column'}, mfilename,'outputPath',1);
    chkscalar     = @(x) isnumeric(x) && isscalar(x);
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
%     chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'TibiaForcez',chkVector);
    addRequired(p,'TibiaMomentX',chkVector);
    addRequired(p,'TibiaMomentY',chkVector);
    
    % Optional Inputs
    addOptional(p,'ShowPlots'   ,false      ,@islogical);
    addOptional(p,'nfig',1,chkscalar);
    
    parse(p,TibiaForcez,TibiaMomentX,TibiaMomentY,varargin{:});
    
    
    %% =============== Plots setup ===================% 
    AxisPlots = [0 2000 0 1];
    PicSize = [10 10 880 400];
    FigureFile = 'png';
    FaceALphas = 0.18;
    FontSizes = 28;
    MarkersSizes = 14;
    LinesWidths = 2.8;
    figureFormat = 'epsc'; %'png'
    Fonts = 'Times New Roman';
    
    %% Reference values for an adult dummy male 50-percentile
    % These values were taken from the fitting results in [Kuppa2001]
    
    if true % values for RTI
        Fzc = 12;% [kN]
        Mrc = 240;% [Nm]
    else % values for TI
        Fzc = 35.9;% [kN]
        Mrc = 225;% [Nm]
    end
    
    % Ref: [Mildon 2018]
    
    fRTI = @(Fz,Mr)((Fz./Fzc) + (Mr./Mrc));
    
    %% Computing the actual probability 
    Mres = sqrt( TibiaMomentX.^2 + TibiaMomentY.^2);
    
    wholeRTI = fRTI(TibiaForcez./1e3 ,Mres);
    [RTI_value, RTI_indx] = max(wholeRTI);
    
    if p.Results.ShowPlots

    %                 AxisPlots = [0 xthCC(end) 0 1];
            figName = 'RTI';
    %                 plegends={'AIS3+'};
            plot(wholeRTI)
    %                 plotNpairedData(p.Results.nfig,[xthCC],...
    %                                      [Mres, TibiaForcez],...
    %                                 '-',figName,plegends,...
    %                                 'Thorax CC','Thorax Injury Probability',...
    %                                 false,pwd,figureFormat,AxisPlots,1);
            hold on;
    %                 for iAISlevel=2:4
                plot([0 RTI_indx],[RTI_value RTI_value],...
                        '-.k','linewidth',3);
    %                 end
            hold on; 
            plot([RTI_indx RTI_indx],[0 RTI_value],...
                '--k','linewidth',2);
    %                 hLegend = legend( ...
    %                           plegends, ...
    %                           'FontName',Fonts,...
    %                           'FontSize', FontSizes,'FontWeight','bold',...
    %                           'orientation', 'vertical',...
    %                           'location', 'SouthEast' );
            set(gcf, 'Position', PicSize);
            set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
        end
    
    
    [RTI_value, RTI_indx] = max(wholeRTI);

end

    