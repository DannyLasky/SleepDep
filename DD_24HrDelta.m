function DD_24HrDelta(hourlyMatrix, hourlyTable, fileNameEDF, useScores)

% Works with DannyDelta_v8.m to produce hourly graphs of both delta and gamma
% Last updated 9/15/22, Danny Lasky

if useScores == 1
    runColumns = [3,6,9,12];
    gammaAdd = 12;
elseif useScores == 0
    runColumns = 3;
    gammaAdd = 3;
end
    
[~,titleName]=fileparts(fileNameEDF);

for m = runColumns

    n = m + gammaAdd;

    figure
    set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 14 8]);
    s1 = subplot(2,1,1);
        plot(1:24,hourlyMatrix(:,m), 'LineWidth', 2);
        graphTitle = strrep(titleName,'_',' ');
        title(graphTitle, 'FontSize', 18)
        ylabel(hourlyTable.Properties.VariableNames{m}, 'FontSize', 14);
    
        xlim([0,24.5]);
        xticks(1:24)
        %ylim([0.5,2]);         % If making yAxis equal across days
        ylim tight              % If generating automatically
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

    s2 = subplot(2,1,2);
        plot(1:24, hourlyMatrix(:,n), 'LineWidth', 2);
        xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
        ylabel(hourlyTable.Properties.VariableNames{n}, 'FontSize', 14);
    
        xlim([0,24.5])
        xticks(1:24)
        %ylim([0.5,2]);         % If making yAxis equal across days
        ylim tight              % If generating automatically
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

    saveas(gcf, strcat("24 Hr ",hourlyTable.Properties.VariableNames{m}," ",hourlyTable.Properties.VariableNames{n},'.png'))

end
