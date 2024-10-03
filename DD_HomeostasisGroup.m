% Uses fitting parameters from linear rise of delta and exponential decline of delta to display differences between treatments

%% Defining manually within script for now, but could be made into a function to work with DannyDeltaGroup
outputDir = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Group output\";

justSEM = 1;        % 0 for all figures, 1 for just the SEM group fits

findMax = nan(numGroups,1);
for n = 1:numGroups
    findMax(n) = height(fileNameArr{n});
end
maxAnimals = max(findMax);

%% Prepare matrices
animalID            = nan(maxAnimals, numGroups);
epochsPerHour       = nan(maxAnimals, numGroups);

riseSlopeByHour     = nan(maxAnimals, numGroups);
riseSlopeByEpoch    = nan(maxAnimals, numGroups);
riseYIntercept      = nan(maxAnimals, numGroups);
riseRsquare         = nan(maxAnimals, numGroups);

riseFit                     = cell(maxAnimals, numGroups);
validWakeBeforeNREMDur      = cell(maxAnimals, numGroups);
clusterMaxDeltaAfterWake    = cell(maxAnimals, numGroups);

declineAmp          = nan(maxAnimals, numGroups);
declineTau          = nan(maxAnimals, numGroups);
declineConstant     = nan(maxAnimals, numGroups);

clusterBoutStartsVector = cell(maxAnimals, numGroups);
declineFit              = cell(maxAnimals, numGroups);

%% Read in data
for n = 1:numGroups
    for m = 1:length(fileNameArr{n})
        inputDir = fullfile("P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output round 6", strcat(fileNameArr{n}(m)));
        load(fullfile(inputDir, "Homeostasis Output"));
        
        animalID(m,n)           = output.ID;
        epochsPerHour(m,n)      = output.epochsPerHour;

        riseSlopeByEpoch(m,n)   = output.riseSlopeByEpoch;
        riseSlopeByHour(m,n)    = output.riseSlopeByHour;
        riseYIntercept(m,n)     = output.riseYIntercept;
        riseRsquare(m,n)        = output.riseRsquare;
        
        riseFit{m,n}                    = output.riseFit;
        validWakeBeforeNREMDur{m,n}     = output.validWakeBeforeNREMDur;
        clusterMaxDeltaAfterWake{m,n}   = output.clusterMaxDeltaAfterWake;

        declineAmp(m,n)         = output.declineAmp;
        declineTau(m,n)         = output.declineTau;
        declineConstant(m,n)    = output.declineConstant;

        clusterBoutStartsVector{m,n}    = output.clusterBoutStartsVector;
        declineFit{m,n}                 = output.declineFit;
    end
end

cd(outputDir)
swarmX = [ones(maxAnimals, 1), 2*ones(maxAnimals, 1), 3*ones(maxAnimals, 1), 4*ones(maxAnimals, 1)];

