% function [output] = DD_Homeo(finalMatrix, homeoScores, fileNameEDF, epochLength)

% Works with DannyDelta to produce sleep homeostasis figures used in Jones's grant
% Script adapted from Sleep_homeostasis_integration_RQ

%% Prepare variables
Epoch = transpose(1:length(homeoScores));
deltaPwr = finalMatrix(:,1);                % Currently using unnormalized 

[~, titleName]= fileparts(fileNameEDF);
graphTitle = strrep(titleName,'_',' ');
output.ID = titleName;

%% Find all consecutive runs of each sleep stage and their durations.
disp('Finding dwell times and runs, etc.')
[vals, lengths, runStarts] = dwelltime(homeoScores);
runLoop = 1;

%% Change artifact values flanked by wake to wake (need proper wake durations for homeostasis calculations)
while runLoop == 1
    artifactVals = find(vals == 0);
    artifactFlanked = NaN(length(artifactVals),1);
    for n = 1:length(artifactVals)
        artifactFlanked(n) = vals(artifactVals(n)-1) + vals(artifactVals(n)+1);
        if artifactFlanked(n) == 2
            homeoScores(runStarts(artifactVals(n)):runStarts(artifactVals(n)) + lengths(artifactVals(n)) - 1) = 1;
        else
            runLoop = 0;
        end
    end
    if isempty(artifactVals)
        runLoop = 0;
    end
    [vals, lengths, runStarts] = dwelltime(homeoScores);
end

close all

%% Find nearest NREM bouts to each NREM bout to determine which are in clusters and which are isolated
NREMIndx = find(vals == 2);

prevNREMBout = circshift(NREMIndx,1);
prevNREMEpoch = runStarts(prevNREMBout) + lengths(prevNREMBout) - 1;
prevNREMDistance = runStarts(NREMIndx) - prevNREMEpoch - 1;
prevNREMDistance(1) = NaN;

nextNREMBout = circshift(NREMIndx,-1);
nextNREMEpoch = runStarts(nextNREMBout);
currNREMEnd = runStarts(NREMIndx) + lengths(NREMIndx) - 1;
nextNREMDistance = nextNREMEpoch - currNREMEnd - 1;
nextNREMDistance(end) = NaN;

shorterNREMLength = min([prevNREMDistance, nextNREMDistance], [], 2, 'omitnan');

%% Defining clusters and remove ones that are too small to be deemed clusters
clusterMatrix = [shorterNREMLength, runStarts(NREMIndx), currNREMEnd];
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

clusterCount = clusterEnd - clusterStart + 1;

clusterStartNREM = clusterMatrix(clusterStart,2);
clusterEndNREM = clusterMatrix(clusterEnd,3);

clusterLengthNREM = clusterEndNREM - clusterStartNREM + 1;

figure
scatter(clusterCount, clusterLengthNREM)
xlim([0 max(clusterCount)+2])

cleanScores = clusterScores;

% Cluster must span at have NREM spanning at lease 200 epochs
%{
for n = 1:length(clusterCount)
    if clusterLengthNREM(n) < 200    % Hand select cluster parameters for now  
        cleanScores(clusterStartNREM(n):clusterEndNREM(n)) = 1;
    end
end
%}

% Cluster must contain 100 NREM epochs
for n = 1:length(clusterCount)
    if sum(cleanScores(clusterStartNREM(n):clusterEndNREM(n)) == 2) < 100    % Hand select cluster parameters for now  
        cleanScores(clusterStartNREM(n):clusterEndNREM(n)) = 1;
    end
end

% Cluster must contain a NREM bout of at least 40 epochs
for n = 1:length(clusterCount)
    tempLong = cleanScores(clusterStartNREM(n):clusterEndNREM(n)) == 2;
    longestNREM = max(accumarray(nonzeros((cumsum(~tempLong)+1).*tempLong),1));
    if longestNREM < 50
        cleanScores(clusterStartNREM(n):clusterEndNREM(n)) = 1;
    end
end

