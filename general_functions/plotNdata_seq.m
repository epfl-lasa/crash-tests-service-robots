% Data Plotting
% Plotting up to 8 different colored data

function plotNdata_seq(nfig,time,YDATA,FigName,legends,Xlabel,Ylabel,Col,RECORD)

    colm7=[0/255 52/255 222/255];
    colm3=[0/255 102/255 204/255];
    colm1=[51/255 153/255 255/255];
    colm4=[0/255 204/255 102/255];
    colm2=[153/255 153/255 0/255];
    colm5=[255/255 128/255 0/255];
    colm6=[204/255 0/255 0/255];
    colm8=[5/255 5/255 5/255];
    
    load('ColorsData');     % colm# , Bcol#, Rcol#, Ocol#, Gcol#
    colm1=[51/255 153/255 255/255];
    FaceALphas = 0.18;
    FontSizes = 28;
    MarkersSizes = 14;
    LinesWidths = 2.8;
    FigureFile = 'epsc';
    Fonts = 'Times New Roman';
    if ismac
        figPath = ('Figures/');
    else
        figPath = ('Figures\');
    end
    [m,n] = size(YDATA);
    figure(nfig);
    set(gcf, 'name', FigName);
    set(gcf, 'Position', [10 10 1080 480]);
    set(gca,'FontName',Fonts,...
            'FontSize', FontSizes,...
            'LineWidth',LinesWidths);
    %title(title);
    hold on;
    grid on;
    hYLabel=ylabel(Ylabel);
    hXLabel=xlabel(Xlabel);
    for j=1:n
        plot(time(1:length(YDATA(:,j))),YDATA(:,j),'Color',eval(['colm',num2str(j*2)]),'LineWidth',LinesWidths);
    end
    
%     legend(legends,'FontName',Fonts,'FontSize',FontSizes,'FontWeight','bold','Location','northoutside');
    hLegend = legend( ...
              legends, ...
              'FontName',Fonts,...
              'FontSize', FontSizes,'FontWeight','bold',...
              'orientation', 'horizontal',...
              'location', 'NorthOutside' );
    
    set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
    
    Ymin=min(min(YDATA));
    Ymax=max(max(YDATA));
        set(gca, ...
          'Box'         , 'off'     , ...
          'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
          'XMinorTick'  , 'on'      , ...
          'YMinorTick'  , 'on'      , ...
          'YGrid'       , 'on'      , ...
          'XColor'      , Gcol5, ...
          'YColor'      , Gcol5, ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
          'LineWidth'   , 1         );

    set([hXLabel, hYLabel]  , ...
            'FontName',  Fonts,...
            'FontSize',  FontSizes,...
            'color',     [0 0 0]);
    
    if (RECORD) 
        saveas(nfig,strcat(figPath,num2str(nfig),'-',FigName),FigureFile);
    end
    hold off;

    
end