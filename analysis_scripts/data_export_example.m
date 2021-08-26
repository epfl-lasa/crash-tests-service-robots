% Short script for reading and plotting collisions of a given location on
% the dummy side.
% Author: Diego F. Paez G.
% Date: 17 Mar 2021

% Configuration: 
% Clone the repository:
%  git clone https://github.com/epfl-lasa/service_robots_collisions.git
%  git checkout -b new_branch

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

    %% Options    
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
        
    %% Load Data-set of Collisions   
        % Calling data of injury from AIS car crashing
        % lading crash tests:
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
                         {'4-$133kg$, $3.1ms^{-1}$'}... %SUCCESFULL IMPACT
                         {'5-$133kg$, $3.1ms^{-1}$'}...
                         ];
         H3.testSpeed = [1.0 1.5 3.1 3.1 3.1];
         H3.testMass = [133 133 133 133 133];
        % Constants from the current dataset
        Freq = 20000;
        Ts = 1/Freq; % Sampling period in [s]
        
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
     
        %% Data Structure short explanation:
        
        % Head Acceleration (norm of 3-d accelerations) areas = sqrt(ax^2+ay^2+az^2)
        % data_raw_Q3.test_7.head.areas
        % Impact Force measured at the robot (Fx is the frontal force)
        % data_filtered.test_7.impact.Fx
        
        %% =================== DATA VISUALIZATION =================== %
        if DRAW_PLOTS
            % ======================= Setup B ========================== %
            % ---------- Robot Mass = 133 kg / impact at head --------- %
            
            % ---------- Impact Force Data --------- %
            minTime = -5;
            maxTime = 50;
            minY = -10;
            maxY = 5000;
            AxisPlots = [minTime maxTime minY maxY];
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_5.time>200,1); %length(data_raw.test_5.time) ;
            plot_range = find(data_filtered.test_1.time>minTime,1):find(data_filtered.test_1.time>maxTime,1);
            plotNpairedData(nfig,[data_filtered.test_5.time(plot_range) ...
                                    data_filtered.test_6.time(plot_range) ...
                                    data_filtered.test_7.time(plot_range) ],...
                                [data_filtered.test_5.impact.Fx(plot_range) ...
                                    data_filtered.test_6.impact.Fx(plot_range)...
                                    data_filtered.test_7.impact.Fx(plot_range)],...
                                '-','Impact-Q3-Head-Robot [133Kg]',{'1.0 (m/s)' '1.5 (m/s)' '3.1 (m/s)'},...
                                'time [ms]','Head Impact Force [N]',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);
            
            % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 0;
            maxY = 200;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-Acceleration-Impact-Q3-Head-Robot[133Kg]';
            plegends = {'1.0 (m/s)' '1.5 (m/s)' '3.1 (m/s)'};
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_raw_Q3.test_1.time>minX,1):...
                                find(data_raw_Q3.test_1.time>maxX,1);
            plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range) ...
                                    data_raw_Q3.test_6.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                    data_raw_Q3.test_7.time(plot_range) ],...
                                [data_raw_Q3.test_5.head.areas(plot_range) ...
                                    data_raw_Q3.test_6.head.areas(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_7.head.areas(plot_range)],...
                                '-',figName,...
                                {'1.0 (m/s)' '1.5 (m/s)' '3.1 (m/s)'},...
                                'time [ms]','Acceleration [g]',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);  
                            
            
            % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 20;
            maxY = -160;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-Acceleration-ax-Impact-Q3-Head-Robot[133Kg]';
            plegends = {'1.0 (m/s)' '1.5 (m/s)' '3.1 (m/s)'};
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_raw_Q3.test_1.time>minX,1):...
                                find(data_raw_Q3.test_1.time>maxX,1);
            plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range) ...
                                    data_raw_Q3.test_6.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                    data_raw_Q3.test_7.time(plot_range) ],...
                                [data_raw_Q3.test_5.head.ax(plot_range) ...
                                    data_raw_Q3.test_6.head.ax(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_7.head.ax(plot_range)],...
                                '-',figName,...
                                {'1.0 (m/s)' '1.5 (m/s)' '3.1 (m/s)'},...
                                'time [ms]','Acceleration Ax [g]',SAVE_PLOTS,figPath,...
                                figureFormat);  

             % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 20;
            maxY = -200;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-Acceleration-ay-Impact-Q3-Head-Robot[133Kg]';
            plegends = {'1.0 (m/s)' '1.5 (m/s)' '3.1 (m/s)'};
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_raw_Q3.test_1.time>minX,1):...
                                find(data_raw_Q3.test_1.time>maxX,1);
            plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range) ...
                                    data_raw_Q3.test_6.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                    data_raw_Q3.test_7.time(plot_range) ],...
                                [data_raw_Q3.test_5.head.ay(plot_range) ...
                                    data_raw_Q3.test_6.head.ay(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_7.head.ay(plot_range)],...
                                '-',figName,...
                                {'1.0 (m/s)' '1.5 (m/s)' '3.1 (m/s)'},...
                                'time [ms]','Acceleration Ay [g]',SAVE_PLOTS,figPath,...
                                figureFormat);  
                                               
        end
        
        %% Exporting extract of impact to the head:
        
        load('/Users/diego/Documents/MATLAB/LASA/CrowdBots/human-robot-collider/src/matlab/Test6.mat');
        f_hs = 1000;
        fpass = 100;
        t_start = -95;
        robot_speed = lowpass(velList',fpass,f_hs);
        
        head_3.robot_speed_list = robot_speed;
        head_3.robot_speed = robot_speed(:,15);
        samples = length(head_3.robot_speed);
        head_3.robot_time = linspace(t_start,samples+t_start,samples)'.*1e-3;
        
        minTime = -10;
        maxTime = 100;
        plot_range5 = find(data_filtered.test_5.time>minTime,1):...
                        find(data_filtered.test_5.time>maxTime,1);
        plot_range6 = find(data_filtered.test_5.time>minTime,1):...
                        find(data_filtered.test_5.time>maxTime,1);
        plot_range7 = find(data_filtered.test_5.time>minTime,1):...
                        find(data_filtered.test_5.time>maxTime,1);
        

        % Integrating step to get all head velocities
        for i_test=[5:7]
        %    evalRange = eval(['find(data_raw_Q3.test_',num2str(i_test),...
        %                     '.time>minX,1):data_raw_Q3.test_',num2str(i_test),'.time(end);']);
             q3_data{i_test}.time = eval(['data_raw_Q3.test_',num2str(i_test),'.time.*1e-3;']);
             q3_data{i_test}.vel.res = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.areas.*9.81)']);
             q3_data{i_test}.vel.x = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.ax.*9.81)']);
             q3_data{i_test}.vel.y = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.ay.*9.81)']);
             q3_data{i_test}.vel.z = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.head.az.*9.81)']);
        %          tcontact = groundTimes(i_test) - evalRange(1);
             ground_indx(i_test) = eval(['find(data_raw_Q3.test_',num2str(i_test),'.time>groundTimes(',num2str(i_test),'),1);']);
             q3_data{i_test}.vel.ground = q3_data{i_test}.vel.res(ground_indx(i_test));
        end
        
        head_1.vel = q3_data{5}.vel.res(plot_range5);
        head_2.vel = q3_data{6}.vel.res(plot_range6);
        head_3.vel = q3_data{7}.vel.res(plot_range7);
        
        head_1.vx = q3_data{5}.vel.x(plot_range5);
        head_2.vx = q3_data{6}.vel.x(plot_range6);
        head_3.vx = q3_data{7}.vel.x(plot_range7);
        
        head_1.vy = q3_data{5}.vel.y(plot_range5);
        head_2.vy = q3_data{6}.vel.y(plot_range6);
        head_3.vy = q3_data{7}.vel.y(plot_range7);
        
        head_1.vz = q3_data{5}.vel.z(plot_range5);
        head_2.vz = q3_data{6}.vel.z(plot_range6);
        head_3.vz = q3_data{7}.vel.z(plot_range7);
        
        head_1.robot_mass = Q3.testMass(5);
        head_2.robot_mass = Q3.testMass(6);
        head_3.robot_mass = Q3.testMass(7);
        
        head_1.robot_start_speed = Q3.testSpeed(5);
        head_2.robot_start_speed = Q3.testSpeed(6);
        head_3.robot_start_speed = Q3.testSpeed(7);
        
        head_1.time = data_raw_Q3.test_5.time(plot_range5);
        head_2.time = data_raw_Q3.test_6.time(plot_range6);
        head_3.time = data_raw_Q3.test_7.time(plot_range7);
        
        head_1.acc = data_raw_Q3.test_5.head.areas(plot_range5);
        head_2.acc = data_raw_Q3.test_6.head.areas(plot_range6);
        head_3.acc = data_raw_Q3.test_7.head.areas(plot_range7);
        
        head_1.ax = data_raw_Q3.test_5.head.ax(plot_range5);
        head_2.ax = data_raw_Q3.test_6.head.ax(plot_range6);
        head_3.ax = data_raw_Q3.test_7.head.ax(plot_range7);
        
        head_1.ay = data_raw_Q3.test_5.head.ay(plot_range5);
        head_2.ay = data_raw_Q3.test_6.head.ay(plot_range6);
        head_3.ay = data_raw_Q3.test_7.head.ay(plot_range7);
        
        head_1.az = data_raw_Q3.test_5.head.az(plot_range5);
        head_2.az = data_raw_Q3.test_6.head.az(plot_range6);
        head_3.az = data_raw_Q3.test_7.head.az(plot_range7);
        
        head_1.force = data_filtered.test_5.impact.Fx(plot_range5);
        head_2.force = data_filtered.test_6.impact.Fx(plot_range6);
        head_3.force = data_filtered.test_7.impact.Fx(plot_range7);
        
        head_1.pelvis.acc = data_raw_Q3.test_5.pelvis.areas(plot_range5);
        head_2.pelvis.acc = data_raw_Q3.test_6.pelvis.areas(plot_range6);
        head_3.pelvis.acc = data_raw_Q3.test_7.pelvis.areas(plot_range7);
        
        head_1.pelvis.ax = data_raw_Q3.test_5.pelvis.ax(plot_range5);
        head_2.pelvis.ax = data_raw_Q3.test_6.pelvis.ax(plot_range6);
        head_3.pelvis.ax = data_raw_Q3.test_7.pelvis.ax(plot_range7);
        
        head_1.pelvis.ay = data_raw_Q3.test_5.pelvis.ay(plot_range5);
        head_2.pelvis.ay = data_raw_Q3.test_6.pelvis.ay(plot_range6);
        head_3.pelvis.ay = data_raw_Q3.test_7.pelvis.ay(plot_range7);
        
        head_1.pelvis.az = data_raw_Q3.test_5.pelvis.az(plot_range5);
        head_2.pelvis.az = data_raw_Q3.test_6.pelvis.az(plot_range6);
        head_3.pelvis.az = data_raw_Q3.test_7.pelvis.az(plot_range7); 
        
        head_1.thorax.acc = data_raw_Q3.test_5.thorax.areas(plot_range5);
        head_2.thorax.acc = data_raw_Q3.test_6.thorax.areas(plot_range6);
        head_3.thorax.acc = data_raw_Q3.test_7.thorax.areas(plot_range7);
        
        head_1.thorax.ax = data_raw_Q3.test_5.thorax.ax(plot_range5);
        head_2.thorax.ax = data_raw_Q3.test_6.thorax.ax(plot_range6);
        head_3.thorax.ax = data_raw_Q3.test_7.thorax.ax(plot_range7);
        
        head_1.thorax.ay = data_raw_Q3.test_5.thorax.ay(plot_range5);
        head_2.thorax.ay = data_raw_Q3.test_6.thorax.ay(plot_range6);
        head_3.thorax.ay = data_raw_Q3.test_7.thorax.ay(plot_range7);
        
        head_1.thorax.az = data_raw_Q3.test_5.thorax.az(plot_range5);
        head_2.thorax.az = data_raw_Q3.test_6.thorax.az(plot_range6);
        head_3.thorax.az = data_raw_Q3.test_7.thorax.az(plot_range7);
        
        save([outputPath,'/child_head_impact.mat'],'head_1','head_2','head_3') 
 
