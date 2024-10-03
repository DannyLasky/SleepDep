%% Histogram of nearby NREM bouts
ExcelRows = 2:131;
MatlabRows = ExcelRows - 1;         % Offset by 1 row since 1st row becomes the table header in Matlab
ExcelArr = readtable("Master Sheet Sleep Dep");
fileArr = ExcelArr(MatlabRows,'FilePath');
fileArr = table2array(fileArr);
fileArr = string(fileArr);
outputDir = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Group output";

epochDur = 4;
epochsPerMin = 60 / epochDur;
epochsToMin = 1/epochsPerMin;

NREMLimitMin = 10;     % Manually selected threshhold between short wake and long wake (intra-cluster and inter-cluster)
NREMLimitEpochs = NREMLimitMin * epochsPerMin;

shorterNREMLength   = cell(length(ExcelRows),1);
clusterCount        = cell(length(ExcelRows),1);
clusterEpochCount   = cell(length(ExcelRows),1);
clusterNREMCount    = cell(length(ExcelRows),1);

for fileCount = 1:length(fileArr)
    filePath = fileArr(fileCount);
    [~,currentName] = fileparts(filePath);
    currentPath = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Output 06-07-23\" + currentName;
    cd(currentPath);

    homeoScores = readmatrix('Scores Simple');
    fileNameEDF = strcat(currentName, '.edf');
    [~,titleName]=fileparts(fileNameEDF);
    graphTitle = strrep(titleName,'_',' ');
    output.ID = titleName;

    disp('Finding dwell times and runs, etc.')
    [boutValues, boutLengths, boutStarts] = dwelltime(homeoScores);

%% Change artifact values flanked by wake to wake
    runLoop = 1;
    while runLoop == 1
        artifactValues = find(boutValues == 0);
        artifactFlanked = NaN(length(artifactValues),1);
        for n = 1:length(artifactValues)
            if artifactValues(n) == length(boutStarts)
                runLoop = 0;
            else
                artifactFlanked(n) = boutValues(artifactValues(n)-1) + boutValues(artifactValues(n)+1);
                if artifactFlanked(n) == 2
                    homeoScores(boutStarts(artifactValues(n)):boutStarts(artifactValues(n)) + boutLengths(artifactValues(n)) - 1) = 1;
                else
                    runLoop = 0;
                end
            end
        end
        if isempty(artifactValues)
            runLoop = 0;
        end
        [boutValues, boutLengths, boutStarts] = dwelltime(homeoScores);
    end

    close all

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

    shorterNREMLength{fileCount} = min([prevNREMDistance, nextNREMDistance], [], 2, 'omitnan');

%% Viewing the average length of clusters in epochs and bouts
    invalidNREMFilter = shorterNREMLength{fileCount} > NREMLimitEpochs;
    invalidNREM = NREMIndex(invalidNREMFilter);
    clusterScores = homeoScores;
    
    for n = 1:length(invalidNREM)
        clusterScores(boutStarts(invalidNREM(n)) : boutStarts(invalidNREM(n)) + boutLengths(invalidNREM(n)) - 1) = 1;
    end    

    clusterMatrix = [shorterNREMLength{fileCount}, boutStarts(NREMIndex), currNREMEnd];
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
    clusterStart = find(clusterStartTemp == 1);

    clusterEnd = circshift(clusterStart,-1) - 1;
    clusterEnd(end) = length(clusterMatrix);

    clusterCount{fileCount} = clusterEnd - clusterStart + 1;

    clusterStartNREM = clusterMatrix(clusterStart,2);
    clusterEndNREM = clusterMatrix(clusterEnd,3);
   
    clusterEpochCount{fileCount} = clusterEndNREM - clusterStartNREM + 1;

%% Calculating the number of NREM epochs in each cluster
    for n = 1:length(clusterStartNREM)
        clusterNREMCount{fileCount}(n) = sum(homeoScores(clusterStartNREM(n):clusterEndNREM(n)) == 2);
    end
end

%% Distances between NREM bouts (frequency)
C57SalineNum = 1:30;
C57KainateNum = 31:65;
DBASalineNum = 66:90;
DBAKainateNum = 91:130;

closestNREMByDuration_C57SA = cell2mat(shorterNREMLength(1:30)) * epochsToMin;
closestNREMByDuration_C57KA = cell2mat(shorterNREMLength(31:65)) * epochsToMin;
closestNREMByDuration_DBASA = cell2mat(shorterNREMLength(66:90)) * epochsToMin;
closestNREMByDuration_DBAKA = cell2mat(shorterNREMLength(91:130)) * epochsToMin;

