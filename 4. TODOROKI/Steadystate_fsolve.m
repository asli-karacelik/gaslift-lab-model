%% Folder and file settings
folder = '.'; % Current directory
file_pattern = 'S_0_*.csv'; % Match the file naming convention
fileList = dir(fullfile(folder, file_pattern)); % Get list of files

% Inside your MainScript.m
for fileIdx = 1:length(fileList)
    % Get the filename
    filename = fileList(fileIdx).name;
    disp(['Processing file: ', filename]); % Display progress
    
    % Extract S value from the filename
    S_value_str = regexp(filename, 'S_(\d+\_\d+)_', 'tokens'); 
   
   % Check if a match was found
if ~isempty(S_value_str)
    % Extract the first matched token
    S_value_str = S_value_str{1}{1};  % Since 'tokens' returns a cell of cells, we need to extract the first element

    % Convert the string with underscore to a numeric value
    S_value_str = strrep(S_value_str, '_', '.');  % Replace underscores with a dot
    S_value = str2double(S_value_str);  % Convert the string to a numeric value
else
    error('Invalid filename format. Could not extract S value from: %s', filename);
end

% Display the extracted numeric value
disp(S_value);

    % Load parameters with dynamic S
    par = Parameter(S_value);
    disp(par);  % Check structure after calling Parameter function
    
    % Read data from the current CSV file
    filepath = fullfile(folder, filename);
    data = readtable(filepath);
    air = data{:, 1} * 1e3; % Convert air flow rates
    water = data{:, 2} * (1e3 * par.rhol); % Convert water flow rates

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
    
    for Qginj = lower_limit:increment:upper_limit % Volumetric inflow rate (cm^3/s)
        disp(['Processing Qginj: ', num2str(Qginj)]); % Debugging
        
        opt = optimoptions('fsolve', 'MaxIter', 1e3, 'MaxFunEvals', 1e3);
        [x, ~, exitflag, output] = fsolve(@(x)SteadystateFcn_fsolve(x, Qginj, par), x0, opt);
        
        disp(['fsolve exitflag: ', num2str(exitflag)]); % Debugging
        
        if exitflag <= 0
            warning('fsolve failed for Qginj = %.2f', Qginj);
            continue;
        end
        
        [F, wlout] = SteadystateFcn_fsolve(x, Qginj, par);
        disp(['Computed wlout: ', num2str(wlout)]); % Debugging
        
        if isnan(wlout) || isinf(wlout)
            warning('Invalid wlout value for Qginj = %.2f', Qginj);
            continue;
        end
        
        results_wlout = [results_wlout wlout];
    end
    
    %% Plot the results
    if isempty(results_wlout)
        warning('No results to plot for S = %.3f', S_value);
        continue;
    end
    
    Qginj = lower_limit:increment:upper_limit;
    figure;
    plot(Qginj, results_wlout, ':_r', 'MarkerSize', 4, 'MarkerEdge', 'b', 'LineWidth', 1);
    hold on;
    plot(air, water, '-k', 'MarkerSize', 3);
    xlabel('Q_{g,inj} (cm^3/s)');
    ylabel('w_{l,out} (g/s)');
    legend('Simulated', 'Experimental');
    title(['Results for S = ', num2str(S_value)]);
    hold off;
end