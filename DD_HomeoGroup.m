function DD_HomeoMulti(fileArr, numGroups, inputHomeo, outputDir, groupNames, graphTitle, colorCodes)

% Uses fitting parameters from linear rise of delta and exponential decline
% of delta to display differences between treatments
findMax = nan(numGroups,1);
for n = 1:numGroups
    findMax(n) = height(fileArr{n});
end
lengthMax = max(findMax);

H1.Slope            = nan(lengthMax,numGroups);
H1.YInt             = nan(lengthMax,numGroups);
H1.RSq              = nan(lengthMax,numGroups);
H2.Amp              = nan(lengthMax,numGroups);
H2.Tau              = nan(lengthMax,numGroups);
H2.Constant         = nan(lengthMax,numGroups);
H2.xFit             = cell(lengthMax,numGroups);
H2.yFit             = cell(lengthMax,numGroups);
H2.Fit              = cell(lengthMax,numGroups);
H2.Epoch_to_Hours   = nan(lengthMax,numGroups);

for n = 1:numGroups
    for m = 1:length(fileArr{n})
        load(fullfile(inputHomeo, strcat(fileArr{n}(m), " HomeoOutput")));
        H1.Slope(m,n)           = output.homeo1.slope;
        H1.YInt(m,n)            = output.homeo1.yint;
        H1.RSq(m,n)             = output.homeo1.rsq;
        H2.Amp(m,n)             = output.homeo2.fitpars(1);
        H2.Tau(m,n)             = output.homeo2.fitpars(2) * output.homeo2.Epoch_to_Hours;
        H2.Constant(m,n)        = output.homeo2.fitpars(3);
        H2.xFit{m,n}            = output.homeo2.x;
        H2.yFit{m,n}            = output.homeo2.y;
        H2.Fit{m,n}             = output.homeo2.fit;
        H2.Epoch_to_Hours(m,n)  = output.homeo2.Epoch_to_Hours;
    end
end

figure
boxplot(H1.Slope)
title('Slopes')

figure
boxplot(H2.Tau)
title('Decline')

for n = 1:numGroups
    figure
    hold on
    box off
    for m = 1:length(fileArr{n})
        plot(H2.Epoch_to_Hours(m,n).*H2.xFit{m,n}, H2.yFit{m,n}, 'ko'); hold on
        plot(H2.Epoch_to_Hours(m,n).*H2.xFit{m,n}, H2.Fit{m,n}, 'ro', 'markerfacecolor', 'r')
        xlabel('Hours After Entering a Sleep Cluster', 'FontSize', 14)
        ylabel('Average NREM Bout Delta Power', 'FontSize', 14)
    end
end