cd(outputDir)

figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 5 4]);
histogram(closestNREMByDuration_C57SA, 0:epochsToMin:15, 'DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineWidth', 1.03);
hold on
histogram(closestNREMByDuration_C57KA, 0:epochsToMin:15, 'DisplayStyle', 'stairs', 'EdgeColor', 'b', 'LineWidth', 1.03);
histogram(closestNREMByDuration_DBASA, 0:epochsToMin:15, 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 1.03);
histogram(closestNREMByDuration_DBAKA, 0:epochsToMin:15, 'DisplayStyle', 'stairs', 'EdgeColor', 'm', 'LineWidth', 1.03);
xline(NREMLimitMin, 'k')
leg{1} = plot(nan, 'k');
leg{2} = plot(nan, 'b');
leg{3} = plot(nan, 'r');
leg{4} = plot(nan, 'm');
hold off
title('Frequency of Durations Between NREM Bouts', 'FontWeight', 'Normal', 'FontSize', 10);
xlabel('Closest NREM Bout (minutes)', 'FontSize', 10);
ylabel('Frequency', 'FontSize', 10);
legend([leg{:}], 'C57 Saline', 'C57 Kainate', 'DBA Saline', 'DBA Kainate', 'FontSize', 10);
exportgraphics(gcf, 'Cluster Frequency Histogram.png', 'Resolution', 300)

%% Distances between NREM bouts (probability)
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 5 4]);
histogram(closestNREMByDuration_C57SA, 0:epochsToMin:15, 'Normalization', 'probability','DisplayStyle', 'stairs', 'EdgeColor', 'k', 'LineWidth', 1.03);
hold on
histogram(closestNREMByDuration_C57KA, 0:epochsToMin:15, 'Normalization', 'probability', 'DisplayStyle', 'stairs', 'EdgeColor', 'b', 'LineWidth', 1.03);
histogram(closestNREMByDuration_DBASA, 0:epochsToMin:15, 'Normalization', 'probability', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 1.03);
histogram(closestNREMByDuration_DBAKA, 0:epochsToMin:15, 'Normalization', 'probability', 'DisplayStyle', 'stairs', 'EdgeColor', 'm', 'LineWidth', 1.03);
xline(NREMLimitMin, 'k')
leg{1} = plot(nan, 'k');
leg{2} = plot(nan, 'b');
leg{3} = plot(nan, 'r');
leg{4} = plot(nan, 'm');
hold off
title('Probability of Durations Between NREM Bouts', 'FontWeight', 'Normal', 'FontSize', 10);
xlabel('Closest NREM Bout (minutes)', 'FontSize', 10);
ylabel('Probability', 'FontSize', 10);
legend([leg{:}], 'C57 Saline', 'C57 Kainate', 'DBA Saline', 'DBA Kainate', 'FontSize', 10);
exportgraphics(gcf, 'Cluster Probability Histogram.png', 'Resolution', 300)

%% Distances between NREM bouts (cumulative probability)
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 5 4]);
cumProb(1,1) = cdfplot(closestNREMByDuration_C57SA);
hold on
cumProb(1,2) = cdfplot(closestNREMByDuration_C57KA);
cumProb(1,3) = cdfplot(closestNREMByDuration_DBASA);
cumProb(1,4) = cdfplot(closestNREMByDuration_DBAKA);
xline(NREMLimitMin, 'k')
hold off

set(cumProb(:,1), 'Color', 'k', 'LineWidth', 1.03)
set(cumProb(:,2), 'Color', 'b', 'LineWidth', 1.03)
set(cumProb(:,3), 'Color', 'r', 'LineWidth', 1.03)
set(cumProb(:,4), 'Color', 'm', 'LineWidth', 1.03)

xlim([0 15])
title('Cumulative Probability of Durations Between NREM Bouts', 'FontWeight', 'Normal', 'FontSize', 10);
xlabel('Closest NREM Bout (minutes)', 'FontSize', 10);
ylabel('Cumulative Probability', 'FontSize', 10);
legend('C57 Saline', 'C57 Kainate', 'DBA Saline', 'DBA Kainate', 'FontSize', 10, 'Location', 'best');
exportgraphics(gcf, 'Cluster Cumulative Probability.png', 'Resolution', 300)

