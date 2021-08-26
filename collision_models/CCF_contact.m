%% CCF Model
function [Fext, Krh, elastic_mod] = CCF_contact(state,robot,human,...
                                        varargin)

    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x) ; %&& (x >= 0)
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
    chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'state',chkscalar);
    addRequired(p,'robot',@isstruct);
    addRequired(p,'human',@isstruct);
    % Optional Inputs

    parse(p,state,robot,human,varargin{:});
    deformation = state(1);
    deformation_dt = state(2);
    
    robot = p.Results.robot;
    human = p.Results.human;

    global DEBUG_FLAG
%        Er = elastic_mod_robot
%        Eh = elastic_mod_human
%        Vc = poisson_ratio_robot_cover
%        Vs = poisson_ratio_human (scalp)
%        Eh = elastic_mod_human
%        Er = elastic_mod_robot
%        Eh = elastic_mod_human
%        Er = elastic_mod_robot
%        Rc = radius_human = scalp_width+human_radius_adult[human_part_id]
%        Rs = radius_robot = cover_width+robot_radius


%         Expecting  deformation in the negative plane for the
%         current equations to work properly
%         deformation = -deformation;

    % Checking if collision looses contact
    if deformation < 0
%         fprintf("Collision off-contact: %.2f \n",deformation)
        deformation = 0;
    end

    if ~isreal(deformation)
%         fprintf("Deformation format incorrect (img): %.2f \n",deformation)
        deformation = 0;
    end
    
    % Unsure WHY there is a discontinuity at at the intercept (zero-crossing)?
    
    elastic_mod_human = real(human.eff_elastic_mod(deformation)) ;
    if DEBUG_FLAG && ~isreal(elastic_mod_human)
            fprintf("imaginary human-mod: %f.2 \n",deformation);
%                 elastic_mod_human = real(elastic_mod_human);
    end
    elastic_mod_robot = real(robot.eff_elastic_mod(deformation));
    if DEBUG_FLAG && ~isreal(elastic_mod_robot)
            fprintf("imaginary robot-mod: %i \n",deformation);
%                 elastic_mod_robot = real(elastic_mod_robot);
    end

    elastic_mod(1,1) = elastic_mod_human;
    elastic_mod(2,1)= elastic_mod_robot;

    if isreal(elastic_mod_human) && isreal(elastic_mod_robot) 
        Krh = (4/3).* (1/( ((1-(robot.poisson_ratio_cover.^2))./ elastic_mod_robot) ...
                +( (1-(human.poisson_ratio_cover.^2))/ elastic_mod_human)) )...
                .*robot.radius_cs;
            
        if DEBUG_FLAG && ~isreal(Krh)
            fprintf("imaginary Krh: %.4f \n",deformation);
        end
        Fext = Krh * (deformation^(robot.n_d));
        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext: %f \n", Fext);
            disp(Krh)
            disp(deformation)
        end
    else
%             error('Deformation returns on imaginary plane (possibly the signed is inverted)')
         Fext = 0;
         Krh = 0;
         elastic_mod(1,1)=0;
         elastic_mod(2,1)=0;             
    end

end