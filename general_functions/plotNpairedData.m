% Data Plotting
% Plotting up to 8 different colored data with color-blind palletes

% Inputs:
%           nfig : [REQ'D]    [n]{scalar};  figure reference number
%           XDATA  :      [REQ'D]    [m x n]{double};   Column-wise vectors
%           for x-axis plots
%           YDATA  :      [REQ'D]    [m x n]{double};   Column-wise vectors
%           for x-axis plots
% Optional arguments:
% plotChar,FigName,legends,Xlabel,Ylabel,RECORD,figPath,AxisDist,colorCode
% Author: Diego F. Paez G.
% Date: 1 Dec 2020

function plotNpairedData(nfig,XDATA,YDATA,...
                        varargin)
                    

           defaultChar = '-';
           defaultName = [num2str(nfig),'-PlotNdata'];
           defaultFormat = 'epsc';
           defaultlegend = {' '};
           defaultXlabel = {' '};
           defaultYlabel = {' '};
           defaultRecord = false;
           defaultPath = pwd;
           defaultAxis = [min(min(XDATA)), max(max(XDATA)), min(min(YDATA)), max(max(YDATA)) ];
           defaultColor = 4;
            
% Outputs:  
%         Desired Plot
% Copyright 2020, Dr. Diego Paez-G.

%%  Cehccking functions for variable types
    chkMatrix = @(x) validateattributes(x ,{'double'},{'2d'}, mfilename,'outputPath',1);
    chkRow = @(x) validateattributes(x ,{'double'},{'row'}, mfilename,'outputPath',1);
    chknum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar = @(x) ischar(x);
    chkcell = @(x) iscell(x);
    % Otherways to validate attributes:
    % validateattributes( varA, { 'numeric' }, { 'scalar', 'positive' } );
    % validateattributes( varA, { 'double' }, { 'vector', 'numel', 3, '>' 5, '<=' 25' } );    

%%    Parse User Inputs/Outputs                                        
    p = inputParser;

%                addRequired(p,'width',validScalarPosNum);
%                addOptional(p,'height',defaultHeight,validScalarPosNum);
%                addParameter(p,'units',defaultUnits,@isstring);
%                addParameter(p,'shape',defaultShape,...
%                              @(x) any(validatestring(x,expectedShapes)));
%                parse(p,width,varargin{:});
% 
    % Required Inputs
    addRequired(p,'nfig', chknum)
    addRequired(p,'XDATA',chkMatrix);
    addRequired(p,'YDATA',chkMatrix);

    % Optional Inputs
    addOptional(p,'plotChar',defaultChar,chkchar);
    addOptional(p,'FigName',defaultName,chkchar);
    addOptional(p,'legends',defaultlegend,chkcell);
    addOptional(p,'Xlabel',defaultXlabel,chkchar);
    addOptional(p,'Ylabel',defaultYlabel,chkchar);
    addOptional(p,'RECORD',defaultRecord,@islogical);
    addOptional(p,'figPath',defaultPath,chkchar);
    addOptional(p,'figureFormat',defaultFormat,chkchar);
    addOptional(p,'AxisDist',defaultAxis, chkRow)
    addOptional(p,'colorCode',defaultColor,chknum);
    
    parse(p,nfig,XDATA,YDATA,varargin{:});    
    
%%  ########## DEFINE Color palettes #########
    
    % % #From Paul Tol: https://personal.sron.nl/~pault/
    switch (p.Results.colorCode)
        case 1
            nPalet = ["EE6677", "228833", "4477AA", "CCBB44", "66CCEE", "AA3377", "BBBBBB"]; % Tol_bright 
        case 2
            nPalet = ["88CCEE", "44AA99", "117733", "332288", "DDCC77", "999933","CC6677", "882255", "AA4499", "DDDDDD"]; % Tol_muted 
        case 3
            nPalet = ["BBCC33", "AAAA00", "77AADD", "EE8866", "EEDD88", "FFAABB", "99DDFF", "44BB99", "DDDDDD"];% Tol_light 
        case 4
            nPalet = ["E69F00", "56B4E9", "009E73", "F0E442", "0072B2", "D55E00", "CC79A7", "000000" ];% Okabe_Ito 
        case 5
            LB=flipud(lbmap(256,'BrownBlue')); %
            largest=7;
            smallest=0.5;
            contour_len = 5;
            indexValue = 3;     % value for which to set a particular color
            topColor = LB(end,:);         % color for maximum data value (red = [1 0 0])
            indexColor = LB(128,:);       % color for indexed data value (white = [1 1 1])
            bottomcolor = LB(1,:);      % color for minimum data value (blue = [0 0 1])
            % Calculate where proportionally indexValue lies between minimum and max
            index = contour_len*abs(indexValue-smallest)/(largest-smallest);
            % Create color map ranging from bottom color to index color
            % Multipling number of points by 100 adds more resolution
            customCMap1 = [linspace(bottomcolor(1),indexColor(1),5*index)',...
                        linspace(bottomcolor(2),indexColor(2),5*index)',...
                        linspace(bottomcolor(3),indexColor(3),5*index)'];
            % Create color map ranging from index color to top color
            % Multipling number of points by 100 adds more resolution
            customCMap2 = [linspace(indexColor(1),topColor(1),5*(contour_len-index))',...
                        linspace(indexColor(2),topColor(2),5*(contour_len-index))',...
                        linspace(indexColor(3),topColor(3),5*(contour_len-index))'];
            colorPalet = [customCMap1;customCMap2];  % Combine colormaps
            colorPalet = bone(15);
        otherwise
    % % #From Color Universal Design (CUD): https://jfly.uni-koeln.de/color/
            nPalet = ["E69F00", "56B4E9", "009E73", "F0E442", "0072B2", "D55E00", "CC79A7", "000000" ];% Okabe_Ito 
    end
    load('ColorsData');     % colm# , Bcol#, Rcol#, Ocol#, Gcol#
% %     % Paired data
% %     colA = [225 190  106]./255;
% %     colB = [64 176 166]./255;
% %     
% %     colm7=[0/255 52/255 222/255];
% %     colm3=[0/255 102/255 204/255];
% %     colm1=[51/255 153/255 255/255];
% %     colm4=[0/255 204/255 102/255];
% %     colm2=[153/255 153/255 0/255];
% %     colm5=[255/255 128/255 0/255];
% %     colm6=[204/255 0/255 0/255];
% %     colm8=[5/255 5/255 5/255];

%     ColorPalet(1,:) = [0 0 0];
    if ~exist('colorPalet','var')
        for iColor = 1:length(nPalet)
            colorPalet(iColor,:) = hex2rgb(nPalet(iColor),255)./255;
        end
    end
    
    FaceALphas = 0.18;
    FontSizes = 28;
    MarkersSizes = 14;
    LinesWidths = 3.0;
%     figureFormat = 'png';%'epsc';
    Fonts = 'Times New Roman';
    
    %% ########## Starting Plots #########
    [m,n] = size(YDATA);
    figure(nfig);
    set(gcf, 'name', p.Results.FigName);
    set(gcf, 'Position', [10 10 1080 480]);
    set(gca,'FontName',Fonts,...
            'FontSize', FontSizes,...
            'LineWidth',LinesWidths);
    %title(title);
    hold on;
%     grid on;
    hYLabel=ylabel(p.Results.Ylabel);
    hXLabel=xlabel(p.Results.Xlabel);
    for jData=1:n
        plot(XDATA(:,jData),YDATA(:,jData),...
            p.Results.plotChar,'Color',colorPalet(jData,:),...
            'LineWidth',LinesWidths);
        hold on;
    end
    
%     legend(p.Results.legends,'FontName',Fonts,'FontSize',FontSizes,'FontWeight','bold','Location','northoutside');
    hLegend = legend( ...
              p.Results.legends, ...
              'FontName',Fonts,...
              'FontSize', FontSizes,'FontWeight','bold',...
              'orientation', 'vertical',...
              'location', 'NorthEast',...
              'Interpreter','latex'...
                );
% 	legend(label1,label2,'Interpreter','latex')
%     p.Results.legends
    Ymin=min(min(YDATA));
    Ymax=max(max(YDATA));
        set(gca, ...
          'Box'         , 'off'     , ...
          'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
          'XMinorTick'  , 'off'      , ...
          'YMinorTick'  , 'off'      , ...
          'YGrid'       , 'off'      , ...
          'XColor'      , Gcol6, ...
          'YColor'      , Gcol6, ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
          'LineWidth'   , 1         );
    
    axis(p.Results.AxisDist)

    set([hXLabel, hYLabel]  , ...
            'FontName',  Fonts,...
            'FontSize',  FontSizes,...
            'color',     [0 0 0]);
    
        
    if p.Results.RECORD
        set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
        saveas(nfig,strcat(p.Results.figPath,p.Results.FigName),p.Results.figureFormat);
    end
%     hold off;

    
end