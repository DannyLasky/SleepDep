function [alignedScores, justScores, homeoScores, alignedStart, alignedEnd, scoredArtifact] = ...
    DD_Scores(sleepScores, startEpochOffset, endEpochOffset, epochLength, DSTCheck)

% Works with DannyDelta_v8.m to work up the scores in preparation for graphing
% Aligns them to match the EDF, counts artifact, and creates a copy where artifact won't interrupt a wake bout
% Last updated 9/14/22, Danny Lasky

%% Aligning the full sleep state table
if startEpochOffset > 0
    sleepScores = [sleepScores(1:startEpochOffset,:); sleepScores];
    sleepScores{1:startEpochOffset,1} = nan;
    
    startAdjust = transpose(sleepScores{startEpochOffset+1,2} - seconds(epochLength:epochLength:startEpochOffset*epochLength));
    sleepScores{1:startEpochOffset,2} = flipud(startAdjust);
    
    endAdjust = transpose(sleepScores{startEpochOffset+1,3} - seconds(epochLength:epochLength:startEpochOffset*epochLength));
    sleepScores{1:startEpochOffset,3} = flipud(endAdjust);
    
    sleepScores{1:startEpochOffset,4} = nan;

    tempEmpty = cell(startEpochOffset,1);
    sleepScores{1:startEpochOffset,5} = tempEmpty;
elseif startEpochOffset < 0
    keepEpochs   = abs(startEpochOffset) + 1;
	sleepScores  = sleepScores(keepEpochs:end,:);
end

if endEpochOffset > 0
    sleepScores = [sleepScores; sleepScores(1:endEpochOffset,:)];
    sleepScores{end-endEpochOffset+1:end,1} = nan;   
    
    startAdjust = transpose(sleepScores{end-endEpochOffset+1,2} - seconds(epochLength:epochLength:endEpochOffset*epochLength));
    sleepScores{end-endEpochOffset+1:end,2} = flipud(startAdjust);
    
    endAdjust = transpose(sleepScores{end-endEpochOffset+1,3} - seconds(epochLength:epochLength:endEpochOffset*epochLength));
    sleepScores{end-endEpochOffset+1:end,3} = flipud(endAdjust);
    
    sleepScores{end-endEpochOffset+1:end,4} = nan;

    tempEmpty = cell(endEpochOffset,1);
    sleepScores{end-endEpochOffset+1:end,5} = tempEmpty;
elseif endEpochOffset < 0
    cutEpochs   = abs(endEpochOffset);
	sleepScores  = sleepScores(1:end-cutEpochs,:);
end

alignedScores = sleepScores;
fprintf('%d scored epochs after shifting.\n',height(alignedScores))

%% Create a matrix of just the aligned scores for later computations
justScores = table2array(alignedScores(:,4));

%% Display the DST state. aligned start time, aligned end time, and number of artifact bouts
if DSTCheck == 1
    fprintf('EDF was recorded during DST.\n')
elseif DSTCheck == 0
    fprintf('EDF was not recorded during DST.\n')
end

alignedStart = alignedScores{1,2};
alignedStart.Format = 'hh.mm.ss';
fprintf('File starts aligned to %s.\n', alignedStart)

alignedEnd = alignedScores{end,3};
alignedEnd.Format = 'hh.mm.ss';
fprintf('File ends aligned to %s.\n', alignedEnd)

%artBouts = find(justScores(:,1) == 0)';    % Can view all artifact epoch positions
%artBoutsString = num2str(artBouts);        % Can view all artifact epoch positions

scoredArtifact = sum(justScores(:,1) == 0);
fprintf('%d sleep scored artifact epochs.\n', scoredArtifact);

%% Remove scored artifact falls in the middle of a Wake state (flanked on both sides by Wake)
homeoScores = justScores;
[vals, lengths, run_starts] = dwelltime(justScores);

valsWake  = vals == 1;
valsArt   = vals == 0;
valsTotal = valsWake + valsArt;
valsSum = movsum(valsTotal,3);
rowsChange = find(valsSum == 3);

for n = 1:length(rowsChange)
    homeoScores(run_starts(rowsChange(n)) : run_starts(rowsChange(n)) + lengths(rowsChange(n)) - 1) = 1;
end

cleanedArtifact = sum(homeoScores(:,1) == 0);
fprintf('%d sleep scored artifact epochs not between two periods of Wake.\n', cleanedArtifact);
