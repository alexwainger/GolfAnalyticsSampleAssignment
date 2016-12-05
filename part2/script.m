%%% Golf Analytics Sample Assignment Part 2
%%% Alex Wainger
%% Constants
input_name = 'round-2014-small.txt';
output_name = 'results.txt';
modelspec = 'RoundScore ~ GIRRank + OverallPuttingAvg__OfPutts_';
mc_column_name = 'RoundScore';
mc_iters = 10000;
mc_sample_size = 4;
mc_threshold = 270;

%% Read File
T = file_to_table(input_name);

%% Linear Regression
model = linear_regression(T, modelspec);

%% Monte Carlo
vector = transpose(table2array(T(:, mc_column_name)));
[percentage, error] = monte_carlo(vector, mc_iters, mc_sample_size, mc_threshold);

%% Write Results To A File
write_to_file(output_name, model, percentage, error);

%% Functions

function T = file_to_table(f_name)
% file_to_table reads in a semi-colon delimited file and converts it to a
% table using the readtable function

% Input Vars
% f_name - String, name of file to import

% Output Vars
% T - table, with variable names from header row

    T = readtable(f_name, 'Delimiter', ';', 'ReadVariableNames', 1, 'ReadRowNames', 0);

end


function model = linear_regression(table, spec)
% linear_regression runs a linear regression using the inputted table and 
% model spec (which uses variable names from the table), returns the model

% Input Vars
% table - Table with all data needed for regression
% spec - String, representing the regression function

% Output Vars
% model - LinearModel object, output of the fitlm function

    model = fitlm(table,spec);

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
            model.Coefficients{'GIRRank', {'Estimate', 'SE'}});
    fprintf(fid, 'Putt Coefficient (c): %f (Estimate), %f (SE)\n', ...
            model.Coefficients{'OverallPuttingAvg__OfPutts_', {'Estimate', 'SE'}});
    fprintf(fid, 'R-Squared: %f\n', model.Rsquared.Ordinary);
    fprintf(fid, 'Number of Data Points: %d', model.NumObservations);
    fprintf(fid, '\n\n--- Monte Carlo Output ---\nEstimate: %f\nStandard Error: %f', mc_percentage, mc_error);
    
end