% Script adapted from Sleep_homeostasis_integration_RQ
% Last updated By Danny Lasky, 2024

%% Defining manually within script for now, but could be made into a function to work with DannyDelta
ExcelRow = 71;
tableName = "Master Sheet Sleep Dep";
inputPath = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output round 1";
outputPath = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output round 6";
fullSaveFigs = 1;           % 0 to just save as PDF, 1 to also save as matlab figure and vector-based

epochDur = 4;
epochsPerMin = 60 / epochDur;
epochsToMin = 1/epochsPerMin;

NREMLimitEpochs = 150;      % Manually selected threshhold between short wake and long wake (intra-cluster and inter-cluster)
minimumNREMEpochs = 150;    % Manually selected minimum number of NREM epochs required for a cluster
validMinWakeDur = 150;      % Manually selected mininum number of Wake epochs to preceed a NREM cluster for the rise of delta
NREMLimitMin = NREMLimitEpochs / epochsPerMin;

sleepDepStartEpoch = 901;
sleepDepEndEpoch = 4500;

ExcelArr = readtable("Master Sheet Sleep Dep");
currentFilePath = ExcelArr(ExcelRow, "FilePath");
[~, fileName] = fileparts(string(table2array(currentFilePath)));
fileNameEDF = fileName + '.edf';
inputDir = inputPath + '\' + fileName;
outputDir = outputPath + '\' + fileName;

cd(inputDir);
finalMatrix = readmatrix('Final Table.csv');
homeoScores = readmatrix('Scores Homeostasis.csv');
epochsNumbered = 1:length(homeoScores);

%% Find all consecutive runs of each sleep stage and their durations.
[boutValues, boutLengths, boutStarts] = dwelltime(homeoScores);
close(gcf)
if ~exist(outputDir, 'dir')
    mkdir(outputDir)
end

cd(outputDir)
disp("\nNow running: " + fileName)

%% Define variables
epochCount = transpose(1:length(homeoScores));
deltaPower = finalMatrix(:,1);    % Currently using unnormalized 
graphTitle = strrep(fileName,'_',' ');

