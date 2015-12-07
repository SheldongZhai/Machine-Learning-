ffdsaf%% CompSci 571 Final Project Script
%
% Xiaodong Zhai (xz125@duke.edu)
% Dec, 2015
%
% All scripts of backtesting are of my previous work or work for this final
% project; the ksr.m is downloaded from Matlab forum and my thanks to its
% author, Yi Cao at Cranfield University
%
% All data is from the course High Frequency Financial Econometrics, Duke
% University, Professor George Tauchen and Mr. Red Davis.

%% IMPORT CALSS AND INITIATE STATE
import Strategy_SimpleMavg Strategy_HPMavg Strategy_KernelMavg
import MarketPortfolio

clc; clear;

% READ DATA
% read .xlsx data file
Data.raw = load('SPY_5min.dat');
Data.price = Data.raw(:, 3);
Data.symbol = 'SPY';
fprintf('data loaded (%d * %d)\n', size(Data.price));

% assign Data variables
Data.time_date = datetime(Data.raw(94225:94614, 1), 'ConvertFrom', 'yyyymmdd');
Data.time = datetime( ...
    helper.YMDid(Data.raw(94225:94614,1:2)), 'ConvertFrom', 'datenum');

% INITIATE PARAMETERS
% choose what  to backtest
nbr_slct = 1;
Input.symbol = Data.symbol;

% Example Period
Input.price = Data.price(94225:94614); % 20111101-20111107
%Input.price = Data.price(135079:end); % 20131212-20141212
%Input.price = Data.price(152491:154051); % 20141104-20141204



fprintf('data selected: %d\n', nbr_slct);
Input.sample_period_indx = 100;


%% BACKTEST SIMPLE MAVG & PERFORMANCE
ma_short = [1 1 2 2 6]; 
ma_long =  [2 3 3 6 12];

for i = 1 : length(ma_short)
    % with for loop, to iteratively create portfolios with each windows
    % and record the results
    
    Strats.mac_simple = Strategy_SimpleMavg(Input.symbol, Data.time, ...
        Input.price, ma_short(i), ma_long(i));
    
    Ports.mac_simple = mktptf(Strats.mac_simple, 100);
    
    Ports.mac_simple.backtest(); 
    
    Results.return.simple(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_simple.total_ret];
    
    Results.sharpe.simple(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_simple.get_sharpes()];
    
    Results.maxdrawd.simple(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_simple.get_maxdrawd()];
    
    Results.directaccu.simple(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_simple.get_drctaccur()];
%     disp([ma_short(i) ma_long(i)]);
%     disp(Ports.mac_simple.total_ret);
end
    

%% BACKTEST KERNEL REGRESSION MAVG

% distributions: gauss / parabolic / triang / cosine

for i = 1 : length(ma_short)
    % with for loop, to iteratively create portfolios with each windows
    % and record the results
    
    Strats.mac_kernel = Strategy_KernelMavg(Input.symbol, Data.time, ...
    Input.price, Input.sample_period_indx, ma_short(i), ma_long(i), 'gauss');
    
    Ports.mac_kernel = mktptf(Strats.mac_kernel, 100);
    
    Ports.mac_kernel.backtest(); 
    
    Results.return.kernel(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_kernel.total_ret];
    
    Results.sharpe.kernel(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_kernel.get_sharpes()];
    
    Results.maxdrawd.kernel(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_kernel.get_maxdrawd()];
    
    Results.directaccu.kernel(i, :) = [ma_short(i) ma_long(i) ...
        Ports.mac_kernel.get_drctaccur()];
   
end

all(Strats.mac_kernel.kernel_estimate == Input.price);
plot(1:length(Input.price), Strats.mac_kernel.kernel_estimate, 1:length(Input.price), Input.price)

%%
f = figure();
h = plot(1:length(Input.price), Input.price, ...
    1:length(Input.price), [nan(99,1);Strats.mac_kernel.kernel_estimate(100:end)] );
set(h(1),'linewidth',1.5);
set(h(2),'linewidth',1.5);
title('Real Price Series and Kernel Ridge Regression Line');
legend('Price', 'Kernel Ridge Regression');
xlabel('Time (5-min): 20111101 - 20111107');
ylabel('Price (USD)');
saveas(f, 'fig_2.jpg');


%% SUMMARY STATISTICS

% mean
SumStats.mean = mean(Data.price);
% std
SumStats.std = std(Data.price);
% skewness
SumStats.skew = skewness(Data.price);
% kurtosis
SumStats.kurt = kurtosis(Data.price);
% jarqur-bera test
for k = 1:nbr_slct
    [~, SumStats.jbtest(k).p, SumStats.jbtest(k).jbstat, ~] = ...
        jbtest(Data.price(:,k));
end
% autocorrelation
for k = 1:nbr_slct
        [SumStats.autocorr(:, k), ~, ~] = autocorr(Data.price(:,k), 7);
end

%% PLOTS

% plot prices
h = figure();
handle = 5; % handle = 1 / ... / nbr_slct
plot(Data.time, Data.price(:, 1:handle));
title('Price (proxy) Series');
xlabel('Time');
legend(Data.symbol(1:handle));
saveas(h, 'fig_price_series.fig');

% plot price and hp-filter estimate, for one series
% notes: in the sampling period, no estimate existed
h = figure();
handle = 4; 
plot(Data.time, Data.price(:,handle), ...
    Data.time, Strats.mac_hp.hp_estimate(:, handle));
title('Price(proxy) and HP-Filter Estimate');
xlabel('Time');
legend(Data.symbol(handle), 'HP-Filter Estimate');
saveas(h, strcat('fig_hp_est_', Data.symbol{handle}, '.fig'));

% plot hp_filter strategy total asset, for one series
k = 7; % with k to decide which to plot
h = Ports.mac_hp.plot_portfolio(4);
saveas(h, strcat('fig_hp_portfolio_', Data.symbol{handle}, '.fig'));

% plot kernel regression and price, for one series
h = figure();
handle = 4; 
plot(Data.time, Data.price(:,handle), ...
    Data.time, Strats.mac_kernel.kernel_estimate(:, handle));
title(['Price(proxy) and Kernel Estimate' ' ' Strats.mac_kernel.dist]);
xlabel('Time');
legend(Data.symbol(handle), 'Kernel Estimate');
saveas(h, strcat('fig_kernel_est_', Data.symbol{handle}, '.fig'));

% plot kernel strategy total asset, for one series
k = 7; % with k to decide which to plot
h = Ports.mac_kernel.plot_portfolio(4);
saveas(h, strcat('fig_kernel_portfolio_', Data.symbol{handle}, '.fig'));

