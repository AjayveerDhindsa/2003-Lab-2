%% cleaning
clc; clear; close all;

%% read data
Data = xlsread('BallData.xlsx');
Height = Data(2:12, 2:5);
SecTime = Data(16:25, 3:6);
TotTime = Data(30:40, 2);

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