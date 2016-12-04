%%% Golf Analytics Sample Assignment Part 2
%%% Alex Wainger
%%
file_name = 'round-2014-small.txt';
column_names = {'RoundScore', 'GIRRank', 'OverallPuttingAvg__OfPutts_'};

T = readtable(file_name, 'Delimiter', ';', 'ReadVariableNames', 1, 'ReadRowNames', 0);

%%

modelspec = 'RoundScore ~ GIRRank + OverallPuttingAvg__OfPutts_';
model = fitlm(T,modelspec);

%%
scores = transpose(table2array(columns_of_interest(:, 1)));
rng(1);
random_mat = randi(numel(scores), 10000, 4);
samples = scores(random_mat);
sum(sum(samples, 2) <= 270) / numel(scores);