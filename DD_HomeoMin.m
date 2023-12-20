function [output] = DD_HomeoMin(finalMatrix, homeoScores, fileNameEDF, epochLength, outputDir)

% Works with DannyDelta_v8.m to produce sleep homeostasis figures used in Jones's grant
% Script adapted from Sleep_homeostasis_integration_RQ
% Predefined the NREM_after_WAKE_maxdeltapwr matrix size
% Added omitnan to mean and max delta power calculations since my data contains those
% Changed figure titles and file output names and format from PDF to PNG
% This version was created since the original file selection and power computations were unnecessary
% Last updated 9/15/22, Danny Lasky

%% This section will specify all variables necessary to run the Sleep_homeostasis_integration_RQ code
% From line 120 onwards
tic
cd(outputDir)
Epoch = transpose(1:length(homeoScores));
epochsecs = epochLength;
deltapwr = finalMatrix(:,1);    % Currently using unnormalized 

[~,titleName]=fileparts(fileNameEDF);
graphTitle = strrep(titleName,'_',' ');
output.ID = titleName;

%% Line 120 onwards

% Find all consecutive runs of each sleep stage and their durations.
% vals       = sleep score, as above
% lengths    = duration of each run IN EPOCHS, NOT TIME
% run_starts = indices of the beginning of each run
disp('Finding dwell times and runs, etc.')
[vals, lengths, run_starts] = dwelltime(homeoScores);
runLoop = 1;

while runLoop == 1
    artifactVals = find(vals == 0);
    artifactFlanked = NaN(length(artifactVals),1);
    for n = 1:length(artifactVals)
        artifactFlanked(n) = vals(artifactVals(n)-1) + vals(artifactVals(n)+1);
        if artifactFlanked(n) == 2
            homeoScores(run_starts(artifactVals(n)):run_starts(artifactVals(n)) + lengths(artifactVals(n)) - 1) = 1;
        else
            runLoop = 0;
        end
    end
    if isempty(artifactVals)
        runLoop = 0;
    end
    [vals, lengths, run_starts] = dwelltime(homeoScores);
end

Score = homeoScores;

output.sleep.epochsecs                = epochsecs;
output.sleep.dwelltimes.vals          = vals;
output.sleep.dwelltimes.lengths       = lengths;
output.sleep.dwelltimes.run_starts	= run_starts;

close(gcf)
        
%% Homeostasis measures
% Find indices of all NREMs that are immediately preceded by WAKE
% Omit the first one to avoid indexing error, then correct by adding 1 to the index
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

for q = 1:length(NREM_after_WAKE_Indx)
	NREM_after_WAKE_trace(run_starts(NREM_after_WAKE_Indx(q)):run_starts(NREM_after_WAKE_Indx(q)) + NREM_after_WAKE_dur(q)-1) = 1;
    NREM_after_WAKE_avgdeltapwr(q) = mean(deltapwr((run_starts(NREM_after_WAKE_Indx(q)):run_starts(NREM_after_WAKE_Indx(q)) + NREM_after_WAKE_dur(q)-1)),'omitnan');
  	NREM_after_WAKE_maxdeltapwr(q) = max(deltapwr((run_starts(NREM_after_WAKE_Indx(q)):run_starts(NREM_after_WAKE_Indx(q)) + NREM_after_WAKE_dur(q)-1)));
end

NREM_after_WAKE_trace(length(Epoch)+1:end) = []; % Correct for small mismatch at the end
NREM_after_WAKE_deltatrace = NREM_after_WAKE_trace.*deltapwr;
        
output.sleep.NREM_after_WAKE_Indx             = NREM_after_WAKE_Indx;
output.sleep.WAKE_before_NREM_Indx            = WAKE_before_NREM_Indx;
output.sleep.NREM_after_WAKE_dur              = NREM_after_WAKE_dur;
output.sleep.WAKE_before_NREM_dur             = WAKE_before_NREM_dur;
output.sleep.NREM_after_WAKE_avgdeltapwr      = NREM_after_WAKE_avgdeltapwr;
output.sleep.NREM_after_WAKE_maxdeltapwr      = NREM_after_WAKE_maxdeltapwr;
output.sleep.NREM_after_WAKE_trace            = NREM_after_WAKE_trace;
output.sleep.NREM_after_WAKE_deltatrace       = NREM_after_WAKE_deltatrace;
output.sleep.NREM_after_WAKE_maxdeltapwr      = NREM_after_WAKE_maxdeltapwr;
output.sleep.NREM_after_WAKE_maxdeltapwr      = NREM_after_WAKE_maxdeltapwr;

Epoch_to_Hours = epochsecs ./ 60 ./ 60;

%% Figure 1: Hypnogram side-by-side with NREM delta power

disp('Plotting hypnogram.')
figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
ax1 = subplot(2, 1, 1);
    hold on
	plot(Epoch_to_Hours.*Epoch, Score, 'k-');
    p1 = plot(Epoch_to_Hours.*Epoch, 2.*NREM_after_WAKE_trace, 'r+');
    p2 = plot(Epoch_to_Hours.*run_starts(WAKE_before_NREM_Indx), 1, 'b+');
  	set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
 	xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
   	ylabel('Sleep Stage', 'FontSize', 14);
  	title(graphTitle, 'FontSize', 16)
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

