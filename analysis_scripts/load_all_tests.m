
% Script for reading the raw data and orginizing it on a structure
% Filters are applied as well to each sensor accordignly to known
% Dummy testing standards for each type of data.
% Author: Diego F. Paez G.
% Date: 8 Dec 2020 --> 
% Copyright 2020, Dr. Diego Paez-G.

%% Script for extracting and plotting test data
    clearvars; close all; clc; 
    [parentdir,~,~]=fileparts(pwd);
    [maindir,~,~]=fileparts(parentdir);
    % Folders Configuration 
    saveDir = fullfile(maindir,'collision_data', 'data_raw/');
    addpath(fullfile(parentdir, 'general_functions'));      
    % Set here the desired ooutput directory for saving the process dataset
    % Set here the path to the analysis dataset
    data_folder = fullfile('../../collision_data/', 'collision_test_analysis');
    %     data_folder = fullfile(parentdir, 'collision_test_analysis');
    test_folders = dir(fullfile(data_folder,'Test_*'))';
    
    
    data_raw_Q3 = struct();
    data_raw_H3 = struct();
    Freq = 20000;
    Ts = 1/Freq; % Sampling period in [s]
    data_filtered = struct();

    %% Options    
    DRAW_PLOTS = true;
    SAVE_PLOTS = false;
    SAVE_VIDEO = false;
    READDATA = false;

    %% Read Raw data from .xlsx files
    if READDATA
        % Reading Q3 dummy data
        data_q3 = [1:10,16:19];
        for indx_i= data_q3
                data_raw_Q3.(['test_',num2str(indx_i)]) = read_Q3data(test_folders(indx_i));
                data_raw_Q3.(['test_',num2str(indx_i)]).TestName = test_folders(indx_i).name;
                % Filtering data to meet standard evaluaitons of crash safety
                %     CFC-60 --> 100Hz / -30dB
                %     CFC-180 --> 300Hz / -30dB
                %     CFC-600 --> 1000Hz / -40dB
                %     CFC-1000 --> 1650Hz / -40dB
                % Impact Force / Deformation Data is accepted with CFC-600
                cutoff_freq = 1000; 
                data_filtered.(['test_',num2str(indx_i)]).time ...
                    = data_raw_Q3.(['test_',num2str(indx_i)]).time ;
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).impact.Fx] =...
                    filterJ211(data_raw_Q3.(['test_',num2str(indx_i)]).impact.Fx,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.deflection] =...
                    filterJ211(data_raw_Q3.(['test_',num2str(indx_i)]).thorax.deflection,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                % Thorax Acceleration Data is accepted with CFC-180
                cutoff_freq = 300; 
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.ax] =...
                    filterJ211(data_raw_Q3.(['test_',num2str(indx_i)]).thorax.ax,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.ay] =...
                    filterJ211(data_raw_Q3.(['test_',num2str(indx_i)]).thorax.ay,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.az] =...
                    filterJ211(data_raw_Q3.(['test_',num2str(indx_i)]).thorax.az,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.areas] =...
                    filterJ211(data_raw_Q3.(['test_',num2str(indx_i)]).thorax.areas,...
                                        Ts,cutoff_freq,'ShowPlots',true);
        end

        % Reading H3 dummy data
        data_h3 = 11:15;
        for indx_i=data_h3
                data_raw_H3.(['test_',num2str(indx_i)]) = read_H3data(test_folders(indx_i));
                data_raw_H3.TestName = test_folders(indx_i).name;
                data_filtered.(['test_',num2str(indx_i)]).time ...
                    = data_raw_H3.(['test_',num2str(indx_i)]).time ;
                % Impact Force / Deformation Data is accepted with CFC-600
                cutoff_freq = 1000; 
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).impact.Fx] =...
                    filterJ211(data_raw_H3.(['test_',num2str(indx_i)]).impact.Fx,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                                % Thorax Acceleration Data is accepted with CFC-180
                cutoff_freq = 300; 
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.ax] =...
                    filterJ211(data_raw_H3.(['test_',num2str(indx_i)]).thorax.ax,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.ay] =...
                    filterJ211(data_raw_H3.(['test_',num2str(indx_i)]).thorax.ay,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.az] =...
                    filterJ211(data_raw_H3.(['test_',num2str(indx_i)]).thorax.az,...
                                        Ts,cutoff_freq,'ShowPlots',true);
                
                [coeffs, data_filtered.(['test_',num2str(indx_i)]).thorax.areas] =...
                    filterJ211(data_raw_H3.(['test_',num2str(indx_i)]).thorax.areas,...
                                        Ts,cutoff_freq,'ShowPlots',true);
        end
        
