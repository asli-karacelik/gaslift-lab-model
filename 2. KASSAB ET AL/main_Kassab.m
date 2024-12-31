clear all
clc
%% Folder and file settings
folder = '.'; % Current directory
file_pattern = '*.csv'; % Match the file extension
file_list = dir(fullfile(folder, file_pattern)); % Get list of files

% Excel file loop
for file_idx = 1:length(file_list)
    % Get the filename
    file_name = file_list(file_idx).name;
    
    % Extract submergence ratio from the filename
    S_str = regexp(file_name, '(\d+\_\d+)', 'tokens'); 

    % Extract the first matched token
    S_str = S_str{1}{1};  % 'tokens' returns a cell of cells

    % Convert the string with underscore to a numeric value
    S_str = strrep(S_str, '_', '.');  % Replace underscores with a dot
    S = str2double(S_str);  % Convert the string to a numeric value

    % Load parameters with dynamic submergence ratio (S)
    par = function_parameter_Kassab(S);
    
    % Read data from the current CSV file
    file_path = fullfile(folder, file_name);
    data = readtable(file_path);
    air = data{:, 1} * (1e3/3.6e3); % Convert air flow rates (kg/h to g/s)
    water = data{:, 2} * (1e3/3.6e3); % Convert water flow rates (kg/h to g/s)

    % Set bounds for air flow rates
    air_min = min(air);
    air_max = max(air);
    lower_limit = air_min; 
    upper_limit = air_max; 
    increment = (air_max - air_min) / 20;
    
    %% Fsolve computations
    results_wlout = [];
    results_exitflag = [];
    x1 = par.mg0; % Initial gas mass (g)
    x2 = par.ml0; % Initial liquid mass (g)
    x0 = [x1 x2];
    
    for Qginj = lower_limit:increment:upper_limit % Volumetric air inflow rate (cm3/s)
        opt = optimoptions('fsolve', 'MaxIter', 1e3, 'MaxFunEvals', 1e3, 'Display','off');
        [x, fval, exitflag, output] = fsolve(@(x)function_model_Kassab(x, Qginj, par), x0, opt);
        [F, wlout] = function_model_Kassab(x, Qginj, par);
        results_wlout = [results_wlout wlout];
    end
    
    %% Plot the results
    Qginj = lower_limit:increment:upper_limit;
    figure;
    plot(Qginj, results_wlout, '--m', 'LineWidth', 1);
    hold on;
    plot(air, water, '-k');
    xlabel('w_{g,inj} (g/s)');
    ylabel('w_{l,out} (g/s)');
    legend('Theory', 'Experiment');
    title(['Results for Submergence Ratio = ', num2str(S)]);
    hold off;
end