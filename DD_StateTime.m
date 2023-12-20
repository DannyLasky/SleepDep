function [stateTable] = DD_StateTime(fileNameEDF,justScores,epochLength)

% Works with DannyDelta_v8.m to produce hourly sleep state graphs for Wake, NREM and REM
% Last updated 9/15/22, Danny Lasky

%% Separating the scores into their separate states
wakeFilter = justScores	== 1;
NREMFilter = justScores	== 2;
REMFilter = justScores	== 3;
artFilter = justScores  == 0;

wakeEpochs = justScores;
wakeEpochs((wakeFilter == 0),:) = NaN;

NREMEpochs = justScores;
NREMEpochs((NREMFilter == 0),:) = NaN;

REMEpochs = justScores;
REMEpochs((REMFilter == 0),:) = NaN;

baseEpochs = justScores;
baseEpochs((artFilter == 1),:) = NaN;

%% Chunking the states into hour long bouts
hourlyEpochs = 3600/epochLength;
dailyEpochs = hourlyEpochs * 24;

startChunk = 1:hourlyEpochs:dailyEpochs;
endChunk = hourlyEpochs:hourlyEpochs:dailyEpochs;

wakeHourly = nan(24,1);
NREMHourly = nan(24,1);
REMHourly  = nan(24,1);
baseHourly = nan(24,1);

for n = 1:24
    wakeHourly(n) = nnz(~isnan(wakeEpochs(startChunk(n):endChunk(n))));
    NREMHourly(n) = nnz(~isnan(NREMEpochs(startChunk(n):endChunk(n))));
    REMHourly(n)  = nnz(~isnan(REMEpochs(startChunk(n):endChunk(n))));
    baseHourly(n) = nnz(~isnan(baseEpochs(startChunk(n):endChunk(n))));
end

%% Converting to percentage time in each state by dividing by number of non-artifact epochs in the hour
wakeNorm = wakeHourly./baseHourly * 100;
NREMNorm = NREMHourly./baseHourly * 100;
REMNorm  = REMHourly./baseHourly  * 100;

[~,titleName]=fileparts(fileNameEDF);

%% Output matrix
stateMatrix = [wakeHourly,NREMHourly,REMHourly,baseHourly,wakeNorm,NREMNorm,REMNorm];

stateTable = array2table(stateMatrix,'VariableNames',{'Wake Hourly', 'NREM Hourly', 'REM Hourly', 'Base Hourly', ...
        'Wake Norm', 'NREM Norm' 'REM Norm'});

writetable(stateTable, 'State Table.csv')
    
%% Graphing
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 14 11]);
s1 = subplot(3,1,1);
    plot(1:24,wakeNorm,'LineWidth', 2);
    graphTitle = strrep(titleName,'_',' ');
    title(graphTitle, 'FontSize', 18)
    ylabel('Wake (%)', 'FontSize', 14);

    xlim([0,24.5]);
    xticks(1:24)
    %ylim([0.5,2]);         %If making yAxis equal across days
    ylim tight              %If generating automatically
    yLimit = ylim;
    s1.XAxis.FontSize = 12;
    s1.YAxis.FontSize = 12;

    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'y','FaceAlpha',0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'k','FaceAlpha',0.1)

    if 0 == contains(fileNameEDF,["baseline","Baseline","recovery","Recovery"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end

s2 = subplot(3,1,2);
    plot(1:24,NREMNorm,'LineWidth', 2);
    ylabel('NREM (%)', 'FontSize', 14);

    xlim([0,24.5])
    xticks(1:24)
    %ylim([0.5,2]);         %If making yAxis equal across days
    ylim tight              %If generating automatically
    yLimit = ylim;
    s2.XAxis.FontSize = 12;
    s2.YAxis.FontSize = 12;

    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'y','FaceAlpha',0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'k','FaceAlpha',0.1)

    if 0 == contains(fileNameEDF,["baseline","Baseline","recovery","Recovery"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end

s3 = subplot(3,1,3);
    plot(1:24,REMNorm,'LineWidth', 2);
    xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
    ylabel('REM (%)', 'FontSize', 14);

    xlim([0,24.5])
    xticks(1:24)
    %ylim([0.5,2]);         %If making yAxis equal across days
    ylim tight              %If generating automatically
    yLimit = ylim;
    s3.XAxis.FontSize = 12;
    s3.YAxis.FontSize = 12;

    x = [0 12 12 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'y','FaceAlpha',0.1)
    x = [12 24.5 24.5 12];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'k','FaceAlpha',0.1)

    if 0 == contains(fileNameEDF,["baseline","Baseline","recovery","Recovery"])
        x = [1 5 5 1];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end

saveas(gcf, 'State Time.png')
