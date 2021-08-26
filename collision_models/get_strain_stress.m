%% Starting new script to obtain the impact energy denisty and strain stress at a given bone
%% Stress computation from the Model of 2 spheres colliding
% Function to estimate the force excerted in deformation ckntact between a
% robot and a human body part based on a Hertzian Reference Frame between a
% deformable

% author: Diego Paez-G.

function [sigma]  = get_strain_stress(deformation,Fext,robot,human,...
                                    varargin)
    % Hunt-Crossley Model output of contact stress in the human-body part side
    
    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x) ; %&& (x >= 0)
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
    chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'deformation',chkscalar);
    addRequired(p,'Fext',chkscalar);
    addRequired(p,'robot',@isstruct);
    addRequired(p,'human',@isstruct);
    % Optional Inputs

    parse(p,deformation,Fext,robot,human,varargin{:});
    deformation = p.Results.deformation;
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
    
    if deformation <= (robot.deformation_sm) % bs_{max}

        sigma =  ((3.* Fext) ./ (2*pi).*deformation) .* robot.radius_cs.^(-2);
        
        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext: %f \n", Fext);
            disp(Krh)
            disp(deformation)
        end

    elseif deformation > (robot.deformation_sm) && deformation <= (robot.deformation_cm) % bc_{max}
                   
        sigma =  ((3.* Fext) ./ (2*pi).*(deformation - robot.deformation_sm)) .* robot.radius_cb.^(-2)...
                            + robot.stress_skin_max;
        

        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext b_sm: %f \n", Fext);
            disp(Krh)
            disp(deformation)
        end
    elseif deformation > (robot.deformation_cm) %\deformation > bc_{max}
        
        sigma =  ((3.* Fext) ./ (2*pi).*(deformation - robot.deformation_cm)) .* robot.radius_rb.^(-2)...
                            + robot.stress_cover_max ;

        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext b_cm: %f \n", Fext);
            disp(Krh)
            disp(deformation)
        end
    end

end
