function DD_StateTimeGroup(fileArr, numGroups, inputDir, outputDir, groupNames, graphTitle, colorCodes)

% Works with DannyDelta.m to produce graphs of both delta and gamma across multiple treatments
% Produces a graph with points made hourly with SEM error bars
% Last updated 9/16/2022, Danny Lasky

%% Create treatment matrices
wakeMatrix = cell(numGroups,1);
NREMMatrix = cell(numGroups,1);
REMMatrix  = cell(numGroups,1);

for n = 1:numGroups
    wakeMatrix{n} = zeros(11,length(fileArr{n}));
    NREMMatrix{n} = zeros(11,length(fileArr{n}));
    REMMatrix{n}  = zeros(11,length(fileArr{n}));
    for m = 1:height(fileArr{n})
        currentFile = fileArr{n}{m};
        tempDir = fullfile(inputDir,currentFile);
        cd(tempDir)
        stateMatrixTemp = readmatrix('State Table.csv');
        for p = 1:11
            wakeMatrix{n}(p,m) = mean(stateMatrixTemp(2*p:2*p+1, 5));
            NREMMatrix{n}(p,m) = mean(stateMatrixTemp(2*p:2*p+1, 6));
            REMMatrix{n}(p,m)  = mean(stateMatrixTemp(2*p:2*p+1, 7));
        end
    end
end

%% Find means and standard error of the means of groups
wakeMeansSEMs = cell(numGroups,1);
NREMMeansSEMs = cell(numGroups,1);
REMMeansSEMs  = cell(numGroups,1);

for n = 1:numGroups
    wakeMeansSEMs{n} = zeros(11,2);
    NREMMeansSEMs{n} = zeros(11,2);
    REMMeansSEMs{n}  = zeros(11,2);
    for m = 1:11
        wakeMeansSEMs{n}(m,1) = mean(wakeMatrix{n}(m,:), 'omitnan');
        wakeMeansSEMs{n}(m,2) =  std(wakeMatrix{n}(m,:), 'omitnan')/sqrt(sum(~isnan((wakeMatrix{n}(m,:)))));
        NREMMeansSEMs{n}(m,1) = mean(NREMMatrix{n}(m,:), 'omitnan');
        NREMMeansSEMs{n}(m,2) =  std(NREMMatrix{n}(m,:), 'omitnan')/sqrt(sum(~isnan((NREMMatrix{n}(m,:)))));
        REMMeansSEMs{n}(m,1)  = mean(REMMatrix{n}(m,:),  'omitnan');
        REMMeansSEMs{n}(m,2)  =  std(REMMatrix{n}(m,:),  'omitnan')/sqrt(sum(~isnan((REMMatrix{n}(m,:)))));
    end
end

%% Create an output table and save it
cd(outputDir)
loopTable = table(nan(11,1),'VariableNames',{'Remove'});

for n = 1:numGroups
    addTable = splitvars(table(wakeMeansSEMs{n}));
    addTable.Properties.VariableNames = [strcat("Mean ",groupNames(n)," Wake"),strcat("SEM ",groupNames(n)," Wake")];
    loopTable = [loopTable, addTable];

    addTable = splitvars(table(NREMMeansSEMs{n}));
    addTable.Properties.VariableNames = [strcat("Mean ",groupNames(n)," NREM"),strcat("SEM ",groupNames(n)," NREM")];
    loopTable = [loopTable, addTable];
    
    addTable = splitvars(table(REMMeansSEMs{n}));
    addTable.Properties.VariableNames = [strcat("Mean ",groupNames(n)," REM"),strcat("SEM ",groupNames(n)," REM")];
    loopTable = [loopTable, addTable];
end

for n = 1:numGroups
    addTable = splitvars(table(wakeMatrix{n}));
    addTable.Properties.VariableNames = strcat(fileArr{n}," Wake");
    loopTable = [loopTable, addTable];

    addTable = splitvars(table(NREMMatrix{n}));
    addTable.Properties.VariableNames = strcat(fileArr{n}," NREM");
    loopTable = [loopTable, addTable];

    addTable = splitvars(table(REMMatrix{n}));
    addTable.Properties.VariableNames = strcat(fileArr{n}," REM");
    loopTable = [loopTable, addTable];
end

finalTable = loopTable(:,2:end);

writetable(finalTable, strcat(graphTitle, " Sleep States.csv"))