%% Figure 1: boxplots of rise of delta power slope
if justSEM ~= 1
    figure('Units', 'Inches', 'OuterPosition', [1 1 4 4]);
    boxplot(riseSlopeByHour, 'Color', 'k')
    hold on
    swarmchart(swarmX, riseSlopeByHour, 'r')
    yline(0, 'b')
    title(graphTitle + " Rise of Sleep Pressue Slope", 'FontSize', 10, 'FontWeight', 'normal')
    ylabel('Slope (NREM Delta / Hours of Wake)')
    xticklabels(groupNames)
    exportgraphics(gcf, "Rise of Delta Slope " + graphTitle + ".png", 'Resolution', 300)
    
    %% Figure 2: boxplots of rise of delta power y-intercept
    figure('Units', 'Inches', 'OuterPosition', [1 1 4 4]);
    boxplot(riseYIntercept, 'Color', 'k')
    hold on
    swarmchart(swarmX, riseYIntercept, 'r')
    yline(0, 'b')
    title(graphTitle + " Rise of Sleep Pressue Y-intercept", 'FontSize', 10, 'FontWeight', 'normal')
    ylabel('Y-intecept (NREM Delta)')
    xticklabels(groupNames)
    exportgraphics(gcf, "Rise of Delta Y-intercept " + graphTitle + ".png", 'Resolution', 300)
    
    %% Figure 3: boxplots of rise of delta power R-squared
    figure('Units', 'Inches', 'OuterPosition', [1 1 4 4]);
    boxplot(riseRsquare, 'Color', 'k')
    hold on
    swarmchart(swarmX, riseRsquare, 'r')
    yline(0, 'b')
    title(graphTitle + " Rise of Sleep Pressue R-squared", 'FontSize', 10, 'FontWeight', 'normal')
    ylabel('Rise of Delta R-squared')
    xticklabels(groupNames)
    exportgraphics(gcf, "Rise of Delta R-squared " + graphTitle + ".png", 'Resolution', 300)
    
    %% Figure 4: boxplots of decline of delta power amplitude
    figure('Units', 'Inches', 'OuterPosition', [1 1 4 4]);
    boxplot(declineAmp, 'Color', 'k')
    hold on
    swarmchart(swarmX, declineAmp, 'r')
    ylim([-50 100])
    title(graphTitle + " Decline of Sleep Pressue Amplitude", 'FontSize', 10, 'FontWeight', 'normal')
    ylabel('Amplitude (NREM Delta)')
    xticklabels(groupNames)
    exportgraphics(gcf, "Decline of Delta Amplitude " + graphTitle + ".png", 'Resolution', 300)
    
    %% Figure 5: boxplots of decline of delta power tau
    figure('Units', 'Inches', 'OuterPosition', [1 1 4 4]);
    boxplot(declineTau, 'Color', 'k')
    hold on
    swarmchart(swarmX, declineTau, 'r')
    ylim([0 5000])
    title(graphTitle + " Decline of Sleep Pressue Tau", 'FontSize', 10, 'FontWeight', 'normal')
    ylabel('Amplitude (NREM Delta)')
    xticklabels(groupNames)
    exportgraphics(gcf, "Decline of Delta Tau " + graphTitle + ".png", 'Resolution', 300)
    
    %% Figure 6: boxplots of decline of delta power constant
    figure('Units', 'Inches', 'OuterPosition', [1 1 4 4]);
    boxplot(declineConstant, 'Color', 'k')
    hold on
    swarmchart(swarmX, declineConstant, 'r')
    ylim([-50 100])
    title(graphTitle + " Decline of Sleep Pressue Constant", 'FontSize', 10, 'FontWeight', 'normal')
    ylabel('Amplitude (NREM Delta)')
    xticklabels(groupNames)
    exportgraphics(gcf, "Decline of Delta Constant " + graphTitle + ".png", 'Resolution', 300)
    
    %% Figure 7: displaying group average rise lines with individual animals
    xValsHr = 0:3;
    yRiseMn = cell(numGroups, 1);
    yRiseSEM = nan(numGroups, length(xValsHr));
    for n = 1:numGroups
        yRiseMn{n} = mean(riseSlopeByHour(:,n), 'omitnan') * xValsHr + mean(riseYIntercept(:,n), 'omitnan');
        yRiseSEM(n,:) = std(riseSlopeByHour(:,n), 'omitnan') / sqrt(sum(~isnan(riseSlopeByHour(:,n))));
    end
    
    figure('Units', 'Inches', 'OuterPosition', [1 1 6.5 6.5]);
    for n = 1:numGroups
        nexttile
        for m = 1:length(fileNameArr{n})
            plot(epochsPerHour(m,n) * validWakeBeforeNREMDur{m,n}, riseFit{m,n}, 'k')
            hold on
        end
        plot(xValsHr, yRiseMn{n}, 'r', 'LineWidth', 1.5)
        box off
        xlim([0 3])
        ylim([0 150])
        title(groupNames(n), 'FontSize', 10, 'FontWeight', 'normal')
        xlabel('Previous Wake Duration (hours)', 'FontSize', 10)
        ylabel("Max Cluster NREM Delta Power", 'FontSize', 10)
    end
    exportgraphics(gcf, "Rise of Sleep Pressure Collective Fits " + graphTitle + ".png", 'Resolution', 300)

    %% Figure 8: displaying group average decline lines with individual animals
    figure('Units', 'Inches', 'OuterPosition', [1 1 6.5 6.5]);
    for n = 1:numGroups
        nexttile
        for m = 1:length(fileNameArr{n})
            plot(xValsEpochToHour, yDeclineVals{n}(m,:), 'k')
            hold on
        end
        plot(xValsEpochToHour, yDeclineMn(n,:), 'r', 'LineWidth', 1.5)
        box off
        xlim([0 3])
        ylim([0 70])
        title(groupNames(n), 'FontSize', 10, 'FontWeight', 'normal')
        xlabel('Hours After Entering a Sleep Cluster', 'FontSize', 10)
        ylabel('Average Bout NREM Delta Power', 'FontSize', 10)
    end
    exportgraphics(gcf, "Decline of Sleep Pressure Collective Fits " + graphTitle + ".png", 'Resolution', 300)
