%%% Golf Analytics Sample Assignment Part 2
%%% Alex Wainger
%% Constants
input_name = 'round-2014-small.txt';
output_name = 'results.txt';
mc_iters = 10000;
mc_sample_size = 4;
mc_threshold = 270;

%% Read File
[x,y] = file_to_matrices(input_name);

%% Linear Regression
model = linear_regression(x, y);

%% Monte Carlo
[percentage, error] = monte_carlo(y, mc_iters, mc_sample_size, mc_threshold);

%% Write Results To A File
write_to_file(output_name, model, percentage, error);

%% Functions

function [x, y] = file_to_matrices(f_name)
% file_to_table reads in a semi-colon delimited file and converts it to a
% table using the readtable function

% Input Vars
% f_name - String, name of file to import

% Output Vars
% x - Matrix, containing predictor values
% y - Vector, containing dependent values

    fid = fopen(f_name);
    fgetl(fid); % skip header
    line = fgetl(fid);

    x = [];
    y = [];
    while ischar(line)
        A = textscan(line,'%s', 'delimiter',';');
        score = str2double(A{:}{16});
        gir = str2double(A{:}{80});
        putt = str2double(A{:}{123});

        x = [x; gir, putt];
        y = [y; score];

        line = fgetl(fid);
    end
    
    fclose(fid);

end


function model = linear_regression(x, y)
% linear_regression runs a linear regression using the inputted x features
% and y values to predict, returns the model

% Input Vars
% x - Matrix, containing predictor values
% y - Vector, containing dependent values

% Output Vars
% model - LinearModel object, output of the fitlm function

    model = fitlm(x, y);

end

function [percentage, error] = monte_carlo(vector, iters, sample_size, threshold)
% monte_carlo runs a monte carlo simulation using "iters" number of
% iterations, taking a random sample of size "sample_size", and returning
% the percentage of the random samples that are less than or equal to
% threshold

% Input Vars
% vector - row vector with observed data 
% iters - number of times to run the simulation
% sample_size - number of samples to take during each iteration
% threshold - value to compare sum of the samples to

% Output Vars
% percentage - the result of the monte carlo simulation, percentage of
% random samples that summed to less than or equal to the threshold

    % Seeds random number generator so that results are reproducible
    rng(1);
    
    % Creates matrix of random indices to collect samples
    random_mat = randi(numel(vector), iters, sample_size);
    
    % Take samples from observed data vector
    samples = vector(random_mat);
    
    % Compare each of the sample totals to the threshold, sum to get
    % number of times less than or equal to threshold, divide by number of
    % trials
    percentage = sum(sum(samples, 2)<= threshold) / iters;
    
    % The number of successes, N, is a binomial RV with parameters n =
    % iters, and p = percentage. The variance of the estimator p_hat, is
    % then the variance of N (np(1-p) because it's binomial) divided by 
    % iters^2 (once to get the percentage from the total, once to reflect 
    % the fact that it is a sample variance). The standard error can be 
    % found by taking the square root of this value.
    error = sqrt((percentage * (1 - percentage)) / iters);
end

function write_to_file(output_name, model, mc_percentage, mc_error)
% write_to_file writes the results of this script to a results.txt file

% Input Vars
% output_name - file to write to
% model - linear regression model
% percentage - monte carlo simulation result

% Output Vars
% None.

    fid = fopen(output_name, 'w');
    fprintf(fid, '--- Regression Output ---\nIntercept (a): %f (Estimate), %f (SE)\n', ...
            model.Coefficients{'(Intercept)', {'Estimate', 'SE'}});
    fprintf(fid, 'GIR Coefficient (b): %f (Estimate), %f (SE)\n', ...
            model.Coefficients{'x1', {'Estimate', 'SE'}});
    fprintf(fid, 'Putt Coefficient (c): %f (Estimate), %f (SE)\n', ...
            model.Coefficients{'x2', {'Estimate', 'SE'}});
    fprintf(fid, 'R-Squared: %f\n', model.Rsquared.Ordinary);
    fprintf(fid, 'Number of Data Points: %d', model.NumObservations);
    fprintf(fid, '\n\n--- Monte Carlo Output ---\nEstimate: %f\nStandard Error: %f', mc_percentage, mc_error);
    
end