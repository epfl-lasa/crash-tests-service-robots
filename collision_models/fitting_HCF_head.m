    % Short script fir simulating multiple parameter changes on the robot
    % desing and control
    % Author: Diego F. Paez G.
    % Date: 28 April 2021
    
%% Script for Fitting Injury Metrics through Contact Models
        % Load paths and data
        clearvars; close all; clc; 
        [parentdir,~,~]=fileparts(pwd);
        [maindir,~,~]=fileparts(parentdir);
        % Folders Configuration 
        outputPath = fullfile(maindir,'collision_data', 'data_metrics');
        addpath(fullfile(maindir,'collision_data','data_metrics'));
        addpath(fullfile(maindir,'collision_data','data_raw'));
        addpath(fullfile(parentdir, 'general_functions'));%
        addpath(fullfile(parentdir, 'analysis_scripts'));%
        addpath(fullfile(parentdir, 'collision_models'));%
        figPath = fullfile(parentdir, 'figures/');
        global DEBUG_FLAG;
        DEBUG_FLAG=true;
        DRAW_PLOTS = true;
        SAVE_PLOTS = false;
        SAVE_VIDEO = false;
        READDATA   = false;
        nfig=1;
        
        PicSize = [10 10 780 480];
        FaceALphas = 0.18;
        FontSizes = 24;
        MarkersSizes = 14;
        LinesWidths = 2.8;
        figureFormat = 'epsc';%'png';
        Fonts = 'Times New Roman';
        load('ColorsData');
        
        % Load Data-set of Collisions
        % Calling data of injury from AIS car crashing lading crash tests:

        load('Q3_raw_collision_struct.mat')
        load('H3_raw_collision_struct.mat')
        load('filtered_collision_struct.mat')
        data_q3 = [1:10,16:19];
        
        q3_testNames = [{'Thorax-$1.0m/s$'}... $test_1
                     {'Thorax-$1.5m/s$'}... $test_2
                     {'Thorax-$3.1m/s$'}... $test_3
                     {'Thorax-$3.2m/s$'}... $test_4
                     {'Head-$1.0m/s$'}... $test_5
                     {'Head-$1.5m/s$'}... $test_6
                     {'Head-$3.1m/s$'}... $test_7
                     {'Tibia-$1.0m/s$'}... $test_8
                     {'Tibia-$1.5v$'}... $test_9
                     {'Tibia-$3.1m/s$'}... $test_10
                     {'Thorax-$1.0m/s ^*$'}... $test_16
                     {'Thorax-$1.5m/s ^*$'}... $test_17
                     {'Thorax-$3.1m/s ^*$'}... $test_18
                     {'Thorax-$3.0m/s ^*$'}... $test_19
                    ...
                    ];
        Q3.testSpeed = [1.0 1.5 3.1 3.2 ...
                        1.0 1.5 3.1...
                        1.0 1.5 3.1...
                        1.0 1.5 3.1 3.0...
                        ];
        Q3.testMass = [133 133 133 133 ...
                        133 133 133 ...
                        133 133 133 ...
                        60  60  60  60 ...
                        ];
        
        data_h3 = 11:15;
        
        h3_testNames = [{'1-$133kg$, $1.0ms^{-1}$'}...
                         {'2-$133kg$, $1.5ms^{-1}$'}...
                         {'3-$133kg$, $3.1ms^{-1}$'}...
                         {'4-$133kg$, $3.1ms^{-1}$'}... % SUCCESFULL IMPACT
                         {'5-$133kg$, $3.1ms^{-1}$'}...
                         ];
         H3.testSpeed = [1.0 1.5 3.1 3.1 3.1];
         H3.testMass = [133 133 133 133 133];
        % Constants from the current dataset
        Freq = 20000;
        Ts = 1/Freq; % Sampling period in [s]
        g_const = 9.81;
        
        % Data Structure short explanation:

        % Head Acceleration (norm of 3-d accelerations) areas = sqrt(ax^2+ay^2+az^2)
        % data_raw_Q3.test_7.head.areas
        % Impact Force measured at the robot (Fx is the frontal force)
        % data_filtered.test_7.impact.Fx
        
         % Data taken from Crash report - manually labeled the start of
        % contact on the ground;
        % [1]'Test_01_Q3-Ribcage' [1.0m/s]
        % [2]'Test_02_Q3-Ribcage' [1.5m/s]
        % [3]'Test_03-2_Q3-Ribcage' [3.1m/s]
        % [4]'Test_03_Q3-Ribcage_FAILED' [3.2m/s]
        % [5]'Test_04_Q3-Head' [1.0m/s]
        % [6]'Test_05_Q3-Head' [1.5m/s]
        % [7]'Test_06_Q3-Head' [3.1m/s]
        % [8]'Test_07_Q3-Legs' [1.0m/s]
        % [9]'Test_08_Q3-Legs' [1.5m/s]
        % [10]'Test_09_Q3-Legs' [3.1m/s]
        %[16]'Test_13_Q3-Ribcage' [1.0m/s]
        %[17]'Test_14_Q3-Ribcage' [1.5m/s]
        %[18]'Test_15-2_Q3-Ribcage' [3.1m/s]
        %[19]'Test_15_Q3-Ribcage_FAILED' [3.0m/s]

