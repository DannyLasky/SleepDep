function [avgMagArr, avgFreqArr, startEpochOffset, endEpochOffset, DSTCheck] = DD_Align ...
    (epochLength, epochCount, avgMagArr, avgFreqArr, EDFInfo)

% Works with DannyDelta_v8.m to align arrays within the 6:30:00-6:30:00 window
% Last updated 2/7/2022, Danny Lasky

startTime = EDFInfo.StartTime;
startTimeSplit = split(startTime,".");
startTimeNum = str2double(startTimeSplit);

%% Zeitgeber time = 0 (lights on) always at 6:30 on clocks
% During DST, Jesse and the vivarium lights "spring forward" an hour, are coming in an hour earlier (move to Eastern time)
% The computers did not shift forward to account for DST (stay in Central time)
% The EDFs recorded during DST must be aligned to zeitgeber 0
% by aligning to EDF (computer) 5:30 when the lights come on (which was 6:30 "Eastern" time)
tempDateSplit = split(EDFInfo.StartDate,".");
tempDateSplit(3) = strcat('20',tempDateSplit(3));
correctDate = strcat(tempDateSplit(1),'-',tempDateSplit(2),'-',tempDateSplit(3),' 12');
EDFTime = datetime(correctDate, 'timezone', 'America/Chicago','InputFormat','dd-MM-yyyy HH');
DSTCheck = isdst(EDFTime);

if DSTCheck == 0
    startTimeBase = [6;30;0];
elseif DSTCheck == 1
    startTimeBase = [5;30;0];
end

startTimeOffset = startTimeNum - startTimeBase;
startSecOffset = startTimeOffset(1,1)*3600 + startTimeOffset(2,1)*60 + startTimeOffset(3,1);
startEpochOffset = round(startSecOffset/epochLength);

endEpochOffset = 86400/epochLength - fix(startEpochOffset + epochCount);
tempWidth = width(avgMagArr);

if startEpochOffset > 0
	%maxMagArr  = [NaN(startEpochOffset,tempWidth);maxMagArr];
	%maxFreqArr = [NaN(startEpochOffset,tempWidth);maxFreqArr];
    avgMagArr   = [NaN(startEpochOffset,tempWidth);avgMagArr];
    avgFreqArr  = [NaN(startEpochOffset,tempWidth);avgFreqArr];
	%sumMagArr  = [NaN(startEpochOffset,tempWidth);sumMagArr];
elseif startEpochOffset < 0
    cutEpochs   = abs(startEpochOffset) + 1;
	%maxMagArr  = maxMagArr(cutEpochs:end,:);
	%maxFreqArr = maxFreqArr(cutEpochs:end,:);
    avgMagArr   = avgMagArr(cutEpochs:end,:);
    avgFreqArr  = avgFreqArr(cutEpochs:end,:);
	%sumMagArr  = sumMagArr(cutEpochs:end,:);
end

if endEpochOffset > 0
	%maxMagArr  = [maxMagArr;NaN(endEpochOffset,tempWidth)];
	%maxFreqArr = [maxFreqArr;NaN(endEpochOffset,tempWidth)];
    avgMagArr   = [avgMagArr;NaN(endEpochOffset,tempWidth)];
    avgFreqArr  = [avgFreqArr;NaN(endEpochOffset,tempWidth)];
	%sumMagArr  = [sumMagArr;NaN(endEpochOffset,tempWidth)];
elseif endEpochOffset < 0
    cutEpochs  = abs(endEpochOffset);
	%maxMagArr  = maxMagArr(1:end-cutEpochs,:);
	%maxFreqArr = maxFreqArr(1:end-cutEpochs,:);
    avgMagArr  = avgMagArr(1:end-cutEpochs,:);
    avgFreqArr = avgFreqArr(1:end-cutEpochs,:);
	%sumMagArr  = sumMagArr(1:end-cutEpochs,:);
end

fprintf('%d EDF epochs after shifting.\n',length(avgMagArr))
