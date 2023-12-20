%% Input for group graphing
% Day options for graphTitle: "Baseline Day", "Sleep Deprivation Day 1", "Sleep Deprivation Day 2", "Sleep Deprivation Day 3", "Recovery Day", "All Sleep Deprivation Days"
% Treatment options for graphTitle: "C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"
inputDir   = 'P:\Jones_Maganti_Shared\Sleep Dep\Output 06-07-23';
outputDir  = 'P:\Jones_Maganti_Shared\Sleep Dep\Figures 06-07-23';
excelName = 'Master Sheet Sleep Dep';
sleepState = 'NREM Normalized Z-scored';
useScores = 1;
epochLength = 4;
graphTitle = "Recovery Day";

%% Set Excel import options to allow for days to read in as characters
importOptions = detectImportOptions(excelName);
setImport = setvartype(importOptions, 'Day', 'char');
excelArr = readtable(excelName, setImport);

%% Create filters for selecting specific days and conditions
Filter.C57  = contains(excelArr.Strain, 'C57');
Filter.DBA  = contains(excelArr.Strain, 'DBA');
Filter.SA   = contains(excelArr.Injections, 'SA');
Filter.KA   = contains(excelArr.Injections, 'KA');
Filter.Good = contains(excelArr.DataQuality, 'Good');

Filter.Baseline     = contains(excelArr.Day, 'B');
Filter.SleepDep1    = contains(excelArr.Day, '1');
Filter.SleepDep2    = contains(excelArr.Day, '2');
Filter.SleepDep3    = contains(excelArr.Day, '3');
Filter.Recovery     = contains(excelArr.Day, 'R');
Filter.AllSD        = contains(excelArr.Day, ["1", "2", "3"]);

%% Apply filters to find rows with matching conditions in the Excel sheet
C57.SA_B        = find(Filter.C57 + Filter.SA + Filter.Baseline + Filter.Good == 4);
C57.SA_1        = find(Filter.C57 + Filter.SA + Filter.SleepDep1 + Filter.Good == 4);
C57.SA_2        = find(Filter.C57 + Filter.SA + Filter.SleepDep2 + Filter.Good == 4);
C57.SA_3        = find(Filter.C57 + Filter.SA + Filter.SleepDep3 + Filter.Good == 4);
C57.SA_R        = find(Filter.C57 + Filter.SA + Filter.Recovery + Filter.Good == 4);
C57.SA_AllSD    = find(Filter.C57 + Filter.SA + Filter.AllSD + Filter.Good == 4);

C57.KA_B        = find(Filter.C57 + Filter.KA + Filter.Baseline + Filter.Good == 4);
C57.KA_1        = find(Filter.C57 + Filter.KA + Filter.SleepDep1 + Filter.Good == 4);
C57.KA_2        = find(Filter.C57 + Filter.KA + Filter.SleepDep2 + Filter.Good == 4);
C57.KA_3        = find(Filter.C57 + Filter.KA + Filter.SleepDep3 + Filter.Good == 4);
C57.KA_R        = find(Filter.C57 + Filter.KA + Filter.Recovery + Filter.Good == 4);
C57.KA_AllSD    = find(Filter.C57 + Filter.KA + Filter.AllSD + Filter.Good == 4);

DBA.SA_B        = find(Filter.DBA + Filter.SA + Filter.Baseline + Filter.Good == 4);
DBA.SA_1        = find(Filter.DBA + Filter.SA + Filter.SleepDep1 + Filter.Good == 4);
DBA.SA_2        = find(Filter.DBA + Filter.SA + Filter.SleepDep2 + Filter.Good == 4);
DBA.SA_3        = find(Filter.DBA + Filter.SA + Filter.SleepDep3 + Filter.Good == 4);
DBA.SA_R        = find(Filter.DBA + Filter.SA + Filter.Recovery + Filter.Good == 4);
DBA.SA_AllSD    = find(Filter.DBA + Filter.SA + Filter.AllSD + Filter.Good == 4);

