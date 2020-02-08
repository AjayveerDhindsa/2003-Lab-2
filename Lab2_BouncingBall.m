%% Read In Data
clc;
clear;
close all
% Reading in data
Data1 = readcell('Trial_1.txt');
Data2 = readcell('Trial_2.txt');
Data3 = readcell('Trial_3.txt');
% Appendixing Data into different vectors
time1 = Data1(18:end,1);
time2 = Data2(8:end,1);
time3 = Data3(24:end,1);
% Have to use X as video imported sideways into LoggerPro, so X is really Y
x1 = Data1(18:end,2);
x2 = Data2(8:end,2);
x3 = Data3(24:end,2);

avg_x1 = mean(cell2mat(x1));
avg_x2 = mean(cell2mat(x2));
avg_x3 = mean(cell2mat(x3));

%% Plotting Data for Trial 3
figure(1)
plot(cell2mat(time3),abs(cell2mat(x3) - max(cell2mat(x3))))
title('Bouncing Ball Height (m) vs. Time (s)')
xlabel('Time (s)')
ylabel('Height (m)')

%% Finding e_height
% Finding when the ball reaches apex of bounce
localtest = islocalmax(abs(cell2mat(x3) - max(cell2mat(x3))));
localmax = find(localtest);
x3_max = abs(cell2mat(x3(localmax)) - max(cell2mat(x3)));

% Using Equation (2) and max height of each bounce to solve e_height
for i=1:length(x3_max)-1
    e_height(i) = ((x3_max(i+1)) / x3_max(i))^(1/2);
end

%% Finding e_bounces
% Finding when the ball hit the floor
localtest = islocalmin(abs(cell2mat(x3) - max(cell2mat(x3))));
localmin = find(localtest);
time_min = cell2mat(time3(localmin));

% Using the times of when the ball hit the floor and finding the difference
% between successive floor touches to solve for t_n and t_n-1 and then
% using Equation (3) to solve e_bounces
for i = 1:length(time_min)-2
   e_bounces(i) = (time_min(i+2) - time_min(i+1)) / (time_min(i+1) - time_min(i)); 
end

%% Finding e_stop
% Equation (4) in Lab Doc
g = 9.81;
e_stop = (cell2mat(time3(end)) - sqrt((2*cell2mat(x3(end))/g))) / (cell2mat(time3(end)) + sqrt((2*cell2mat(x3(end))/g)))

%% Finding Mean and STD of Different Coefficients of Restitution
e_height_mean = mean(e_height(1:13))
e_bounces_mean = mean(e_bounces(1:13))

e_avg = mean([e_height_mean, e_bounces_mean, e_stop])