function DD_24HrDeltaGroup(fileArr, numGroups, inputDir, outputDir, groupNames, ...
	graphTitle, sleepState, colorCodes)

% Works with DannyDelta_v8.m to produce a graph of delta power across multiple treatments
% Produces a graph with hourly points and SEM error bars
% Last updated 9/16/2022, Danny Lasky

%% Select what columns to read from the table for desired sleep state
if sleepState == "NREM Raw"
    columnNum = 7;
elseif sleepState == "NREM Normalized"
    columnNum = 8;
elseif sleepState == "NREM Normalized Z-scored"
    columnNum = 9;
else
    error("Must be an approved sleep state definition")
end

%% Create treatment matrices
groupMatrices = cell(numGroups,1);
for n = 1:numGroups
    groupMatrices{n} = zeros(11,length(fileArr{n}));
    
    for m = 1:height(fileArr{n})
        currentFile = fileArr{n}{m};
        tempDir = fullfile(inputDir,currentFile);
        cd(tempDir)
        hourlyMatrixTemp = readmatrix('Hourly Table.csv');
        for p = 1:11
            groupMatrices{n}(p,m) = mean(hourlyMatrixTemp(2*p:2*p+1,columnNum), 'omitnan');
        end
    end
end

%% Find means and standard error of the means of groups
MeansSEMs = cell(numGroups,1);
for n = 1:numGroups
    MeansSEMs{n} = zeros(11,2);
    for m = 1:11
        MeansSEMs{n}(m,1) = mean(groupMatrices{n}(m,:), 'omitnan');
        MeansSEMs{n}(m,2) = std(groupMatrices{n}(m,:), 'omitnan')/sqrt(sum(~isnan((groupMatrices{n}(m,:)))));
    end
end

%% Create an output table and save it
cd(outputDir)
loopTable = table(nan(11,1),'VariableNames',{'Remove'});

for n = 1:numGroups
    addTable = splitvars(table(MeansSEMs{n}));
    addTable.Properties.VariableNames = [strcat("Mean ",groupNames(n)),strcat("SEM ",groupNames(n))];
    loopTable = [loopTable, addTable];
end

for n = 1:numGroups
    addTable = splitvars(table(groupMatrices{n}));
    addTable.Properties.VariableNames = fileArr{n};
    loopTable = [loopTable, addTable];
end

finalTable = loopTable(:,2:end);

writetable(finalTable, strcat(graphTitle," ",sleepState," 24Hr.csv"))

%% Graph output 
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 12 7]);
hold on
p = cell(1,numGroups);
for n = 1:numGroups
	p{n} = plot(1:11,MeansSEMs{n}(1:11,1),'LineWidth',1.5,'Color',colorCodes(n));
	errorbar(1:11,MeansSEMs{n}(1:11,1),MeansSEMs{n}(1:11,2),'LineWidth',1.5,'LineStyle','None','Color',colorCodes(n));
end
set(gca,'FontSize',12)
xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
ylabel(strcat(sleepState," Delta Power"), 'FontSize', 14);
xlim([0,11.5]);
%ylim([0.5,4.5]);        %If making yAxis equal across days
ylim tight             %If generating automatically
yLimit = ylim;
xticks(1:11)
xticklabels({'2–3','4–5', '6–7', '8–9', '10–11', '12–13', '14–15', '16–17', '18–19', '20–21', '22–23'})
title(strcat(graphTitle," Hourly Delta Power"), 'FontSize', 18)

x = [0 5.5 5.5 0];
y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
patch(x,y,'y','FaceAlpha',0.1)
x = [5.5 11.5 11.5 5.5];
y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
patch(x,y,'k','FaceAlpha',0.1)

if contains(graphTitle,["baseline","Baseline","recovery","Recovery"]) == 0
	x = [0 2 2 0];
	y = [yLimit(1,1) yLimit(1,1) yLimit(1,2) yLimit(1,2)];
	patch(x,y,'r','FaceAlpha',0.1)
end


if contains(graphTitle,["baseline","Baseline"]) == 1
    h = legend([p{1} p{2} p{3} p{4}], groupNames, 'FontSize', 12,'NumColumns',2);
    pos = get(h,'Position');
    posx = 0.624;
    posy = 0.83;
    set(h,'Position',[posx posy pos(3) pos(4)]);
end

%posx = 0.6927;
%posy = 0.9242;
exportgraphics(gcf, strcat(graphTitle," ",sleepState," 24Hr.tiff"), 'Resolution', 300)
