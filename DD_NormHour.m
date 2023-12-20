function [finalMatrix, finalTable, hourlyMatrix, hourlyTable, artDeltaSum, artGammaSum] = DD_NormHour(epochLength, ...
    avgMagArr, justScores, useScores)

% Works with DannyDelta_v8.m to normalize the band power output, break into hourly sections and create output
% Last updated 9/14/2022, Danny Lasky

%% Create filters for specific sleep states
if useScores == 1
    wakeFilter = justScores       == 1;
    NREMFilter = justScores       == 2;
    REMFilter = justScores        == 3;
    artifactFilter = justScores   == 0;

    avgMagAll = avgMagArr;
    avgMagAll((artifactFilter == 1),:) = NaN;

    avgMagWake = avgMagArr;
    avgMagWake((wakeFilter == 0),:) = NaN;

    avgMagNREM = avgMagArr;
    avgMagNREM((NREMFilter == 0),:) = NaN;

    avgMagREM = avgMagArr;
    avgMagREM((REMFilter == 0),:) = NaN;

%% Break into individual arrays and normalize
    deltaAvgAll  = avgMagAll(:,1);
    deltaAvgWake = avgMagWake(:,1);
    deltaAvgNREM = avgMagNREM(:,1);
    deltaAvgREM  = avgMagREM(:,1);

    gammaAvgAll  = avgMagAll(:,4);
    gammaAvgWake = avgMagWake(:,4);
    gammaAvgNREM = avgMagNREM(:,4);
    gammaAvgREM  = avgMagREM(:,4);

    deltaAvgN       = zeros(size(deltaAvgAll));
    deltaAvgWakeN   = zeros(size(deltaAvgWake));
    deltaAvgNREMN   = zeros(size(deltaAvgNREM));
    deltaAvgREMN    = zeros(size(deltaAvgREM));
    gammaAvgN       = zeros(size(gammaAvgAll));
    gammaAvgWakeN   = zeros(size(gammaAvgWake));
    gammaAvgNREMN   = zeros(size(gammaAvgNREM));
    gammaAvgREMN    = zeros(size(gammaAvgREM));
    
    for n = 1:86400/epochLength
        deltaAvgN(n,1)     = deltaAvgAll(n,1)/sum(avgMagAll(n,2:4));       % Normalize by dividing by theta + sigma + gamma
        deltaAvgWakeN(n,1) = deltaAvgWake(n,1)/sum(avgMagWake(n,2:4));
        deltaAvgNREMN(n,1) = deltaAvgNREM(n,1)/sum(avgMagNREM(n,2:4));
        deltaAvgREMN(n,1)  = deltaAvgREM(n,1)/sum(avgMagREM(n,2:4));
        
        gammaAvgN(n,1)     = gammaAvgAll(n,1)/sum(avgMagAll(n,1:3));       % Normalize by dividing by delta + theta + sigma
        gammaAvgWakeN(n,1) = gammaAvgWake(n,1)/sum(avgMagWake(n,1:3));
        gammaAvgNREMN(n,1) = gammaAvgNREM(n,1)/sum(avgMagNREM(n,1:3));
        gammaAvgREMN(n,1)  = gammaAvgREM(n,1)/sum(avgMagREM(n,1:3));
    end

