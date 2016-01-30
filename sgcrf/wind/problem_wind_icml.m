function [X Y t s] = problem_wind_icml(path)

wind = csvread([path 'wind/train.csv'], 1, 0);
for i=1:7,
  wf{i} = csvread([path 'wind/windforecasts_wf' num2str(i) '.csv'], 1, 0);
  wf{i}(wf{i} == -10000) = nan;
  wf{i}(:,1) = date_to_timestamp(wf{i}(:,1));
end

[X Y] = problem_wind(wind, wf);
rand('state', 1);
clear params;
params.num_ar_features = 7*8;
params.rbf_mus = 10;
params.bandwidth = 7;
X = features_wind(X, params, struct);
[m p] = size(Y); n = size(X, 2);

% Normalize columns
%X(:,1:7*8) = bsxfun(@minus, X(:,1:7*8), mean(X(:,1:7*8)));
%Y = bsxfun(@minus, Y, mean(Y));

X(:,1:end-1) = bsxfun(@rdivide, bsxfun(@minus, X(:,1:end-1),  mean(X(:,1:end-1))), ...
                      std(X(:,1:end-1)));
Y = bsxfun(@rdivide, bsxfun(@minus, Y, mean(Y)), std(Y));

rand('state', 1);
split = cvpartition_grouped(m, 5, 8);
t = find(split.training(:,1));
s = find(split.test(:,1));


