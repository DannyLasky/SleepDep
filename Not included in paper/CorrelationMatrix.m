%% Column x Time P-values, DBA SA vs KA Wake/NREM/REM (0.0001 is really <0.0001)
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 6.5 6.5]);

groupsY = ["Baseline" ; "Sleep Dep D1" ; "Sleep Dep D2" ; "Sleep Dep D3" ; "Recovery"];
groupsX = ["Wake" ; "NREM Sleep" ; "REM Sleep"];

DBA_Wake = [0.0489; 0.0073; 0.0001; 0.0276; 0.0610];
DBA_NREM = [0.0777; 0.0001; 0.0254; 0.0534; 0.0697];
DBA_REM  = [0.0097; 0.0424; 0.0254; 0.0005; 0.0003];

pValue = [DBA_Wake, DBA_NREM, DBA_REM];

h = heatmap(groupsX, groupsY, pValue);
title('DBA Saline v Kainate Time × Injection Effect')
h.FontSize = 14;

clim([0, 1])
h.Colormap = h.Colormap(1:200,:);

h.Colormap(1:5, :)  = repmat([75/255, 255/255, 46/255], 5, 1);
h.Colormap(6:10, :) = repmat([188/255, 255/255, 172/255], 5, 1);
h.Colormap(11:15, :)  = repmat([255/255, 217/255, 206/255], 5, 1);
h.Colormap(16:25, :)  = repmat([255/255, 176/255, 148/255], 10, 1);
h.Colormap(26:200, :) = repmat([255/255, 120/255, 76/255], 175, 1);

exportgraphics(gcf, 'DBA Saline v Kainate Time × Injection Effect.tiff', 'Resolution', 600)

%% Just Column P-values, DBA SA vs KA Wake/NREM/REM (0.0001 is really <0.0001)
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 6.5 6.5]);

groupsY = ["Baseline" ; "Sleep Dep D1" ; "Sleep Dep D2" ; "Sleep Dep D3" ; "Recovery"];
groupsX = ["Wake" ; "NREM Sleep" ; "REM Sleep"];

DBA_Wake = [0.0596; 0.0288; 0.0067; 0.0305; 0.0367];
DBA_NREM = [0.0926; 0.0306; 0.0094; 0.0352; 0.0489];
DBA_REM  = [0.0088; 0.2054; 0.0053; 0.0299; 0.0048];

pValue = [DBA_Wake, DBA_NREM, DBA_REM];

h = heatmap(groupsX, groupsY, pValue);
title('DBA Saline v Kainate Injection Effect')
h.FontSize = 14;

clim([0, 1])
h.Colormap = h.Colormap(1:200,:);

h.Colormap(1:5, :)  = repmat([75/255, 255/255, 46/255], 5, 1);
h.Colormap(6:10, :) = repmat([188/255, 255/255, 172/255], 5, 1);
h.Colormap(11:15, :)  = repmat([255/255, 217/255, 206/255], 5, 1);
h.Colormap(16:25, :)  = repmat([255/255, 176/255, 148/255], 10, 1);
h.Colormap(26:200, :) = repmat([255/255, 120/255, 76/255], 175, 1);

exportgraphics(gcf, 'DBA Saline v Kainate Injection Effect.tiff', 'Resolution', 600)

%% Column x Time P-values, C57 SA vs KA Wake/NREM/REM (0.0001 is really <0.0001)
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 6.5 6.5]);

groupsY = ["Baseline" ; "Sleep Dep D1" ; "Sleep Dep D2" ; "Sleep Dep D3" ; "Recovery"];
groupsX = ["Wake" ; "NREM Sleep" ; "REM Sleep"];

C57_Wake = [0.6818; 0.0731; 0.4322; 0.0112; 0.5752];
C57_NREM = [0.8053; 0.0507; 0.4222; 0.0069; 0.5999];
C57_REM  = [0.0484; 0.6514; 0.0508; 0.3416; 0.1658];

pValue = [C57_Wake, C57_NREM, C57_REM];

h = heatmap(groupsX, groupsY, pValue);
title('C57 Saline v Kainate Time × Injection Effect')
h.FontSize = 14;

clim([0, 1])
h.Colormap = h.Colormap(1:200,:);

h.Colormap(1:5, :)  = repmat([75/255, 255/255, 46/255], 5, 1);
h.Colormap(6:10, :) = repmat([188/255, 255/255, 172/255], 5, 1);
h.Colormap(11:15, :)  = repmat([255/255, 217/255, 206/255], 5, 1);
h.Colormap(16:25, :)  = repmat([255/255, 176/255, 148/255], 10, 1);
h.Colormap(26:200, :) = repmat([255/255, 120/255, 76/255], 175, 1);

