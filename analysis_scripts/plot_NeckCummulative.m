% % Computing AIS (Abbreviated Injury Scale from Injury metric (Nij, HIC15, HIC36)
% Author: Diego F. Paez G.
% Date: 15 Feb 2021
%% plot_NeckCumulative
% Inputs:
%           Force_vector
%           forces_plot
%           time_plot
%           Freq
% Optional Parameters:           
%           nfig:  [OPTIONAL]  {scalar} ; figure number
%           figPath:  [OPTIONAL]  {char} ; path to save plots
%           SavePlot:  [OPTIONAL]  {logical}    ;    Plot AIS scales and results (DEFAULT = FALSE)
% Examples:
%         plot_NeckCummulative(abs(data_raw_Q3.test_7.neck.Fx(rangeImpact)./1e3),Forces_Fx,time_Fx,Freq,...
%                             nfig,figPath,figName,Ylabel,SAVE_PLOTS);

        % Source: [EuroNcap 2015] Neck
        % Higher performance limit ==> pAIS+3 < 5%
        % Shear force Fx = 1.9kN @ 0 msec, 1.2kN @ 25 - 35msec, 1.1kN @ 45msec 
        % Tension force Fz  2.7kN @ 0 msec, 2.3kN @ 35msec, 1.1kN @ 60msec
        % Extension  My =  42Nm 
        %
        % Lower performance and capping limit  ==> pAIS+3 < 20%
        % Shear force Fx = 3.1kN @ 0msec, 1.5kN @ 25 - 35msec, 1.1kN @ 45msec*
        % Tension force Fz = 3.3kN @ 0msec, 2.9kN @ 35msec, 1.1kN @ 60msec*
        % Extension My = 57Nm* (Significant risk of injury [4])
        % (*EEVC Limits)
        
        %       Values for Q3: from EEVC report and CHILD project
        %         Q3eevcL.Fz = 1555;  % 20% p(AIS+3)
        %         Q3eevcL.My= 79;     % 20% p(AIS+3)
        %         Q3eevc50.pAIS = 0.50;
        %         Q3eevc50.Fz = 1705; % 50% p(AIS+3)
        %         Q3eevc50.My= 96;     % 50% p(AIS+3)
        
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        %﻿Note: Neck Shear and Tension are assessed from cumulative 
        % exceedence plots, with the limits being functions of time. 
        % By interpolation, a plot of points against time is computed. 
        % The minimum point on this plot gives the score. Plots of the 
        % limits and colour rating boundaries are given in Appendix I
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Copyright 2020, Dr. Diego Paez-G.
%%%
function maxFN = plot_NeckCummulative(Force_vector,forces_plot,time_plot,Freq,Flabels,Ftcolor,...
                                varargin)

    %%          Parse User Inputs/Outputs                                        
    p = inputParser;
    chkVec     = @(x) validateattributes(x ,{'double'},{'column'}, mfilename,'outputPath',2);
    chkRow     = @(x) validateattributes(x ,{'double'},{'row'}, mfilename,'outputPath',2);
    chkmatrix     = @(x) validateattributes(x ,{'double'},{'2d'}, mfilename,'outputPath',2);
    chkscalar     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
%     chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'Force_vector',chkmatrix);
    addRequired(p,'forces_plot',chkmatrix);
    addRequired(p,'time_plot',chkmatrix);
    addRequired(p,'Freq',chkscalar);
    addRequired(p,'Flabels',chkcell);
    addRequired(p,'Ftcolor',chkcell);
    % Optional Inputs
    addOptional(p,'nfig',   1,  chkscalar);
    addOptional(p,'figPath',    'AIS_plot', chkchar);
    addOptional(p,'figName',    '/', chkchar);
    addOptional(p,'Ylabel',    'Neck Forces [kN]', chkchar);
    addOptional(p,'SavePlot'   ,false      ,@islogical);
    addOptional(p,'AxisPlots',[0 90 0 5], chkRow);
    
    
    parse(p,Force_vector,forces_plot,time_plot,Freq,Flabels,Ftcolor,varargin{:});
    AxisPlots = p.Results.AxisPlots;
    
    %% =============== Plots setup ===================% 
    colorAlpha = 0.95;
    ColorsAIS = [50 130 0;% 0-20%  % Higher Performance
            220 200 0;% 20-30% % ----
            255 150 0;% 30-40% % % Lower Performance
            160 100 70;% 40-50% % Capping limit
            160 0 0;% 50-100%
                ]./255;
    AISnum = [0;20;30;40;50];
