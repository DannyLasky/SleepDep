function [avgMagArr, avgFreqArr, signalMax, signalMin, signalStd] = DD_Bandpower(normSignal, epochPts, fs)

% Works with DannyDelta_v8.m to read in quantify delta and gamma power via Jones's method
% Last updated 9/14/2022, Danny Lasky

deltaRange = [0.5 4];
thetaRange = [6 9];   
sigmaRange = [10 14];   
gammaRange = [30 70];                    % Changed from [25 100] in original script
%aboveDelta = [4.000000000000001 70];
%aboveDeltaAll = [4.000000000000001 256];

bandRanges = [deltaRange; thetaRange; sigmaRange; gammaRange];
bandNames = {'Delta', 'Theta', 'Sigma', 'Gamma'}.';
bandCount = length(bandNames);

signalMax = max(normSignal);
signalMin = min(normSignal);
signalStd = std(normSignal);

epochCount = 0;
currPt = 1;
lastPt = length(normSignal);

freqBins = (0:epochPts-1);
freqHz = freqBins*fs/epochPts;
ssPSD = ceil(epochPts/2);

while currPt+epochPts-1 <= lastPt
    currEpoch = normSignal(currPt:currPt+epochPts-1,:);      
    freqAxis  = freqHz(1:ssPSD)';
    
    % Spectrum as computed in Sunogawa paper
    X_mags = abs(fft(currEpoch)).^2/length(currEpoch);          % Simple Power Spectrum
    X_mags = X_mags(1:ssPSD);

    % Get measures for separate bands
    for band = 1:bandCount
        rangeLims = bandRanges(band,:);
        indxs = find(freqAxis >= rangeLims(1) & freqAxis <= rangeLims(2));
        %[maxMag(band), mxindx] = max(X_mags(indxs));
        %maxFreq(band)          = freqAxis(indxs(mxindx));
        avgMag(band)            = mean(X_mags(indxs));
        avgFreq(band)           = mean(freqAxis(indxs)); % IS THIS CORRECT?? DOESN'T MATTER FOR NOW...
        %sumMag(band)           = sum(X_mags(indxs));
    end                   

    % Collate and package data for this epoch
    epochCount = epochCount + 1;
    output.PSDMag{epochCount} = X_mags;   % Need to fix this later
        for band = 1:bandCount
            %maxMagArr(epochCount, band)    = maxMag(band);
            %maxFreqArr(epochCount, band)   = maxFreq(band);
            avgMagArr(epochCount, band)     = avgMag(band);
            avgFreqArr(epochCount, band)    = avgFreq(band);
            %sumMagArr(epochCount, band)	= sumMag(band);
        end

    currPt = currPt + epochPts;
end