%% Change all NREM bouts that occur primarily during sleep deprivation to wake
NoNREMSleepDepScores = homeoScores;
REMfollowsSleepDep = 0;
if ~contains(fileNameEDF,["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
    boutEnds = boutStarts + boutLengths - 1;
    boutEpochs = cell(length(boutStarts), 1);
    epochsWithinSleepDep = nan(length(boutStarts), 1);
    boutsWithinSleepDep = zeros(length(boutStarts), 1);
    for n = 1:length(boutEpochs)
        boutEpochs{n} = boutStarts(n):boutEnds(n);
        epochsWithinSleepDep(n) = sum(boutEpochs{n} >= sleepDepStartEpoch & boutEpochs{n} <= sleepDepEndEpoch);
        if epochsWithinSleepDep(n) / length(boutEpochs{n}) > 0.5
            boutsWithinSleepDep(n) = 1;
            NoNREMSleepDepScores(boutEpochs{n}) = 1;
        end
    end
    lastBoutWithinSleepDep = find(ismember(boutsWithinSleepDep, 1), 1, 'last' );    % Change REM on end of sleep deprivation period to wake
    if boutValues(lastBoutWithinSleepDep + 1) == 3
        NoNREMSleepDepScores(boutEpochs{lastBoutWithinSleepDep + 1}) = 1;
        REMfollowsSleepDep = 1;
        disp("REM follows sleep deprivation period and was changed to wake")
    end
end

%% Find sum of scored artifact remaining and manually change to wake to simplify rise and decline computations
artifactScores = sum(NoNREMSleepDepScores == 0);
disp("Changing " + artifactScores + " artifact scores to wake scores")
homeoScores(homeoScores == 0) = 1;
NoNREMSleepDepScores(NoNREMSleepDepScores == 0) = 1;

%% Find nearest NREM bouts to each NREM bout to determine which are in clusters and which are isolated
NREMIndex = find(boutValues == 2);

prevNREMBout = circshift(NREMIndex,1);
prevNREMEpoch = boutStarts(prevNREMBout) + boutLengths(prevNREMBout) - 1;
prevNREMDistance = boutStarts(NREMIndex) - prevNREMEpoch - 1;
prevNREMDistance(1) = NaN;

nextNREMBout = circshift(NREMIndex,-1);
nextNREMEpoch = boutStarts(nextNREMBout);
currNREMEnd = boutStarts(NREMIndex) + boutLengths(NREMIndex) - 1;
nextNREMDistance = nextNREMEpoch - currNREMEnd - 1;
nextNREMDistance(end) = NaN;

shorterNREMLength = min([prevNREMDistance, nextNREMDistance], [], 2, 'omitnan');

%% Defining clusters based on NREM bouts being close enough to other NREM bouts
clusterMatrix = [shorterNREMLength, boutStarts(NREMIndex), currNREMEnd];
solitaryNREM = clusterMatrix(any(clusterMatrix(:,1) > NREMLimitEpochs, 2), :);
clusterMatrix(any(clusterMatrix(:,1) > NREMLimitEpochs, 2), :) = [];

clusterValue = 1;
clusterMatrix(1,4) = clusterValue;
for n = 2:length(clusterMatrix)
    if clusterMatrix(n,2) - clusterMatrix(n-1,3) - 1 > NREMLimitEpochs
        clusterValue = clusterValue + 1;
    end
    clusterMatrix(n,4) = clusterValue;
end

clusterStartTemp = [1; diff(clusterMatrix(:,4))];
clusterStarts = find(clusterStartTemp == 1);

clusterEnd = circshift(clusterStarts,-1) - 1;
clusterEnd(end) = length(clusterMatrix);

clusterCount = clusterEnd - clusterStarts + 1;

clusterStartNREM = clusterMatrix(clusterStarts,2);
clusterEndNREM = clusterMatrix(clusterEnd,3);

clusterLengthNREM = clusterEndNREM - clusterStartNREM + 1;

%% Solitary NREM bouts must contain 150 NREM epochs or are remarked as wake
solitaryNREMBouts = cell(height(solitaryNREM), 1);
for n = 1:height(solitaryNREM)
    solitaryNREMBouts{n} = solitaryNREM(n,2):solitaryNREM(n,3);
end

solitaryNREMBoutLengths = cellfun(@length, solitaryNREMBouts);
shortSolitaryNREMBouts = solitaryNREMBouts(solitaryNREMBoutLengths < minimumNREMEpochs);
longSolitaryNREMBouts = solitaryNREMBouts(solitaryNREMBoutLengths >= minimumNREMEpochs);
disp("Kept " + length(longSolitaryNREMBouts) + " long solitary NREM bout(s)")

shortSolitaryNREMFull = [shortSolitaryNREMBouts{:}];
minimumDurScores = NoNREMSleepDepScores;
minimumDurScores(shortSolitaryNREMFull) = 1;

%% Excluding select artifact periods in three files
if fileNameEDF == "C57_AnimalCNoM_Saline_SleepDepBaseline_reduced.edf"
    minimumDurScores(901:4000) = NaN;
elseif fileNameEDF == "C57_AnimalCRF_Kainate_SleepDepRecovery_reduced.edf"
    minimumDurScores(901:4100) = NaN;
elseif fileNameEDF == "DBA_AnimalDNoF_Saline_SleepDepBaseline_reduced.edf"
    minimumDurScores(901:4100) = NaN;
end

%% Excluding direct transition to REM in one file
if fileNameEDF == "dba~ sleepdep_animal_2_day_0_reduced.edf"
    minimumDurScores(4500:4800) = 1;
end

%% Cluster must contain 150 NREM epochs or are remarked as wake
for n = 1:length(clusterCount)
    if sum(minimumDurScores(clusterStartNREM(n):clusterEndNREM(n)) == 2) < minimumNREMEpochs
        minimumDurScores(clusterStartNREM(n):clusterEndNREM(n)) = 1;
    end
end

%% Display NREM delta power of all NREM, clustered NREM, and filtered NREM
% Find indices of all NREM bouts that are immediately preceded by WAKE
NREMDeltaAfterWake = cell(4,1);
headerVector = ["Outlier Excluded", "Sleep Dep Excluded", "Minimum Duration"];
artifactEpochsRemoved = nan(3,1);

for n = 1:4
    if n == 1 || n == 2
        [boutValues, boutLengths, boutStarts] = dwelltime(homeoScores);
    elseif n == 3
        [boutValues, boutLengths, boutStarts] = dwelltime(NoNREMSleepDepScores);
    elseif n == 4
        [boutValues, boutLengths, boutStarts] = dwelltime(minimumDurScores);
    end
       
    boutValues(boutValues == 0) = NaN;
    NREMAfterWakeIndex = find((boutValues(2:end) == 2) & (boutValues(2:end) + boutValues(1:end-1) == 3)) + 1;
    wakeBeforeNREMIndex = NREMAfterWakeIndex - 1;
            
    % Get the durations and average NREM delta power
    NREMAfterWakeDur = boutLengths(NREMAfterWakeIndex);
    wakeBeforeNREMDur = boutLengths(wakeBeforeNREMIndex);

    % Make a mask for sections of NREM following wake only
    NREMAfterWakeTrace = zeros(length(homeoScores), 1);
    NREMAfterWakeAvgDelta = zeros(length(NREMAfterWakeIndex), 1);
    NREMAfterWakeMaxDelta = zeros(length(NREMAfterWakeIndex), 1);
    NREMAfterWakeAllDelta = cell(length(NREMAfterWakeIndex), 1);
    
    % Find NREM delta power that follows wake
    for m = 1:length(NREMAfterWakeIndex)
        NREMAfterWakeTrace(boutStarts(NREMAfterWakeIndex(m)):boutStarts(NREMAfterWakeIndex(m)) + NREMAfterWakeDur(m)-1) = 1;
    end

    NREMAfterWakeTrace(length(homeoScores) + 1 : end) = []; % Correct for small mismatch at the end
    NREMDeltaAfterWake{n} = NREMAfterWakeTrace .* deltaPower;

    % Remove NREM delta power outliers prior to determining average and max values
    if n > 1
        NREMDeltaAfterWake{n}(NREMDeltaAfterWake{n} == 0) = NaN;
        ZScores = (NREMDeltaAfterWake{n} - mean(NREMDeltaAfterWake{n}, 'omitnan')) / std(NREMDeltaAfterWake{n}, 'omitnan');
        artifactEpochsRemoved(n) = sum(ZScores > abs(5));
        disp("Removed " + artifactEpochsRemoved(n) + " epochs from " + headerVector(n - 1) + " due to having a delta power Z-score greater than 5")
        ZScoreFilter = ZScores > abs(5);
        NREMDeltaAfterWake{n}(ZScoreFilter) = NaN;

        deltaPower = finalMatrix(:,1);
        deltaPower(ZScoreFilter) = NaN;
    end

    % Calculate average and max delta powers of each bout
    for m = 1:length(NREMAfterWakeIndex)
        NREMAfterWakeAvgDelta(m) = mean(deltaPower((boutStarts(NREMAfterWakeIndex(m)):boutStarts(NREMAfterWakeIndex(m)) + NREMAfterWakeDur(m)-1)), 'omitnan');
        NREMAfterWakeMaxDelta(m) = max(deltaPower((boutStarts(NREMAfterWakeIndex(m)):boutStarts(NREMAfterWakeIndex(m)) + NREMAfterWakeDur(m)-1)));
        NREMAfterWakeAllDelta{m} = deltaPower((boutStarts(NREMAfterWakeIndex(m)):boutStarts(NREMAfterWakeIndex(m)) + NREMAfterWakeDur(m)-1));
    end
end
close all

%% Comparison NREM delta plots
epochsPerHour = epochDur / 3600;
figure('Units', 'Inches', 'OuterPosition', [1 1 9 7]);
t = tiledlayout(4,1);
title(t, graphTitle, 'FontSize', 12)
nexttile
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{1}, 'k')
    set(gca, 'ylim', [0 max(NREMDeltaAfterWake{1})])
    box off     
    ylabel('NREM Delta Power', 'FontSize', 10);
    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'y', 'FaceAlpha', 0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1)
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x, y, 'r', 'FaceAlpha', 0.1)
    end