% %        Child Head Data: 
% %        head_3.time / head_3.vel / head_3.time / head_3.force / 
% %        head_3.ax / head_3.ay / head_3.az / 
% %        head_3.vx / head_3.vy / head_3.vz / 
% %        Robot Velocity data:
% %        head_3.robot_time / head_3.robot_speed
       close all; clc;
        % ---------- Head Velocity Data --------- %
            minX = -1;
            maxX = 100;
            minY = -.1;
            maxY = 3.5;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-velocities-Impact-3-Q3-Head-Robot[133Kg]';
            plegends = {'Vx' 'Vy' 'Vz'};
            nfig = nfig +1;
            plotNpairedData(nfig,[head_3.time ...
                                    head_3.time ...%                                 data_raw.test_3.time(plot_range) ...
                                    head_3.time],...
                                [-head_3.vx ...
                                    head_3.vy...%                                 data_raw.test_3.head.ay(plot_range)...
                                    head_3.vz],...
                                '-',figName,...
                                plegends,...
                                'time [ms]','Velocity (m/s)',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);  
            hold on;
            plot(head_3.robot_time.*1e3,head_3.robot_speed,'.r','MarkerSize',14);%'LineWidth',2);
            plegends = {'Vx' 'Vy' 'Vz' 'Robot'};
            hLegend = legend(...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'horizontal',...
                  'location', 'northoutside' );