%% Average duration between NREM bouts per animal (boxplots)
closestNREMByDurationAvg = cellfun(@mean,shorterNREMLength) * epochsToMin;
closestNREMByDurationAvg_C57SA = closestNREMByDurationAvg(1:30);
closestNREMByDurationAvg_C57KA = closestNREMByDurationAvg(31:65);
closestNREMByDurationAvg_DBASA = closestNREMByDurationAvg(66:90);
closestNREMByDurationAvg_DBAKA = closestNREMByDurationAvg(91:130);

figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 4 4]);
boxplot_X1 = [ones(length(closestNREMByDurationAvg_C57SA),1); 2*ones(length(closestNREMByDurationAvg_C57KA),1); 3*ones(length(closestNREMByDurationAvg_DBASA),1); 4*ones(length(closestNREMByDurationAvg_DBAKA),1)];
boxplot_Y1 = [closestNREMByDurationAvg_C57SA; closestNREMByDurationAvg_C57KA; closestNREMByDurationAvg_DBASA; closestNREMByDurationAvg_DBAKA];
boxplot(boxplot_Y1, boxplot_X1)
title('Average Durations Between NREM Bouts Per Recording', 'FontWeight', 'Normal', 'FontSize', 10)
xticklabels(["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"])
ylabel('Average Closest NREM Bout (minutes)', 'FontSize', 10)
exportgraphics(gcf, 'Closest NREM Bout Per Recording.png', 'Resolution', 300)

%% Average number of clusters per animal (boxplots)
clusterCountAvg = cellfun(@length, clusterCount);
clusterCountAvg_C57SA = clusterCountAvg(1:30);
clusterCountAvg_C57KA = clusterCountAvg(31:65);
clusterCountAvg_DBASA = clusterCountAvg(66:90);
clusterCountAvg_DBAKA = clusterCountAvg(91:130);

figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 4 4]);
boxplot_X2 = [ones(length(clusterCountAvg_C57SA),1); 2*ones(length(clusterCountAvg_C57KA),1); 3*ones(length(clusterCountAvg_DBASA),1); 4*ones(length(clusterCountAvg_DBAKA),1)];
boxplot_Y2 = [clusterCountAvg_C57SA; clusterCountAvg_C57KA; clusterCountAvg_DBASA; clusterCountAvg_DBAKA];
boxplot(boxplot_Y2, boxplot_X2)
title('Average Number of NREM Clusters Per Recording', 'FontWeight', 'Normal', 'FontSize', 10)
xticklabels(["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"])
ylabel('Number of NREM Clusters', 'FontSize', 10)
exportgraphics(gcf, 'Number of NREM Clusters Per Recording.png', 'Resolution', 300)

%% NREM bouts per cluster (boxplots)
clusterNREMBoutsAvg = cellfun(@mean, clusterCount);
clusterNREMBoutsAvg_C57SA = clusterNREMBoutsAvg(1:30);
clusterNREMBoutsAvg_C57KA = clusterNREMBoutsAvg(31:65);
clusterNREMBoutsAvg_DBASA = clusterNREMBoutsAvg(66:90);
clusterNREMBoutsAvg_DBAKA = clusterNREMBoutsAvg(91:130);

figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 4 4]);
boxplot_X2 = [ones(length(clusterNREMBoutsAvg_C57SA),1); 2*ones(length(clusterNREMBoutsAvg_C57KA),1); 3*ones(length(clusterNREMBoutsAvg_DBASA),1); 4*ones(length(clusterNREMBoutsAvg_DBAKA),1)];
boxplot_Y2 = [clusterNREMBoutsAvg_C57SA; clusterNREMBoutsAvg_C57KA; clusterNREMBoutsAvg_DBASA; clusterNREMBoutsAvg_DBAKA];
boxplot(boxplot_Y2, boxplot_X2)
title('Average NREM Bouts in a Cluster Per Recording', 'FontWeight', 'Normal', 'FontSize', 10)
xticklabels(["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"])
ylabel('NREM Bouts Per Cluster', 'FontSize', 10);
exportgraphics(gcf, 'NREM Bouts in a Cluster Per Recording.png', 'Resolution', 300)

%% Cluster total duration (start NREM to end NREM - boxplots)
clusterDurationAvg = cellfun(@mean, clusterEpochCount) * epochsToMin;
clusterDurationAvg_C57SA = clusterDurationAvg(1:30);
clusterDurationAvg_C57KA = clusterDurationAvg(31:65);
clusterDurationAvg_DBASA = clusterDurationAvg(66:90);
clusterDurationAvg_DBAKA = clusterDurationAvg(91:130);

figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 4 4]);
boxplot_X3 = [ones(length(clusterDurationAvg_C57SA),1); 2*ones(length(clusterDurationAvg_C57KA),1); 3*ones(length(clusterDurationAvg_DBASA),1); 4*ones(length(clusterDurationAvg_DBAKA),1)];
boxplot_Y3 = [clusterDurationAvg_C57SA; clusterDurationAvg_C57KA; clusterDurationAvg_DBASA; clusterDurationAvg_DBAKA];
boxplot(boxplot_Y3, boxplot_X3)
title('Average Cluster Duration Per Recording', 'FontWeight', 'Normal', 'FontSize', 10)
xticklabels(["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"])
ylabel('Cluster Duration (minutes)', 'FontSize', 10);
exportgraphics(gcf, 'Cluster Duration Per Recording.png', 'Resolution', 300)

%% Cluster NREM duration (NREM duration from start NREM to end NREM - boxplots)
clusterNREMCountAvg = cellfun(@mean, clusterNREMCount) * epochsToMin;
clusterNREMDurationAvg_C57SA = clusterNREMCountAvg(1:30);
clusterNREMDurationAvg_C57KA = clusterNREMCountAvg(31:65);
clusterNREMDurationAvg_DBASA = clusterNREMCountAvg(66:90);
clusterNREMDurationAvg_DBAKA = clusterNREMCountAvg(91:130);

figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 4 4]);
boxplot_X4 = [ones(length(clusterNREMDurationAvg_C57SA),1); 2*ones(length(clusterNREMDurationAvg_C57KA),1); 3*ones(length(clusterNREMDurationAvg_DBASA),1); 4*ones(length(clusterNREMDurationAvg_DBAKA),1)];
boxplot_Y4 = [clusterNREMDurationAvg_C57SA; clusterNREMDurationAvg_C57KA; clusterNREMDurationAvg_DBASA; clusterNREMDurationAvg_DBAKA];
boxplot(boxplot_Y4, boxplot_X4)
title('Average Cluster NREM Duration Per Recording', 'FontWeight', 'Normal', 'FontSize', 10)
xticklabels(["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"])
ylabel('Cluster NREM Duration (minutes)', 'FontSize', 10);
exportgraphics(gcf, 'Cluster Duration Per Recording.png', 'Resolution', 300)

%% Group together all NREM cluster length data
clusterNREMBoutsAvg_C57SA_Mn = mean(clusterNREMBoutsAvg_C57SA);
clusterNREMBoutsAvg_C57KA_Mn = mean(clusterNREMBoutsAvg_C57KA);
clusterNREMBoutsAvg_DBASA_Mn = mean(clusterNREMBoutsAvg_DBASA);
clusterNREMBoutsAvg_DBAKA_Mn = mean(clusterNREMBoutsAvg_DBAKA);

clusterNREMDurationAvg_C57SA_Mn = mean(clusterNREMDurationAvg_C57SA);
clusterNREMDurationAvg_C57KA_Mn = mean(clusterNREMDurationAvg_C57KA);
clusterNREMDurationAvg_DBASA_Mn = mean(clusterNREMDurationAvg_DBASA);
clusterNREMDurationAvg_DBAKA_Mn = mean(clusterNREMDurationAvg_DBAKA);

clusterNREMBoutsAvg_C57SA_SEM = std(clusterNREMBoutsAvg_C57SA) / sqrt(length(clusterNREMBoutsAvg_C57SA));
clusterNREMBoutsAvg_C57KA_SEM = std(clusterNREMBoutsAvg_C57KA) / sqrt(length(clusterNREMBoutsAvg_C57KA));
clusterNREMBoutsAvg_DBASA_SEM = std(clusterNREMBoutsAvg_DBASA) / sqrt(length(clusterNREMBoutsAvg_DBASA));
clusterNREMBoutsAvg_DBAKA_SEM = std(clusterNREMBoutsAvg_DBAKA) / sqrt(length(clusterNREMBoutsAvg_DBAKA));