%%  %%%%%%%% Simulation parameters for HCF Model ############
    close all; clc;
    clear robot human ColModel deformation state Khr Fext timeVec F_fit
    nfig =1;
    DEBUG_FLAG = false;
    % Getting mechanical data of the robots and tests setup (sizes, elastic modulus, and masses)
    robot_mechanical_properties;
    sampDown = 1;
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'HRC'; %'CCF' or 'HCF' or 'Spring' or 'HRC'
    % % % EA =EB = 2.3e9
    method.time = 15; % time in ms
    method.tstep= 0.01 * sampDown; % time in ms
    state.pos = 0.0; 
    state.acc = 0.0;
    
    robot.part = 'qolo_driver_bumper'; 
    human.part = 'head_child'; % For collision data
    
    % Parameters for HRC Model
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;
    robot.damping_cs = 2.5;
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Parameters for HCF Model
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Parameters for CCF Model
    robot.n_d = 1.5; % Hertzian Deformation exponential
    human.n_s = 1.5; % Skin Deformation exponential
    robot.n_c = 1.5; % Robot cover Deformation exponential
    human.n_f = 0.9; % human differential deformation
    robot.n_f = 0.8; % robot differential deformation
    robot.xgainA = 4;
    human.xgainB = 1;
    robot.EA = 1.0e9; %% Fitted Gain --> To be determine
    human.EB = 1.0e9; %% Fitted Gain --> To be determine
    human.cover_width = 0.003;
    
    % Parameters for Spring-Model
    human.stiffness = 150 * 1e3; % N/m --> Skull

%     for j_test=5:7
%         % For Test Data from Mobile Service Robots:
%         qolo_robot = service_test{j_test};
%         state.vel = qolo_robot.speed;
%         robot.part = qolo_robot.part; 
%         human.part = 'head_child'; % For collision data
%         service_test{j_test}.colModel = contact_simulation(state,robot,human,method);
%         figure;
%         plot(service_test{j_test}.colModel.timeVec,-service_test{j_test}.colModel.Fext)
%     end     
    j_test = 7;
    vel_0 = service_test{j_test}.speed;
    minTime = 0; 
    timeVec = [minTime:method.tstep:method.time].*1e-3';

    variable_set = [...
            3.2; %     robot.n_cs = 1.65; 1.9;  2.3; %     robot.n_cb = 1.8;         2.35; %     robot.n_rb = 2.65;
            1.2; %     robot.Dhr = 7e6; 0.9; %     human.limit_def = 0.9; %             171.5; %      robot.stiffness_kcb = 5.3e8; 
            ];
        