% 	ColorSummer = {'#ffffd4','#fee391','#fec44f','#fe9929','#d95f0e','#993404'};
    ColorSummer = [
                    255,255,212
                    254,227,145
                    254,196,79
                    254,153,41
                    217,95,14 %                    153,52,4
                    ]./255;
    ColorDivergent= [
                   57, 92, 107
                   242, 244, 229
                   211, 203, 146
                   221,115,64%239,138,98
                   142,16,30%178,24,43
                    ]./255;
                
	ColorWinter = [
                   57, 92, 107
                   242, 244, 229
                   211, 203, 146
                   160, 169, 117
                   117, 130, 72
                    ]./255;
                
        PlotColor = ColorDivergent;
        PicSize = [10 10 780 480];
        FigureFile = 'png';
        FaceALphas = 0.1;
        FontSizes = 24;
        MarkersSizes = 14;
        LinesWidths = 2.8;
        FigureFile = 'png';%'epsc';
        Fonts = 'Times New Roman';
        load('ColorsData'); 
        
    %%  Making the Cummulative plot
        figure(p.Results.nfig);
        time2 = [time_plot, fliplr(time_plot)];
        for iLevel=1:4
            plot(time_plot, forces_plot(iLevel,:),...
                    '--','LineWidth',LinesWidths,...
                    'Color',PlotColor(iLevel,:));
            hold on;
            if iLevel>1
                inBetween = [forces_plot(iLevel-1,:), fliplr(forces_plot(iLevel,:))];
                fill(time2, inBetween,PlotColor(iLevel,:),...
                    'FaceAlpha',colorAlpha...
                        );
                  
%                 % Create array of polkadot coordinates that span the size of the polygon
%                 xrange =  (max(time2)-min(time2)) / 90;
%                 yrange =  (max(inBetween)-min(inBetween))/ 50;
%                 [dotsX,dotsY] = ndgrid(...
%                                     min(time2): xrange*(5/iLevel) : max(time2), ...
%                                     min(inBetween): yrange*(5/iLevel) : max(inBetween));  
%                 % Determine which coordinates are on or in your polygon
%                 [in,on] = inpolygon(dotsX,dotsY,time2,inBetween); 
%                 % extract coordinates in or on polygon
%                 inX = dotsX(in|on); 
%                 inY = dotsY(in|on);
%                 h = plot(inX,inY,'.','MarkerSize',4,'Color',ColorsAIS(5,:),...
%                             'MarkerFaceColor',ColorsAIS(5,:)); 
            else
                inBetween = [zeros(1,length(forces_plot)), fliplr(forces_plot(iLevel,:))];
                fill(time2, inBetween,PlotColor(iLevel,:),...
                    'FaceAlpha',colorAlpha...
                    );
%                 % Create array of polkadot coordinates that span the size of the polygon
%                 xrange =  (max(time2)-min(time2)) / 100;
%                 yrange =  (max(inBetween)-min(inBetween))/ 60;
%                 [dotsX,dotsY] = ndgrid(...
%                                     min(time2): xrange*(5/iLevel) : max(time2), ...
%                                     min(inBetween): yrange*(5/iLevel) : max(inBetween));  
%                 % Determine which coordinates are on or in your polygon
%                 [in,on] = inpolygon(dotsX,dotsY,time2,inBetween); 
%                 % extract coordinates in or on polygon
%                 inX = dotsX(in|on); 
%                 inY = dotsY(in|on);
%                 h = plot(inX,inY,'.','MarkerSize',4,'Color',ColorsAIS(5,:),...
%                             'MarkerFaceColor',ColorsAIS(5,:)); 
            end
        end
        inBetween = [forces_plot(iLevel,:), fliplr(5.*ones(1,length(forces_plot)))];
        fill(time2, inBetween,PlotColor(iLevel+1,:),...
                    'FaceAlpha',colorAlpha...
                    );