nexttile
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{2}, 'k')
    set(gca, 'ylim', [0 max(NREMDeltaAfterWake{2})])
    box off     
    ylabel(["Outlier Excluded" ; "NREM Delta Power"], 'FontSize', 10);
    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'y', 'FaceAlpha', 0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1)
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x, y, 'r', 'FaceAlpha', 0.1)
    end
nexttile
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{3}, 'k')
    set(gca, 'ylim', [0 max(NREMDeltaAfterWake{3})])
    box off     
    ylabel(["Sleep Dep Excluded"; "NREM Delta Power"], 'FontSize', 10);
    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'y','FaceAlpha',0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1)
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x, y, 'r', 'FaceAlpha', 0.1)
    end
nexttile
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    set(gca, 'ylim', [0 max(NREMDeltaAfterWake{4})])
    box off     
    xlabel('Zeitgeber Time (hours)', 'FontSize', 10);
    ylabel(["Minimum Duration"; "NREM Delta Power"], 'FontSize', 10);
    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'y', 'FaceAlpha', 0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1)
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x, y, 'r', 'FaceAlpha', 0.1)
    end

exportgraphics(gcf, "Homeostasis Hypnogram Simple.png", 'Resolution', 300)
if fullSaveFigs == 1
    savefig("Homeostasis Hypnogram Simple.fig")
    print("Homeostasis Hypnogram Simple", '-depsc', '-vector');