ax2 = subplot(2, 1, 2);
  	plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace, 'k')
 	set(gca, 'ylim', [0 max(NREM_after_WAKE_deltatrace)])
   	box off     
  	xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
   	ylabel('NREM Delta Power', 'FontSize', 14);
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

exportgraphics(gcf,strcat(graphTitle," Hypno Simple.tiff"),'Resolution',300)


%% Figure 2: Length of previous wake (>= 80 sec) vs peak delta power of following NREM bout
validMinWAKEDur = 20; % Epochs
validindx = find(WAKE_before_NREM_dur >= validMinWAKEDur);
validx = WAKE_before_NREM_dur(validindx);
validy = NREM_after_WAKE_maxdeltapwr(validindx);
                       
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
        
disp('Plotting homeostasis.')
figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
subplot(2, 1, 1); 
	plot(epochsecs.*WAKE_before_NREM_dur, NREM_after_WAKE_maxdeltapwr, 'ko')
   	xlabel('Previous Wake Duration (sec)', 'FontSize', 12)
   	ylabel({'Peak NREM Delta Power'}, 'FontSize', 12)
    xLimit = xlim;
    ylim tight
    yLimit = ylim;
    box off
   	title(graphTitle, 'FontSize', 16)
subplot(2, 1, 2); 
  	plot(epochsecs.*validx, validy, 'ko'); hold on
  	plot(epochsecs.*validx, yfit, 'r-')
	xlabel('Previous Long Wake Duration (sec)', 'FontSize', 12)
  	ylabel({'Peak NREM Delta Power'}, 'FontSize', 12)
    xlim(xLimit)
    ylim tight
    ylim(yLimit);
    box off
    text(-0.12, 1.1, {['Slope = ' num2str(P(1), '%2.2e')]; ['Y-int = ' num2str(P(2), '%2.2e')]; ['R^2 = ' ...
        num2str(rsq, '%2.2e')]}, 'fontname', 'times', 'fontsize', 12, 'color', 'r','Units','normalized')

exportgraphics(gcf,strcat(graphTitle," Delta Rise.tiff"),'Resolution',300)

%% Figure 3: Showing decline of delta
validMinNREM = 40;          % Epochs
validMinWAKE = 225;         % Epochs

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

    figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
      	plot(Epoch_to_Hours.*xFit, yFit, 'ko'); hold on
    	plot(Epoch_to_Hours.*xFit, fit, 'ro', 'markerfacecolor', 'r')
        box off
     	xlabel('Hours After Entering a Sleep Bout Following Wake >= 15 Min', 'FontSize', 12)
      	ylabel('NREM Delta Power', 'FontSize', 12)
     	text(0.1.*max(Epoch_to_Hours.*xFit), 0.9.*max(yFit), {['amp = ' num2str(amp)]; ['tau = ' num2str(Epoch_to_Hours.*tau)]; ['const = ' num2str(const)]}, 'fontname', 'times', 'fontsize', 14, 'color', 'r')
       	title(graphTitle, 'FontSize', 16)   
        exportgraphics(gcf, strcat(graphTitle," Delta Decline.tiff"), 'Resolution', 300)

%% Figure 4: Hypnogram with NREM delta power marked for average delta power by NREM bout and NREM bouts following long wake
figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
subplot(2,1,1)
ax1 = subplot(2, 1, 1);
    hold on
 	Epoch_to_Hours = epochsecs ./ 60 ./ 60;
	plot(Epoch_to_Hours.*Epoch, Score, 'k-');
    p1 = plot(Epoch_to_Hours.*Epoch, 2.*NREM_after_WAKE_trace, 'r+');
    p2 = plot(Epoch_to_Hours.*run_starts(WAKE_before_NREM_Indx), 1, 'b+');
  	set(gca, 'ylim', [0.8 3.2], 'ytick', 1:3, 'yticklabel', char('Wake', 'NREM', 'REM'))
 	xlabel('Zeitgeber Time (hours)', 'FontSize', 14);
   	ylabel('Sleep Stage', 'FontSize', 14);
  	title(graphTitle, 'FontSize', 16)
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

    ax2 = subplot(2, 1, 2);
      	plot(Epoch_to_Hours.*Epoch, NREM_after_WAKE_deltatrace, 'k'); hold on
    	plot(Epoch_to_Hours.*run_starts(NREM_after_WAKE_Indx(validIndxAllNREM)), NREM_after_WAKE_avgdeltapwr(validIndxAllNREM), 'ro-', 'markerfacecolor', 'r');
        plot(Epoch_to_Hours.*clipStartUnique, NREM_after_WAKE_avgdeltapwr(circleIndx), 'bo', 'LineWidth', 2, 'MarkerSize', 28);
        ylabel({'Average NREM Delta Power'}, 'FontSize', 14)
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
    
exportgraphics(gcf,strcat(graphTitle," Hypno Complex.tiff"), 'Resolution', 300)        

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
toc
