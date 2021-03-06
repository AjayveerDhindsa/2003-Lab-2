%% Authors
% Ajay Dhindsa
% Evan Meany
% Cole Sechrist
%% Read In Data
clc;
clear;
close all
% Reading in data
Data = readmatrix('BallData.xlsx');
Data1 = readcell('Trial_1.txt');
Data2 = readcell('Trial_2.txt');
Data3 = readcell('Trial_3.txt');
% Appendixing Data into different vectors
time1 = Data1(18:end,1);
time2 = Data2(8:end,1);
time3 = Data3(24:end,1);
SecTime = Data(16:25, 3:6);
TotTime = Data(30:40, 2);
% Have to use X as video imported sideways into LoggerPro, so X is really Y
x1 = Data1(18:end,2);
x2 = Data2(8:end,2);
x3 = Data3(24:end,2);
Height = Data(2:12, 2:5);

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
e_height_mean = mean(e_height(1:13));
e_bounces_mean = mean(e_bounces(1:13));
e_avg = mean([e_height_mean, e_bounces_mean, e_stop]);

%% height e calc
B12 = zeros(11,1); %bounce 1 to 2
B23 = zeros(11,1);
B34 = zeros(11,1);
for i = 1:11
    B12(i) = sqrt(Height(i,2)/Height(i,1));
    B23(i) = sqrt(Height(i,3)/Height(i,2));
    B34(i) = sqrt(Height(i,4)/Height(i,3));
end
eh12 = mean(B12); %coef for bounce 1 to 2
eh23 = mean(B23);
eh34 = mean(B34);
eh = (eh12 + eh23 + eh34)/3;

%% time e calc
TN12 = zeros(10,1); %time between bounce 1 to 2
TN23 = zeros(10,1);
TN34 = zeros(10,1);
for i = 1:10
    TN12 = SecTime(i,2)/SecTime(i,1);
    TN23 = SecTime(i,3)/SecTime(i,2);
    TN34 = SecTime(i,4)/SecTime(i,3);
end
etn12 = mean(TN12);
etn23 = mean(TN23);
etn34 = mean(TN34);
etn = (etn12 + etn23 + etn34)/3;

%% time stop e calc
TS = zeros(11,1);
h0 = 1;             %meters
g = 9.81;           %meters/sec
term = sqrt((2*h0)/g);
for i = 1:11
    TS = (TotTime(i) - term)/((TotTime(i) + term));
end
ets = mean(TS);

%% height standard deviation 
%find the partial derivative of each measured quantity
%for each of the three trials


%d/dhn = 1/2*[((hn^(-1/2))/hn-1^(1/2)]
stdH = zeros(1,4);
for i = 1:4
    stdH(i) = std(Height(1:11,i));
end

meanH = zeros(1,4);
for i = 1:4
    meanH(i) = mean(Height(1:11,i));
end

derHn = zeros(1,3);
derHn1 = zeros(1,3);
stdeH = zeros(1,3);
for i = 1:3
    derHn(i) = .5*((meanH(i+1)^(-.5))/(meanH(i)^(1/2)));
    derHn1(i) = -.5*((meanH(i+1)^(.5))/(meanH(i)^(1.5)));
    stdeH(i) = sqrt(((derHn(i)*stdH(i+1)))^(2) + ((derHn1(i)*stdH(i)))^(2));
end
errH = mean(stdeH);

%% time standard deviation 

stdTn = zeros(1,4);
for i = 1:4
    stdTn(i) = std(SecTime(1:10,i));
end

meanTn = zeros(1,4);
for i = 1:4
    meanTn(i) = mean(SecTime(1:10,i));
end

derTn = zeros(1,3);
derTn1 = zeros(1,3);
stdeTn = zeros(1,3);
for i = 1:3
    derTn(i) = 1/meanTn(i);
    derTn1(i) = -(meanTn(i+1)*(meanTn(i)^(-2)));
    stdeTn(i) = sqrt((derTn(i)*stdTn(i+1))^(2) + (derTn1(i)*stdTn(i))^(2));
end
errTn = mean(stdeTn);

%% time stop standard deviation

stdTs = std(TotTime(1:11));
meanTs = mean(TotTime(1:11));
derTs = ((meanTs + sqrt(2*h0/g)) - (meanTs - sqrt(2*h0/g)))/((meanTs + sqrt(2*h0/g))^(.5));
stdeTs = sqrt((derTs*stdTs)^(2));


%% error ploots

figure(1)
errorbar(1, eh, errH, 'Linewidth', 2);
hold on;
errorbar(2, etn, errTn, 'Linewidth', 2);
hold on;
errorbar(3, ets, stdeTs, 'Linewidth', 2);
set(gca,'xtick',[1, 2, 3]);
xlim([0 4]);
ylim([0 1]);
xlabel('Trial')
ylabel('Coef of Restitution')
title('Calculated Coef of Restitutions with error')
lgd = legend('Height', 'Time between bounces', 'Total to stop');
title(lgd, 'Calculation Method')