%         % Create array of polkadot coordinates that span the size of the polygon
%                 xrange =  (max(time2)-min(time2)) / 200;
%                 yrange =  (max(inBetween)-min(inBetween))/ 100;
%                 [dotsX,dotsY] = ndgrid(...
%                                     min(time2): xrange*(5/iLevel) : max(time2), ...
%                                     min(inBetween): yrange*(5/iLevel) : max(inBetween));  
%                 % Determine which coordinates are on or in your polygon
%                 [in,on] = inpolygon(dotsX,dotsY,time2,inBetween); 
%                 % extract coordinates in or on polygon
%                 inX = dotsX(in|on); 
%                 inY = dotsY(in|on);
%                 h = plot(inX,inY,'.','MarkerSize',4,'Color',ColorsAIS(5,:),...
%                             'MarkerFaceColor',ColorsAIS(5,:)); 
        
%         max(abs())
        [lenF, tesN]= size(Force_vector);
        maxFN = zeros(1,tesN);
        for iTest=1:tesN
            
            Fcm = zeros(1,90);
            timec = 0:90;
            for istep=0:90
                rangT = istep*Freq/1e3;
                maxfcm = 0;
                for jRange=1:lenF-rangT
                    maxfcm = max(maxfcm,mean(Force_vector(jRange:jRange+rangT,iTest)));
                end
                Fcm(istep+1) = maxfcm;
            end
            [maxF,tcm] = max(Fcm);
            tcm = tcm-1;
            ph{iTest}.hdl = plot(timec,Fcm,...
                    '.-','Color',char(Ftcolor(iTest)),...%                     'Color','k',...
                    'MarkerSize',MarkersSizes-6,'lineWidth',LinesWidths-1);
            hold on;
            plot(tcm,maxF,...
                    char(Flabels(iTest)),...%                     'Color','k',...
                    'MarkerSize',MarkersSizes-2,...
                         'lineWidth',LinesWidths);
            maxFN(iTest)= maxF;
        end
        
            Xlabel = 'Positive Cumulative Exceedence Time';
            hold on; grid on;
            plegend = {'Thorax [60kg]',...
                    'Thorax [133kg]',...
                    'Head',...
                    'Legs'...
                        };
            legendNum = [11;1;5;8];
            hLegend = legend([ph{legendNum(1)}.hdl ph{legendNum(2)}.hdl ph{legendNum(3)}.hdl ph{legendNum(4)}.hdl ],...
                           plegend, ...
                          'FontName',Fonts,...
                          'FontSize', FontSizes,'FontWeight','bold',...
                          'orientation', 'vertical',...
                          'location', 'North' );
            
            set(gcf, 'Position', PicSize);
            set(gcf,'PaperPositionMode', 'auto');
            hold on;
            hXLabel=xlabel(Xlabel);
            hYLabel=ylabel(p.Results.Ylabel);
            set(gca, ...
                  'Box'         , 'off'     , ...
                  'TickDir'     , 'out'     , ... % 
                  'TickLength'  , [.02 .02] , ...
                  'XMinorTick'  , 'on'      , ...
                  'YMinorTick'  , 'on'      , ...
                  'YGrid'       , 'on'      , ...
                  'XColor'      , Gcol3, ...
                  'YColor'      , Gcol3, ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
                  'LineWidth'   , 1.5         );
            

            set([hXLabel, hYLabel]  , ...
                    'FontName',  Fonts,...
                    'FontSize',  FontSizes,...
                    'color',     [0 0 0]);
            axis(AxisPlots);
        
        colormap(PlotColor)
        cb = colorbar('location','eastoutside'); 
        caxis([0 60]) % sets colorbar limits 
        set(cb,'xtick',[])

        if p.Results.SavePlot
            saveas(p.Results.nfig,strcat(p.Results.figPath,p.Results.figName),FigureFile);
        end
    
end

    