%% Remove epochs if 3 standard deviations outside mean
    artDeltaAll = (deltaAvgN - mean(deltaAvgN, 'omitnan'))/std(deltaAvgN, 'omitnan');
    artDeltaWake = (deltaAvgWakeN - mean(deltaAvgWakeN, 'omitnan'))/std(deltaAvgWakeN, 'omitnan');
    artDeltaNREM = (deltaAvgNREMN - mean(deltaAvgNREMN, 'omitnan'))/std(deltaAvgNREMN, 'omitnan');
    artDeltaREM = (deltaAvgREMN - mean(deltaAvgREMN, 'omitnan'))/std(deltaAvgREMN, 'omitnan');

    artGammaAll = (gammaAvgN - mean(gammaAvgN, 'omitnan'))/std(gammaAvgN, 'omitnan');
    artGammaWake = (gammaAvgWakeN - mean(gammaAvgWakeN, 'omitnan'))/std(gammaAvgWakeN, 'omitnan');
    artGammaNREM = (gammaAvgNREMN - mean(gammaAvgNREMN, 'omitnan'))/std(gammaAvgNREMN, 'omitnan');
    artGammaREM = (gammaAvgREMN - mean(gammaAvgREMN, 'omitnan'))/std(gammaAvgREMN, 'omitnan');

    for n = 1:86400/epochLength
        if abs(artDeltaAll(n)) >= 3
            artDeltaAll(n) = 1;
        else
            artDeltaAll(n) = 0;
        end
    
        if abs(artDeltaWake(n)) >= 3
            artDeltaWake(n) = 1;
        else
            artDeltaWake(n) = 0;
        end
    
        if abs(artDeltaNREM(n)) >= 3
            artDeltaNREM(n) = 1;
        else
            artDeltaNREM(n) = 0;
        end       
    
        if abs(artDeltaREM(n)) >= 3
            artDeltaREM(n) = 1;
        else
            artDeltaREM(n) = 0;
        end       
    
        if abs(artGammaAll(n)) >= 3
            artGammaAll(n) = 1;
        else
            artGammaAll(n) = 0;
        end       
        
        if abs(artGammaWake(n)) >= 3
            artGammaWake(n) = 1;
        else
            artGammaWake(n) = 0;
        end      
    
        if abs(artGammaNREM(n)) >= 3
            artGammaNREM(n) = 1;
        else
            artGammaNREM(n) = 0;
        end      
    
        if abs(artGammaREM(n)) >= 3
            artGammaREM(n) = 1;
        else
            artGammaREM(n) = 0;
        end      
    end

    artDeltaSum = sum(artDeltaAll);
    artGammaSum = sum(artGammaAll);

    fprintf('%d Z-scored delta artifact epochs.\n', artDeltaSum);
    fprintf('%d Z-scored gamma artifact epochs.\n', artGammaSum);
    
    deltaAvgNA     = deltaAvgN;
    deltaAvgWakeNA = deltaAvgWakeN;
    deltaAvgNREMNA = deltaAvgNREMN;
    deltaAvgREMNA  = deltaAvgREMN;

    gammaAvgNA     = gammaAvgN;
    gammaAvgWakeNA = gammaAvgWakeN;
    gammaAvgNREMNA = gammaAvgNREMN;
    gammaAvgREMNA  = gammaAvgREMN;

    for n = 1:86400/epochLength
        if artDeltaAll(n) == 1
            deltaAvgNA(n) = NaN;
        end
        if artDeltaWake(n) == 1
            deltaAvgWakeNA(n) = NaN;
        end    
        if artDeltaNREM(n) == 1
            deltaAvgNREMNA(n) = NaN;
        end     
        if artDeltaREM(n) == 1
            deltaAvgREMNA(n) = NaN;
        end     
        if artGammaAll(n) == 1
            gammaAvgNA(n) = NaN;
        end
        if artGammaWake(n) == 1
            gammaAvgWakeNA(n) = NaN;
        end
        if artGammaNREM(n) == 1
            gammaAvgNREMNA(n) = NaN;
        end
        if artGammaREM(n) == 1
            gammaAvgREMNA(n) = NaN;
        end    
    end

%% Create master matrix and table
    finalMatrix = [deltaAvgAll,deltaAvgN,deltaAvgNA,deltaAvgWake,deltaAvgWakeN,deltaAvgWakeNA,deltaAvgNREM,deltaAvgNREMN, ...
        deltaAvgNREMNA,deltaAvgREM,deltaAvgREMN,deltaAvgREMNA,gammaAvgAll,gammaAvgN,gammaAvgNA,gammaAvgWake,gammaAvgWakeN, ...
        gammaAvgWakeNA,gammaAvgNREM,gammaAvgNREMN,gammaAvgNREMNA,gammaAvgREM,gammaAvgREMN,gammaAvgREMNA];
    finalTable = array2table(finalMatrix,'VariableNames',{'Delta All', 'Delta All N', 'Delta All NA', 'Delta Wake', ...
        'Delta Wake N', 'Delta Wake NA', 'Delta NREM', 'Delta NREM N', 'Delta NREM NA', 'Delta REM', 'Delta REM N', ...
        'Delta REM NA', 'Gamma All', 'Gamma All N', 'Gamma All NA', 'Gamma Wake', 'Gamma Wake N', 'Gamma Wake NA', ...
        'Gamma NREM','Gamma NREM N','Gamma NREM NA', 'Gamma REM', 'Gamma REM N', 'Gamma REM NA'});

