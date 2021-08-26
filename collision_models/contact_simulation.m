% % Contact Force estimation for trasciend response of human-robot
% collision. 
% This function offers 2 possible simulation of contact dynamics:
% 1. HCF: [Park et.al.2011]﻿10.1109/ICRA.2011.5980282
% 2. CCF: [Vemula.et.al.2017]﻿10.1109/IRIS.2017.8250128

% Author: Diego F. Paez G.
% Date: April 28, 2021

% Inputs:
%           state: [REQ'D] scalar{double}; Column-wise vector of sampling times
%           robot:  [REQ'D]  {struct} ; AIS level for plot
%           human:  [REQ'D]  {struct} ; AIS level for plot

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
% %     method.contact = 'HCF'; %'CCF' or 'HCF'
% %     method.time = 15; % time in ms
% %     method.tstep= 0.1; % time in ms
% %     ColModel = contact_simulation(state,manipulator,adult,method);

% Copyright 2020, Dr. Diego Paez-G.

%%%

function ColModel = contact_simulation(state,robot,human,method,...
                            varargin)
    global DEBUG_FLAG
    % A function that outputs the collision contact force vector for the
    % given initial conditions at the given location on the body 
    % initially only: Head Impact
    % Adult parameters are known only: 
    % Children data needs to be added
    % %          Parse User Inputs/Outputs                                        
    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
    chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'state',@isstruct);
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

    parse(p,state,robot,human,method,varargin{:});
    robot = p.Results.robot;
    human = p.Results.human;
    method = p.Results.method;
    nfig = p.Results.nfig;

    % % Starting the function code
    ColModel = struct();
    robot = get_elastic_model(robot.part,robot);
    human = get_elastic_model(human.part,human);
    
    human.radius = human.cover_width + human.inner_radius;
    robot.radius = robot.cover_width + robot.inner_radius;
    
 % % % % % % % % % % Constants for HFC-model % % % % % % % % % % 
    
    % contact cover-skin
        robot.radius_cs =  ( (1/(human.cover_width+human.inner_radius))...
                        + (1/(robot.radius)) )^(-1/2);
        robot.stiffness_kcs = (4/3).*( ...
                     ( (1-(robot.poisson_ratio_cover.^2))./ robot.elastic_mod_cover) ...
            +((1-(human.poisson_ratio_cover.^2))/ human.elastic_mod_cover)).^(-1)...
            .*robot.radius_cs;
        
        % contact cover-bone
%         robot.radius_cb = ( (1/(human.inner_radius)) + (1/(robot.radius)) )^(-1/2); 
        robot.radius_cb = ( (1/(human.inner_radius + human.cover_width)) + (1/(robot.radius)) )^(-1/2);
        
        robot.stiffness_kcb = (4/3).*( ...
                     ( (1-(robot.poisson_ratio_cover.^2))./ robot.elastic_mod_cover) ...
            +((1-(human.poisson_ratio.^2))/ human.elastic_mod_bone)).^(-1)...
            .*robot.radius_cb;
  
        robot.radius_hr = robot.radius_cb;
        robot.stiffness_hr = robot.stiffness_kcb;
        
        % contact robot_frame-bone
%         robot.radius_rb = ( (1/(human.inner_radius)) + (1/(robot.inner_radius)) )^(-1/2);
        robot.radius_rb = ( (1/(human.inner_radius + human.cover_width*(1-robot.limit_def))) ...
                                + (1/(robot.inner_radius + robot.cover_width*(1-robot.limit_def))) )^(-1/2);
        
        robot.stiffness_krb = (4/3).*( ...
                     ( (1-(robot.poisson_ratio.^2))./ robot.elastic_mod_frame) ...
            +((1-(human.poisson_ratio.^2)) / human.elastic_mod_bone) ).^(-1)...
            .*robot.radius_rb;
        
        %%%%% These values were fitted from Collision Data in [Park. 2011]]
        robot.deformation_sm = human.limit_def*human.cover_width;
        robot.deformation_cm = robot.limit_def*robot.cover_width;
        
        % Getting the deformation force limits for each material
        robot.force_skin_max = robot.stiffness_kcs * (robot.deformation_sm^robot.n_cs);
        robot.force_cover_max = (robot.stiffness_kcb * ...
                    ((robot.deformation_cm - robot.deformation_sm)^robot.n_cb) )...
                            + robot.force_skin_max;

        % Getting the deformation stress limits
        robot.stress_skin_max = ((3.* robot.force_skin_max) ./ (2*pi).*robot.deformation_sm) .* robot.radius_cs.^(-2);
        robot.stress_cover_max  = ((3.* robot.force_cover_max) ./ (2*pi).*(robot.deformation_cm - robot.deformation_sm)) .* robot.radius_cb.^(-2)...
                            + robot.stress_skin_max;    
            

%         [Fsm, ~,~]  = HCF_contact(robot.deformation_sm,robot,human)
%         [Fcm, ~,~]  = HCF_contact(robot.deformation_cm,robot,human)

    switch (method.contact)
        case {'CCF'}
            contact_model = @CCF_contact;
        case {'HCF'}
            contact_model = @HCF_contact;
        otherwise
            contact_model = @HR_contact;
    end

    switch (method.condition)
        case {'constrained'}
            ColModel.contactM = robot.mass;
        case {'unconstrained'}
            ColModel.contactM = 1 / ((1/human.mass)+(1/robot.mass)) ;
    end
    robot.contactM = ColModel.contactM;

%     timeVec = [0:method.tstep:method.time]';
%     Khr = zeros(size(timeVec));
%     Fext = zeros(size(Khr));
%     deformation.pos = ones(size(Khr)).*state.pos;
%     deformation.vel = ones(size(Khr)).*state.vel;
%     deformation.acc = ones(size(Khr)).*state.acc;
%     elastic_mod = zeros(2,length(Khr));

    % Using ODE45 to solve the contact simulation:
%     tspan = [0 method.time.*1e-3];
    tspan = [0:method.tstep:method.time].*1e-3';
    y0 = [state.pos state.vel];
    [timeVec,y] = ode113(@(time,y) contactODE(time,y,robot,human,contact_model), tspan, y0);
    deformation.pos = y(:,1);
    indx_end = find(deformation.pos<0,1);
    deformation.vel = y(:,2);
    
    deformation.pos(indx_end:end) = 0;
    deformation.vel(indx_end:end) = 0;
    
    Khr = zeros(size(deformation.pos));
    Fext = zeros(size(deformation.pos));
    compressive_stress = zeros(size(Fext));
    deformation.acc = ones(size(deformation.pos)).*state.acc;
    elastic_mod = zeros(2,length(deformation.pos));
    
        % Loop for contact force estimation
    for iindx=1:length(timeVec)-1
        [Fext(iindx), Khr(iindx), elastic_mod(:,iindx)] = ...%                            contact_model(deformation.pos(iindx),robot,human);
                            contact_model([deformation.pos(iindx);deformation.vel(iindx)],robot,human);
        compressive_stress(iindx) = get_strain_stress_HR(deformation.pos(iindx),-Fext(iindx),robot,human);
%         cur_state = [deformation.pos(iindx)...
%                         deformation.vel(iindx)...
%                         deformation.acc(iindx)];
%         [deformation.pos(iindx+1),...
%             deformation.vel(iindx+1),...
%             deformation.acc(iindx+1)] ...
%                         = get_next_deformation(cur_state,...
%                                             ColModel.contactM,...
%                                             Fext(iindx),...
%                                             (method.tstep.*1e-3));
    end
    [max_def,indx_dmax] = max(deformation.pos);
    
    %--> Getting Engergy Density in [J/cm^2]
%     energy_density  = trapz(deformation.pos(1:indx_dmax),body_stress(1:indx_dmax)); 
    energy_density  = cumtrapz(deformation.pos,compressive_stress); 
    energy_density_max = energy_density(indx_dmax);
    
%     integral(fun,0,Inf)

    %--> Getting Maximum Tensile Stress [Pa]
    max_tensile = compressive_stress(indx_dmax) * (1 - 2*human.poisson_ratio_cover) / 3;

    deformation.acc = Fext./ColModel.contactM;
    deformation.acc(indx_end:end) = 0;
    
    if DEBUG_FLAG
        figure; plot(timeVec, deformation.pos,'.'); title('defomration \delta');grid on;
        figure; plot(timeVec, deformation.vel,'.'); title('defomration d \delta /dt');grid on;
        figure; plot(timeVec, deformation.acc,'.'); title('defomration d^2 \delta /dt^2');grid on;
%         plot(timeVec, deformation.vel); figure;%hold on;
%         plot(timeVec, deformation.acc); figure;
%         plot(timeVec, Fext); figure;
        
        figure; plot(timeVec, Khr,'*'); title('Effective Stiffness K_{hr}');grid on;
        figure; plot(timeVec, elastic_mod(1,:),'*'); title('Human Elastic Modulus E_{H}'); grid on;
        figure; plot(timeVec, elastic_mod(2,:),'*'); title('Robot Elastic Modulus E_{R}'); grid on;
        
%         legend({'\delta','vel \delta'})
        hold off
        nfig = p.Results.nfig+1;
    end
    
    ColModel.acc = -Fext./(human.mass*9.81);
    ColModel.compressive_stress = compressive_stress;
    ColModel.energy_density = energy_density ./ (100^2); % transform to J/cm2
    ColModel.max_energy_density = energy_density_max./ (100^2); % transform to J/cm2
    ColModel.max_tensile = max_tensile;
    ColModel.Fext = Fext;   
    ColModel.Khr = Khr;
    ColModel.robot = robot;
    ColModel.human = human;
    ColModel.deformation = deformation;
    ColModel.timeVec = timeVec;
    ColModel.elastic_mod = elastic_mod;
    ColModel.contact_model = contact_model;

end
%% Integrating local deformation

function dydt = contactODE(time,state,robot,human,contact_model)

    [Fext, ~] = contact_model(state,robot,human);
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