end

%% Figure 2: Length of previous wake vs peak NREM delta power of following NREM cluster / long solitary bout
validWakeBeforeNREMIndex = find(wakeBeforeNREMDur >= validMinWakeDur);
validWakeBeforeNREMDur = wakeBeforeNREMDur(validWakeBeforeNREMIndex);

validNREMClusterEnds = circshift(validWakeBeforeNREMIndex, -1) - 1;
validNREMClusterEnds(end) = length(NREMAfterWakeIndex);

clusterMaxDeltaAfterWake_Max        = zeros(length(validWakeBeforeNREMDur), 1);
clusterMaxDeltaAfterWake_Range      = cell(length(validWakeBeforeNREMDur), 1);
clusterMaxDeltaAfterWake_Median     = zeros(length(validWakeBeforeNREMDur), 1);

for n = 1:length(clusterMaxDeltaAfterWake_Max)
    clusterAllNREM = cell2mat(NREMAfterWakeAllDelta(validWakeBeforeNREMIndex(n):validNREMClusterEnds(n)));
    clusterMaxDeltaAfterWake_Max(n) = max(clusterAllNREM);
    clusterMaxDeltaAfterWake_Range{n} = maxk(clusterAllNREM, 19);
    clusterMaxDeltaAfterWake_Median(n) = median(clusterMaxDeltaAfterWake_Range{n});
end

% Fit the data (maximum method)
P_Max = polyfit(validWakeBeforeNREMDur, clusterMaxDeltaAfterWake_Max, 1);
riseFit_Max = polyval(P_Max, validWakeBeforeNREMDur);
yResid_Max = clusterMaxDeltaAfterWake_Max - riseFit_Max; 
SSResid_Max = sum(yResid_Max .^ 2);
SSTotal_Max = (length(clusterMaxDeltaAfterWake_Max) - 1) * var(clusterMaxDeltaAfterWake_Max);   
rsq_Max = 1 - SSResid_Max / SSTotal_Max;
slopeByEpoch_Max = P_Max(1);
slopeByHour_Max = slopeByEpoch_Max * epochDur * 60;

% Fit the data (median method)
P_Median = polyfit(validWakeBeforeNREMDur, clusterMaxDeltaAfterWake_Median, 1);
riseFit_Median = polyval(P_Median, validWakeBeforeNREMDur);
yResid_Median = clusterMaxDeltaAfterWake_Median - riseFit_Median; 
SSResid_Median = sum(yResid_Median .^ 2);
SSTotal_Median = (length(clusterMaxDeltaAfterWake_Median) - 1) * var(clusterMaxDeltaAfterWake_Median);   
rsq_Median = 1 - SSResid_Median / SSTotal_Median;
slopeByEpoch_Median = P_Median(1);
slopeByHour_Median = slopeByEpoch_Median * 3600 / epochDur;

