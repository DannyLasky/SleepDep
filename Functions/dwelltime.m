function [vals, lengths, run_starts] = dwelltime(data);

%  [vals, lengths, run_starts] = dwelltime(data);
% 
% DWELL TIMES in various states (aka, Run Length Encoding).
% Find the numerical state values, and the lengths of consecutive runs of those values.
% 
% DATA is a vector of integer state values 
%     e.g., data = [2 1 2 3 3 1 2 2 3 3 1 1 1 1 1 2 2 1 1 3 3 3 3 2 1 3 3 2 2 1 1 1 2 2 2 2 3 1 1 1];
% VALS is a vector of the state values for each run of consecutive values
% LENGTH is the duration (IN DATA POINTS, NOT TIME) of each corresponding run
% RUN_STARTS are the INDICES of the start of each run
%
%   Displays results
% 
% Code based on Michael A
% http://codereview.stackexchange.com/questions/62993/run-length-encoding-of-vectors-in-matlab-looped-version-and-vectorized-version
% 
% MJones 2015
% 
% example:
% 
% data = [2 1 2 3 3 1 2 2 3 3 1 1 1 1 1 2 2 1 1 3 3 3 3 2 1 3 3 2 2 1 1 1 2 2 2 2 3 1 1 1];
% [vals, lengths, run_starts] = dwelltime(data);

data = data(:);
breaks = [true; data(2:end) ~= data(1:end-1)];
run_starts = find([breaks; true]);
vals = data(breaks);
lengths = diff(run_starts);
run_starts(end) = [];

plot(1:length(data), data, 'k.-'); hold on
plot(run_starts, data(run_starts), 'ro')
% [vals lengths run_starts]
