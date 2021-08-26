% % Computing Acc 3ms (Head Injury Criteria)
% Author: Diego F. Paez G.
% Date: 29 April 2020
%% acc3ms_criteria v1.1
% 
% Inputs:
%           Acc  :      [REQ'D]    [m x 1]{double};   Column-wise vector of acceleration data in [g]
%           time    :   [REQ'D]    [m x 1]{double};   Column-wise vector of sampling times in [ms]
%           coeff     : [OPTIONAL]  scalar{double};   Coeeficient from H3 dummy to others (DEFAULT = 1)
%                   'Q1.5 = ' or 'Q3=0.71' or 'Q6'
%           ShowPlots:  [OPTIONAL]  {logical}    ;    Plot filt/orig signals (DEFAULT = FALSE)
%           
% Outputs:
%           hic_value : scalar {double} value of HIC for the given data
%           interval: : [1x2] {double}    ;    2-size with t1 start time and t2 end time
% Examples:

%%

function [maxAcc,interval] = acc3ms_criteria(time,Acc,varargin)

    %%          Parse User Inputs/Outputs                                        
    p = inputParser;
    chktime     = @(x) validateattributes(x ,{'double'},{'column'}, mfilename,'outputPath',1);
    chkAcc     = @(x) validateattributes(x ,{'double'},{'column'}, mfilename,'outputPath',2);
    % Required Inputs
    addRequired(p,'Acc'        ,chkAcc);
    addRequired(p,'time'        ,chktime);

    chkcoeff     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    
    % Optional Inputs
    addOptional(p,'coeff',      1, chkcoeff)
    addOptional(p,'ShowPlots'   ,false      ,@islogical);

    parse(p,time,Acc,varargin{:});
    
    %%  Computing the HIC-15 and interval
    time=time./1e3;
    Ts = (time(2)-time(1));

    vel = cumtrapz(time,Acc); % Velocity added from time t(1)

    len = length(Acc);
    deltaT = 0.003; %3ms
    maxWindow = 0.003; %15ms
    maxAcc = 0;
    t1 = time(1);
    for indx_i = 1:len-deltaT/Ts-1
        % Checking the input data is larger than a window of 3ms
        indx_2 = round(min([len-1,(indx_i+deltaT/Ts)]),0);
        
        deltaT = time(indx_2)-time(indx_i);
        % Checking the data for maxWindow 
        maxAcc_temp = (vel(indx_2)-vel(indx_i)) / deltaT;
         if maxAcc_temp > maxAcc
             maxAcc = maxAcc_temp;
             t1 = time(indx_i);
         end
        
    end
     maxAcc = maxAcc * p.Results.coeff;
     interval = [t1, t1+deltaT];
     
   % =============== Plots setup ===================% 
     if p.Results.ShowPlots
            minY = min(Acc);
            maxY = max(Acc)*1.1;
            minX = interval(1)-maxWindow;
            maxX = interval(2)+maxWindow;
            AxisPlots = [minX maxX minY maxY];
            PicSize = [10 10 780 480];

            FaceALphas = 0.18;
            FontSizes = 24;
            MarkersSizes = 14;
            LinesWidths = 2.8;
        %     figureFormat = 'epsc'; %'png'
            Fonts = 'Times New Roman';
            load('ColorsData');     % colm# , Bcol#, Rcol#, Ocol#, Gcol#

            switch (3)
                case 1
                    nPalet = ["EE6677", "228833", "4477AA", "CCBB44", "66CCEE", "AA3377", "BBBBBB"]; % Tol_bright 
                case 2
                    nPalet = ["88CCEE", "44AA99", "117733", "332288", "DDCC77", "999933","CC6677", "882255", "AA4499", "DDDDDD"]; % Tol_muted 
                case 3
                    nPalet = ["BBCC33", "AAAA00", "77AADD", "EE8866", "EEDD88", "FFAABB", "99DDFF", "44BB99", "DDDDDD"];% Tol_light 
                case 4
                    nPalet = ["E69F00", "56B4E9", "009E73", "F0E442", "0072B2", "D55E00", "CC79A7", "000000" ];% Okabe_Ito 
                otherwise
            % % #From Color Universal Design (CUD): https://jfly.uni-koeln.de/color/
                    nPalet = ["E69F00", "56B4E9", "009E73", "F0E442", "0072B2", "D55E00", "CC79A7", "000000" ];% Okabe_Ito 
            end
            for iColor = 1:length(nPalet)
                colorPalet(iColor,:) = hex2rgb(nPalet(iColor),255)./255;
            end
            ColorsAIS = [50 130 0;% 0-5%
                     220 200 0;% 5-20%
                     255 150 0;% 20-50%
                     190 0 0;% 50-100%
                        ]./255;
            figure;
            hold on; grid on;
            pAcc = plot(time,Acc,...
                    '--','lineWidth',LinesWidths-0.5,'markerSize',MarkersSizes,...
                    'Color',colorPalet(3,:)...
                        );
            pHIC1 = plot([interval(1) interval(1)],[minY maxY],...
                '-','Color',ColorsAIS(1,:),...
                'LineWidth',LinesWidths ...
                );
            pHIC2 = plot([interval(2) interval(2)],[minY maxY],...
                '-','Color',ColorsAIS(2,:),...
                'LineWidth',LinesWidths ...
                );
                    
            plegends = {'Acceleration', 'lower bound', 'upper bound'};
            hLegend = legend([pAcc, pHIC1, pHIC2],...
                      plegends, ...
                      'FontName',Fonts,...
                      'FontSize', FontSizes,'FontWeight','bold',...
                      'orientation', 'vertical',...
                      'location', 'NorthEast' );
            set(gcf, 'Position', PicSize);
            set(gcf,'PaperPositionMode', 'auto');
            hold on;
            hXLabel=xlabel('time [ms]');
            hYLabel=ylabel('Acceleration [g]');
            set(gca, ...
                  'Box'         , 'off'     , ...
                  'TickDir'     , 'out'     , ... % 
                  'TickLength'  , [.02 .02] , ...
                  'XMinorTick'  , 'on'      , ...
                  'YMinorTick'  , 'on'      , ...
                  'YGrid'       , 'on'      , ...
                  'XColor'      , Gcol5, ...
                  'YColor'      , Gcol5, ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
                  'LineWidth'   , 1.5         );
            
            set([hXLabel, hYLabel]  , ...
                    'FontName',  Fonts,...
                    'FontSize',  FontSizes,...
                    'color',     [0 0 0]);
            axis(AxisPlots);
    
     end
% %     %%
% %     % Get all the indices between the provided times
% % %     sampleIndices = find((time>=t1) & (time<=t2));
% %     sampleIndices = find((time>=t1) & (time<=t2));
% % 
% %     % Get the net time:
% %     tNet = t(sampleIndices);
% % 
% %     % Integrating the time *between* samples means you use nSamples-1 for the signal:
% %     aNet = a(sampleIndices(1:end-1));
% % 
% %     % Get the time intervals:
% %     dT = diff(t(sampleIndices));
% % 
% %     % Integrate
% %     integral = cumsum(aNet.*dT);
% % 
% %     % Do the formula:
% %     % Redefine t1 and t2 based on the time samples actually used:
% %     t2 = tNet(end);
% %     t1 = tNet(1);
% % 
% %     HIC = max( (t2-t1) * ((1/(t2-t1)) * integral).^(2.5) )



end

    