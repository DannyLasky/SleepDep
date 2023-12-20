%% Part 1: Histogram of nearby NREM bouts
ExcelRows = 2:121;
MatlabRows = ExcelRows - 1;         % Offset by 1 row since 1st row becomes the table header in Matlab
ExcelArr = readtable("Master Sheet Sleep Dep");
fileArr = ExcelArr(MatlabRows,'FileName');
fileArr = table2array(fileArr);
fileArr = string(fileArr);
outputDir = "/Users/djlasky/Documents/SleepDep/DannyDelta Output/HomeoFit";

shorterNREMLength   = cell(length(ExcelRows),1);
clusterCount        = cell(length(ExcelRows),1);
clusterLengthNREM   = cell(length(ExcelRows),1);

for fileCount = 1:length(fileArr)
    currentFile = fileArr(fileCount);
    cd(fullfile("/Users/djlasky/Documents/SleepDep/DannyDelta_v8 Output",currentFile));
    finalMatrix = readmatrix('Final Table.csv');
    homeoScores = readmatrix('Scores Simple');
    fileNameEDF = strcat(currentFile, '.edf');
    epochLength = 4;

    cd(outputDir)
    Epoch = transpose(1:length(homeoScores));
    epochsecs = epochLength;
    deltapwr = finalMatrix(:,1);    % Currently using unnormalized
    
    [~,titleName]=fileparts(fileNameEDF);
    graphTitle = strrep(titleName,'_',' ');
    output.ID = titleName;

    disp('Finding dwell times and runs, etc.')
    [vals, lengths, run_starts] = dwelltime(homeoScores);

%% Change artifact values flanked by wake to wake
    runLoop = 1;
    while runLoop == 1
        artifactVals = find(vals == 0);
        artifactFlanked = NaN(length(artifactVals),1);
        for n = 1:length(artifactVals)
            if artifactVals(n) == length(run_starts)
                runLoop = 0;
            else
                artifactFlanked(n) = vals(artifactVals(n)-1) + vals(artifactVals(n)+1);
                if artifactFlanked(n) == 2
                    homeoScores(run_starts(artifactVals(n)):run_starts(artifactVals(n)) + lengths(artifactVals(n)) - 1) = 1;
                else
                    runLoop = 0;
                end
            end
        end
        if isempty(artifactVals)
            runLoop = 0;
        end
        [vals, lengths, run_starts] = dwelltime(homeoScores);
    end

    close all

%% Find nearest NREM bouts to each NREM bout to determine which are in clusters and which are isolated
    NREMIndx = find(vals == 2);

    prevNREMBout = circshift(NREMIndx,1);
    prevNREMEpoch = run_starts(prevNREMBout) + lengths(prevNREMBout) - 1;
    prevNREMDistance = run_starts(NREMIndx) - prevNREMEpoch - 1;
    prevNREMDistance(1) = NaN;

    nextNREMBout = circshift(NREMIndx,-1);
    nextNREMEpoch = run_starts(nextNREMBout);
    currNREMEnd = run_starts(NREMIndx) + lengths(NREMIndx) - 1;
    nextNREMDistance = nextNREMEpoch - currNREMEnd - 1;
    nextNREMDistance(end) = NaN;

    shorterNREMLength{fileCount} = min([prevNREMDistance, nextNREMDistance], [], 2, 'omitnan');

%% Part 2: Viewing the average length of clusters in epochs and bouts
    NREMLimit = 100;     % Hand select threshhold until curve fitting works

    invalidNREMFilter = shorterNREMLength{fileCount} > NREMLimit;
    invalidNREM = NREMIndx(invalidNREMFilter);
    clusterScores = homeoScores;
    
    for n = 1:length(invalidNREM)
        clusterScores(run_starts(invalidNREM(n)) : run_starts(invalidNREM(n)) + lengths(invalidNREM(n)) - 1) = 1;
    end    

    clusterMatrix = [shorterNREMLength{fileCount}, run_starts(NREMIndx), currNREMEnd];
    clusterMatrix(any(clusterMatrix(:,1) > NREMLimit, 2), :) = [];
    clusterValue = 1;

    clusterMatrix(1,4) = clusterValue;
    for n = 2:length(clusterMatrix)
        if clusterMatrix(n,2) - clusterMatrix(n-1,3) - 1 > NREMLimit
            clusterValue = clusterValue + 1;
        end
        clusterMatrix(n,4) = clusterValue;
    end
    
    clusterStartTemp = [1; diff(clusterMatrix(:,4))];
    clusterStart = find(clusterStartTemp == 1);

    clusterEnd = circshift(clusterStart,-1) - 1;
    clusterEnd(end) = length(clusterMatrix);

    clusterCount{fileCount} = clusterEnd - clusterStart + 1;

    clusterStartNREM = clusterMatrix(clusterStart,2);
    clusterEndNREM = clusterMatrix(clusterEnd,3);
   
    clusterLengthNREM{fileCount} = clusterEndNREM - clusterStartNREM + 1;

end

%% Group together all NREM separation data
NREMLengths = cell2mat(shorterNREMLength);

figure
histogram(sqrt(NREMLengths), logspace(0, 2, 41))      % Cap of 10000 epoch long bout
set(gca, 'xsc', 'log')

xlabel('Distance to nearby NREM bout', 'FontSize', 14);
ylabel('Frequency', 'FontSize', 14);
title('All Mice All Days', 'FontSize', 16)

%exportgraphics(gcf,strcat('All Mice All Days.tiff'), 'Resolution', 600) 

%% Group together all NREM cluster length data
clusterCounts = cell2mat(clusterCount);
clusterLengthNREMs = cell2mat(clusterLengthNREM);

figure
scatterhist(clusterCounts, clusterLengthNREMs)
xlim([0 max(clusterCounts)+2])