end

%% Figure 9: compute the spread of y-values at each epoch, then compute the rise mean and SEM to get truly representative error bars
xValsEpoch = 0:2700;
xValsEpochToHour = xValsEpoch / 900;
yRiseValsTemp   = NaN(maxAnimals, length(xValsEpoch));
yRiseMnEpoch   = NaN(numGroups, length(xValsEpoch));
yRiseSEMEpoch  = NaN(numGroups, length(xValsEpoch));
for n = 1:numGroups
    for m = 1:length(fileNameArr{n})
        yRiseValsTemp(m,:) = riseSlopeByEpoch(m,n) * xValsEpoch + riseYIntercept(m,n);
    end
    yRiseMnEpoch(n,:) = mean(yRiseValsTemp, 'omitnan');
    yRiseSEMEpoch(n,:) = std(yRiseValsTemp, 'omitnan') / sqrt(sum(~isnan(yRiseValsTemp(:,1))));
end

figure('Units', 'Inches', 'OuterPosition', [1 1 3 3]);
shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(1,:), yRiseSEMEpoch(1,:), 'LineProps', {'color', [0.35 0.76 0.94]})
hold on
shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(2,:), yRiseSEMEpoch(2,:), 'LineProps', {'color', [0.22 0.46 0.57]})
shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(3,:), yRiseSEMEpoch(3,:), 'LineProps', {'color', [0.97 0.75 0.32]})
shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(4,:), yRiseSEMEpoch(4,:), 'LineProps', {'color', [0.61 0.37 0.20]})
box off
xlim([0 3])
ylim([0 120])
title("Change in Sleep Pressure During Wake", 'FontSize', 10, 'FontWeight', 'normal')
xlabel('Previous Wake Duration (hours)', 'FontSize', 10)
ylabel("Near Max Cluster NREM Delta Power", 'FontSize', 10)
legend(["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"], 'FontSize', 10, 'NumColumns', 2, 'Location', 'south')
exportgraphics(gcf, "Rise of Sleep Pressure SEM Fits " + graphTitle + ".png", 'Resolution', 300)

%% Compute values for each decline line at every epoch (fit  =  amp .* exp(-x./tau) + const)
yDeclineValsTemp = NaN(maxAnimals, length(xValsEpoch));
yDeclineVals = cell(numGroups, 1);
yDeclineMn = NaN(numGroups, length(xValsEpoch));
yDeclineSEM = NaN(numGroups, length(xValsEpoch));
for n = 1:numGroups
    for m = 1:length(fileNameArr{n})
        yDeclineValsTemp(m,:) = declineAmp(m,n) * exp(-xValsEpoch / declineTau(m,n)) + declineConstant(m,n);
    end
    yDeclineVals{n} = yDeclineValsTemp;
    yDeclineMn(n,:) = mean(yDeclineValsTemp, 'omitnan');
    yDeclineSEM(n,:) = std(yDeclineValsTemp, 'omitnan') / sqrt(sum(~isnan(yDeclineValsTemp(:,1))));
end