%             56.0; %     head radius = 0.056 m --> 3 [mm]
%             3.0; %     human skin thickness = 0.003 m --> [mm]
%             20.0; %     Robot Impactor radius = 0.040 m --> [mm]
%             6.0; %     Robot Cover thickness = 0.025 m --> [mm]
%                     ];
    human.cover_width = 0.04;
    robot.limit_def = 0.9;
    human.limit_def = 0.9;
%                     4.4; %     
%                     0.8; %     robot.limit_def = 0.8;
%                     0.8; %     human.limit_def = 0.8;
%                     ];
    
	beta1 = variable_set;
    Fext = collision_sim(vel_0,timeVec,beta1,robot,human,method);
    body_stress = zeros(size(Fext));
%     for iindx=1:length(Fext)
%         body_stress(iindx) = get_strain_stress(deformation,-Fext(iindx),robot,human);
%     end
    
    % Testing the new collision models for fitting
    figure;
    plot(timeVec.*1e3,Fext)
%     hold on;
    maxTime = method.time;
    
    % Data to be fitted for Head Impact
    plot_range5 = find(data_filtered.test_5.time>minTime,1):...
                        find(data_filtered.test_5.time>maxTime,1);
    plot_range6 = find(data_filtered.test_5.time>minTime,1):...
                        find(data_filtered.test_5.time>maxTime,1);
    plot_range7 = find(data_filtered.test_5.time>minTime,1):...
                        find(data_filtered.test_5.time>maxTime,1);

    timeSet = downsample([data_filtered.test_5.time(plot_range5) ...
                            data_filtered.test_6.time(plot_range6) ...
                            data_filtered.test_7.time(plot_range7) ], sampDown);
    F_set = downsample([data_filtered.test_5.impact.Fx(plot_range5) ...
                            data_filtered.test_6.impact.Fx(plot_range6)...
                            data_filtered.test_7.impact.Fx(plot_range7)], sampDown);

    hold on;
    plot(timeSet(:,3),F_set(:,3));