%% Change artifact values flanked by wake to wake, again since there are new wake values
runLoop = 1;
while runLoop == 1
    artifactVals = find(vals == 0);
    artifactFlanked = NaN(length(artifactVals),1);
    for n = 1:length(artifactVals)
        if artifactVals(n) == length(runStarts)
            runLoop = 0;
        else
            artifactFlanked(n) = vals(artifactVals(n)-1) + vals(artifactVals(n)+1);
            if artifactFlanked(n) == 2
                homeoScores(runStarts(artifactVals(n)):runStarts(artifactVals(n)) + lengths(artifactVals(n)) - 1) = 1;
            else
                runLoop = 0;
            end
        end
    end
    if isempty(artifactVals)
        runLoop = 0;
    end
    [vals, lengths, runStarts] = dwelltime(homeoScores);
end

%% Display NREM delta power of all NREM, clustered NREM, and clean NREM
% Find indices of all NREMs that are immediately preceded by WAKE
% Omit the first one to avoid indexing error, then correct by adding 1 to the index
NREM_after_WAKE_deltatrace = cell(3,1);  
for n = 1:4
    if n == 1
        [vals, lengths, run_starts] = dwelltime(homeoScores);
    elseif n == 2
        [vals, lengths, run_starts] = dwelltime(homeoScores);
    elseif n == 3
        [vals, lengths, run_starts] = dwelltime(clusterScores);
    else
        [vals, lengths, run_starts] = dwelltime(cleanScores);
    end
       
    vals(vals == 0) = NaN;
    NREM_after_WAKE_Indx = find((vals(2:end)==2) & (vals(2:end)+vals(1:end-1) == 3)) + 1;

    % Get the indices of the preceding wakes
    WAKE_before_NREM_Indx = NREM_after_WAKE_Indx - 1;
            
    % Get the durations and average NREM delta power
    NREM_after_WAKE_dur     = lengths(NREM_after_WAKE_Indx);
    WAKE_before_NREM_dur    = lengths(WAKE_before_NREM_Indx);

    % Make a mask for sections of NREM following wake only
    NREM_after_WAKE_trace   = zeros(length(Epoch), 1);
    NREM_after_WAKE_avgdeltapwr = zeros(length(NREM_after_WAKE_Indx), 1);
    NREM_after_WAKE_maxdeltapwr = zeros(length(NREM_after_WAKE_Indx), 1);
    
    % Find NREM delta power that follow wake
    for q = 1:length(NREM_after_WAKE_Indx)
        NREM_after_WAKE_trace(run_starts(NREM_after_WAKE_Indx(q)):run_starts(NREM_after_WAKE_Indx(q)) + NREM_after_WAKE_dur(q)-1) = 1;
    end

    NREM_after_WAKE_trace(length(Epoch)+1:end) = []; % Correct for small mismatch at the end
    NREM_after_WAKE_deltatrace{n} = NREM_after_WAKE_trace.*deltaPwr;

    % Remove NREM delta power outliers prior to determining average and max values
    if n > 1
        NREM_after_WAKE_deltatrace{n}(NREM_after_WAKE_deltatrace{n} == 0) = NaN;
        ZScores = (NREM_after_WAKE_deltatrace{n} - mean(NREM_after_WAKE_deltatrace{n}, 'omitnan')) ...
            /std(NREM_after_WAKE_deltatrace{n}, 'omitnan');
        disp(sum(ZScores > abs(7)))
        ZScoreFilter = ZScores > abs(7);
        NREM_after_WAKE_deltatrace{n}(ZScoreFilter) = NaN;

        deltPwr = finalMatrix(:,1);
        deltPwr(ZScoreFilter) = NaN;
    end

    % Calculate average and max delta powers of each bout
    for q = 1:length(NREM_after_WAKE_Indx)
        NREM_after_WAKE_avgdeltapwr(q) = mean(deltPwr((run_starts(NREM_after_WAKE_Indx(q)):run_starts(NREM_after_WAKE_Indx(q)) + NREM_after_WAKE_dur(q)-1)),'omitnan');
	        NREM_after_WAKE_maxdeltapwr(q) = max(deltPwr((run_starts(NREM_after_WAKE_Indx(q)):run_starts(NREM_after_WAKE_Indx(q)) + NREM_after_WAKE_dur(q)-1)));
    end
