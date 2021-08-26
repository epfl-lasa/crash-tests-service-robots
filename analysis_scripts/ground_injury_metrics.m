
    % Script for ground injury data analysis and figures

    % % List of Setups from the data recordings:
    % % Each scenario comprises of 3 speeds at contact --> [1.0, 1.5 3.1] (m/s)
    % 4 setups with child dumm Q3 (3-years-old dummy) [1.05m height / 15kg weight]
    % %     Setup A: Dummy Q3 impact at the Chest - [133kg carrier robot]
    % %     Setup A2: Dummy Q3 impact at the Chest - [60kg carrier robot]
    % %     Setup B: Dummy Q3 impact at the Head - [133kg carrier robot]
    % %     Setup C: Dummy Q3 impact at the Legs (Tibia / fibia)  - [133kg carrier robot]

    % Setups with adult dumm HIII (50-percentile adult) [1.77m height / 81.5kg weight] 
    % %     Setup D: Dummy H3 impact at the Legs (Tibia / fibia)  - [133kg carrier robot]
    
    % Author: Diego F. Paez G.
    % Copyright 2020, Dr. Diego Paez-G.
    
    %% Script for gettinng standard Injury Metrics

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
        

        % Options
        SAVE_TAB = true;
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
        figureFormat = 'epsc';%'epsc';
        Fonts = 'Times New Roman';
        load('ColorsData'); 
        
        % Load Data-set of Collisions
        % Calling data of injury from AIS car crashing
        injury_references;
        % lading crash tests:
        load('test_folders.mat')
        load('Q3_raw_collision_struct.mat')
        load('H3_raw_collision_struct.mat')
        load('filtered_collision_struct.mat')

        load('Q3_metrics.mat')
        load('H3_metrics.mat')
        data_q3 = [1:10,16:19];
        q3_testNames = [{'Thorax-$1.0m/s$'}...
                     {'Thorax-$1.5m/s$'}...
                     {'Thorax-$3.1m/s$'}...
                     {'Thorax-$3.2m/s$'}...
                     {'Head-$1.0m/s$'}...
                     {'Head-$1.5m/s$'}...
                     {'Head-$3.1m/s$'}...
                     {'Tibia-$1.0m/s$'}...
                     {'Tibia-$1.5m/s$'}...
                     {'Tibia-$3.1m/s$'}...
                     {'$^*$ Thorax-$1.0m/s$'}...
                     {'$^*$ Thorax-$1.5m/s$'}...
                     {'$^*$ Thorax-$3.1m/s$'}...
                     {'$^*$ Thorax-$3.0m/s$'}...
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
        Q3.weight = 15; %[kg]
        data_h3 = 11:15;

        h3_testNames = [{'1. $1.0m/s$'}... %test_11
                         {'2. $1.5m/s$'}...%test_12
                         {'3. $3.1m/s$'}...%test_13
                         {'4. $3.1m/s$'}...  %test_14  %SUCCESFULL IMPACT
                         {'5. $3.1m/s$'}...%test_15
                         ];
         H3.testSpeed = [1.0 1.5 3.1 3.1 3.1];
         H3.testMass = [133 133 133 133 133];
         H3.weight = 81.5; %[kg]
        % Constants from the current dataset
        Freq = 20000;
        Ts = 1/Freq; % Sampling period in [s]
     
%       Data taken from Crash report - manually labeled the start of
%       contact on the ground;
%         [1]'Test_01_Q3-Ribcage' [1.0m/s]
%         [2]'Test_02_Q3-Ribcage' [1.5m/s]
%         [3]'Test_03-2_Q3-Ribcage' [3.1m/s]
%         [4]'Test_03_Q3-Ribcage_FAILED' [3.2m/s]
%         [5]'Test_04_Q3-Head' [1.0m/s]
%         [6]'Test_05_Q3-Head' [1.5m/s]
%         [7]'Test_06_Q3-Head' [3.1m/s]
%         [8]'Test_07_Q3-Legs' [1.0m/s]
%         [9]'Test_08_Q3-Legs' [1.5m/s]
%         [10]'Test_09_Q3-Legs' [3.1m/s]
%         [11] 'Test_10_H3-Legs' [1.0m/s]
%         [12] 'Test_11_H3-Legs' [1.5m/s]
%         [13] 'Test_12-2_H3-Legs_FAILED' [3.1m/s]
%         [14] 'Test_12-3_H3-Legs' [3.1m/s]
%         [15] 'Test_12_H3-Legs_FAILED' [3.1m/s]
%         [16]'Test_13_Q3-Ribcage' [1.0m/s]
%         [17]'Test_14_Q3-Ribcage' [1.5m/s]
%         [18]'Test_15-2_Q3-Ribcage' [3.1m/s]
%         [19]'Test_15_Q3-Ribcage_FAILED' [3.0m/s]
        groundTimes = [...
                          640; %1
                          596;
                          449;
                          459;
                          653; %5
                          648;  
                          670;
                          1002;
                          1034;
                          1255;  %10
                          1630;
                          1428;
                          0;    %13
                          1654; %14
                          0;    %15
                          685;  %16
                          555;
                          489;
                          467;
                            ];
        h3_groundTimes = [...
                          1630; %11
                          1428; %12
                          0;    %13
                          1654; %14
                          0;    %15
                          ];        
                      

%% ################### Exporting Data Table for LATEX ###################
%     Table of results for Q3(Child dummy 3-years-old):
        Q3.fileName = [];
        Q3.testNum = [];
        Q3.HIC15_robot = [];
        Q3.HIC15_ground = [];
        Q3.Acc_3m = [];
        Q3.Nij  = [];
        Q3.ThCC = [];
        Q3.Thorax_a3ms = [];
        Q3.Vc = [];
        Q3.CTI = [];
        Q3.Force = [];

        for i_indx = data_q3
            Q3.testNum(end+1) = i_indx;
            Q3.fileName{end+1} = eval(['metrics_Q3.test_',num2str(i_indx),'.TestName']);
            Q3.HIC15_robot(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.HIC15_robot']);
            Q3.HIC15_ground(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.HIC15_ground']);
            Q3.Acc_3m(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.head_a_3ms']);
            Q3.Nij(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.Nij']);
            Q3.ThCC(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.ThCC']);
            Q3.Thorax_a3ms(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.Thorax_a3ms']);
            Q3.Vc(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.VC']);
            Q3.CTI(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.CTI']);
            eval(['metrics_Q3.test_',num2str(i_indx),...
                 '.PeakForce = max(data_filtered.test_',num2str(i_indx),'.impact.Fx);'])
            Q3.Force(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.PeakForce']);
        end
        % Correcting Zero Values in HIC-15 (imported this way from excel),
        % however, it should be Non-applicable
        Q3.HIC15_robot(~Q3.HIC15_robot)=NaN;
        Q3.testNames = q3_testNames;
    
    % =========  HIC-15 Analysis for Q3 Dummy tests ======== %
    % ------ Acceleration at the Head for Q3 --------
    
    % Value from literature and standards:
    % Palisson, A., Cassan, F., Trosseille, X., Lesire, P., & Alonzo, F. (2007). 
    % Estimating Q3 dummy injury criteria for frontal impacts using the child project 
    % results and scaling reference values. In International IRCOBI Conference on the 
    % Biomechanics of Injury (pp. 263–276). Netherlands.

    % HIC assessment for blunt impact to the head on the ground (concrete)
    minX = -20;
    maxX = 200;
    Q3_coeff=1;
    Q3.hic_ground = zeros(1,length(Q3.testNum));
    Q3.acc3ms_ground = Q3.hic_ground;
    Q3.acc_peak_ground = Q3.hic_ground;
    Q3.ground_interval = zeros(length(Q3.testNum),2);
    Q3.ground_acc_interval = zeros(length(Q3.testNum),2);
    jindx=1;

%  % HIC assessment for Ground Impacts:
    jindx=1;
    for i_test=Q3.testNum
         evalRange = eval(['find(data_raw_Q3.test_',num2str(i_test),...
                    '.time>groundTimes(i_test)+minX,1):find(data_raw_Q3.test_',num2str(i_test),...
                    '.time>groundTimes(i_test)+maxX,1)']);
        [Q3.hic_ground(jindx),Q3.ground_interval(i_test,:)] = ...
                                    eval(['HIC15_criteria(data_raw_Q3.test_',num2str(i_test),...
                                        '.time(evalRange).*1e-3,data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange))']);
                                    
        [Q3.acc3ms_ground(jindx),Q3.ground_acc_interval(i_test,:)] = ...
                                    eval(['acc3ms_criteria(data_raw_Q3.test_',num2str(i_test),...
                                        '.time(evalRange),data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange))']);
        Q3.acc_peak_ground(jindx) = eval(['max(data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange));']);
        jindx = jindx+1;
    end
    
    % ################### Getting Neck Injury Criteria ###################                      
        
        Q3.NFz =  []; Q3.NFz_impact =  [];
        Q3.NMy =  []; Q3.NMy_impact =  [];
        minX = -5; maxX = 200;
        impactRange = find(data_raw_Q3.test_1.time>minX,1):...
                            find(data_raw_Q3.test_1.time>maxX,1);
        for itest = data_q3
            Q3.NFz_impact(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.Fz(impactRange)))'])./1000;
            Q3.NMy_impact(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.My(impactRange)))'])./1000;
            Q3.NFz(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.Fz))'])./1000;
            Q3.NMy(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.My))'])./1000;
        end
        
    %% ======== Table of results for H3(50-percentil adult human dummy) ========= %
        H3.testNum = [];
        H3.HIC15_ground = [];
        H3.TCFC_right = [];
        H3.TCFC_left  = [];
        H3.TI_lower_right = [];
        H3.TI_lower_left = [];
        H3.TI_upper_right = [];
        H3.TI_upper_left = [];
        H3.Force = [];
        
        for i_indx = data_h3
            H3.testNum(end+1) = i_indx;
            H3.HIC15_ground(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.HIC15_ground']);
            H3.TCFC_right(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TCFC_right']);
            H3.TCFC_left(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TCFC_left']);
            H3.TI_lower_right(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_lower_right']);
            H3.TI_lower_left(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_lower_left']);
            H3.TI_upper_right(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_upper_right']);
            H3.TI_upper_left(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_upper_left']);
            eval(['metrics_H3.test_',num2str(i_indx),...
                 '.PeakForce = max(data_filtered.test_',num2str(i_indx),'.impact.Fx);'])
            H3.Force(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.PeakForce']);
            
        end
        H3.testNames = h3_testNames;
        
        % Getting RTI crieteria
        H3.RTI_lower_right = [];
        H3.RTI_lower_left = [];
        H3.RTI_upper_right = [];
        H3.RTI_upper_left = [];
        H3.RTI_lower_right_idx = [];
        H3.RTI_lower_left_idx = [];
        H3.RTI_upper_right_idx = [];
        H3.RTI_upper_left_idx = [];
        H3.hic_ground = [];
        H3.acc3ms_ground = [];
        H3.acc_peak_ground = [];
        H3.ground_interval = []; 
        H3.ground_acc_interval = [];
        
        for i_indx = data_h3
            mint = -20;
            maxt = 1000;
            rangeImpact = find(eval(['data_raw_H3.test_',num2str(i_indx),'.time'])>mint,1):...
                                find(eval(['data_raw_H3.test_',num2str(i_indx),'.time'])>maxt,1);
            
            [H3.RTI_lower_right(end+1),...
             H3.RTI_lower_right_idx(end+1)]  = RTI_criteria(...
                                       eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRFz(rangeImpact)'])...
                                      ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRMx(rangeImpact)'])...
                                      ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRMx(rangeImpact)'])...
                                                );
            [H3.RTI_lower_left(end+1),...
                H3.RTI_lower_left_idx(end+1)]  = RTI_criteria(...
                                               eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLFz(rangeImpact)'])...
                                              ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLMx(rangeImpact)'])...
                                              ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLMx(rangeImpact)'])...
                                                );
            [H3.RTI_upper_right(end+1),...
                H3.RTI_upper_right_idx(end+1)]  = RTI_criteria(...
                                               eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRFz(rangeImpact)'])...
                                              ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upRMx(rangeImpact)'])...
                                              ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upRMy(rangeImpact)'])...
                                                );
            [H3.RTI_upper_left(end+1),...
                H3.RTI_upper_left_idx(end+1)]  = RTI_criteria(...
                                               eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLFz'])...
                                              ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upLMx'])...
                                              ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upLMy'])...
                                                );
            % HIC assessment for blunt impact to the head on the ground (concrete)
            minX = -20;
            maxX = 200;
            evalRange = eval(['find(data_raw_H3.test_',num2str(i_indx),...
                    '.time>groundTimes(i_indx)+minX,1):find(data_raw_H3.test_',num2str(i_indx),...
                    '.time>groundTimes(i_indx)+maxX,1)']);
                
            [H3.hic_ground(end+1),H3.ground_interval(end+1,:)] = ...
                                    eval(['HIC15_criteria(data_raw_H3.test_',num2str(i_indx),...
                                        '.time(evalRange).*1e-3,data_raw_H3.test_',num2str(i_indx),'.head.areas(evalRange))']);
                                    
            [H3.acc3ms_ground(end+1),H3.ground_acc_interval(end+1,:)] = ...
                                    eval(['acc3ms_criteria(data_raw_H3.test_',num2str(i_indx),...
                                        '.time(evalRange),data_raw_H3.test_',num2str(i_indx),'.head.areas(evalRange))']);
            H3.acc_peak_ground(end+1) = eval(['max(data_raw_H3.test_',num2str(i_indx),'.head.areas(evalRange));']);
        end
        
        
        %% Neck Injury Criteria from Neck Tension/Extension - Q3-dummy
         % ======================= Setup A-B-C ========================== %
        % % % Robot Mass: 133 kg 
        % % % Dummy Q-3: 50-percentile 3-years-old
        
        figName = 'Q3-AIS_NFz-Robot-133kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on H3 were 11-15
        typeInjury = 'NFz';
        typeDummy = 'Q3';
        for itest=1:10
            [Q3.AIS_NFz(itest,:),Q3.AISlevel_NFz(itest)] = pAIS(Q3.NFz(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ======================= Setup A-2 ========================== %
        % % % Robot Mass: 60 kg 
        % % % Dummy Q-3: 50-percentile 3-years-old
        figName = 'Q3-AIS_NFz-Robot-60kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on Q3 were 16-19
        typeInjury = 'NFz';
        typeDummy = 'Q3';
        for itest=[11:14]
            [Q3.AIS_NFz(itest,:),Q3.AISlevel_NFz(itest)] = pAIS(Q3.NFz(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end

                %  HIC-15 conversion to AIS levels
        % ======================= Setup D ========================== %
        % % % Robot Mass = 133 kg 
        % % % Dummy H-3: 50-percentile adult
        nfig = nfig+ 1;
        figName = 'H3-AIS_HIC15-Robot-133kg-ground-impact'; 
        typeInjury = 'HIC15_u';
        typeDummy = 'H3';
        % Tests on H3 where 1-10
        for itest=[1,2,3,4,5]
            [H3.AIS_ground(itest,:), H3.AISlevel(itest)] = pAIS(H3.HIC15_ground(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);   
            
        end
        H3.AIS_ground(itest,:)
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ======================= Setup A-B-C ========================== %
        % % % Robot Mass: 133 kg 
        % % % Dummy Q-3: 50-percentile 3-years-old
        figName = 'Q3-AIS_HIC15-Robot-133kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on H3 were 11-15
        typeInjury = 'HIC15_u';
        typeDummy = 'Q3';
        for itest=1:10
            [Q3.AIS_ground(itest,:),Q3.AISlevel_ground(itest)] = pAIS(Q3.HIC15_ground(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ======================= Setup A-2 ========================== %
        % % % Robot Mass: 60 kg 
        % % % Dummy Q-3: 50-percentile 3-years-old
        figName = 'Q3-AIS_HIC15-Robot-60kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on Q3 were 16-19
        typeInjury = 'HIC15_u';
        typeDummy = 'Q3';
        for itest=[11:14]
            [Q3.AIS_ground(itest,:),Q3.AISlevel_ground(itest)] = pAIS(Q3.HIC15_ground(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ======================= Setup B ========================== %
        % % % Setup B: Dummy Q3 impact at the Head - [133kg carrier robot]
        figName = 'Q3-AIS_HIC15-Robot-133kg-head-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        typeInjury = 'HIC15_u';
        typeDummy = 'Q3';
        % Tests on Q3-head were 5-7
        for itest=[5:7]
            [Q3.AIS_HIC(itest,:),Q3.AISlevel_HIC(itest)] = pAIS(Q3.HIC15_robot(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        Q3.AIS_HIC(8:14,:)=zeros(7,3);
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
                        
        %% --------------- Q3 Ground Impact - Neck Injury -----------------%
        % ============== Cumulative Neck Forces ================ %
        % Source: [EuroNcap 2015] Neck Values for Adult Dummy H3 
        % []: Neck values for Child dummy Q3
        time_Fx = [0 25 35 45 90];
        Forces_Fx = [1.9 1.25 1.25 1.1 1.1; % Higher Performance
                    2.3 1.3 1.3 1.1 1.1;
                    2.7 1.4 1.4 1.1 1.1;
                    3.1 1.5 1.5 1.1 1.1];
        
        time_Fz = [0 35 60 90];
        Forces_Fz = [2.7 2.3 1.1 1.1; % Higher Performance
                    2.9 2.5 1.1 1.1;
                    3.1 2.7 1.1 1.1;
                    3.3 2.9 1.1 1.1];
                
        % ﻿These values scaled to the Q3 correspond to: [Wismans 2008]
        Q3scaleFactor.NF = 0.41;
        Q3scaleFactor.NM = 0.33;
        
        PicSize = [10 10 780 480];
                Flabels = {'*b', '^b', 'ob','vb'... % 1-4 --> Blue - Chest
                    ,'*k', '^k', 'ok'...    % 5-7 --> Black - Head
                    ,'*m', '^m', 'om'...    % 8-10 --> Magenta - Legs-133kg
                    ,'*c', '^c', 'oc', '<c'... % 16-19 --> Cyan - Chest-60kg
                    };
        Ftcolor= {'b', 'b', 'b','b'...
                    ,'k', 'k', 'k'...
                    ,'m', 'm', 'm'...
                    ,'c', 'c', 'c','c'...
                    };
        str_ann = {'*  1 m/s','\Delta 1.5 m/s','o  3.1 m/s'};
        dim_ann = [0.65 0.60 0.3 0.3]; % [x y w h]
        minX = -50;
        maxX = 200;
        % ======================= Setup A ========================== %
        % Dummy impact at chest - [133 kg]
        plot_range1 = find(data_raw_Q3.test_1.time>groundTimes(1)+minX,1):...
                    find(data_raw_Q3.test_1.time>groundTimes(1)+maxX,1);
        plot_range2 = find(data_raw_Q3.test_2.time>groundTimes(2)+minX,1):...
                    find(data_raw_Q3.test_2.time>groundTimes(2)+maxX,1);
        plot_range3 = find(data_raw_Q3.test_3.time>groundTimes(3)+minX,1):...
                    find(data_raw_Q3.test_3.time>groundTimes(3)+maxX,1);
        plot_range4 = find(data_raw_Q3.test_4.time>groundTimes(4)+minX,1):...
                    find(data_raw_Q3.test_4.time>groundTimes(4)+maxX,1);
        % ======================= Setup B ========================== %
        % Dummy Q3 impact at the Legs (Tibia / fibia)-[133kg]%
        plot_range5 = find(data_raw_Q3.test_5.time>groundTimes(5)+minX,1):...
                    find(data_raw_Q3.test_5.time>groundTimes(5)+maxX,1);
        plot_range6 = find(data_raw_Q3.test_6.time>groundTimes(6)+minX,1):...
                    find(data_raw_Q3.test_6.time>groundTimes(6)+maxX,1);
        plot_range7 = find(data_raw_Q3.test_7.time>groundTimes(7)+minX,1):...
                    find(data_raw_Q3.test_7.time>groundTimes(7)+maxX,1);
        % ======================= Setup C ========================== %
        % Dummy Q3 impact at the Legs (Tibia / fibia)-[133kg]%
        plot_range8 = find(data_raw_Q3.test_8.time>groundTimes(8)+minX,1):...
                    find(data_raw_Q3.test_8.time>groundTimes(8)+maxX,1);
        plot_range9 = find(data_raw_Q3.test_9.time>groundTimes(9)+minX,1):...
                    find(data_raw_Q3.test_9.time>groundTimes(9)+maxX,1);
        plot_range10 = find(data_raw_Q3.test_10.time>groundTimes(10)+minX,1):...
                    find(data_raw_Q3.test_10.time>groundTimes(10)+maxX,1);
        % ======================= Setup A2 ========================== %
        % Dummy impact impact at chest - Robot [60skg]
        plot_range16 = find(data_raw_Q3.test_16.time>groundTimes(16)+minX,1):...
                        find(data_raw_Q3.test_16.time>groundTimes(16)+maxX,1);
        plot_range17 = find(data_raw_Q3.test_17.time>groundTimes(17)+minX,1):...
                        find(data_raw_Q3.test_17.time>groundTimes(17)+maxX,1);
        plot_range18 = find(data_raw_Q3.test_18.time>groundTimes(18)+minX,1):...
                        find(data_raw_Q3.test_18.time>groundTimes(18)+maxX,1);
        plot_range19 = find(data_raw_Q3.test_19.time>groundTimes(19)+minX,1):...
                        find(data_raw_Q3.test_19.time>groundTimes(19)+maxX,1);
        
        % ---- Tension during extension forces ----- %
        nfig = nfig +1;
        figName = 'NeckForces-exceedence-Fz-Ground-Q3';
        Ylabel = 'Upper Neck Tension Fz [kN]';
%         Flabels = {'*b', '^b', 'ob','vb'...
%                     ,'*k', '^k', 'ok'...
%                     ,'*m', '^m', 'om'...
%                     };
%         str_ann = {'* = 1 m/s','\Delta = 1.5 m/s','o = 3.1 m/s','\nabla = 3.2 m/s'};
        AxisPlots = [0 90 0 2];
        Q3.maxFz_ground = plot_NeckCummulative(abs([data_raw_Q3.test_1.neck.Fz(plot_range1)...
                            data_raw_Q3.test_2.neck.Fz(plot_range2)...
                            data_raw_Q3.test_3.neck.Fz(plot_range3)...
                            data_raw_Q3.test_4.neck.Fz(plot_range4)...
                            data_raw_Q3.test_5.neck.Fz(plot_range5)...
                            data_raw_Q3.test_6.neck.Fz(plot_range6)...
                            data_raw_Q3.test_7.neck.Fz(plot_range7)...
                            data_raw_Q3.test_8.neck.Fz(plot_range8)...
                            data_raw_Q3.test_9.neck.Fz(plot_range9)...
                            data_raw_Q3.test_10.neck.Fz(plot_range10)...
                            data_raw_Q3.test_16.neck.Fz(plot_range16)...
                            data_raw_Q3.test_17.neck.Fz(plot_range17)...
                            data_raw_Q3.test_18.neck.Fz(plot_range18)...
                            data_raw_Q3.test_19.neck.Fz(plot_range19)...
                            ]./1e3),...
                            Forces_Fz.*Q3scaleFactor.NF,time_Fz,Freq,Flabels,Ftcolor,...
                            nfig,figPath,figName,Ylabel,SAVE_PLOTS,AxisPlots);
        hold on; 
%         dim_ann = [0.7 0.6 0.3 0.3]; % [x y w h]
        annotation('textbox',dim_ann,'String',str_ann,'FitBoxToText','on',...
                       'FontName','TimesNewRoman','FontSize',FontSizes-4,...
                       'BackgroundColor','w'); 
        set(gcf, 'Position', PicSize);
        set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ------------- pAIS+3 for ground Impact (Neck) -----------------%
        nfig = nfig+1;
        typeInjury = 'NFz';
        typeDummy = 'Q3';
        for itest=1:14
            [Q3.AIS_NFz_ground(itest,:),Q3.AISlevel_Neckground(itest)] = pAIS(Q3.maxFz_ground(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
                
        % --------------- Q3 Impact Shear Neck Forces Injury ----------------------%
        nfig = nfig+1;
        figName = 'NeckForces-Shearing-Fx-Ground';
        Ylabel = 'Upper Neck Shearing Fx [kN]';
        minX = -5;
        maxX = 100;
        AxisPlots = [0 90 0 2];
        Q3.maxFx_ground = plot_NeckCummulative(abs([data_raw_Q3.test_1.neck.Fx(plot_range1)...
                            data_raw_Q3.test_2.neck.Fx(plot_range2)...
                            data_raw_Q3.test_3.neck.Fx(plot_range3)...
                            data_raw_Q3.test_4.neck.Fx(plot_range4)...
                            data_raw_Q3.test_5.neck.Fx(plot_range5)...
                            data_raw_Q3.test_6.neck.Fx(plot_range6)...
                            data_raw_Q3.test_7.neck.Fx(plot_range7)...
                            data_raw_Q3.test_8.neck.Fx(plot_range8)...
                            data_raw_Q3.test_9.neck.Fx(plot_range9)...
                            data_raw_Q3.test_10.neck.Fx(plot_range10)...
                            data_raw_Q3.test_16.neck.Fx(plot_range16)...
                            data_raw_Q3.test_17.neck.Fx(plot_range17)...
                            data_raw_Q3.test_18.neck.Fx(plot_range18)...
                            data_raw_Q3.test_19.neck.Fx(plot_range19)...
                            ]./1e3),...
                            Forces_Fx.*Q3scaleFactor.NF,time_Fx,Freq,Flabels,Ftcolor,...
                            nfig,figPath,figName,Ylabel,SAVE_PLOTS,AxisPlots);
        hold on;
%         dim_ann = [0.65 0.60 0.3 0.3]; % [x y w h]
        annotation('textbox',dim_ann,'String',str_ann,'FitBoxToText','on',...
                       'FontName','TimesNewRoman','FontSize',FontSizes-4,...
                       'BackgroundColor','w'); 

        set(gcf, 'Position', PicSize);
        set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        %% ======================= Final Plot Graphs ========================== %
        % CONTINUE HERE: Make a unified plot of the AIS probability for all tests
        % starting with ground impacts (as an independent unified measurement)
        % Color Palette for AIS+3
        % clc; close all;
        ColorsAIS = [50 130 0;% 0-5%
                     220 200 0;% 5-20%
                     255 150 0;% 20-50%
                     190 0 0;% 50-100%
                        ]./255;
        figName = 'AIS3-Ground_Impact';
        nfig = nfig+1;
        plot_resultsAIS(Q3,H3,2, nfig, figPath,figName,figureFormat,true,1)
        
%%      Plotting Each metric pAIS compared with the IARV:
%       For Q3 Dummy = Q3eevcL / Q3eevc50
%       For H3 Dummy = H3encapH / H3encapL / H3encap50
        typeDummy = 'Q3'; 
        typeInjury = 'HIC15';
        AIS3Q3.headL = pAIS(Q3eevcL.HIC15,...
                    typeDummy,typeInjury,false,1);
        typeDummy = 'H3'; 
        typeInjury = 'HIC15';
        AIS3H3.headL = pAIS(H3encapL.HIC15,...
                    typeDummy,typeInjury,false,1);
        typeInjury = 'HIC15';
        AIS3H3.headH = pAIS(H3encapH.HIC15,...
                    typeDummy,typeInjury,false,1);
                
%% Getting Velocity plots for impact to the ground
    
    minX = -10;
    maxX = 2000; % end
    % Integrating step to get all head velocities
    for i_test=Q3.testNum
%          evalRange = eval(['find(data_raw_Q3.test_',num2str(i_test),...
%                     '.time>minX,1):data_raw_Q3.test_',num2str(i_test),'.time(end);']);
         q3_data{i_test}.time = eval(['data_raw_Q3.test_',num2str(i_test),'.time.*1e-3;']);
         q3_data{i_test}.vel.res = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.areas.*9.81)']);
         q3_data{i_test}.vel.x = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.ax.*9.81)']);
         q3_data{i_test}.vel.y = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.ay.*9.81)']);
         q3_data{i_test}.vel.z = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.az.*9.81)']);
         ground_indx(i_test) = eval(['find(data_raw_Q3.test_',num2str(i_test),'.time>groundTimes(',num2str(i_test),'),1);']);
         q3_data{i_test}.vel.ground = q3_data{i_test}.vel.res(ground_indx(i_test));
        jindx = jindx+1;
    end

    %%
%     clc; close all;
        nfig = nfig+1;
        figName = 'Velocity-head-impacts';
        plegends = {'Vx','Vy','Vz'};
        AxisPlots = [minX maxX -100 7000];
        plotNpairedData(nfig,[q3_data{7}.time,...
                              q3_data{7}.time,...
                              q3_data{7}.time...
                                ],...
                            [q3_data{7}.vel.x,...
                            q3_data{7}.vel.y,...
                            q3_data{7}.vel.z,...
                            ],...
                            '*',figName,plegends,...
                            'time (s)','Head Resulting Vel'...
                            ,true,figPath,figureFormat...%                             ,AxisPlots...
                            );
        hold on;
%         plot([q3_data{5}.time(ground_indx(5)) q3_data{5}.time(ground_indx(5))],[0 5],...
%                     '--k','linewidth',2);
%         plot([q3_data{6}.time(ground_indx(6)) q3_data{6}.time(ground_indx(6))],[0 5],...
%                     '--k','linewidth',2);
        plot([q3_data{7}.time(ground_indx(7)) q3_data{7}.time(ground_indx(7))],[-2 10],...
                    '--k','linewidth',2);
        
    
                
        %% ========= Exporting the metric results and pAIS+3 =========== %
        % ---------- Results Ground Impacts ----------- %
        Q3.pAIS3_ground = max([Q3.AIS_ground(:,2) Q3.AIS_NFz_ground(:,3)]')';
        
        table_indx3 = [13;3;7;10;14;4];  % 4 --> 3.2 m/s, 14 --> 3.0 m/s
        table_indx2 = [12;2;6;9];
        table_indx1 = [11;1;5;8];
        
        Q3_indx = [table_indx3; table_indx2;table_indx1];
        H3_indx = [1,2,4];
        Q3.rowNames = [{'1.0 Thorax [133kg]'}...
                     {'1.5 Thorax [133kg]'}...
                     {'3.1 Thorax [133kg]'}...
                     {'3.2 Thorax [133kg]'}...
                     {'1.0 Head'}...
                     {'1.5 Head'}...
                     {'3.1 Head'}...
                     {'1.0 Tibia'}...
                     {'1.5 Tibia'}...
                     {'3.1 Tibia'}...
                     {'1.0 Thorax [60kg]'}...
                     {'1.5 Thorax [60kg]'}...
                     {'3.1 Thorax [60kg]'}...
                     {'3.0 Thorax [60kg]'}...
                     ];
        H3.rowNames = [...
                     {'Tibia [133kg / 1.0m/s]'}...
                     {'Tibia [133kg / 1.5m/s]'}...
                     {'Tibia [133kg / 3.1m/s]'}...
                     {'Tibia [133kg / 3.1m/s]'}...
                     {'Tibia [133kg / 3.1m/s]'}...
                    ...
                    ];
        Q3.location = [{'Thorax'}...
                     {'Thorax'}...
                     {'Thorax'}...
                     {'Thorax'}...
                     {'Head'}...
                     {'Head'}...
                     {'Head'}...
                     {'Tibia'}...
                     {'Tibia'}...
                     {'Tibia'}...
                     {'Thorax'}...
                     {'Thorax'}...
                     {'Thorax'}...
                     {'Thorax'}...
                    ...
                    ];
                
        H3.location = [{'Tibia'}...
                     {'Tibia'}...
                     {'Tibia'}...
                     {'Tibia'}...
                     {'Tibia'}...
                     ];
        rowNames = [Q3.rowNames(Q3_indx)'; H3.rowNames(H3_indx)'];
        GroundData.location = [Q3.location(Q3_indx)'; H3.location(H3_indx)'];
        GroundData.weights = [Q3.testMass(Q3_indx) H3.testMass(H3_indx)]';
        GroundData.speed = [Q3.testSpeed(Q3_indx) H3.testSpeed(H3_indx)]';
        
        NanVec = [NaN NaN NaN];
        GroundData.HIC15_ground = [Q3.HIC15_ground(Q3_indx) H3.HIC15_ground(H3_indx)]';
        GroundData.acc3ms_ground = [Q3.acc3ms_ground(Q3_indx) H3.acc3ms_ground(H3_indx)]';
        GroundData.acc_peak_ground = [Q3.acc_peak_ground(Q3_indx) H3.acc_peak_ground(H3_indx)]';
        GroundData.maxFz_ground = [Q3.maxFz_ground(Q3_indx) NanVec]';
        GroundData.maxFx_ground = [Q3.maxFx_ground(Q3_indx) NanVec]';
        
        GroundData.pAIS3_ground = [Q3.pAIS3_ground(Q3_indx); H3.AIS_ground(H3_indx,2)];
        GroundData.pAIS4_ground = [Q3.AIS_ground(Q3_indx,3); H3.AIS_ground(H3_indx,3)];
        
        % Exporting Latex Table
        Q3.metrics_table = table( GroundData.speed, GroundData.weights,...
                                 GroundData.HIC15_ground, ...
                                 GroundData.acc3ms_ground,GroundData.acc_peak_ground,...
                                 GroundData.maxFz_ground,GroundData.maxFx_ground,...
                                 GroundData.pAIS3_ground.*100, GroundData.pAIS4_ground.*100  ...
                                );

        inputl.tableColLabels = {'Vel (m/s)','Mass (kg)',...
                                '$HIC15$','$Acc_{3ms}$ [g]','Peak Acc [g]',...
                                'Neck Fz [kN]','Neck Fx [kN]',...
                                'p(AIS+3)  [\%]', 'p(AIS+4)  [\%]'...
                                };
%
        Q3.metrics_table.Properties.RowNames = rowNames;
        Q3.metrics_table.Properties.VariableNames = inputl.tableColLabels;

        inputl.data = Q3.metrics_table;
        inputl.dataFormat = {'%.1f',1,'%.0f',2,'%.1f',2,'%.3f',2,'%.1f',2};
        inputl.tableColumnAlignment = 'c';
    %     inputl.dataFormatMode = 'column';
        latex_tot = latexTable(inputl);
        if SAVE_TAB
            fileID = fopen([outputPath,'/ground_impacts.txt'],'w');
            formatSpec = '%s\n';
            [nrows,ncols] = size(latex_tot);
            for row = 1:nrows
                fprintf(fileID,formatSpec,latex_tot{row,:});
            end
            fclose(fileID);
        end
        
        
        %% Exporting table to Excel:
        filename = [outputPath,'/ground_table.xlsx'];
        writetable(Q3.metrics_table,filename,'Sheet',1,'Range','A1')
    
    