%% Find hourly band powers
    hourlyEpochs = 3600/epochLength;
    hourlyMatrix = zeros(24, 24);
    
    for j = 1:24
        for k = 1:24
            tempMatrix = finalMatrix(1+(k-1)*hourlyEpochs:k*hourlyEpochs,j);
            tempLength = length(tempMatrix(~isnan(tempMatrix)));
            if tempLength > 0
            	hourlyMatrix(k,j) = mean(finalMatrix((1+(k-1)*hourlyEpochs:k*hourlyEpochs),j),'omitnan');
            elseif tempLength <= 0
                hourlyMatrix(k,j) = nan;
            end
        end
    end

    hourlyTable = array2table(hourlyMatrix,'VariableNames',{'Delta All', 'Delta All N', 'Delta All NA', 'Delta Wake', ...
        'Delta Wake N', 'Delta Wake NA', 'Delta NREM','Delta NREM N', 'Delta NREM NA', 'Delta REM', 'Delta REM N', ...
        'Delta REM NA', 'Gamma All', 'Gamma All N', 'Gamma All NA', 'Gamma Wake', 'Gamma Wake N', 'Gamma Wake NA', ...
        'Gamma NREM', 'Gamma NREM N', 'Gamma NREM NA', 'Gamma REM', 'Gamma REM N', 'Gamma REM NA'});
end

%% Option for no TSV
if useScores == 0
    deltaAvg = avgMagArr(:,1);
    gammaAvg = avgMagArr(:,4);
    
    deltaAvgN = zeros(size(deltaAvg));
    gammaAvgN = zeros(size(gammaAvg));
    
    for n = 1:86400/epochLength
        deltaAvgN(n,1)     = deltaAvg(n,1)/sum(avgMagArr(n,2:4));
        gammaAvgN(n,1)     = gammaAvg(n,1)/sum(avgMagArr(n,1:3));
    end

    artDelta = (deltaAvgN - mean(deltaAvgN, 'omitnan'))/std(deltaAvgN, 'omitnan');
    artGamma = (gammaAvgN - mean(gammaAvgN, 'omitnan'))/std(gammaAvgN, 'omitnan');

    for n = 1:86400/epochLength
        if abs(artDelta(n)) >= 3
            artDelta(n) = 1;
        else
            artDelta(n) = 0;
        end
    
        if abs(artGamma(n)) >= 3
            artGamma(n) = 1;
        else
            artGamma(n) = 0;
        end
    end

    artDeltaSum = sum(artDelta);
    artGammaSum = sum(artGamma);

    disp(artDeltaSum)
    disp(artGammaSum)

    deltaAvgNA = deltaAvgN;
    gammaAvgNA = gammaAvgN;

    for n = 1:21600
        if artDelta(n) == 1
            deltaAvgNA(n) = NaN;
        end
    
        if artGamma(n) == 1
            gammaAvgNA(n) = NaN;
        end
    end

%% Create master matrix and table
    finalMatrix = [deltaAvg,deltaAvgN,deltaAvgNA,gammaAvg,gammaAvgN,gammaAvgNA];
    finalTable = array2table(finalMatrix,'VariableNames',{'Delta', 'Delta N', 'Delta NA', 'Gamma', 'Gamma N', 'Gamma NA'});

%% Find hourly band powers
    hourlyEpochs = 3600/epochLength;
    hourlyMatrix = zeros(24, 24);

    for j = 1:6
        for k = 1:24
            tempMatrix = finalMatrix(1+(k-1)*hourlyEpochs:k*hourlyEpochs,j);
            tempLength = length(tempMatrix(~isnan(tempMatrix)));
            if tempLength > 45
                hourlyMatrix(k,j) = mean(finalMatrix((1+(k-1)*hourlyEpochs:k*hourlyEpochs),j),'omitnan');
            elseif tempLength <= 45
                hourlyMatrix(k,j) = nan;
            end
        end
    end

    hourlyTable = array2table(hourlyMatrix,'VariableNames',{'Delta', 'Delta N', 'Delta NA', 'Gamma', 'Gamma N', 'Gamma NA'});
end