end

%% Comparison NREM delta plots
close all
Epoch_to_Hours = epochLength ./ 60 ./ 60;
disp('Plotting hypnogram.')
figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
ax1 = subplot(4, 1, 1);
    plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace{1}, 'k')
    set(gca, 'ylim', [0 max(NREM_after_WAKE_deltatrace{1})])
    box off     
    xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
    ylabel('NREM Delta Power', 'FontSize', 14);
    
    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    
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

ax2 = subplot(4, 1, 2);
    plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace{2}, 'k')
    set(gca, 'ylim', [0 max(NREM_after_WAKE_deltatrace{2})])
    box off     
    xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
    ylabel(["Z-Scored NREM" ; "Delta Power"], 'FontSize', 14);

    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    
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

ax3 = subplot(4, 1, 3);
    plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace{3}, 'k')
    set(gca, 'ylim', [0 max(NREM_after_WAKE_deltatrace{3})])
    box off     
    xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
    ylabel(["Clustered NREM"; "Delta Power"], 'FontSize', 14);
    linkaxes([ax1 ax2], 'x')

    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    
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

ax4 = subplot(4, 1, 4);
    plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace{4}, 'k')
    set(gca, 'ylim', [0 max(NREM_after_WAKE_deltatrace{4})])
    box off     
    xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
    ylabel(["Final NREM"; "Delta Power"], 'FontSize', 14);
    linkaxes([ax1 ax2 ax3 ax4], 'x')

    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    
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

exportgraphics(gcf,strcat(graphTitle," Hypno Simple.tiff"),'Resolution',300)

%% Figure 2: Length of previous wake vs peak NREM delta power of following NREM cluster
validMinWAKEDur = NREMLimit;
validindx = find(WAKE_before_NREM_dur >= validMinWAKEDur);
validx = WAKE_before_NREM_dur(validindx);

%validy = NREM_after_WAKE_maxdeltapwr(validindx);
allowableBoutsNREM = 100; % NREM bouts available to be counted as max after first, 100 really means any in the cluster

validy = zeros(length(validx),1);
validyEnds1 = validindx + allowableBoutsNREM;
validyEnds2 = circshift(validindx, -1) - 1;
validyEnds   = min([validyEnds1, validyEnds2], [], 2);
validyEnds(end) = min([validindx(end) + 2, length(NREM_after_WAKE_Indx)]);

for n = 1:length(validy)
    validy(n) = max(NREM_after_WAKE_maxdeltapwr(validindx(n):validyEnds(n)));
end