figure('Units', 'Inches', 'OuterPosition', [1 1 9 4.25]);
tiledlayout(1,2);
nexttile
    plot(epochsPerHour * validWakeBeforeNREMDur, clusterMaxDeltaAfterWake_Max, 'ko')
    hold on
    plot(epochsPerHour * validWakeBeforeNREMDur, riseFit_Max, 'r')
    title("Rise of Sleep Pressure", 'FontSize', 12, 'FontWeight', 'normal')
    xlabel('Previous Wake Duration (hours)', 'FontSize', 10)
    ylabel(["Maximum Cluster" ; "NREM Delta Power"], 'FontSize', 10)
    box off
    text(0.6, 0.15, {['Slope = ' num2str(slopeByHour_Max, '%.2f')]; ['Y-int = ' num2str(P_Max(2), '%.2f')]; ['R^2 = ' num2str(rsq_Max, '%.2f')]}, 'FontSize', 10, 'Units','normalized')
nexttile
    plot(epochsPerHour * validWakeBeforeNREMDur, clusterMaxDeltaAfterWake_Median, 'ko')
    hold on
    plot(epochsPerHour * validWakeBeforeNREMDur, riseFit_Median, 'r')
    title("Rise of Sleep Pressure", 'FontSize', 12, 'FontWeight', 'normal')
    xlabel('Previous Wake Duration (hours)', 'FontSize', 10)
    ylabel(["Near Max Cluster" ; "NREM Delta Power"], 'FontSize', 10)
    box off
    text(0.6, 0.15, {['Slope = ' num2str(slopeByHour_Median, '%.2f')]; ['Y-int = ' num2str(P_Median(2), '%.2f')]; ['R^2 = ' num2str(rsq_Median, '%.2f')]}, 'FontSize', 10, 'Units','normalized')

exportgraphics(gcf, "Rise of Sleep Pressure.png", 'Resolution', 300)
if fullSaveFigs == 1
    savefig("Rise of Sleep Pressure.fig")
    print("Rise of Sleep Pressure", '-depsc', '-vector');
end

%% Figure 3: Decline of delta
NREMAfterWakeBoutStarts = boutStarts(NREMAfterWakeIndex);
wakeBeforeNREMBoutStarts = boutStarts(wakeBeforeNREMIndex(validWakeBeforeNREMIndex));

clusterStarts = NaN(length(validWakeBeforeNREMIndex), 1);
clusterEnds = NaN(length(validWakeBeforeNREMIndex), 1);
clusterBoutStarts = cell(length(validWakeBeforeNREMIndex), 1);
clusterBoutStartsZeroed = cell(length(validWakeBeforeNREMIndex), 1);
clusterBoutDeltaPowers = cell(length(validWakeBeforeNREMIndex), 1);

% Calcuate the average delta power of each NREM bout in a cluster
for n = 1:length(clusterBoutDeltaPowers)
    clusterStartTemp = NREMAfterWakeBoutStarts > wakeBeforeNREMBoutStarts(n);
    if sum(clusterStartTemp) ~= 0
        clusterStarts(n) = min(NREMAfterWakeBoutStarts(clusterStartTemp));
        if n < length(clusterBoutDeltaPowers)
            clusterEndsTemp = NREMAfterWakeBoutStarts < wakeBeforeNREMBoutStarts(n+1);
            clusterEnds(n) = max(NREMAfterWakeBoutStarts(clusterEndsTemp));
        else
            clusterEnds(n) = max(NREMAfterWakeBoutStarts);
        end
        clusterNREMBouts = NREMAfterWakeBoutStarts >= clusterStarts(n) & NREMAfterWakeBoutStarts <= clusterEnds(n);
        clusterBoutStarts{n} = NREMAfterWakeBoutStarts(clusterNREMBouts);
        clusterBoutStartsZeroed{n} = clusterBoutStarts{n} - clusterBoutStarts{n}(1);
        clusterBoutDeltaPowers{n} = NREMAfterWakeAvgDelta(clusterNREMBouts);
    end
end

% Fit trajectory with an exponential (amp, tau, const)
clusterBoutStartsVector = cat(1, clusterBoutStartsZeroed{:});
clusterBoutDeltaPowersVector = cat(1, clusterBoutDeltaPowers{:});
guess = [10, 500, 20];