%         data_raw_H3 = rmfield(data_raw,{'test_1','test_2','test_3','test_4'...
%                                 ,'test_5','test_6','test_7','test_8'...
%                                 ,'test_9','test_10','test_16','test_17','test_18','test_19'})
%         data_raw_Q3 = rmfield(data_raw,{'test_11','test_12','test_13','test_14','test_15'})
        
        % Saving Data 
        save([saveDir,'test_folders.mat'],'test_folders') 
        save([saveDir,'Q3_raw_collision_struct.mat'],'data_raw_Q3') 
        save([saveDir,'H3_raw_collision_struct.mat'],'data_raw_H3') 
        save([saveDir,'filtered_collision_struct.mat'],'data_filtered') 
    else
        load([saveDir,'test_folders.mat'])
        load([saveDir,'Q3_raw_collision_struct.mat'])
        load([saveDir,'H3_raw_collision_struct.mat'])
        load([saveDir,'filtered_collision_struct.mat'])
    end
    
    %% Readinng xls Files

function data = read_Q3data(test_folder)
    %READ_FT_DATA read data from test folder and store them in struct
    %
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    Ts = 1/20000;

        data_file = dir(fullfile(test_folder.folder, test_folder.name, ...
        '01_values', '*.xlsx'))';
        data_file=data_file(1);
        tb = readtable(fullfile(data_file.folder, data_file.name),...
                            'ReadVariableNames',false);
        tb(1:3,:)=[];
        header_tb =  readtable(fullfile(data_file.folder, data_file.name),...
                                'Range','A3:Y3');
        tb.Properties.VariableNames = header_tb.Properties.VariableNames;
%                         
%     {'Time_Ms'            }
%     {'HeadAx_G'           }
%     {'HeadAy_G'           }
%     {'HeadAz_G'           }
%     {'HeadAres_G'         }
%     {'upperNeckFx_N'      }
%     {'upperNeckFy_N'      }
%     {'upperNeckFz_N'      }
%     {'upperNeckFz____N'   }
%     {'upperNeckFz____N_1' }
%     {'upperNeckMx_Nm'     }
%     {'upperNeckMy_Nm'     }
%     {'upperNeckMz_Nm'     }
%     {'ThoraxAx_G'         }
%     {'ThoraxAy_G'         }
%     {'ThoraxAz_G'         }
%     {'ThoraxAres_G'       }
%     {'ThoraxDeflection_Mm'}
%     {'PelvisAx_G'         }
%     {'PelvisAy_G'         }
%     {'PelvisAz_G'         }
%     {'PelvisAres_G'       }
%     {'impactForceFx_N'    }
%     {'impactForceFy_N'    }
%     {'impactForceFz_N'    }

        data = struct();
        data.('time')  = tb.('Time_Ms');
        % Head Sensor - Acceleration in [g]
        data.head = table();
        data.head.('ax') = tb.('HeadAx_G');
        data.head.('ay') = tb.('HeadAy_G');
        data.head.('az') = tb.('HeadAz_G');
        data.head.('areas') = tb.('HeadAres_G');
        
        % Neck Force Sensor - Force in [N] / Torques in [Nm]
        data.neck = table();
        data.neck.('Fx') = tb.('upperNeckFx_N');
        data.neck.('Fy') = tb.('upperNeckFy_N');
        data.neck.('Fz') = tb.('upperNeckFz_N');
%         data.neck.('FzN') = tb.('upperNeckFz____N');
%         data.neck.('FzP') = tb.('upperNeckFz____N_1');
        data.neck.('Mx') = tb.('upperNeckMx_Nm');
        data.neck.('My') = tb.('upperNeckMy_Nm');
        data.neck.('Mz') = tb.('upperNeckMz_Nm');
        
        % Thorax Sensor - Acceleration in [g] / Deflection in [mm]
        data.thorax = table();
        data.thorax.('ax') = tb.('ThoraxAx_G');
        data.thorax.('ay') = tb.('ThoraxAy_G');
        data.thorax.('az') = tb.('ThoraxAz_G');
        data.thorax.('areas') = tb.('ThoraxAres_G');
        data.thorax.('deflection') = tb.('ThoraxDeflection_Mm');
        
        % Pelvis Sensor - Acceleration in [g] / Deflection in [mm]
        data.pelvis = table();
        data.pelvis.('ax') = tb.('PelvisAx_G');
        data.pelvis.('ay') = tb.('PelvisAy_G');
        data.pelvis.('az') = tb.('PelvisAz_G');
        data.pelvis.('areas') = tb.('PelvisAres_G');
       
        % Pelvis Sensor - Acceleration in [g] / Deflection in [mm]
        data.impact = table();
        data.impact.('Fx') = tb.('impactForceFx_N');
        data.impact.('Fy') = tb.('impactForceFy_N');
        data.impact.('Fz') = tb.('impactForceFz_N');