%             set(gcf, 'Position', PicSize);
            if SAVE_PLOTS
                 set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
                saveas(nfig,strcat(figPath,figName),figureFormat);
            end
          % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 20;
            maxY = -200;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-Accelreations-Impact-3-Q3-Head-Robot[133Kg]';
            plegends = {'Ax' 'Ay' 'Az'};
            nfig = nfig +1;
    
            plotNpairedData(nfig,[head_3.time ...
                                    head_3.time ...%                                 data_raw.test_3.time(plot_range) ...
                                    head_3.time],...
                                [head_3.ax ...
                                    head_3.ay...%                                 data_raw.test_3.head.ay(plot_range)...
                                    head_3.az],...
                                '-',figName,...
                                plegends,...
                                'time [ms]','Acceleration [g]',SAVE_PLOTS,figPath,...
                                figureFormat);  
       
 
        %% Exporting extract of impact to the head:
        
        load('/Users/diego/Documents/MATLAB/LASA/CrowdBots/human-robot-collider/src/matlab/Test15-2.mat');
        f_hs = 1000;
        fpass = 100;
        t_start = -95;
        robot_speed = lowpass(velList',fpass,f_hs);
        
        chest_3.robot_speed_list = robot_speed;
        chest_3.robot_speed = robot_speed(:,5);
        samples = length(chest_3.robot_speed);
        chest_3.robot_time = linspace(t_start,samples+t_start,samples)'.*1e-3;
        
        minTime = -10;
        maxTime = 100;
        plot_range16 = find(data_filtered.test_16.time>minTime,1):...
                        find(data_filtered.test_16.time>maxTime,1);
        plot_range17 = find(data_filtered.test_17.time>minTime,1):...
                        find(data_filtered.test_17.time>maxTime,1);
        plot_range18 = find(data_filtered.test_18.time>minTime,1):...
                        find(data_filtered.test_18.time>maxTime,1);
        

        % Integrating step to get all head velocities
        for i_test=[16:18]
        %    evalRange = eval(['find(data_raw_Q3.test_',num2str(i_test),...
        %                     '.time>minX,1):data_raw_Q3.test_',num2str(i_test),'.time(end);']);
             q3_data{i_test}.time = eval(['data_raw_Q3.test_',num2str(i_test),'.time.*1e-3;']);
             q3_data{i_test}.vel.res = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.thorax.areas.*9.81)']);
             q3_data{i_test}.vel.x = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.thorax.ax.*9.81)']);
             q3_data{i_test}.vel.y = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.thorax.ay.*9.81)']);
             q3_data{i_test}.vel.z = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.thorax.az.*9.81)']);
             q3_data{i_test}.deflection = eval(['cumtrapz(q3_data{',num2str(i_test),'}.time,data_raw_Q3.test_',num2str(i_test),'.thorax.deflection)']);
        %          tcontact = groundTimes(i_test) - evalRange(1);
             ground_indx(i_test) = eval(['find(data_raw_Q3.test_',num2str(i_test),'.time>groundTimes(',num2str(i_test),'),1);']);
             q3_data{i_test}.vel.ground = q3_data{i_test}.vel.res(ground_indx(i_test));
        end
        
        chest_1.vel = q3_data{16}.vel.res(plot_range16);
        chest_2.vel = q3_data{17}.vel.res(plot_range17);
        chest_3.vel = q3_data{18}.vel.res(plot_range18);
        
        chest_1.vx = q3_data{16}.vel.x(plot_range16);
        chest_2.vx = q3_data{17}.vel.x(plot_range17);
        chest_3.vx = q3_data{18}.vel.x(plot_range18);
        
        chest_1.vy = q3_data{16}.vel.y(plot_range16);
        chest_2.vy = q3_data{17}.vel.y(plot_range17);
        chest_3.vy = q3_data{18}.vel.y(plot_range18);
        
        chest_1.vz = q3_data{16}.vel.z(plot_range16);
        chest_2.vz = q3_data{17}.vel.z(plot_range17);
        chest_3.vz = q3_data{18}.vel.z(plot_range18);
        
        chest_1.robot_mass = Q3.testMass(5);
        chest_2.robot_mass = Q3.testMass(6);
        chest_3.robot_mass = Q3.testMass(7);
        
        chest_1.robot_start_speed = Q3.testSpeed(5);
        chest_2.robot_start_speed = Q3.testSpeed(6);
        chest_3.robot_start_speed = Q3.testSpeed(7);
        
        chest_1.time = data_raw_Q3.test_16.time(plot_range16);
        chest_2.time = data_raw_Q3.test_17.time(plot_range17);
        chest_3.time = data_raw_Q3.test_18.time(plot_range18);
        
        chest_1.acc = data_raw_Q3.test_16.head.areas(plot_range16);
        chest_2.acc = data_raw_Q3.test_17.head.areas(plot_range17);
        chest_3.acc = data_raw_Q3.test_18.head.areas(plot_range18);
        
        chest_1.ax = data_raw_Q3.test_16.head.ax(plot_range16);
        chest_2.ax = data_raw_Q3.test_17.head.ax(plot_range17);
        chest_3.ax = data_raw_Q3.test_18.head.ax(plot_range18);
        
        chest_1.ay = data_raw_Q3.test_16.head.ay(plot_range16);
        chest_2.ay = data_raw_Q3.test_17.head.ay(plot_range17);
        chest_3.ay = data_raw_Q3.test_18.head.ay(plot_range18);
        
        chest_1.az = data_raw_Q3.test_16.head.az(plot_range16);
        chest_2.az = data_raw_Q3.test_17.head.az(plot_range17);
        chest_3.az = data_raw_Q3.test_18.head.az(plot_range18);
        
        chest_1.force = data_filtered.test_16.impact.Fx(plot_range16);
        chest_2.force = data_filtered.test_17.impact.Fx(plot_range17);
        chest_3.force = data_filtered.test_18.impact.Fx(plot_range18);
        
        chest_1.pelvis.acc = data_raw_Q3.test_16.pelvis.areas(plot_range16);
        chest_2.pelvis.acc = data_raw_Q3.test_17.pelvis.areas(plot_range17);
        chest_3.pelvis.acc = data_raw_Q3.test_18.pelvis.areas(plot_range18);
        
        chest_1.pelvis.ax = data_raw_Q3.test_16.pelvis.ax(plot_range16);
        chest_2.pelvis.ax = data_raw_Q3.test_17.pelvis.ax(plot_range17);
        chest_3.pelvis.ax = data_raw_Q3.test_18.pelvis.ax(plot_range18);
        
        chest_1.pelvis.ay = data_raw_Q3.test_16.pelvis.ay(plot_range16);
        chest_2.pelvis.ay = data_raw_Q3.test_17.pelvis.ay(plot_range17);
        chest_3.pelvis.ay = data_raw_Q3.test_18.pelvis.ay(plot_range18);
        
        chest_1.pelvis.az = data_raw_Q3.test_16.pelvis.az(plot_range16);
        chest_2.pelvis.az = data_raw_Q3.test_17.pelvis.az(plot_range17);
        chest_3.pelvis.az = data_raw_Q3.test_18.pelvis.az(plot_range18);
        
        chest_1.thorax.acc = data_raw_Q3.test_16.thorax.areas(plot_range16);
        chest_2.thorax.acc = data_raw_Q3.test_17.thorax.areas(plot_range17);
        chest_3.thorax.acc = data_raw_Q3.test_18.thorax.areas(plot_range18);
        
        chest_1.thorax.ax = data_raw_Q3.test_16.thorax.ax(plot_range16);
        chest_2.thorax.ax = data_raw_Q3.test_17.thorax.ax(plot_range17);
        chest_3.thorax.ax = data_raw_Q3.test_18.thorax.ax(plot_range18);
        
        chest_1.thorax.ay = data_raw_Q3.test_16.thorax.ay(plot_range16);
        chest_2.thorax.ay = data_raw_Q3.test_17.thorax.ay(plot_range17);
        chest_3.thorax.ay = data_raw_Q3.test_18.thorax.ay(plot_range18);
        
        chest_1.thorax.az = data_raw_Q3.test_16.thorax.az(plot_range16);
        chest_2.thorax.az = data_raw_Q3.test_17.thorax.az(plot_range17);
        chest_3.thorax.az = data_raw_Q3.test_18.thorax.az(plot_range18);
        
        save([outputPath,'/child_chest_impact_60kg.mat'],'chest_1','chest_2','chest_3')  
        