figure
fitOptions = optimset('PlotFcns', 'optimplotfval', 'TolX', 1e-25);
[guess, ~] = fminsearch('fit1exp', guess, fitOptions, clusterBoutStartsVector, clusterBoutDeltaPowersVector);
close(gcf)
[declineAmp, declineTau, declineConstant] = deal(guess(1), guess(2), guess(3));
declineFit  =  declineAmp * exp(-clusterBoutStartsVector / declineTau) + declineConstant;

figure('Units', 'Inches', 'OuterPosition', [1 1 4 4.25]);
plot(epochsPerHour * clusterBoutStartsVector, clusterBoutDeltaPowersVector, 'ko')
hold on
plot(epochsPerHour * clusterBoutStartsVector, declineFit, 'ro', 'MarkerFaceColor', 'r')
box off
title('Decline of Sleep Pressure', 'FontSize', 12, 'FontWeight', 'normal')
xlabel('Hours After Entering a Sleep Cluster', 'FontSize', 10)
ylabel('Average Bout NREM Delta Power', 'FontSize', 10)
text(0.6, 0.85, {['Amp = ' num2str(declineAmp, '%.2f')]; ['Tau = ' num2str(epochsPerHour.*declineTau, '%.2f')]; ['Constant = ' num2str(declineConstant, '%.2f')]}, 'FontSize', 10, 'Units','normalized')

exportgraphics(gcf, "Decline of Sleep Pressure.png", 'Resolution', 300)
if fullSaveFigs == 1
    savefig("Decline of Sleep Pressure.fig")
    print("Decline of Sleep Pressure", '-depsc', '-vector');
end

%% Double plot of rise and decline
figure('Units', 'Inches', 'OuterPosition', [1 1 8 4.25]);
tiledlayout(1,2);
nexttile
    plot(epochsPerHour * validWakeBeforeNREMDur, clusterMaxDeltaAfterWake_Median, 'ko')
    hold on
    plot(epochsPerHour * validWakeBeforeNREMDur, riseFit_Median, 'r')
    title("Rise of Sleep Pressure", 'FontSize', 12, 'FontWeight', 'normal')
    xlabel('Previous Wake Duration (hours)', 'FontSize', 10)
    ylabel(["Relative Max Cluster" ; "NREM Delta Power"], 'FontSize', 10)
    box off
    text(0.6, 0.15, {['Slope = ' num2str(slopeByHour_Median, '%.2f')]; ['Y-int = ' num2str(P_Median(2), '%.2f')]; ['R^2 = ' num2str(rsq_Median, '%.2f')]}, 'FontSize', 10, 'Units','normalized')
nexttile
    plot(epochsPerHour * clusterBoutStartsVector, clusterBoutDeltaPowersVector, 'ko')
    hold on
    plot(epochsPerHour * clusterBoutStartsVector, declineFit, 'ro', 'MarkerFaceColor', 'r')
    box off
    title('Decline of Sleep Pressure', 'FontSize', 12, 'FontWeight', 'normal')
    xlabel('Hours After Entering a Sleep Cluster', 'FontSize', 10)
    ylabel('Average Bout NREM Delta Power', 'FontSize', 10)
    text(0.55, 0.85, {['Amp = ' num2str(declineAmp, '%.2f')]; ['Tau = ' num2str(epochsPerHour.*declineTau, '%.2f')]; ['Constant = ' num2str(declineConstant, '%.2f')]}, 'FontSize', 10, 'Units','normalized')

exportgraphics(gcf, "Rise and Decline of Sleep Pressure.png", 'Resolution', 300)
if fullSaveFigs == 1
    savefig("Rise and Decline of Sleep Pressure.fig")
    print("Rise and Decline of Sleep Pressure", '-depsc', '-vector');
end

%% Figure 4: Hypnogram with NREM delta power marked for average and maximum NREM delta power
[~, clusterStartsIndex] = intersect(NREMAfterWakeBoutStarts, clusterStarts);
[~, clusterEndsIndex] = intersect(NREMAfterWakeBoutStarts, clusterEnds);