DBA.KA_B        = find(Filter.DBA + Filter.KA + Filter.Baseline + Filter.Good == 4);
DBA.KA_1        = find(Filter.DBA + Filter.KA + Filter.SleepDep1 + Filter.Good == 4);
DBA.KA_2        = find(Filter.DBA + Filter.KA + Filter.SleepDep2 + Filter.Good == 4);
DBA.KA_3        = find(Filter.DBA + Filter.KA + Filter.SleepDep3 + Filter.Good == 4);
DBA.KA_R        = find(Filter.DBA + Filter.KA + Filter.Recovery + Filter.Good == 4);
DBA.KA_AllSD    = find(Filter.DBA + Filter.KA + Filter.AllSD + Filter.Good == 4);

%% Prepare specific groups for graphing based on graphTitle variable
if contains(graphTitle, ["Baseline Day", "Sleep Deprivation Day 1", "Sleep Deprivation Day 2", "Sleep Deprivation Day 3", "Recovery Day", "Average of Sleep Deprivation Days"])
    groupNames = ["C57 Saline"; "C57 Kainate"; "DBA Saline"; "DBA Kainate"];
    colorCodes = ["#4dbeee"; "#0072bd"; "#ff6929"; 	"#a2142f"];
elseif contains(graphTitle, ["C57 Saline", "C57 Kainate", "DBA Saline", "DBA Kainate"])
    groupNames = ["Baseline Day"; "Sleep Deprivation Day 1"; "Sleep Deprivation Day 2"; "Sleep Deprivation Day 3"; "Recovery Day"];
    colorCodes = ["#6495ed"; "#5ec22e"; "#3d9612"; "#1e4b09"; "#D22b2b"];
end

if graphTitle == "Baseline Day"
    excelGroups = {C57.SA_B; C57.KA_B; DBA.SA_B; DBA.KA_B};
elseif graphTitle == "Sleep Deprivation Day 1"
    excelGroups = {C57.SA_1; C57.KA_1; DBA.SA_1; DBA.KA_1};
elseif graphTitle == "Sleep Deprivation Day 2"
    excelGroups = {C57.SA_2; C57.KA_2; DBA.SA_2; DBA.KA_2};
elseif graphTitle == "Sleep Deprivation Day 3"
    excelGroups = {C57.SA_3; C57.KA_3; DBA.SA_3; DBA.KA_3};
elseif graphTitle == "Recovery Day"
    excelGroups = {C57.SA_R; C57.KA_R; DBA.SA_R; DBA.KA_R};
elseif graphTitle == "Average of Sleep Deprivation Days"
    excelGroups = {C57.SA_AllSD; C57.KA_AllSD; DBA.SA_AllSD; DBA.KA_AllSD};
elseif graphTitle == "C57 Saline"
     excelGroups = {C57.SA_B; C57.SA_1; C57.SA_2; C57.SA_3; C57.SA_R};
elseif graphTitle == "C57 Kainate"
    excelGroups = {C57.KA_B; C57.KA_1; C57.KA_2; C57.KA_3; C57.KA_R};
elseif graphTitle == "DBA Saline"
     excelGroups = {DBA.SA_B; DBA.SA_1; DBA.SA_2; DBA.SA_3; DBA.SA_R};
elseif graphTitle == "DBA Kainate"
    excelGroups = {DBA.KA_B; DBA.KA_1; DBA.KA_2; DBA.KA_3; DBA.KA_R};
else
    error("graphTitle must contain a valid title")
end

%% Prepare files within each group to be analyzed together
numGroups = length(excelGroups);
fileTable = cell(numGroups,1);
fileArr = cell(numGroups,1);

for n = 1:numGroups
	fileTable{n} = excelArr(excelGroups{n},'FilePath');
	fileArr{n} = table2array(fileTable{n});
end

%% Grouped 24-hour delta power graph and table
DD_24HrDeltaGroup(fileArr, numGroups, inputDir, outputDir, groupNames, graphTitle, sleepState, colorCodes);

%% Grouped sleep state graph and table
if useScores == 1
	DD_StateTimeGroup(fileArr, numGroups, inputDir, outputDir, groupNames, graphTitle, colorCodes);
end

%% Grouped homeostasis analysis and graphing by line and curve parameters
%DD_HomeoMulti(fileArr, numGroups, inputHomeo, outputDir, groupNames, graphTitle, colorCodes)