% Fit the data (see https://www.mathworks.com/help/matlab/data_analysis/linear-regression.html)
P = polyfit(validx, validy, 1);
yfit = polyval(P,validx);
yresid = validy - yfit; 
SSresid = sum(yresid.^2);
SStotal = (length(validy)-1) * var(validy);   
rsq = 1 - SSresid/SStotal;
        
output.homeo1.validMinWAKEDur        = validMinWAKEDur; %Epochs
output.homeo1.validx                 = validx; % Epochs
output.homeo1.validy                 = validy; % Norm Delta Power
output.homeo1.slope                  = P(1); % Slope of fit
output.homeo1.yint                   = P(2); % y-intercept of fit
output.homeo1.rsq                    = rsq; % R^2 of fit
     
Epoch_to_Hours = epochsecs ./ 60 ./ 60;

disp('Plotting homeostasis.')
%figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
figure('Units', 'Inches', 'OuterPosition', [1 1 6 6]);
%{
subplot(2, 1, 1); 
    plot(epochsecs.*WAKE_before_NREM_dur, NREM_after_WAKE_maxdeltapwr, 'ko')
	    xlabel('Previous Wake Duration (sec)', 'FontSize', 14)
	    ylabel({'Peak NREM Delta Power'}, 'FontSize', 14)
    xLimit = xlim;
    ylim tight
    yLimit = ylim;
    box off
	    title('C57 Saline Mode Animal', 'FontSize', 16)
subplot(2, 1, 2); 
%}
	    plot(Epoch_to_Hours.*validx, validy, 'ko'); hold on
	    plot(Epoch_to_Hours.*validx, yfit, 'r-')
    title('C57 Saline Model Rise', 'FontSize', 16)
    xlabel('Previous Wake Duration (hours)', 'FontSize', 14)
	    ylabel(["Maximum Sleep Cluster" ; "NREM Delta Power"], 'FontSize', 14)
    %xlim(xLimit)
    ylim tight
    ylim(yLimit);
    box off
    text(0.12, 0.88, {['Slope = ' num2str(P(1), '%2.2e')]; ['Y-int = ' num2str(P(2), '%2.2e')]; ['R^2 = ' ...
        num2str(rsq, '%2.2e')]}, 'fontname', 'times', 'fontsize', 12, 'color', 'r','Units','normalized')

exportgraphics(gcf,strcat(graphTitle," Delta Rise.tiff"),'Resolution', 600)

%% Figure 3: Showing decline of delta
validMinNREM = 1;          % Epochs
validMinWAKE = 100;         % Epochs

validIndxStartNREM  = find(NREM_after_WAKE_dur >= validMinNREM);
validIndxAllNREM    = find(NREM_after_WAKE_dur >= 1);
validIndxWake       = find(WAKE_before_NREM_dur >= validMinWAKE);
        
NREM_after_WAKE_run_starts_min = run_starts(NREM_after_WAKE_Indx(validIndxStartNREM));
NREM_after_WAKE_run_starts_all = run_starts(NREM_after_WAKE_Indx);
WAKE_before_NREM_run_starts    = run_starts(WAKE_before_NREM_Indx(validIndxWake));

% Grab trajectories of decline in delta power after prolonged wake periods
clippedDeltaPowerVals = cell(length(validIndxWake)-1,1);
clippedDeltaPowerIndx = cell(length(validIndxWake)-1,1);
clipStart             = NaN(length(validIndxWake)-1,1);

% For each long wake period, calculate the sets of delta power values (normalized to max in the clip)
for m = 1:length(validIndxWake)-1
    clipStartTemp   = NREM_after_WAKE_run_starts_min > WAKE_before_NREM_run_starts(m);
    if sum(clipStartTemp) ~= 0
        clipStart(m)       = min(NREM_after_WAKE_run_starts_min(clipStartTemp));
        clipEndTemp     = NREM_after_WAKE_run_starts_all < WAKE_before_NREM_run_starts(m+1);
        clipEnd         = max(NREM_after_WAKE_run_starts_all(clipEndTemp));
        clip = NREM_after_WAKE_run_starts_all >= clipStart(m) & NREM_after_WAKE_run_starts_all <= clipEnd;
        if sum(clip) == 0
            clippedDeltaPowerIndx{m} = [];
            clippedDeltaPowerVals{m} = [];
        else
	            clippedDeltaPowerIndx{m}    = NREM_after_WAKE_run_starts_all(clip);
            clippedDeltaPowerIndx{m}    = clippedDeltaPowerIndx{m} - clippedDeltaPowerIndx{m}(1);
            clippedDeltaPowerVals{m}    = NREM_after_WAKE_avgdeltapwr(clip);
        end
    end
end

% Last entry in the valid indx, no reason to not include it
if WAKE_before_NREM_run_starts(end) < NREM_after_WAKE_run_starts_min(end)
    clipStartTemp           = NREM_after_WAKE_run_starts_min > WAKE_before_NREM_run_starts(end);
    clipStart(m+1)          = min(NREM_after_WAKE_run_starts_min(clipStartTemp));
    clipEnd                 = max(NREM_after_WAKE_run_starts_all);
    clip = NREM_after_WAKE_run_starts_all >= clipStart(m+1) & NREM_after_WAKE_run_starts_all <= clipEnd;
    clippedDeltaPowerIndx{m+1}    = NREM_after_WAKE_run_starts_all(clip);
    clippedDeltaPowerIndx{m+1}    = clippedDeltaPowerIndx{m+1} - clippedDeltaPowerIndx{m+1}(1);
    clippedDeltaPowerVals{m+1}    = NREM_after_WAKE_avgdeltapwr(clip);
end

% Fit trajectory with an exponential ([amp, tau, const])
xFit = cat(1, clippedDeltaPowerIndx{:});
yFit = cat(1, clippedDeltaPowerVals{:});
guess = [1, 500, 0];

figure
    [guess, ~] = fminsearch( 'fit1exp', guess, [], xFit, yFit);
    close(gcf)
    [amp, tau, const] = deal(guess(1), guess(2), guess(3));
    fit  =  amp .* exp(-xFit./tau) + const;

    %figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
    figure('Units', 'Inches', 'OuterPosition', [1 1 6 6]);
  	    plot(Epoch_to_Hours.*xFit, yFit, 'ko'); hold on
	    plot(Epoch_to_Hours.*xFit, fit, 'ro', 'markerfacecolor', 'r')
        box off
 	    xlabel('Hours After Entering a Sleep Cluster', 'FontSize', 14)
  	    ylabel('Average NREM Delta Power', 'FontSize', 14)
 	    text(0.1.*max(Epoch_to_Hours.*xFit), 0.9.*max(yFit), {['amp = ' num2str(amp)]; ['tau = ' num2str(Epoch_to_Hours.*tau)]; ['const = ' num2str(const)]}, 'fontname', 'times', 'fontsize', 14, 'color', 'r')
   	    title("C57 Saline Model Decline", 'FontSize', 16)   
        exportgraphics(gcf, strcat(graphTitle," Delta Decline.tiff"), 'Resolution', 300)

%% Double plot of rise and decline
figure('Units', 'Inches', 'OuterPosition', [1 1 11.5 5.5]);
tiles = tiledlayout(1,2);
title(tiles, 'C57 Saline Model Animal Rise and Decline', 'FontSize', 16, 'FontWeight', 'Bold')
nexttile
    plot(Epoch_to_Hours.*validx, validy, 'ko'); hold on
    plot(Epoch_to_Hours.*validx, yfit, 'r-')
    xlabel('Previous Wake Duration (hours)', 'FontSize', 14)
        ylabel("Maximum Sleep Cluster NREM Delta Power", 'FontSize', 14)
    %xlim(xLimit)
    ylim tight
    ylim(yLimit);
    box off
    text(0.08, 0.88, {['Slope = ' num2str(P(1), '%2.2e')]; ['Y-int = ' num2str(P(2), '%2.2e')]; ['R^2 = ' ...
        num2str(rsq, '%2.2e')]}, 'fontsize', 12, 'color', 'r','Units','normalized')

nexttile
    plot(Epoch_to_Hours.*xFit, yFit, 'ko'); hold on
    plot(Epoch_to_Hours.*xFit, fit, 'ro', 'markerfacecolor', 'r')
    box off
	    xlabel('Hours After Entering a Sleep Cluster', 'FontSize', 14)
	    ylabel('Average NREM Bout Delta Power', 'FontSize', 14)
	    text(0.08, 0.88, {['Amp = ' num2str(amp)]; ['Tau = ' num2str(Epoch_to_Hours.*tau)]; ['Const = ' num2str(const)]}, ...
        'fontsize', 12, 'color', 'r','Units','normalized')

    exportgraphics(gcf, strcat("Model Rise and Decline.tiff"), 'Resolution', 600)

%% Figure 4: Hypnogram with NREM delta power marked for average delta power by NREM bout and NREM bouts following long wake
%figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.9 0.9]);
figure('Units', 'Inches', 'OuterPosition', [1 1 11.5 9]);
subplot(3,1,1)
ax1 = subplot(3,1,1);
    hold on
	    Epoch_to_Hours = epochsecs ./ 60 ./ 60;
    plot(Epoch_to_Hours.*Epoch, cleanScores, 'k-');
    p1 = plot(Epoch_to_Hours.*Epoch, 2.*NREM_after_WAKE_trace, 'r+');
    p2 = plot(Epoch_to_Hours.*run_starts(WAKE_before_NREM_Indx), 1, 'b+');
    set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
    xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
    ylabel('Sleep Stage', 'FontSize', 14);
	    title('C57 Saline Model Animal', 'FontSize', 16)
    box off
	    zoom on

    xlim([0,24.5])
    xticks(1:24)
    yLimit = ylim;
    
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

    h = legend([p1 p2(1)], {'NREM after Wake', 'Start of previous Wake'}, 'Location','bestoutside','FontSize',12);
    pos = get(h,'Position');
    posx = 0.763;
    posy = 0.93;
    set(h,'Position',[posx posy pos(3) pos(4)]);    
    
    clipStartUnique = unique(clipStart,'rows');
    clipStartUnique = clipStartUnique(~isnan(clipStartUnique));
    [~,circleIndx] = intersect(NREM_after_WAKE_run_starts_all, clipStartUnique, 'stable');

    ax2 = subplot(3,1,2);
  	    plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace{4}, 'k'); hold on
	    plot(Epoch_to_Hours.*run_starts(NREM_after_WAKE_Indx(validIndxAllNREM)), NREM_after_WAKE_avgdeltapwr(validIndxAllNREM), 'ro-', 'markerfacecolor', 'r');
        plot(Epoch_to_Hours.*clipStartUnique, NREM_after_WAKE_avgdeltapwr(circleIndx), 'bo', 'LineWidth', 2, 'MarkerSize', 28);
        ylabel(["Average NREM" ; "Bout Delta Power"], 'FontSize', 14)
        xlabel("Zeitgeber Time (hours)", 'FontSize', 14)
    linkaxes([ax1 ax2], 'x')

    xlim([0,24.5])
    xticks(1:24)    
   
    yLimit = ylim;
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

    ax3 = subplot(3,1,3);
  	    plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace{4}, 'k'); hold on
	    plot(Epoch_to_Hours.*run_starts(NREM_after_WAKE_Indx(validIndxAllNREM)), NREM_after_WAKE_maxdeltapwr(validIndxAllNREM), 'ro-', 'markerfacecolor', 'r');
        plot(Epoch_to_Hours.*clipStartUnique, validy, 'bo', 'LineWidth', 2, 'MarkerSize', 28);
        ylabel(["Maximum NREM" ; "Bout Delta Power"], 'FontSize', 14)
        xlabel("Zeitgeber Time (hours)", 'FontSize', 14)
    linkaxes([ax1 ax2 ax3], 'x')

    xlim([0,24.5])
    xticks(1:24)    
   
    yLimit = ylim;
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

exportgraphics(gcf,strcat(graphTitle," Hypno Complex.tiff"), 'Resolution', 600)   

%% Preparing data to be exported
output.homeo2.validMinNREM          = validMinNREM; 
output.homeo2.validMinWAKE          = validMinWAKE; 
output.homeo2.validIndxStartNREM    = validIndxStartNREM; 
output.homeo2.validIndxWake         = validIndxWake; 
output.homeo2.clippedDeltaPowerVals = clippedDeltaPowerVals; 
output.homeo2.clippedDeltaPowerIndx = clippedDeltaPowerIndx; 
output.homeo2.x                     = xFit; 
output.homeo2.y                     = yFit; 
output.homeo2.fit                   = fit; 
output.homeo2.fitpars               = guess;
output.homeo2.Epoch_to_Hours        = Epoch_to_Hours;

%% Save data to the matfile   
disp('Saving sleep homeostasis data.')
save(strcat(titleName, " HomeoOutput.mat"), 'output', '-v7.3', '-nocompression')

disp('Done with this animal.')
