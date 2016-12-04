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

%% Monte Carlo
vector = transpose(table2array(T(:, mc_column_name)));
percentage = monte_carlo(vector, mc_iters, mc_sample_size, mc_threshold);

%% Functions

function T = file_to_table(f_name)
    T = readtable(f_name, 'Delimiter', ';', 'ReadVariableNames', 1, 'ReadRowNames', 0);
end

function model = linear_regression(table, spec)
    model = fitlm(table,spec);
end

function percentage = monte_carlo(vector, iters, sample_size, threshold)
    rng(1);
    random_mat = randi(numel(vector), iters, sample_size);
    samples = vector(random_mat);
    percentage = sum(sum(samples, 2) <= threshold) / numel(vector);
end