% % % % % % % % % % % Fitting Force Data into Gaussians for each Velocity % % % % % % % % 
    maxTime3 = 5.0; maxTime2 = 6.1; maxTime1 = 6.3;

    end1 = find(timeSet(:,1)>maxTime1,1);    
    F1 = F_set(1:end1,1);
    time1 = timeSet(1:end1,1);
    end2 = find(timeSet(:,2)>maxTime2,1);
    F2 = F_set(1:end2,2);
    time2 = timeSet(1:end2,2);
    end3 = find(timeSet(:,3)>maxTime3,1);
    F3 = F_set(1:end3,3);
    time3 = timeSet(1:end3,3);

    DEBUG_FLAG = true;
    [fitresult1, gof1] = FitForceLegs(time1, F1);
    [fitresult2, gof2] = FitForceLegs(time2, F2);
    [fitresult3, gof3] = FitForceLegs3(time3, F3);

    F_fit = [fitresult1(timeSet(:,1)),...
             fitresult2(timeSet(:,2)),...
             fitresult3(timeSet(:,3))
             ];
    Fmax = max(F_set);
    V_in = [1.0, 1.5, 3.1];
    %
    minTime = 0;
    maxTime = 10;
    minY = -10;
    maxY = 5000;
    AxisPlots = [minTime maxTime minY maxY];
    nfig = 5;
    if DEBUG_FLAG
        plotNpairedData(nfig,[timeSet ],...
                            [F_set],...
                            '--','Impact-Q3-Head-Robot [133Kg]',{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                            'time [ms]','Head Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        plotNpairedData(nfig,[timeSet ],...
                            [F_fit],...
                            '-','Gaussian_Fit_Impact-Q3-Head-Robot133Kg',{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                            'time [ms]','Fitted Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        plot(timeVec.*1e3,Fext,'*r')
    end

    timeSet = timeSet.*1e-3;
    
%% % Fitting Single model data for Human-Roobt Force with Damping (\lamda(n,alpha))
        
        human.cover_width = 0.03;
        robot.limit_def = 0.8;
        human.limit_def = 0.8;

        data_number = 3;
        
        mdl1 = @(beta,x) collision_sim(1.0,x,beta,robot,human,method);
        mdl2 = @(beta,x) collision_sim(1.5,x,beta,robot,human,method);
        mdl3 = @(beta,x) collision_sim(3.1,x,beta,robot,human,method);
        
		% Prepare input for NLINMULTIFIT and perform fitting        
        t_choice = timeSet(:,data_number);
		F_choice = F_fit(:,data_number);
		mdl_choice = eval(strcat('mdl',num2str(data_number)));
% 		Initial estiamte

        beta0 = variable_set;
        beta = beta0;
        % Options for the Non-linear Fitting function handling
        opts = statset('nlinfit');
        opts.RobustWgtFun = 'bisquare';
        [beta,r,J,Sigma,mse,errorparam,robustw]...
                        = nlinfit(t_choice, F_choice, mdl_choice, beta0,opts);
        % Results set: 
        beta
        % Calculate parameter confidence intervals
		ci = nlparci(beta,r,'Jacobian',J);   
        
 		% Calculate model predictions and confidence intervals
        [ypred1,delta1] = nlpredci(mdl1,timeSet(:,1),beta,r,'covar',Sigma);
        [ypred2,delta2] = nlpredci(mdl2,timeSet(:,2),beta,r,'covar',Sigma);
        [ypred3,delta3] = nlpredci(mdl3,timeSet(:,3),beta,r,'covar',Sigma);
        
       %% %  % % % Fitting HCF model through Non-linear least-square % % % % % % % %
	    mdl1 = @(beta,x) collision_sim(1.0,x,beta,robot,human,method);
		mdl2 = @(beta,x) collision_sim(1.5,x,beta,robot,human,method);
        mdl3 = @(beta,x) collision_sim(3.1,x,beta,robot,human,method);
        
		% Prepare input for NLINMULTIFIT and perform fitting        
        t_cell = {timeSet(:,1), timeSet(:,2), timeSet(:,3)};
		F_cell = {F_fit(:,1), F_fit(:,2), F_fit(:,3)};
        
		mdl_cell = {mdl1, mdl2, mdl3};
% 		Initial estiamte
        beta0 = variable_set;
        
        % Options for the Non-linear Fitting function handling
%         opts = statset('nlinfit');
%         opts.RobustWgtFun = 'bisquare';
		[beta_all,r_all,J_all,Sigma_all,mse_all,errorparam_all,robustw_all] = ...
					nlinmultifit(t_cell, F_cell, mdl_cell, beta0);
        beta_all


        %% Evaluating All Data points after fitting:
%         data_number=4;
        beta_test = beta; 
        beta_test = [2.5; 2.2];
%         beta_test = [3.46; 123.8];%1.32;
        % or 
%         data_number=3;
%         beta_test = beta;
        
        % Calculate model predictions and confidence intervals
		[ypred1,delta1] = nlpredci(mdl1,timeSet(:,1),beta_test,r,'covar',Sigma);
		[ypred2,delta2] = nlpredci(mdl2,timeSet(:,2),beta_test,r,'covar',Sigma);
        [ypred3,delta3] = nlpredci(mdl3,timeSet(:,3),beta_test,r,'covar',Sigma);
        
        % % Plot results % % % % 
        nfig = nfig+1;
		FigName = strcat('HRF_model-Child_head-Singlefit-',num2str(data_number));
        plegends = {'$$ \Delta \dot{x}= 1.0 (m/s)$$', '$$ \Delta \dot{x}=  1.5 (m/s) $$', '$$ \Delta \dot{x}=  3.1 (m/s) $$'};
        AxisDist = [minTime 15*1e-3 minY maxY];
        figure(nfig);
		hold all;
		box on;
		p1 = scatter(timeSet(:,1),F_fit(:,1),'blue');
		p2 = scatter(timeSet(:,2),F_fit(:,2),'green');
        p3 = scatter(timeSet(:,3),F_fit(:,3),'r');
		plot(timeSet(:,1),ypred1,'Color','blue','LineWidth',LinesWidths);
		plot(timeSet(:,1),ypred1+delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,1),ypred1-delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,2),ypred2,'Color',[0 0.5 0],'LineWidth',LinesWidths);
		plot(timeSet(:,3),ypred2+delta2,'Color',[0 0.5 0],'LineStyle',':');
		plot(timeSet(:,3),ypred2-delta2,'Color',[0 0.5 0],'LineStyle',':');   
        plot(timeSet(:,3),ypred3,'Color','r','LineWidth',LinesWidths);
		plot(timeSet(:,3),ypred3+delta3,'Color','r','LineStyle',':');
		plot(timeSet(:,3),ypred3-delta3,'Color','r','LineStyle',':');   
        XLabel = 'time [ms]';
        YLabel = 'Impact Force [N]';
        hYLabel=ylabel(YLabel);
        hXLabel=xlabel(XLabel);
%         plegends = {'1.0m/s', '1.5m/s', '3.1 m/s'};
        
        set(gcf, 'Position', [10 10 1080 480]);
        hLegend = legend([p1, p2, p3],...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'vertical',...
                  'location', 'NorthEast',...
                  'Interpreter','latex'...
                );
%         Ymin=min(min(YDATA));
%         Ymax=max(max(YDATA));
            set(gca, ...
              'Box'         , 'off'     , ...
              'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'on'      , ...
              'YMinorTick'  , 'on'      , ...
              'YGrid'       , 'off'      , ...
              'XColor'      , [0.1 0.1 0.1], ...
              'YColor'      , [0.1 0.1 0.1], ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
              'LineWidth'   , 1         );
        set([hXLabel, hYLabel]  , ...
            'FontName',  Fonts,...
            'FontSize',  FontSizes,...
            'color',     [0 0 0]);
        axis(AxisDist)
        
        if true
            set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,FigName),figureFormat);
        end
    
        % HIC Comparison
        % Estiamting HIC from Real data and from Simulations
        Q3_coeff =1;
        [q3_hic(5),q3interval(5,:)] = HIC15_criteria(data_raw_Q3.test_5.time(plot_range5).*1e-3,...
                                                data_raw_Q3.test_5.head.areas(plot_range5),...
                                                Q3_coeff,false);
        [q3_hic(6),q3interval(6,:)] = HIC15_criteria(data_raw_Q3.test_6.time(plot_range6).*1e-3,...
                                                data_raw_Q3.test_6.head.areas(plot_range6),...
                                                Q3_coeff,false);
        [q3_hic(7),q3interval(7,:)] = HIC15_criteria(data_raw_Q3.test_7.time(plot_range7).*1e-3,...
                                                data_raw_Q3.test_7.head.areas(plot_range7),...
                                                Q3_coeff,false);
        
        % Generate Simulated Head Acceleration:
        accpred1 = F_fit(:,1)./(child_head.head_mass*9.81);
        accpred2 = F_fit(:,2)./(child_head.head_mass*9.81);
        accpred3 = F_fit(:,3)./(child_head.head_mass*9.81);
        timeVec = timeSet(:,1);
        
        % Estiamting HIC from Gaussian data:
        [q3g_hic(5),q3ginterval(5,:)] = HIC15_criteria(timeVec,...
                                                accpred1,...
                                                Q3_coeff,false);
        [q3g_hic(6),q3ginterval(6,:)] = HIC15_criteria(timeVec,...
                                                accpred2,...
                                                Q3_coeff,false);
        [q3g_hic(7),q3ginterval(7,:)] = HIC15_criteria(timeVec,...
                                                accpred3,...
                                                Q3_coeff,false);
        
        acc_dev1 = ypred1./(child_head.head_mass*9.81);
        acc_dev2 = ypred2./(child_head.head_mass*9.81);
        acc_dev3 = ypred3./(child_head.head_mass*9.81);
        % Estiamting HIC from Gaussian data:
        [q3s_hic(5),q3ginterval(5,:)] = HIC15_criteria(timeVec,...
                                                acc_dev1,...
                                                Q3_coeff,false);
        [q3s_hic(6),q3ginterval(6,:)] = HIC15_criteria(timeVec,...
                                                acc_dev2,...
                                                Q3_coeff,false);
        [q3s_hic(7),q3ginterval(7,:)] = HIC15_criteria(timeVec,...
                                                acc_dev3,...
                                                Q3_coeff,false);
        q3.apeak = [max(data_raw_Q3.test_5.head.areas(plot_range5)); 
                     max(data_raw_Q3.test_6.head.areas(plot_range6));
                     max(data_raw_Q3.test_7.head.areas(plot_range7));
                     ];
        
        q3s.apeak = [max(acc_dev1); 
                     max(acc_dev2);
                     max(acc_dev3);
                     ];
        q3.error = [(data_raw_Q3.test_5.head.areas(plot_range5) - acc_dev1),...
                 (data_raw_Q3.test_6.head.areas(plot_range6) - acc_dev2),...
                 (data_raw_Q3.test_7.head.areas(plot_range7) - acc_dev3)...
                 ];
        q3.error2 = [(accpred3 - acc_dev1),...
                 (accpred2 - acc_dev2),...
                 (accpred1 - acc_dev3)...
                 ];
        
        q3_hic
        q3g_hic
        q3s_hic
        nfig = nfig+1;
        figName = 'Predicted Acceleration';
        minTime = 0;
        maxTime = method.time;
        AxisPlots = [minTime maxTime -1 220];
       
         plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range5) ...
                                data_raw_Q3.test_6.time(plot_range6) ...%                                 data_raw.test_3.time(plot_range) ...
                                data_raw_Q3.test_7.time(plot_range7) ],...
                            [data_raw_Q3.test_5.head.areas(plot_range5) ...
                                data_raw_Q3.test_6.head.areas(plot_range6)...%                                 data_raw.test_3.head.ay(plot_range)...
                                data_raw_Q3.test_7.head.areas(plot_range7)],...
                            '-.',figName,...
                            plegends,...
                            'time (ms)','Head Acceleration (g m/s^2)',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        plotNpairedData(nfig,[timeVec, ...
                                timeVec,...
                                timeVec ... 
                                ].*1e3,...
                            [acc_dev1,...
                                    acc_dev2,...
                                    acc_dev3 ...
                                ],...
                            '-',figName,plegends,...
                            'time (ms)','Head Acceleration (g m/s^2)'...
                            ,false,figPath,figureFormat...%                             ,AxisPlots...
                            );
        hold on;
        legend( ...
              plegends, ...
              'FontName',Fonts,...
              'FontSize', FontSizes,'FontWeight','bold',...
              'orientation', 'vertical',...
              'location', 'NorthEast',...
              'Interpreter','latex'...
                );
        dim_ann = [0.61 0.3 0.3 0.3]; % [x y w h]
%         str_ann = {'Solid lines = Model-derived','Dotted lines = Head Data'};
%         annotation('textbox',dim_ann,'String',str_ann,'FitBoxToText','on',...
%                        'FontName','TimesNewRoman','FontSize',20);
        if true       
            set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        hold off;
        
        %% Error to each Metric:
        
        Error.rmse = sqrt(mean(q3.error.^2));
        Error.mse = (mean(q3.error.^2));
        Error.std = std(q3.error);
        Error.hic = (q3s_hic)./q3_hic;
        Error.peak = [(q3s.apeak) ./q3.apeak]'
        
        Error2.rmse = sqrt(mean(q3.error2.^2));
        Error2.mse = (mean(q3.error2.^2));
        Error2.std = std(q3.error2);
        Error2.hic = (q3s_hic)./q3_hic;
        Error2.peak = [(q3s.apeak) ./q3.apeak]'
        
        