%         %% Low Pass 
%         data.(sensor_name).('Fx') = filter(lpFilter, data.(sensor_name){:,'Fx'});

    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
end

function data = read_H3data(test_folder)
    %READ_FT_DATA read data from test folder and store them in struct
    %
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

    Ts = 1/20000;

    data_file = dir(fullfile(test_folder.folder, test_folder.name, ...
        '01_values', '*_CFC1000.xlsx'))';
        
        data = struct();
        tb = readtable(fullfile(data_file.folder, data_file.name),...
                            'ReadVariableNames',false);
        tb(1:3,:)=[];
        header_tb =  readtable(fullfile(data_file.folder, data_file.name),...
                                'Range','A3:AR3');
        tb.Properties.VariableNames = header_tb.Properties.VariableNames;
%                         
        data.('time')  = tb.('Time_Ms');
        % Head Sensor - Acceleration in [g]
        data.head = table();
        data.head.('ax') = tb.('HeadAx_G');
        data.head.('ay') = tb.('HeadAy_G');
        data.head.('az') = tb.('HeadAz_G');
        data.head.('areas') = tb.('HeadAres_G');
        
        
        % Thorax Sensor - Acceleration in [g] / Deflection in [mm]
        data.thorax = table();
        data.thorax.('ax') = tb.('ThoraxAx_G');
        data.thorax.('ay') = tb.('ThoraxAy_G');
        data.thorax.('az') = tb.('ThoraxAz_G');
        data.thorax.('areas') = tb.('ThoraxAres_G');
                
        % Pelvis Sensor - Acceleration in [g] / Deflection in [mm]
        data.pelvis = table();
        data.pelvis.('ax') = tb.('PelvisAx_G');
        data.pelvis.('ay') = tb.('PelvisAy_G');
        data.pelvis.('az') = tb.('PelvisAz_G');
        data.pelvis.('areas') = tb.('PelvisAres_G');
        
        % Tibia Force Sensor - Force in [N] / Torques in [Nm]
        data.tibia = table();
        data.tibia.('upRMx') = tb.('upTibiaRMx_Nm');
        data.tibia.('upRMy') = tb.('upTibiaRMy_Nm');
        data.tibia.('upLMx') = tb.('upTibiaLMx_Nm');
        data.tibia.('upLMy') = tb.('upTibiaLMy_Nm');
        
        data.tibia.('loRMx') = tb.('loTibiaRMx_Nm');
        data.tibia.('loLMx') = tb.('loTibiaLMx_Nm');
        data.tibia.('loRFy') = tb.('loTibiaRFy_N');
        data.tibia.('loLFy') = tb.('loTibiaLFy_N');
        data.tibia.('loRFz') = tb.('loTibiaRFz_N');
        data.tibia.('loLFz') = tb.('loTibiaLFz_N');
%         data.tibia.('RFzN') = tb.('loTibiaRFz____N');
%         data.tibia.('LFzP') = tb.('loTibiaLFz____N');
        
        % Femur force Sensor - Acceleration in [g] / Deflection in [mm]
        data.femur = table();
        data.femur.('RFx') = tb.('femurRFx_N');
        data.femur.('RFy') = tb.('femurRFy_N');
        data.femur.('RFz') = tb.('femurRFz_N');
        data.femur.('RMx') = tb.('femurRMx_Nm');
        data.femur.('RMy') = tb.('femurRMy_Nm');
        data.femur.('RMz') = tb.('femurRMz_Nm');
        
        data.femur.('LFx') = tb.('femurLFx_N');
        data.femur.('LFy') = tb.('femurLFy_N');
        data.femur.('LFz') = tb.('femurLFz_N');
        data.femur.('LMx') = tb.('femurLMx_Nm');
        data.femur.('LMy') = tb.('femurLMy_Nm');
        data.femur.('LMz') = tb.('femurLMz_Nm');
        % %     {'femurRFz____N'  }
        % %     {'femurLFz____N'  }
        
        % Pelvis Sensor - Acceleration in [g] / Deflection in [mm]
        data.knee = table();
        data.knee.('RF') = tb.('kneeR_N');
        data.knee.('LF') = tb.('kneeL_N');
       
        % Pelvis Sensor - Acceleration in [g] / Deflection in [mm]
        data.impact = table();
        data.impact.('Fx') = tb.('impactForceFx_N');
        data.impact.('Fy') = tb.('impactForceFy_N');
        data.impact.('Fz') = tb.('impactForceFz_N');

    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
end