maxClusterDeltaAtClusterStart = [clusterStarts * epochsPerHour, clusterMaxDeltaAfterWake_Median];
maxBoutDeltaAtClusterEnd = [clusterEnds * epochsPerHour, NREMAfterWakeAvgDelta(clusterEndsIndex)];
riseOfDeltaMatrix = sortrows([maxClusterDeltaAtClusterStart; maxBoutDeltaAtClusterEnd], 1);

figure('Units', 'Inches', 'OuterPosition', [1 1 9 6.5]);
t = tiledlayout(3,1);
title(t, graphTitle, 'FontSize', 12)
nexttile
    plot(epochsPerHour * epochsNumbered, minimumDurScores, 'k');
    hold on
    p1 = plot(epochsPerHour * epochsNumbered, 2 * NREMAfterWakeTrace, 'r+');
    p2 = plot(epochsPerHour * boutStarts(wakeBeforeNREMIndex), 1, 'b+');
    set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
    box off
    ylabel('Sleep Stage', 'FontSize', 10);
    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'y', 'FaceAlpha', 0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1)
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x, y, 'r', 'FaceAlpha', 0.1)
    end
    h = legend([p1 p2(1)], {'NREM After Wake', 'Start of Previous Wake'}, 'FontSize', 10);
    set(h,'Position',[0.763 0.93 0.221 0.0667]);    
nexttile;
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    hold on
    p1 = plot(epochsPerHour * boutStarts(NREMAfterWakeIndex), NREMAfterWakeAvgDelta, 'ro-', 'markerfacecolor', 'r');
    p2 = plot(epochsPerHour * clusterStarts, NREMAfterWakeAvgDelta(clusterStartsIndex), 'co', 'markerfacecolor', 'c');
    ylabel(["Average Bout" ; "NREM Delta Power"], 'FontSize', 10)
    xlim([0,24.5])
    xticks(1:24)    
    yLimit = ylim;
    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'y', 'FaceAlpha', 0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1)
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end
    h = legend([p1 p2(1)], {'Start of Bout', 'Start of Cluster'}, 'FontSize', 10);
    set(h,'Position',[0.763 0.59 0.191 0.0667]);
nexttile;
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    hold on
    plot(epochsPerHour * boutStarts(NREMAfterWakeIndex), NREMAfterWakeMaxDelta, 'ro-', 'markerfacecolor', 'r');
    plot(epochsPerHour * clusterStarts, clusterMaxDeltaAfterWake_Median, 'co', 'markerfacecolor', 'c');
    ylabel(["Maximum NREM" ; "Bout Delta Power"], 'FontSize', 10)
    xlabel("Zeitgeber Time (hours)", 'FontSize', 10)
    xlim([0,24.5])
    xticks(1:24)    
    yLimit = ylim;
    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'y', 'FaceAlpha', 0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'k','FaceAlpha',0.1)
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end

exportgraphics(gcf, "Homeostasis Hypnogram Detailed.png", 'Resolution', 300)   
if fullSaveFigs == 1
    savefig("Homeostasis Hypnogram Detailed.fig")
    print("Homeostasis Hypnogram Detailed", '-depsc', '-vector');
end

%% Figure 5: Reducing the marked NREM delta power to a single panel alongside a hypnogram
figure('Units', 'Inches', 'OuterPosition', [1 1 9 4.5]);
t = tiledlayout(2,1);
title(t, graphTitle, 'FontSize', 12)
nexttile
    plot(epochsPerHour * epochsNumbered, minimumDurScores, 'k');
    hold on
    plot(epochsPerHour * clusterStarts, 2, 'co', 'markerfacecolor', 'c', 'MarkerSize', 5);
    set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
    box off
    yLab1 = ylabel('Sleep Stage', 'FontSize', 10);
    yLabPos = get(yLab1, 'Position');
    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x, y, 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    end
