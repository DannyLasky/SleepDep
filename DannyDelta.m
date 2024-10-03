% Last updated 2/2024 by Danny Lasky

%% CHANGE ME! ⌄⌄⌄
ExcelRows = 58;
useScores = 1;                  % Toggle 0 for off, 1 for on
epochLength = 4;                % in seconds
tableName = "Master Sheet Sleep Dep";
inputDir = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\EDFs and TXTs"';
outputDir = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output";
%% CHANGE ME! ^^^

%% Initialize variabes
MatlabRows = ExcelRows - 1;     % Offset by 1 row since 1st row becomes the table header in Matlab
ExcelArr = readtable(tableName);
fileArr = ExcelArr(MatlabRows, 'FilePath');
fileArr = table2array(fileArr);
fileArr = string(fileArr);

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')     % Turn off unnecessary warning
warning('off', 'MATLAB:MKDIR:DirectoryExists')              % Turn off unnecessary warning

%% Begin full file loop and set input directory
for fileCount = 1:length(fileArr)
    currentFile = fileArr(fileCount);
    fprintf('Currently running %s.\n', currentFile);
    cd(inputDir);
    
%% Read in EDF and sleep scores, select the RF signal, and expand the array
    [fullArr, fs, fileNameEDF, sleepScores, EDFInfo] = DD_Read(currentFile, useScores, epochLength);

%% Define sampling points per epoch and epoch count
    epochPts = fs*epochLength;
    epochCount = floor(length(fullArr)/epochPts);

%% Apply Pfam's 60-Hz filter, high-pass filter, and full EEG normalization
    [normSignal, sig, modelfit, mu] = normalizeEEG(fullArr, fs);

%% Quantify delta and gamma power with a modified version of Jones's method
    [avgMagArr, avgFreqArr, signalMax, signalMin, signalStd] = DD_Bandpower(normSignal, epochPts, fs);

%% Align epochs in 6:30:00am-6:30:00am window and with scored epoch periods
    [avgMagArr, avgFreqArr, startEpochOffset, endEpochOffset, EDFTime, DSTCheck] = DD_Align ...
        (epochLength, epochCount, avgMagArr, avgFreqArr, EDFInfo);

%% Work up the TSV and make sleep state specific matrices
    if useScores == 1
        [alignedScores, justScores, homeoScores, alignedStart, alignedEnd, scoredArtifact] = ...
            DD_Scores(sleepScores, startEpochOffset, endEpochOffset, epochLength, EDFTime, DSTCheck);
    end

%% Normalize the band powers, Remove artifact, divide into hourly segments, and create a master matrix and tables
    [finalMatrix, finalTable, hourlyMatrix, hourlyTable, artDeltaSum, artGammaSum] = DD_NormHour(epochLength, ...
        avgMagArr, justScores, useScores);

%% Create supplementary table, create output directory, and save off tables
    suppTable = table(modelfit, sig, mu, signalMax, signalMin, signalStd, DSTCheck, alignedStart, alignedEnd, ...
        scoredArtifact, artDeltaSum, artGammaSum);

    fileSplit = strsplit(fileArr(fileCount), "\");
    fileName = fileSplit(end);
    
    outputDirFull = fullfile(outputDir, fileName);
    mkdir(outputDirFull);
    cd(outputDirFull);

    writetable(finalTable, 'Final Table.csv')
    writetable(hourlyTable, 'Hourly Table.csv')
    writetable(suppTable, 'Supp Table.csv')

    if useScores == 1
        writetable(alignedScores, 'Scores Detailed.csv')
        writematrix(justScores, 'Scores Simple.csv')
        writematrix(homeoScores, 'Scores Homeostasis.csv')
    end

%% Create hourly delta gamma graphs for all epochs or a sleep state
    DD_24HrDelta(hourlyMatrix, hourlyTable, fileNameEDF, useScores);

%% Create hourly time spent in Wake/NREM/REM graphs
    if useScores == 1
        [stateTable] = DD_StateTime(fileNameEDF,justScores,epochLength);
    end
end
