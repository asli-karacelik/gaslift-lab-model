function par = Kassab_parameter_function(S)
%% Parameters
% Enter parameters
par.S = S;                           % Ratio of the height of the vertical pipe to height of the reservoir
par.D = 2.54;                        % Diameter of the vertical pipe (cm)
par.H = 375;                         % Height of the vertical pipe (cm)

% Constant parameters
par.A = pi * par.D^2 / 4;            % Area of the vertical pipe (cm2)
par.g = 980.665;                     % Acceleration of gravity (cm/s2)
par.Hres = par.H * par.S;            % Height of the reservoir (cm)
par.V = par.A * par.H;               % Volume of the vertical pipe (cm3)
par.Mg = 28.951;                     % Molecular weight of gas (g/mol)
par.patm = 1013250;                  % Atmospheric pressure (g/cm-s2)
par.R = 8.314462618 * 1e7;           % Universal gas constant (cm3⋅(g/cm-s2)/(K⋅mol))
par.rhol = 0.998204;                 % Liquid density (g/cm3) at 20 °C
par.pres = 1013250 + par.rhol * par.g * par.Hres; % Reservoir pressure (g/cm-s2)
par.T = 293.15;                      % Temperature (K)

%% Initial conditions
par.alphal0 = 0.1;                   % Initial liquid volume fraction
par.ml0 = par.V * par.alphal0 * par.rhol; % Initial liquid mass (g)
par.ptop0 = 1013250;                 % Initial top pressure (g/cm-s2)
par.mg0 = par.ptop0 * par.V * (1 - par.alphal0) * par.Mg / (par.R * par.T); % Initial gas mass (g)
end

% align_comments('Kassab_parameter_function.m', 40)