%        close all; clc;
        % ---------- Head Velocity Data --------- %
            minX = -1;
            maxX = 100;
            minY = -0.5;
            maxY = 3.5;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Chest-velocities-Impact-3-Q3-Robot[133Kg]';
            plegends = {'Vx' 'Vy' 'Vz'};
            nfig = nfig +1;
            plotNpairedData(nfig,[chest_3.time ...
                                    chest_3.time ...%                                 data_raw.test_3.time(plot_range) ...
                                    chest_3.time],...
                                [-chest_3.vx ...
                                    chest_3.vy...%                                 data_raw.test_3.head.ay(plot_range)...
                                    chest_3.vz],...
                                '-',figName,...
                                plegends,...
                                'time [ms]','Velocity (m/s)',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);  
            hold on;
            plot(chest_3.robot_time.*1e3,chest_3.robot_speed,'-.r','LineWidth',2);
            plegends = {'Vx' 'Vy' 'Vz' 'Robot'};
            hLegend = legend(...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'horizontal',...
                  'location', 'northoutside' );
%             set(gcf, 'Position', PicSize);
            if SAVE_PLOTS
                 set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
                saveas(nfig,strcat(figPath,figName),figureFormat);
            end
          % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 20;
            maxY = -200;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Chest-Accelreations-Impact-3-Q3-Robot[133Kg]';
            plegends = {'Ax' 'Ay' 'Az'};
            nfig = nfig +1;
    
            plotNpairedData(nfig,[chest_3.time ...
                                    chest_3.time ...%                                 data_raw.test_3.time(plot_range) ...
                                    chest_3.time],...
                                [chest_3.ax ...
                                    chest_3.ay...%                                 data_raw.test_3.head.ay(plot_range)...
                                    chest_3.az],...
                                '-',figName,...
                                plegends,...
                                'time [ms]','Acceleration [g]',SAVE_PLOTS,figPath,...
                                figureFormat);  
                                                  
                            
        %% Exporting extract of impact to the head:
        
        load('/Users/diego/Documents/MATLAB/LASA/CrowdBots/human-robot-collider/src/matlab/Test12.mat');
        f_hs = 1000;
        fpass = 100;
        t_start = -95;
        robot_speed = lowpass(velList',fpass,f_hs);
        
        adult_3.robot_speed_list = robot_speed;
        adult_3.robot_speed = robot_speed(:,5);
        samples = length(adult_3.robot_speed);
        adult_3.robot_time = linspace(t_start,samples+t_start,samples)'.*1e-3;
        
        minTime = -10;
        maxTime = 200;
        plot_range14 = find(data_raw_H3.test_14.time>minTime,1):...
                        find(data_raw_H3.test_14.time>maxTime,1);
        
        adult_3.robot_mass = H3.testMass(4);
        adult_3.robot_start_speed = H3.testSpeed(4);
        adult_3.time = data_raw_H3.test_14.time(plot_range14);
       
        adult_3.force = data_filtered.test_14.impact.Fx(plot_range14);
        adult_3.thorax.ax = data_filtered.test_14.thorax.ax(plot_range14);
        adult_3.thorax.ay = data_filtered.test_14.thorax.ay(plot_range14);
        adult_3.thorax.az = data_filtered.test_14.thorax.az(plot_range14);        

        adult_3.pelvis.ax = data_raw_H3.test_14.pelvis.ax(plot_range14);
        adult_3.pelvis.ay = data_raw_H3.test_14.pelvis.ay(plot_range14);
        adult_3.pelvis.az = data_raw_H3.test_14.pelvis.az(plot_range14);

        adult_3.head.ax = data_raw_H3.test_14.head.ax(plot_range14);
        adult_3.head.ay = data_raw_H3.test_14.head.ay(plot_range14);
        adult_3.head.az = data_raw_H3.test_14.head.az(plot_range14);
        
        save([outputPath,'/adult_impact_133kg.mat'],'adult_3')  
        
          % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 20;
            maxY = -200;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Chest-Accelreations-Impact-3-Q3-Robot[133Kg]';
            plegends = {'Ax' 'Ay' 'Az'};
            nfig = nfig +1;
    
            plotNpairedData(nfig,[adult_3.time ...
                                    adult_3.time ...%                                 data_raw.test_3.time(plot_range) ...
                                    adult_3.time],...
                                [adult_3.pelvis.ax ...
                                    adult_3.pelvis.ay...%                                 data_raw.test_3.head.ay(plot_range)...
                                    adult_3.pelvis.az],...
                                '-',figName,...
                                plegends,...
                                'time [ms]','Acceleration [g]',SAVE_PLOTS,figPath,...
                                figureFormat);  
                                                  