clusterNREMDurationAvg_C57SA_SEM = std(clusterNREMDurationAvg_C57SA) / sqrt(length(clusterNREMDurationAvg_C57SA));
clusterNREMDurationAvg_C57KA_SEM = std(clusterNREMDurationAvg_C57KA) / sqrt(length(clusterNREMDurationAvg_C57KA));
clusterNREMDurationAvg_DBASA_SEM = std(clusterNREMDurationAvg_DBASA) / sqrt(length(clusterNREMDurationAvg_DBASA));
clusterNREMDurationAvg_DBAKA_SEM = std(clusterNREMDurationAvg_DBAKA) / sqrt(length(clusterNREMDurationAvg_DBAKA));

figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 5 5]);
scatter(clusterNREMBoutsAvg_C57SA, clusterNREMDurationAvg_C57SA, 'k', 'MarkerEdgeAlpha', 0.5, 'LineWidth', 0.75)
hold on
scatter(clusterNREMBoutsAvg_C57KA, clusterNREMDurationAvg_C57KA, 'b', 'MarkerEdgeAlpha', 0.5, 'LineWidth', 0.75)
scatter(clusterNREMBoutsAvg_DBASA, clusterNREMDurationAvg_DBASA, 'r', 'MarkerEdgeAlpha', 0.5, 'LineWidth', 0.75)
scatter(clusterNREMBoutsAvg_DBAKA, clusterNREMDurationAvg_DBAKA, 'm', 'MarkerEdgeAlpha', 0.5, 'LineWidth', 0.75)

scatter(clusterNREMBoutsAvg_C57SA_Mn, clusterNREMDurationAvg_C57SA_Mn, 'k', 'filled', 'Marker', 'square')
scatter(clusterNREMBoutsAvg_C57KA_Mn, clusterNREMDurationAvg_C57KA_Mn, 'b', 'filled', 'Marker', 'square')
scatter(clusterNREMBoutsAvg_DBASA_Mn, clusterNREMDurationAvg_DBASA_Mn, 'r', 'filled', 'Marker', 'square')
scatter(clusterNREMBoutsAvg_DBAKA_Mn, clusterNREMDurationAvg_DBAKA_Mn, 'm', 'filled', 'Marker', 'square')

errorbar(clusterNREMBoutsAvg_C57SA_Mn, clusterNREMDurationAvg_C57SA_Mn, clusterNREMBoutsAvg_C57SA_SEM, 'horizontal', 'k', 'LineWidth', 1.05)
errorbar(clusterNREMBoutsAvg_C57SA_Mn, clusterNREMDurationAvg_C57SA_Mn, clusterNREMDurationAvg_C57SA_SEM, 'vertical', 'k', 'LineWidth', 1.05)
errorbar(clusterNREMBoutsAvg_C57KA_Mn, clusterNREMDurationAvg_C57KA_Mn, clusterNREMBoutsAvg_C57KA_SEM, 'horizontal', 'b', 'LineWidth', 1.05)
errorbar(clusterNREMBoutsAvg_C57KA_Mn, clusterNREMDurationAvg_C57KA_Mn, clusterNREMDurationAvg_C57KA_SEM, 'vertical', 'b', 'LineWidth', 1.05)
errorbar(clusterNREMBoutsAvg_DBASA_Mn, clusterNREMDurationAvg_DBASA_Mn, clusterNREMBoutsAvg_DBASA_SEM, 'horizontal', 'r', 'LineWidth', 1.05)
errorbar(clusterNREMBoutsAvg_DBASA_Mn, clusterNREMDurationAvg_DBASA_Mn, clusterNREMDurationAvg_DBASA_SEM, 'vertical', 'r', 'LineWidth', 1.05)
errorbar(clusterNREMBoutsAvg_DBAKA_Mn, clusterNREMDurationAvg_DBAKA_Mn, clusterNREMBoutsAvg_DBAKA_SEM, 'horizontal', 'm', 'LineWidth', 1.05)
errorbar(clusterNREMBoutsAvg_DBAKA_Mn, clusterNREMDurationAvg_DBAKA_Mn, clusterNREMDurationAvg_DBAKA_SEM, 'vertical', 'm', 'LineWidth', 1.05)
hold off

title('Average Cluster NREM Bouts and Duration Per Recording', 'FontWeight', 'Normal', 'FontSize', 10)
xlabel('NREM Bouts Per Cluster', 'FontSize', 10);
ylabel('NREM Duration Per Cluster (minutes)', 'FontSize', 10);
legend('C57 SA', 'C57 KA', 'DBA SA', 'DBA KA', 'FontSize', 10);
