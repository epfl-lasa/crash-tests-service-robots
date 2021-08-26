function [fitresult, gof] = forceFit(time1, F1)
%CREATEFIT(TIME1,F1)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : time1
%      Y Output: F1
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%% Fit: 'untitled fit 1'.
    global DEBUG_FLAG
    [xData, yData] = prepareCurveData( time1, F1 );

    % Set up fittype and options.
    ft = fittype( 'gauss1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [-Inf -Inf 0];
    opts.StartPoint = [810.030929457343 3.84999999999999 1.02976236622325];

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );

    % Plot fit with data.
    if DEBUG_FLAG
        figure( 'Name', 'untitled fit 1' );
        h = plot( fitresult, xData, yData );
        legend( h, 'F1 vs. time1', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
        % Label axes
        xlabel( 'time1', 'Interpreter', 'none' );
        ylabel( 'F1', 'Interpreter', 'none' );
        grid on
    end