nexttile;
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    hold on
    clusterPlot = plot(epochsPerHour * clusterStarts, clusterMaxDeltaAfterWake_Median, 'co', 'markerfacecolor', 'c', 'MarkerSize', 5);
    boutPlot = plot(epochsPerHour * clusterBoutStarts{1}, clusterBoutDeltaPowers{1}, 'ro', 'markerfacecolor', 'r', 'MarkerSize', 5);         % Marker only for legend    
    for n = 1:length(clusterBoutStarts)
        plot(epochsPerHour * clusterBoutStarts{n}, clusterBoutDeltaPowers{n}, 'ro-', 'markerfacecolor', 'r', 'MarkerSize', 5);
        clusterRiseXVals = epochsPerHour * [(clusterStarts(n) - validWakeBeforeNREMDur(n)), clusterStarts(n)];
        clusterRiseYVals = [clusterMaxDeltaAfterWake_Median(n) - (slopeByHour_Median * (clusterRiseXVals(2) - clusterRiseXVals(1))), clusterMaxDeltaAfterWake_Median(n)];
        plot(clusterRiseXVals, clusterRiseYVals, 'c');
    end
    box off 
    xlabel("Zeitgeber Time (hours)", 'FontSize', 10)
    yLab2 = ylabel("NREM Delta Power", 'FontSize', 10);
    yLab2.Position(1) = -1.449645390070922;
    xlim([0,24.5])
    xticks(1:24)    
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    if ~contains(fileNameEDF, ["baseline", "Baseline", "recovery", "Recovery", "day 0", "Day 0", "day_0", "Day_0"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x, y, 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    end
   h = legend([clusterPlot boutPlot], {'Start of Cluster', 'Start of Bout'}, 'FontSize', 10);
   set(h, 'Position',[0.725 0.9 0.18 0.08]); 

exportgraphics(gcf,strcat("Homeostasis Hypnogram Final.png"), 'Resolution', 300)  
if fullSaveFigs == 1
    savefig("Homeostasis Hypnogram Final.fig")
    print("Homeostasis Hypnogram Final", '-depsc', '-vector');
end

%% Preparing data to be exported
output.ID = fileName;
output.validMinWakeDur                  = validMinWakeDur;          % Epochs
output.validWakeBeforeNREMDur           = validWakeBeforeNREMDur;   % Epochs
output.clusterAllNREM                   = clusterAllNREM;
output.clusterMaxDeltaAfterWake         = clusterMaxDeltaAfterWake_Median; % NREM delta power
output.clusterMaxDeltaAfterWakeRange    = clusterMaxDeltaAfterWake_Range;

output.riseSlopeByEpoch             = slopeByEpoch_Median;          % Slope of fit (epochs on x axis)
output.riseSlopeByHour              = slopeByHour_Median;           % Slope of fit (hours on x axis)
output.riseYIntercept               = P_Median(2);                  % y-intercept of fit
output.riseRsquare                  = rsq_Median;                   % R^2 of fit
output.riseFit                      = riseFit_Median;

output.clusterBoutStartsVector      = clusterBoutStartsVector; 
output.clusterBoutDeltaPowersVector = clusterBoutDeltaPowersVector; 
output.declineAmp                   = declineAmp;
output.declineTau                   = declineTau;
output.declineConstant              = declineConstant;
output.declineFit                   = declineFit; 
output.epochsPerHour                = epochsPerHour;

output.validWakeBeforeNREMIndex     = validWakeBeforeNREMIndex;
output.clusterBoutDeltaPowers       = clusterBoutDeltaPowers;
output.clusterMatrix                = clusterMatrix;
output.clusterCount                 = clusterCount;
output.clusterStarts                = clusterStarts;
output.clusterEnds                  = clusterEnds;
output.artifactEpochsToWake         = artifactScores;
output.longSolitaryNREMBouts        = longSolitaryNREMBouts;
output.REMfollowsSleepDep           = REMfollowsSleepDep;
output.artifactEpochsRemoved        = artifactEpochsRemoved;
output.NREMAfterWakeAvgDelta        = NREMAfterWakeAvgDelta;
output.NREMAfterWakeMaxDelta        = NREMAfterWakeMaxDelta;

output.epochsNumbered               = epochsNumbered;
output.minimumDurScores             = minimumDurScores;
output.clusterBoutStarts            = clusterBoutStarts;
output.NREMDeltaAfterWake           = NREMDeltaAfterWake;

save("Homeostasis Output.mat", 'output', '-v7.3', '-nocompression')