exportgraphics(gcf, 'C57 Saline v Kainate Time × Injection Effect.tiff', 'Resolution', 600)

%% Just Column P-values, C57 SA vs KA Wake/NREM/REM (0.0001 is really <0.0001)
figure
set(gcf, 'Units', 'Inches', 'OuterPosition', [1 1 6.5 6.5]);

groupsY = ["Baseline" ; "Sleep Dep D1" ; "Sleep Dep D2" ; "Sleep Dep D3" ; "Recovery"];
groupsX = ["Wake" ; "NREM Sleep" ; "REM Sleep"];

C57_Wake = [0.1010; 0.2743; 0.2033; 0.7852; 0.0610];
C57_NREM = [0.0853; 0.2629; 0.1579; 0.7450; 0.0500];
C57_REM  = [0.6782; 0.4320; 0.5367; 0.5449; 0.3789];

pValue = [C57_Wake, C57_NREM, C57_REM];

h = heatmap(groupsX, groupsY, pValue);
title('C57 Saline v Kainate Injection Effect')
h.FontSize = 14;

clim([0, 1])
h.Colormap = h.Colormap(1:200,:);

h.Colormap(1:5, :)  = repmat([75/255, 255/255, 46/255], 5, 1);
h.Colormap(6:10, :) = repmat([188/255, 255/255, 172/255], 5, 1);
h.Colormap(11:15, :)  = repmat([255/255, 217/255, 206/255], 5, 1);
h.Colormap(16:25, :)  = repmat([255/255, 176/255, 148/255], 10, 1);
h.Colormap(26:200, :) = repmat([255/255, 120/255, 76/255], 175, 1);

exportgraphics(gcf, 'C57 Saline v Kainate Injection Effect.tiff', 'Resolution', 600)








%%

%{
groups = ["DBA SA Baseline" ; "DBA SA SD Day 1" ; "DBA SA SD Day 2" ; "DBA SA SD Day 3" ; "DBA SA Recovery" ; ...
    "DBA KA Baseline" ; "DBA KA SD Day 1" ; "DBA KA SD Day 2" ; "DBA KA SD Day 3" ; "DBA KA Recovery"]

pValue = [NaN, 0.0002, 0.0024, , , , , , , 

h = heatmap(groups, groups, pValue)
%}





%{

%% Sample Correlation Matrix
load patients
tbl = table(LastName,Age,Gender,SelfAssessedHealthStatus,...
    Smoker,Weight,Location);
h = heatmap(tbl,'Smoker','SelfAssessedHealthStatus','ColorVariable','Age','ColorMethod','median');
xh = h.Colormap > -0.7 & h.Colormap < 0.7;
[rowIdx, colIdx] = find(xh == 1);
h.Colormap(rowIdx, colIdx) = 0.5;

%% Working towards a full correlation matrix
groups = ["C57 SA Baseline" ; "C57 SA SD Day 1" ; "C57 SA SD Day 2" ; "C57 SA SD Day 3" ; "C57 SA Recovery" ; ...
    "C57 KA Baseline" ; "C57 KA SD Day 1" ; "C57 KA SD Day 2" ; "C57 KA SD Day 3" ; "C57 KA Recovery" ; ...
    "DBA SA Baseline" ; "DBA SA SD Day 1" ; "DBA SA SD Day 2" ; "DBA SA SD Day 3" ; "DBA SA Recovery" ; ...
    "DBA KA Baseline" ; "DBA KA SD Day 1" ; "DBA KA SD Day 2" ; "DBA KA SD Day 3" ; "DBA KA Recovery"]

pValue = [NaN, 2:20; 1, NaN, 3:20 ; 1:2, NaN, 4:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20; 1:20]


h = heatmap(groups, groups, pValue)

%% Working towards automated ANOVA tests
cd('/Users/djlasky/Documents/SleepDep/DannyDelta Output/Sleep State Blocked')

sleepStates = readmatrix('Sleep Deprivation Day 1 Sleep States.csv');

DBA_Saline_REM  = sleepStates(:,80:83).';
DBA_Saline_REM = DBA_Saline_REM(:);

DBA_Kainate_REM = sleepStates(:,93:96).';
DBA_Kainate_REM = DBA_Kainate_REM(:);

DBAs = [DBA_Saline_REM, DBA_Kainate_REM];

anova2(DBAs, 4)

%}