%% Graph output 
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 6.5 13]);
subplot(3,1,1)
    hold on
    p = cell(1,numGroups);
    for n = 1:numGroups
        p{n} = plot(1:11,wakeMeansSEMs{n}(1:11,1),'LineWidth',1.5,'Color',colorCodes(n));
        errorbar(1:11,wakeMeansSEMs{n}(1:11,1),wakeMeansSEMs{n}(1:11,2),'LineWidth',1.5,'LineStyle', ...
            'None','Color',colorCodes(n));
    end
    set(gca,'FontSize',12)
    if graphTitle == "Baseline Day"
        ylabel(strcat('Wake (%)'), 'FontSize', 14);
    end
    xlim([0,11.5]);
    ylim([-20,100]);        % If making yAxis equal across days
    %ylim tight             % If generating automatically
    yLimit = ylim;
    xticks(1:11)
    xticklabels({'2–3','4–5', '6–7', '8–9', '10–11', '12–13', '14–15', '16–17', '18–19', '20–21', '22–23'})
    title(strcat(graphTitle), 'FontSize', 18)
    yticks(0:20:100)
    yticklabels({'0', '20', '40', '60', '80', '100'})
    yline(0)

    x = [0 5.5 5.5 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'y','FaceAlpha',0.1)
    x = [5.5 11.5 11.5 5.5];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'k','FaceAlpha',0.1)

    if 0 == contains(graphTitle,["baseline","Baseline","recovery","Recovery"])
        x = [0 2 2 0];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end
    
    if graphTitle == "Baseline Day"
        if length(colorCodes) == 4
            leg = legend([p{1} p{2} p{3} p{4}], groupNames, 'FontSize', 12, 'NumColumns', 2);
            leg.ItemTokenSize = [15, 15];
        elseif length(colorCodes) == 5
            leg = legend([p{1} p{2} p{3} p{4} p{5}], groupNames, 'FontSize', 12, 'NumColumns', 2, 'Location', 'Best');
            leg.ItemTokenSize = [15, 15];
        end
        pos = get(leg, 'Position');
        posx = 0.5;
        posy = 0.75;
        set(leg, 'Position', [posx posy pos(3) pos(4)]);
        
        annotation('textbox', [.135 .82 .1 .1], 'String', 'Light', 'FontSize', 12, 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'Margin', 1.5);
        annotation('textbox', [.503 .82 .1 .1], 'String', 'Dark', 'FontSize', 12, 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'Margin', 1.5);
    end

subplot(3,1,2)
    hold on
    for n = 1:numGroups
        plot(1:11,NREMMeansSEMs{n}(1:11,1),'LineWidth',1.5,'Color',colorCodes(n));
        errorbar(1:11,NREMMeansSEMs{n}(1:11,1),NREMMeansSEMs{n}(1:11,2),'LineWidth',1.5,'LineStyle', ...
            'None','Color',colorCodes(n));
    end
    set(gca,'FontSize',12)
    if graphTitle == "Baseline Day"
        ylabel(strcat('NREM (%)'), 'FontSize', 14);
    end
    xlim([0,11.5]);
    ylim([-20,100]);        % If making yAxis equal across days
    %ylim tight             % If generating automatically
    yLimit = ylim;
    xticks(1:11)
    xticklabels({'2–3','4–5', '6–7', '8–9', '10–11', '12–13', '14–15', '16–17', '18–19', '20–21', '22–23'})
    yticks(0:20:100)
    yticklabels({'0', '20', '40', '60', '80', '100'})
    yline(0)

    x = [0 5.5 5.5 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'y','FaceAlpha',0.1)
    x = [5.5 11.5 11.5 5.5];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'k','FaceAlpha',0.1)

    if 0 == contains(graphTitle,["baseline","Baseline","recovery","Recovery"])
        x = [0 2 2 0];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end
    
subplot(3,1,3)
    hold on
    for n = 1:numGroups
        plot(1:11,REMMeansSEMs{n}(1:11,1),'LineWidth',1.5,'Color',colorCodes(n));
        errorbar(1:11,REMMeansSEMs{n}(1:11,1),REMMeansSEMs{n}(1:11,2),'LineWidth',1.5,'LineStyle', ...
            'None','Color',colorCodes(n));
    end
    set(gca,'FontSize',12)
    xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
    if graphTitle == "Baseline Day"
        ylabel(strcat('REM (%)'), 'FontSize', 14);
    end
    xlim([0,11.5]);
    ylim([-3,15]);         % If making yAxis equal across days
    %ylim tight           % If generating automatically
    yLimit = ylim;
    xticks(1:11)
    xticklabels({'2–3','4–5', '6–7', '8–9', '10–11', '12–13', '14–15', '16–17', '18–19', '20–21', '22–23'})
    yticks(0:3:15)
    yticklabels({'0', '3', '6', '9', '12', '15'})
    yline(0)

    x = [0 5.5 5.5 0];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'y','FaceAlpha',0.1)
    x = [5.5 11.5 11.5 5.5];
    y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
    patch(x,y,'k','FaceAlpha',0.1)

    if 0 == contains(graphTitle,["baseline","Baseline","recovery","Recovery"])
        x = [0 2 2 0];
        y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
        patch(x,y,'r','FaceAlpha',0.1)
    end

exportgraphics(gcf,strcat(graphTitle," Sleep States.tiff"),'Resolution', 600)
