function [fitresult, gof] = FitForceLegs(time3, F3)
%CREATEFIT(TIME3,F3)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : time3
%      Y Output: F3
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 22-Jun-2021 12:34:03


%% Fit: 'untitled fit 1'.
global DEBUG_FLAG
[xData, yData] = prepareCurveData( time3, F3 );

% Set up fittype and options.
ft = fittype( 'gauss2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0 -Inf -Inf 0];
opts.Robust = 'Bisquare';
opts.StartPoint = [4434.53535172682 11.1 1.58391418255131 3164.0972858309 8.84999999999999 2.54804280978307];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

if DEBUG_FLAG
    % Create a figure for the plots.
    figure( 'Name', '2-Gaussians Force' );

    % Plot fit with data.
    subplot( 2, 1, 1 );
    h = plot( fitresult, xData, yData );
    legend( h, 'F3 vs. time3', '2-Gaussians Force', 'Location', 'NorthEast', 'Interpreter', 'none' );
    % Label axes
    xlabel( 'time3', 'Interpreter', 'none' );
    ylabel( 'F3', 'Interpreter', 'none' );
    grid on

    % Plot residuals.
    subplot( 2, 1, 2 );
    h = plot( fitresult, xData, yData, 'residuals' );
    legend( h, '2-Gaussians Force - residuals', 'Zero Line', 'Location', 'NorthEast', 'Interpreter', 'none' );
    % Label axes
    xlabel( 'time3', 'Interpreter', 'none' );
    ylabel( 'F3', 'Interpreter', 'none' );
    grid on
end


