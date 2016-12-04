%%% Golf Analytics Sample Assignment Part 2
%%% Alex Wainger
%% Constants
file_name = 'round-2014-small.txt';
modelspec = 'RoundScore ~ GIRRank + OverallPuttingAvg__OfPutts_';
mc_column_name = 'RoundScore';
mc_iters = 10000;
mc_sample_size = 4;
mc_threshold = 270;

%% Read File

T = file_to_table(file_name);

%% Linear Regression
model = linear_regression(T, modelspec);
disp(model);

%% Monte Carlo
vector = transpose(table2array(T(:, mc_column_name)));
percentage = monte_carlo(vector, mc_iters, mc_sample_size, mc_threshold);
disp(percentage);

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

function percentage = monte_carlo(vector, iters, sample_size, threshold)
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
    
    % sum samples for each iteration, compare to threshold, sum to get
    % number of times less than or equal to threshold, divide by number of
    % trials
    percentage = sum(sum(samples, 2) <= threshold) / iters;
end