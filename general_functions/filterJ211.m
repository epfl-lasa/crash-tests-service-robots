function [coeff,Data_filt] = filterJ211(Data,dt,corner,varargin)
%% filterJ211 v1.03                                                   
% filterJ211 is simply a Matlab wrapper for the 
% BUTTERWORTH 4-POLE PHASELESS DIGITAL FILTER outlined in Appendix C of the
% SAE-J211 (revMARCH95) standard.
% <http://standards.sae.org/j211/1_201403/>
%
% Inputs:
%           Data  :  [REQ'D]    [m x 1]{double};   Column-wise vector of Unfiltered data
%           dt    :  [REQ'D]    scalar {double}    ;    Period (1/fs)
%           corner:  [REQ'D]    scalar {double}    ;    -3dB lowpass cutoff (in Hz)
%           ApplyFilter : [OPTIONAL]  {logical}    ;    Actually filter        (DEFAULT = TRUE)
%           ShowPlots   : [OPTIONAL]  {logical}    ;    Plot filt/orig signals (DEFAULT = FALSE)
%           
% 
% Outputs:
%           coeff     : struct with fields "A" and "B" will filter coeffs
%           Data_filt : 1xn vector {double} representing the filtered data
%
% Examples:
%           [coeffs, sig_out] = filterJ211(sig_in,1e-4,100,'ShowPlots',true)
%           filterJ211(sig_in,1e-4,100)               
%           *** RUN W/OUT OUTPUT ARGS TO AUTOMATICALLY PLOT RESULTS ***
%
% See also: 
% |filtfilt|

% Copyright 2015 E. Meade Spratley, PhD
%%%

%% Parse User Inputs/Outputs                                        
p = inputParser;

chkData     = @(x) validateattributes(x ,{'double'},{'column'}, mfilename,'outputPath',1);
chkDT       = @(d) validateattributes(d ,{'double'},{'scalar'}, mfilename,'dt'        ,2);
chkCorner   = @(d) validateattributes(d ,{'double'},{'scalar'}, mfilename,'CornerFreq',3);

% Required Inputs
addRequired(p,'Data'        ,chkData);
addRequired(p,'Dt'          ,chkDT);
addRequired(p,'CornerFreq'  ,chkCorner);

% Optional Inputs
addOptional(p,'ApplyFilter' ,true       ,@islogical);
addOptional(p,'ShowPlots'   ,false      ,@islogical);

parse(p, Data,dt,corner, varargin{:});

%% Distribute vars                                                  
parserFields = fieldnames(p); 
for ii = 1:length(parserFields)
    q.(parserFields{ii}) = p.(parserFields{ii});
end

if ismember('ShowPlots',p.UsingDefaults) && nargout == 0
    q.Results.ShowPlots   = true;
    q.Results.ApplyFilter = true;
end

Data    = q.Results.Data;
dt      = q.Results.Dt;
corner  = q.Results.CornerFreq;
order   = 2;  

%% Calculate Coefficients                                           
CFC = 0.6 * corner;
if round(corner,0) == 1650
    CFC  = 1000;
end

wd = 2*pi*CFC*2.0775;
wa = (sin(wd*dt/2))/(cos(wd*dt/2));

a0 = (wa^2)/(1+wa*(2^.5)+wa^2);
a1 = 2*a0;
a2 = a0;

b0 = 1;
b1 = -2*((wa^2)-1)/(1+wa*(2^.5)+wa^2);
b2 = (-1+wa*(2^.5)-wa^2) / (1+wa*(2^.5)+wa^2);

% Collect coefficients
b = [a0; a1; a2]';
a = [b0; -b1; -b2]';

coeff.A = repmat(a,[order/2,1]);
coeff.B = repmat(b,[order/2,1]);

%% Apply Phaseless Filter (using above coefficients)                
% Actually filter
if q.Results.ApplyFilter && license('test','Signal_Toolbox')
    try        
        % Requires Signal Processing Toolbox
        Data_filt = filtfilt(coeff.B,coeff.A,Data); % Use |filtfilt| for phaseless
        
    catch ME
        Data_filt = [];
        warning(ME.message)        
    end
else
    Data_filt = [];
end

%% Debug -- Show plots if no output args                            
if q.Results.ShowPlots
        fig1 = figure;
        ax1 = axes('Parent',fig1);    hold(ax1,'on');
        ylabel('Magnitude');
        grid(ax1,'on'); grid(ax1,'minor');
        
        plot(Data,'-','LineWidth',0.50,'DisplayName','Input Data');
        plot(Data_filt,'-','LineWidth',1,'DisplayName','Filtered Data');
        legend('-DynamicLegend');
        
        hold(ax1,'off')
end