%% Figure 10: compute the spread of y-values at each epoch, then compute the decline mean and SEM to get truly representative error bars
figure('Units', 'Inches', 'OuterPosition', [1 1 3 3]);
shadedErrorBar(xValsEpochToHour, yDeclineMn(1,:), yDeclineSEM(1,:), 'LineProps', {'color', [0.35 0.76 0.94]})
hold on
shadedErrorBar(xValsEpochToHour, yDeclineMn(2,:), yDeclineSEM(2,:), 'LineProps', {'color', [0.22 0.46 0.57]})
shadedErrorBar(xValsEpochToHour, yDeclineMn(3,:), yDeclineSEM(3,:), 'LineProps', {'color', [0.97 0.75 0.32]})
shadedErrorBar(xValsEpochToHour, yDeclineMn(4,:), yDeclineSEM(4,:), 'LineProps', {'color', [0.61 0.37 0.20]})
box off
xlim([0 3])
ylim([0 60])
title("Change in Sleep Pressure During Sleep", 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Calibri')
xlabel('Hours After Entering a Sleep Cluster', 'FontSize', 10, 'FontName', 'Calibri')
ylabel('Average Bout NREM Delta Power', 'FontSize', 10, 'FontName', 'Calibri')
exportgraphics(gcf, "Decline of Sleep Pressure SEM Fits " + graphTitle + ".png", 'Resolution', 300)

%% Figure 11: Publication-quality rise and decline figure
if graphTitle == "All Sleep Deprivation Days"
   graphTitle = "Sleep Deprivation Days";
end

figure('Units', 'Inches', 'OuterPosition', [1 1 2.5 5]);
t = tiledlayout(2,1);
title(t, graphTitle, 'FontSize', 10, 'FontName', 'Calibri')
nexttile
    shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(1,:), yRiseSEMEpoch(1,:), 'LineProps', {'color', [0.35 0.76 0.94], 'LineWidth', 1.1})
    hold on
    shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(2,:), yRiseSEMEpoch(2,:), 'LineProps', {'color', [0.16 0.35 0.43], 'LineWidth', 1.1})
    shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(3,:), yRiseSEMEpoch(3,:), 'LineProps', {'color', [0.97 0.75 0.32], 'LineWidth', 1.1})
    shadedErrorBar(xValsEpochToHour, yRiseMnEpoch(4,:), yRiseSEMEpoch(4,:), 'LineProps', {'color', [0.61 0.37 0.20], 'LineWidth', 1.1})
    box off
    yyaxis right
    ylim([0 110])
    yticks([0 20 40 60 80 100])
    yyaxis left
    xlim([0 3])
    ylim([0 110])
    yticks([0 20 40 60 80 100])
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    ax.YAxis(2).Color = [0 0 0];
    title("Sleep Pressure Change During Wake", 'FontSize', 8, 'FontWeight', 'normal', 'FontName', 'Calibri')
    xlabel('Previous Wake Duration (hours)', 'FontSize', 8, 'FontName', 'Calibri')
    yLab1 = ylabel("Cluster Near-max NREM Delta Power", 'FontSize', 8, 'FontName', 'Calibri');
    if graphTitle == "Baseline Day"
        leg = legend(["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"], 'FontSize', 8, 'FontName', 'Calibri', 'NumColumns', 2, 'Location', 'southeast');
        leg.Position = [0.192,0.577, 0.680, 0.080];
        legend('boxoff')
        leg.ItemTokenSize = [12, 12];
    end
nexttile
    shadedErrorBar(xValsEpochToHour, yDeclineMn(1,:), yDeclineSEM(1,:), 'LineProps', {'color', [0.35 0.76 0.94], 'LineWidth', 1.1})
    hold on
    shadedErrorBar(xValsEpochToHour, yDeclineMn(2,:), yDeclineSEM(2,:), 'LineProps', {'color', [0.16 0.35 0.43], 'LineWidth', 1.1})
    shadedErrorBar(xValsEpochToHour, yDeclineMn(3,:), yDeclineSEM(3,:), 'LineProps', {'color', [0.97 0.75 0.32], 'LineWidth', 1.1})
    shadedErrorBar(xValsEpochToHour, yDeclineMn(4,:), yDeclineSEM(4,:), 'LineProps', {'color', [0.61 0.37 0.20], 'LineWidth', 1.1})
    box off
    yyaxis right
    ylim([0 50])
    yyaxis left
    xlim([0 3])
    ylim([0 50])
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    ax.YAxis(2).Color = [0 0 0];
    title("Sleep Pressure Change During Sleep", 'FontSize', 8, 'FontWeight', 'normal', 'FontName', 'Calibri')
    xlabel('Duration in Sleep Cluster (hours)', 'FontSize', 8, 'FontName', 'Calibri')
    yLab2 = ylabel('Bout Average NREM Delta Power', 'FontSize', 8, 'FontName', 'Calibri');
    yLab2.Position(1) = yLab1.Position(1);
exportgraphics(gcf, graphTitle + " Rise and Decline.png", 'Resolution', 300)
savefig(graphTitle + " Rise and Decline.fig")
print(graphTitle + " Rise and Decline", '-depsc', '-vector');