% % Contact Force estimation for trasciend response of human-robot
% collision. 
% This function offers 3 possible simulation of contact dynamics:
% 1. HCF: [Park et.al.2011]﻿10.1109/ICRA.2011.5980282
% 2. CCF: [Vemula.et.al.2017]﻿10.1109/IRIS.2017.8250128
% 3. Spring: linear spring 

% Author: Diego Paez G.
% Date: April 28, 2021

% Inputs:
%           vel_0: [REQ'D] scalar{double}; Initial velocity at collision
%           variable_set: [REQ'D] scalar{double}; Column-wise vector of model specific parameters
%           state: [REQ'D] scalar{double}; Column-wise vector of sampling times
%           robot:  [REQ'D]  {struct} ; 
%           human:  [REQ'D]  {struct} ; 

% Optional Parameters:           
%           nfig:  [OPTIONAL]  {scalar} ; figure number
%           figPath:  [OPTIONAL]  {char} ; path to save plots
%           SavePlot:  [OPTIONAL]  {logical}    ;    Plot AIS scales and results (DEFAULT = FALSE)
% Examples:
% %     manipulator.part = 'manipulator'; % For collision data from crashes
% %     adult.part = 'head_adult'; % For collision data    
% %     manipulator_robot = exp{27};
% %     % Initial State: Differential contact state of the 2 objects
% %     state.vel = 3.1;
% %     state.pos = 0.0; state.acc = 0.0;
% %     
% %     % Simulation method for the collision
% %     method.condition = 'unconstrained';
% %     method.contact = 'HCF'; %'CCF' or 'Spring'
% %     method.time = 15; % time in ms
% %     method.tstep= 0.1; % time in ms
% %     ColModel = contact_simulation(state,manipulator,adult,method);

% Copyright 2020, Dr. Diego Paez-G.

%%%

function Fext = collision_sim(vel_0,timeVec,variable_set,robot,human,method,...
                            varargin)
    global DUBUG_FLAG
    % A function that outputs the collision contact force vector for the
    % given initial conditions at the given location on the body
    % initially only: Head Impact
    % Adult parameters are known only:
    % Children data needs to be added
    % %          Parse User Inputs/Outputs                                   
    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkCol     = @(x) validateattributes(x ,{'double'},{'column'}, mfilename,'outputPath',1);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
    chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'vel_0',chkscalar);
    addRequired(p,'timeVec',@isvector);
    addRequired(p,'variable_set',@isvector);
    addRequired(p,'robot',@isstruct);
    addRequired(p,'human',@isstruct);
    addRequired(p,'method',@isstruct);
    % Optional Inputs
    addOptional(p,'nfig',   1,  chkscalar);
    addOptional(p,'figPath',    'figures', chkchar);
    addOptional(p,'figName',    'F_{ext}', chkchar);
    addOptional(p,'figureFormat', 'epsc', chkchar);
    addOptional(p,'SavePlot'   ,false      ,@islogical);
    addOptional(p,'colorCode',1,chknum);

    parse(p,vel_0,timeVec,variable_set,robot,human,method,varargin{:});

%     nfig = p.Results.nfig;
%     timeVec = [0:method.tstep:method.time]';
    Khr = zeros(size(timeVec));
    Fext = zeros(size(Khr));
%     body_stress = zeros(size(Khr));
    deformation.pos = ones(size(Khr)).*0;
    deformation.vel = ones(size(Khr)).*vel_0;
    deformation.acc = ones(size(Khr)).*0;
    elastic_mod = zeros(2,length(Khr));

    % % Starting the function code
    ColModel = struct();    
    switch (method.contact)
        case {'CCF'}
            % Parameters for CCF Model
%             robot.n_d = 1.5;
%             robot.n_s = 1.5;
%             robot.n_c = 1.5;
%             robot.n_f = 0.8;
%             robot.EA = 5.0e9; %% Fitted Gain --> To be determine
%             human.EB = 5.0e9; %% Fitted Gain --> To be determine
%             robot.xgainA = 2;
%             human.cover_width = 0.003;
            % Constants for HC-model
             % Limit Variable inputs to larger than 0
             
            robot.n_d = max(variable_set(1),0);
            human.n_s = max(variable_set(2),0);
            robot.n_c = max(variable_set(3),0);
            robot.n_f = max(variable_set(4),0);
            human.n_f = max(variable_set(4),0);
            robot.EA = min(max(variable_set(5),1),500) * 1e8;
            human.EB = min(max(variable_set(6),1),500) * 1e8;
%             human.EB = robot.EA;
%             robot.xgainA = min(max(variable_set(7),1),20);
             % Limit Variable inputs 0 <= X <= 1
%             human.cover_width  = min(max(variable_set(8),1),20) * 1e-3;
            
            robot = get_elastic_model(robot.part,robot);
            human = get_elastic_model(human.part,human);
             % contact cover-skin
            robot.radius_cs =  ( (1/(human.cover_width+human.inner_radius))...
                            + (1/(robot.radius)) )^(-1/2);

            switch (method.condition)
                case {'constrained'}
                    ColModel.contactM = robot.mass;
                case {'unconstrained'}
                    ColModel.contactM = 1 / ((1/human.mass)+(1/robot.mass)) ;
            end
            robot.contactM = ColModel.contactM;
            contact_model = @CCF_contact;
            % Loop for contact force estimation
%             for iindx=1:length(timeVec)-1
%                 [Fext(iindx), Khr(iindx), elastic_mod(:,iindx)] = ...
%                                     contact_model(deformation.pos(iindx),robot,human);
%                 cur_state = [deformation.pos(iindx)...
%                                 deformation.vel(iindx)...
%                                 deformation.acc(iindx)];
% 
%                 [deformation.pos(iindx+1),...
%                     deformation.vel(iindx+1),...
%                     deformation.acc(iindx+1)] ...
%                                 = get_next_deformation(cur_state,...
%                                                     ColModel.contactM,...
%                                                     Fext(iindx),...
%                                                     (method.tstep.*1e-3));
%             end
            
            y0 = [deformation.pos(1) deformation.vel(1)];
            [timeOut,y] = ode113(@(time,y) contactODE(time,y,robot,human,contact_model), timeVec, y0);
            deformation.pos = y(:,1);
            deformation.vel = y(:,2);
            % Loop for contact force estimation
            for iindx=1:length(timeOut)-1
                [Fext(iindx), Khr(iindx), elastic_mod(:,iindx)] = ...
                                    contact_model(deformation.pos(iindx),robot,human);
            end
            deformation.acc = Fext./ColModel.contactM;
            Fext = -Fext;
        case {'HCF'}
            % Variables for HC-model
            robot.n_cs = max(variable_set(1),0);
            robot.n_cb = max(variable_set(2),0);
            robot.n_rb = max(variable_set(3),0);
            
            % Limit Variable inputs 0 <= X <= 1
            robot = get_elastic_model(robot.part,robot);
            human = get_elastic_model(human.part,human);
            
            human.inner_radius  = min(max(variable_set(4),1),100) * 1e-3;
            human.cover_width  = min(max(variable_set(5),1),50) * 1e-3;
            robot.inner_radius = min(max(variable_set(6),1),100) * 1e-3;
            robot.cover_width = min(max(variable_set(7),1),100) * 1e-3;
%             robot.limit_def = min(max(variable_set(5),0),1);
%             human.limit_def = min(max(variable_set(6),0),1);

            human.radius = human.cover_width + human.inner_radius;
            robot.radius = robot.cover_width + robot.inner_radius;

             % contact cover-skin
            robot.radius_cs =  ( (1/(human.cover_width+human.inner_radius))...
                            + (1/(robot.radius)) )^(-1/2);

            robot.stiffness_kcs = (4/3).*( ...
                         ( (1-(robot.poisson_ratio_cover.^2))./ robot.elastic_mod_cover) ...
                +((1-(human.poisson_ratio_cover.^2))/ human.elastic_mod_cover)).^(-1)...
                .*robot.radius_cs;
            % contact cover-bone
%             robot.radius_cb = ( (1/(human.inner_radius)) + (1/(robot.radius)) )^(-1/2); 
            robot.radius_cb = ( (1/(human.inner_radius + human.cover_width*(1-robot.limit_def))) + (1/(robot.radius)) )^(-1/2);

            robot.stiffness_kcb = (4/3).*( ...
                         ( (1-(robot.poisson_ratio_cover.^2))./ robot.elastic_mod_cover) ...
                +((1-(human.poisson_ratio.^2))/ human.elastic_mod_bone)).^(-1)...
                .*robot.radius_cb;

            % contact robot_frame-bone
%             robot.radius_rb = ( (1/(human.inner_radius)) + (1/(robot.inner_radius)) )^(-1/2);
            robot.radius_rb = ( (1/(human.inner_radius + human.cover_width*(1-robot.limit_def))) ...
                                + (1/(robot.inner_radius + robot.cover_width*(1-robot.limit_def))) )^(-1/2);

            robot.stiffness_krb = (4/3).*( ...
                         ( (1-(robot.poisson_ratio.^2))./ robot.elastic_mod_frame) ...
                +((1-(human.poisson_ratio.^2)) / human.elastic_mod_bone) ).^(-1)...
                .*robot.radius_rb;

            %%%%% These values were fitted from Collision Data in [Park. 2011]]
            robot.deformation_sm = human.limit_def*human.cover_width;
            robot.deformation_cm = robot.limit_def*robot.cover_width;

            robot.force_skin_max = robot.stiffness_kcs * (robot.deformation_sm^robot.n_cs);
            
            robot.force_cover_max = (robot.stiffness_kcb * ...
                        ((robot.deformation_cm - robot.deformation_sm)^robot.n_cb) )...
                                + robot.force_skin_max;
                            
            robot.stress_skin_max = ((3.* robot.force_skin_max) ./ (2*pi).*robot.deformation_sm) .* robot.radius_cs.^(-2);
            
            robot.stress_cover_max  = ((3.* robot.force_cover_max) ./ (2*pi).*(robot.deformation_cm - robot.deformation_sm)) .* robot.radius_cb.^(-2)...
                            + robot.stress_skin_max;    
            
            switch (method.condition)
                case {'constrained'}
                    ColModel.contactM = robot.mass;
                case {'unconstrained'}
                    ColModel.contactM = 1 / ((1/human.mass)+(1/robot.mass)) ;
            end
            
            robot.contactM = ColModel.contactM;
            contact_model = @HCF_contact;
%             tspan = [0:method.tstep:method.time].*1e-3';
            y0 = [deformation.pos(1) deformation.vel(1)];
            
            [timeOut,y] = ode113(@(time,y) contactODE(time,y,robot,human,contact_model), timeVec, y0);
            deformation.pos = y(:,1);
            deformation.vel = y(:,2);
            % Loop for contact force estimation
            for iindx=1:length(timeOut)-1
                [Fext(iindx), Khr(iindx), elastic_mod(:,iindx)] = ...
                                    contact_model(deformation.pos(iindx),robot,human);
%                 body_stress(iindx) = get_strain_stress(deformation,-Fext(iindx),robot,human);
            end
            deformation.acc = Fext./ColModel.contactM;
            
%             for iindx=1:length(timeVec)-1
%                 [Fext(iindx), Khr(iindx), elastic_mod(:,iindx)] = ...
%                                     contact_model(deformation.pos(iindx),robot,human);
%                 cur_state = [deformation.pos(iindx)...
%                                 deformation.vel(iindx)...
%                                 deformation.acc(iindx)];
% 
%                 [deformation.pos(iindx+1),...
%                     deformation.vel(iindx+1),...
%                     deformation.acc(iindx+1)] ...
%                                 = get_next_deformation(cur_state,...
%                                                     ColModel.contactM,...
%                                                     Fext(iindx),...
%                                                     (method.tstep.*1e-3));
%             end
            Fext = -Fext;
        case {'HRC'}
            % Variables for HC-model
%             robot.n_cs = variable_set(1); %max(variable_set(1),0);
            %robot.stiffness_kcs = max(variable_set(2),0) * 1e5;
            robot.n_hr = max(variable_set(1),0);
%             robot.n_rb = max(variable_set(3),0);
            robot.damping_hr = variable_set(2); % max(variable_set(2),0);
%             robot.stiffness_hr = max(variable_set(3),0) *1e9;
            
            % Limit Variable inputs 0 <= X <= 1
            robot = get_elastic_model(robot.part,robot);
            human = get_elastic_model(human.part,human);
%             human.inner_radius  = min(max(variable_set(3),1),100) * 1e-3;
%             human.cover_width  = min(max(variable_set(4),1),100) * 1e-3;
%             robot.inner_radius = min(max(variable_set(5),1),100) * 1e-3;
%             robot.cover_width = min(max(variable_set(6),1),100) * 1e-3;
%             robot.limit_def = min(max(variable_set(5),0),1);
%             human.limit_def = min(max(variable_set(4),0),1);

            human.radius = human.cover_width + human.inner_radius;
            robot.radius = robot.cover_width + robot.inner_radius;

             % contact cover-skin
            robot.radius_cs =  ( (1/(human.cover_width+human.inner_radius))...
                            + (1/(robot.radius)) )^(-1/2);

            robot.stiffness_kcs = (4/3).*( ...
                         ( (1-(robot.poisson_ratio_cover.^2))./ robot.elastic_mod_cover) ...
                +((1-(human.poisson_ratio_cover.^2))/ human.elastic_mod_cover)).^(-1)...
                .*robot.radius_cs;
            
            % contact cover-bone
%             robot.radius_cb = ( (1/(human.inner_radius)) + (1/(robot.radius)) )^(-1/2); 
            robot.radius_cb = ( (1/(human.inner_radius + human.cover_width*(1-human.limit_def))) + (1/(robot.radius)) )^(-1/2);

            robot.stiffness_kcb = (4/3).*( ...
                         ( (1-(robot.poisson_ratio_cover.^2))./ robot.elastic_mod_cover) ...
                +((1-(human.poisson_ratio.^2))/ human.elastic_mod_bone)).^(-1)...
                .*robot.radius_cb;
            
            robot.stiffness_hr = robot.stiffness_kcb;
            
            % contact robot_frame-bone
%             robot.radius_rb = ( (1/(human.inner_radius)) + (1/(robot.inner_radius)) )^(-1/2);
            robot.radius_rb = ( (1/(human.inner_radius + human.cover_width*(1-robot.limit_def))) ...
                                + (1/(robot.inner_radius + robot.cover_width*(1-robot.limit_def))) )^(-1/2);

            robot.stiffness_krb = (4/3).*( ...
                         ( (1-(robot.poisson_ratio.^2))./ robot.elastic_mod_frame) ...
                +((1-(human.poisson_ratio.^2)) / human.elastic_mod_bone) ).^(-1)...
                .*robot.radius_rb;

            %%%%% These values were fitted from Collision Data in [Park. 2011]]
            robot.deformation_sm = human.limit_def*human.cover_width;
            robot.deformation_cm = robot.limit_def*robot.cover_width;
            
            robot.force_skin_max = robot.stiffness_kcs * (robot.deformation_sm^robot.n_cs);
            
            robot.force_cover_max = (robot.stiffness_kcb * ...
                        ((robot.deformation_cm - robot.deformation_sm)^robot.n_cb) )...
                                + robot.force_skin_max;
                            
            robot.stress_skin_max = ((3.* robot.force_skin_max) ./ (2*pi).*robot.deformation_sm) .* robot.radius_cs.^(-2);
            
            robot.stress_cover_max  = ((3.* robot.force_cover_max) ./ (2*pi).*(robot.deformation_cm - robot.deformation_sm)) .* robot.radius_cb.^(-2)...
                            + robot.stress_skin_max;    
            
            switch (method.condition)
                case {'constrained'}
                    ColModel.contactM = robot.mass;
                case {'unconstrained'}
                    ColModel.contactM = 1 / ((1/human.mass)+(1/robot.mass)) ;
            end
            
            robot.contactM = ColModel.contactM;
            contact_model = @HR_contact;
%             tspan = [0:method.tstep:method.time].*1e-3';
            y0 = [deformation.pos(1) deformation.vel(1)];
            
            [timeOut,y] = ode113(@(time,y) contact_HR(y,robot,human,contact_model), timeVec, y0);
            deformation.pos = y(:,1);
            deformation.vel = y(:,2);
            % Loop for contact force estimation
            for iindx=1:length(timeOut)-1
                [Fext(iindx), Khr(iindx), elastic_mod(:,iindx)] = ...
                                    contact_model([deformation.pos(iindx);deformation.vel(iindx)],robot,human);
%                 body_stress(iindx) = get_strain_stress(deformation,-Fext(iindx),robot,human);
            end
            deformation.acc = Fext./ColModel.contactM;
            
%             for iindx=1:length(timeVec)-1
%                 [Fext(iindx), Khr(iindx), elastic_mod(:,iindx)] = ...
%                                     contact_model(deformation.pos(iindx),robot,human);
%                 cur_state = [deformation.pos(iindx)...
%                                 deformation.vel(iindx)...
%                                 deformation.acc(iindx)];
% 
%                 [deformation.pos(iindx+1),...
%                     deformation.vel(iindx+1),...
%                     deformation.acc(iindx+1)] ...
%                                 = get_next_deformation(cur_state,...
%                                                     ColModel.contactM,...
%                                                     Fext(iindx),...
%                                                     (method.tstep.*1e-3));
%             end
            Fext = -Fext;
            
        case {'Spring'}
            % Constants for Spring-model
             % Limit Variable inputs to larger than 0
            human.stiffness = max(variable_set(1),0);
            robot = get_elastic_model(robot.part,robot);
            human = get_elastic_model(human.part,human);
            omega_n = sqrt(((robot.mass + human.mass)/(robot.mass*human.mass))* human.stiffness);
            tau = 2*pi/omega_n;
            timeVec = timeVec./1e3;
            deformation.acc = ( (robot.mass./(robot.mass+human.mass)).* ...
                            deformation.vel(1).*omega_n.*cos(omega_n.*timeVec));
                
            Fext = human.mass .* deformation.acc(timeVec<(tau/2));                
%                 cur_state = [deformation.pos(iindx)...
%                                 deformation.vel(iindx)...
%                                 deformation.acc(iindx)];
%                 [deformation.pos(iindx+1),...
%                     deformation.vel(iindx+1),...
%                     deformation.acc(iindx+1)] ...
%                                 = get_next_deformation(cur_state,...
%                                                     ColModel.contactM,...
%                                                     Fext(iindx),...
%                                                     (method.tstep.*1e-3));
%             Fext = -Fext;
    end

end

%% Integrating local deformation

function dydt = contact_HR(state,robot,human,contact_model)

    [Fext, ~] = contact_model(state,robot,human);
    dydt = [ state(2); 
             Fext ./ robot.contactM
            ];
end

function dydt = contactODE(time,state,robot,human,contact_model)

    [Fext, ~] = contact_model(state(1),robot,human);
    dydt = [ state(2); 
             Fext ./ robot.contactM
            ];
end

function [pos, vel, acc ] = get_next_deformation(state,contactM,Fext,tstep)

    % F_ext should be negative
    acc = Fext./contactM;
    vel = state(2) + getIntegral(state(3),acc,tstep);
    pos = state(1) + getIntegral(state(2),vel,tstep);

end
