function [fullArr, fs, fileNameEDF, sleepScores, EDFInfo] = DD_Read(currentFile, useScores, epochLength)

% Works with DannyDelta_v8.m to read in EDF and TXT, select the RF signal, and expand the array
% Last updated 9/15/22, Danny Lasky

%% Read in EDF and TXT
fileNameEDF = strcat(currentFile,'.edf');
EDFData = edfread(fileNameEDF);

if useScores == 1
    fileNameTXT = strcat(currentFile,'.txt');
    sleepScores = readtable(fileNameTXT);
elseif useScores == 0
    sleepScores = 'No Scores';
end

%% Selects the RF signal and expands the array
EDFInfo = edfinfo(fileNameEDF);
signalNames = EDFInfo.SignalLabels;

% Selective fix for the animal with RF and LP signals switched
if contains(currentFile, "LPandRFswitched") == 1
    RFNumber = find(contains(signalNames, 'LP'));
else
    RFNumber = find(contains(signalNames, 'RF'));
end

% Fix for animals with RF in animal ID to find correct right frontal signal
if length(RFNumber) == 2  
    if contains(currentFile,["DBAKainate~AnimalLRF", "DBAKainate~AnimalRF"]) == 0                   
        if length(signalNames{1}) > 3
            signalNames{1} = 'X';
        end
        if length(signalNames{2}) > 3
            signalNames{2} = 'X';
        end
        if length(signalNames{3}) > 3
            signalNames{3} = 'X';
        end
        RFNumber = find(contains(signalNames, 'RF'));
    else
        RFNumber = find(contains(signalNames, ["RF7-DBAK", "RF6-DBAK"]));
    end
end

if currentFile == "Ronde030413"
    RFData = EDFData.Signal0;
else
    RFData = EDFData.(RFNumber);
end

extraRFData = mod(length(RFData),epochLength);
RFData = RFData(1:end-extraRFData,:);

fullArr = cell2mat(RFData);

%% Check for EDF RF sampling frequency of 512 Hz and removes extra sleep score if present
if currentFile == "Ronde030413"
    fs = 256;
else
    fs = EDFInfo.NumSamples(RFNumber,1);
end

if fs ~= 512
    disp('EDF RF sampling frequency is not 512 Hz.')
end

if height(sleepScores) > length(RFData)/epochLength
    sleepScores(end,:) = [];
end
