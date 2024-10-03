%% C57 Saline
inputDir = fullfile("P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output round 6", "C57_AnimalCLRF_Saline_SleepDepBaseline_reduced");
load(fullfile(inputDir, "Homeostasis Output"));

outputDir = "P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Group output\Homeostasis Sample Animals";

epochsPerHour           = output.epochsPerHour;
epochsNumbered          = output.epochsNumbered;
minimumDurScores        = output.minimumDurScores;
clusterStarts           = output.clusterStarts;
NREMDeltaAfterWake      = output.NREMDeltaAfterWake;
clusterBoutDeltaPowers  = output.clusterBoutDeltaPowers;
validWakeBeforeNREMDur  = output.validWakeBeforeNREMDur;
clusterMaxDeltaAfterWake = output.clusterMaxDeltaAfterWake;
riseSlopeByHour         = output.riseSlopeByHour;
clusterBoutStarts       = output.clusterBoutStarts;

figure('Units', 'Inches', 'OuterPosition', [1 1 5 3.5]);
t = tiledlayout(2,1);
title(t, "C57 Saline Baseline Day", 'FontSize', 10, 'FontName', 'Calibri')
nexttile
    plot(epochsPerHour * epochsNumbered, minimumDurScores, 'k');
    hold on
    plot(epochsPerHour * clusterStarts, 2, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
    box off
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    yLab1 = ylabel('Sleep Stage', 'FontSize', 8, 'FontName', 'Calibri');
    xlim([0,24.5])
    xticks(0:24)
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
nexttile;
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    hold on
    plot(epochsPerHour * clusterStarts, clusterMaxDeltaAfterWake, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    for n = 1:length(clusterBoutStarts)
        plot(epochsPerHour * clusterBoutStarts{n}, clusterBoutDeltaPowers{n}, 'ro-', 'markerfacecolor', 'r', 'MarkerSize', 4);
        clusterRiseXVals = epochsPerHour * [(clusterStarts(n) - validWakeBeforeNREMDur(n)), clusterStarts(n)];
        clusterRiseYVals = [clusterMaxDeltaAfterWake(n) - (riseSlopeByHour * (clusterRiseXVals(2) - clusterRiseXVals(1))), clusterMaxDeltaAfterWake(n)];
        plot(clusterRiseXVals, clusterRiseYVals, 'c');
    end
    box off 
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    xlabel("Zeitgeber Time (hours)", 'FontSize', 8, 'FontName', 'Calibri')
    yLab2 = ylabel("NREM Delta Power", 'FontSize', 8, 'FontName', 'Calibri');
    xlim([0,24.5])
    ylim([0 150])
    yLab2.Position(1) = yLab1.Position(1);
    xticks(0:24)    
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
cd(outputDir)
exportgraphics(gcf,strcat("C57 Saline Baseline Day Homeostasis.png"), 'Resolution', 300)
savefig("C57 Saline Baseline Day Homeostasis.fig")
print("C57 Saline Baseline Day Homeostasis", '-depsc', '-vector');

%% C57 Kainate
inputDir = fullfile("P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output round 6", "C57~ SEModel_animal_4_baseline_3-10-21_reduced");
load(fullfile(inputDir, "Homeostasis Output"));

epochsPerHour           = output.epochsPerHour;
epochsNumbered          = output.epochsNumbered;
minimumDurScores        = output.minimumDurScores;
clusterStarts           = output.clusterStarts;
NREMDeltaAfterWake      = output.NREMDeltaAfterWake;
clusterBoutDeltaPowers  = output.clusterBoutDeltaPowers;
validWakeBeforeNREMDur  = output.validWakeBeforeNREMDur;
clusterMaxDeltaAfterWake = output.clusterMaxDeltaAfterWake;
riseSlopeByHour         = output.riseSlopeByHour;
clusterBoutStarts       = output.clusterBoutStarts;

figure('Units', 'Inches', 'OuterPosition', [1 1 5 3.5]);
t = tiledlayout(2,1);
title(t, "C57 Kainate Baseline Day", 'FontSize', 10, 'FontName', 'Calibri')
nexttile
    plot(epochsPerHour * epochsNumbered, minimumDurScores, 'k');
    hold on
    plot(epochsPerHour * clusterStarts, 2, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
    box off
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    yLab1 = ylabel('Sleep Stage', 'FontSize', 8, 'FontName', 'Calibri');
    xlim([0,24.5])
    xticks(0:24)
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
nexttile;
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    hold on
    clusterPlot = plot(epochsPerHour * clusterStarts, clusterMaxDeltaAfterWake, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    boutPlot = plot(epochsPerHour * clusterBoutStarts{1}, clusterBoutDeltaPowers{1}, 'ro', 'markerfacecolor', 'r', 'MarkerSize', 4);         % Marker only for legend    
    for n = 1:length(clusterBoutStarts)
        plot(epochsPerHour * clusterBoutStarts{n}, clusterBoutDeltaPowers{n}, 'ro-', 'markerfacecolor', 'r', 'MarkerSize', 4);
        clusterRiseXVals = epochsPerHour * [(clusterStarts(n) - validWakeBeforeNREMDur(n)), clusterStarts(n)];
        clusterRiseYVals = [clusterMaxDeltaAfterWake(n) - (riseSlopeByHour * (clusterRiseXVals(2) - clusterRiseXVals(1))), clusterMaxDeltaAfterWake(n)];
        plot(clusterRiseXVals, clusterRiseYVals, 'c');
    end
    box off 
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    xlabel("Zeitgeber Time (hours)", 'FontSize', 8, 'FontName', 'Calibri')
    yLab2 = ylabel("NREM Delta Power", 'FontSize', 8, 'FontName', 'Calibri');
    xlim([0,24.5])
    ylim([0 150])
    yLab2.Position(1) = yLab1.Position(1);
    xticks(0:24)    
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    leg = legend([clusterPlot boutPlot], {'Start of Cluster', 'Start of Bout'}, 'FontSize', 8, 'FontName', 'Calibri');
    legend('boxoff')
    leg.Position = [0.123, 0.366, 0.192, 0.088];
    leg.ItemTokenSize(1) = 10;
cd(outputDir)
exportgraphics(gcf,strcat("C57 Kainate Baseline Day Homeostasis.png"), 'Resolution', 300)
savefig("C57 Kainate Baseline Day Homeostasis.fig")
print("C57 Kainate Baseline Day Homeostasis", '-depsc', '-vector');

%% DBA Saline
inputDir = fullfile("P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output round 6", "DBA_SleepDep_BaselineDay_F220_reduced");
load(fullfile(inputDir, "Homeostasis Output"));

epochsPerHour           = output.epochsPerHour;
epochsNumbered          = output.epochsNumbered;
minimumDurScores        = output.minimumDurScores;
clusterStarts           = output.clusterStarts;
NREMDeltaAfterWake      = output.NREMDeltaAfterWake;
clusterBoutDeltaPowers  = output.clusterBoutDeltaPowers;
validWakeBeforeNREMDur  = output.validWakeBeforeNREMDur;
clusterMaxDeltaAfterWake = output.clusterMaxDeltaAfterWake;
riseSlopeByHour         = output.riseSlopeByHour;
clusterBoutStarts       = output.clusterBoutStarts;

figure('Units', 'Inches', 'OuterPosition', [1 1 5 3.5]);
t = tiledlayout(2,1);
title(t, "DBA Saline Baseline Day", 'FontSize', 10, 'FontName', 'Calibri')
nexttile
    plot(epochsPerHour * epochsNumbered, minimumDurScores, 'k');
    hold on
    plot(epochsPerHour * clusterStarts, 2, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
    box off
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    yLab1 = ylabel('Sleep Stage', 'FontSize', 8, 'FontName', 'Calibri');
    xlim([0,24.5])
    xticks(0:24)
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
nexttile;
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    hold on
    plot(epochsPerHour * clusterStarts, clusterMaxDeltaAfterWake, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    for n = 1:length(clusterBoutStarts)
        plot(epochsPerHour * clusterBoutStarts{n}, clusterBoutDeltaPowers{n}, 'ro-', 'markerfacecolor', 'r', 'MarkerSize', 4);
        clusterRiseXVals = epochsPerHour * [(clusterStarts(n) - validWakeBeforeNREMDur(n)), clusterStarts(n)];
        clusterRiseYVals = [clusterMaxDeltaAfterWake(n) - (riseSlopeByHour * (clusterRiseXVals(2) - clusterRiseXVals(1))), clusterMaxDeltaAfterWake(n)];
        plot(clusterRiseXVals, clusterRiseYVals, 'c');
    end
    box off 
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    xlabel("Zeitgeber Time (hours)", 'FontSize', 8, 'FontName', 'Calibri')
    yLab2 = ylabel("NREM Delta Power", 'FontSize', 8, 'FontName', 'Calibri');
    xlim([0,24.5])
    ylim([0 150])
    yLab2.Position(1) = yLab1.Position(1);
    xticks(0:24)
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
cd(outputDir)
exportgraphics(gcf,strcat("DBA Saline Baseline Day Homeostasis.png"), 'Resolution', 300)
savefig("DBA Saline Baseline Day Homeostasis.fig")
print("DBA Saline Baseline Day Homeostasis", '-depsc', '-vector');

%% DBA Kainate
inputDir = fullfile("P:\P_Drive_copy\Jones_Maganti_Shared\Sleep Dep\Lasky 2024\Individual output round 6", "dba~ sleepdep_animal_2_day_0_reduced");
load(fullfile(inputDir, "Homeostasis Output"));

epochsPerHour           = output.epochsPerHour;
epochsNumbered          = output.epochsNumbered;
minimumDurScores        = output.minimumDurScores;
clusterStarts           = output.clusterStarts;
NREMDeltaAfterWake      = output.NREMDeltaAfterWake;
clusterBoutDeltaPowers  = output.clusterBoutDeltaPowers;
validWakeBeforeNREMDur  = output.validWakeBeforeNREMDur;
clusterMaxDeltaAfterWake = output.clusterMaxDeltaAfterWake;
riseSlopeByHour         = output.riseSlopeByHour;
clusterBoutStarts       = output.clusterBoutStarts;

figure('Units', 'Inches', 'OuterPosition', [1 1 5 3.5]);
t = tiledlayout(2,1);
title(t, "DBA Kainate Baseline Day", 'FontSize', 10, 'FontName', 'Calibri')
nexttile
    plot(epochsPerHour * epochsNumbered, minimumDurScores, 'k');
    hold on
    plot(epochsPerHour * clusterStarts, 2, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
    box off
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    yLab1 = ylabel('Sleep Stage', 'FontSize', 8, 'FontName', 'Calibri');
    yLabPos = get(yLab1, 'Position');
    xlim([0,24.5])
    xticks(0:24)
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
nexttile;
    plot(epochsPerHour * epochsNumbered, NREMDeltaAfterWake{4}, 'k')
    hold on
    plot(epochsPerHour * clusterStarts, clusterMaxDeltaAfterWake, 'co', 'markerfacecolor', 'c', 'MarkerSize', 4);
    for n = 1:length(clusterBoutStarts)
        plot(epochsPerHour * clusterBoutStarts{n}, clusterBoutDeltaPowers{n}, 'ro-', 'markerfacecolor', 'r', 'MarkerSize', 4);
        clusterRiseXVals = epochsPerHour * [(clusterStarts(n) - validWakeBeforeNREMDur(n)), clusterStarts(n)];
        clusterRiseYVals = [clusterMaxDeltaAfterWake(n) - (riseSlopeByHour * (clusterRiseXVals(2) - clusterRiseXVals(1))), clusterMaxDeltaAfterWake(n)];
        plot(clusterRiseXVals, clusterRiseYVals, 'c');
    end
    box off 
    ax = gca;
    ax.FontSize = 8;
    ax.FontName = 'Calibri';
    xlabel("Zeitgeber Time (hours)", 'FontSize', 8, 'FontName', 'Calibri')
    yLab2 = ylabel("NREM Delta Power", 'FontSize', 8, 'FontName', 'Calibri');
    xlim([0,24.5])
    ylim([0 150])
    yLab2.Position(1) = yLab1.Position(1);
    xticks(0:24)    
    yLimit = ylim;
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x, y, 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none')
cd(outputDir)
exportgraphics(gcf,strcat("DBA Kainate Baseline Day Homeostasis.png"), 'Resolution', 300)
savefig("DBA Kainate Baseline Day Homeostasis.fig")
print("DBA Kainate Baseline Day Homeostasis", '-depsc', '-vector');