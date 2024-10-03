SleepDep
Sleep analysis code developed in the Jones and Maganti Labs
Feel free to reach me at djlasky@ucdavis.edu or dannyjlasky@gmail.com. D.L. 2024

The following toolboxes are required to run the scripts:
	Signal Processing Toolbox
	DSP System Toolbox
	Statistics and Machine Learning Toolbox
	Econometrics Toolbox (only for Hayden's Markov Model code)

Expectations for input files
	You require an EDF to run the script. So far they have been 24-hour files
	If the mice are sleep scored, you can have an additional TXT file to analyze the sleep scores
	These two files must have the EXACT same name other than the extension (e.g., "Animal_1_day_2.edf" and "Animal_1_day_2.txt")
	
To prepare a TXT file to run:
	1. Open Sirenia Sleep Pro
	2. File > Open > (Load in sleep scored EDF)
	3. File > Export > Scores To TSV > (Name it the same as the EDF)

Preparing the Excel sheet
	Enter the data in an Excel spreadsheet in a similar way as Master Sheet Sleep Dep (C57sDBAs tab) 
	The path to this Excel sheet is: "P:\Jones_Maganti_Shared\Sleep Dep\Master Sheet Sleep Dep.xlsx"
	In this spreadsheet, you want to format your data like the "C57sDBAs" tab. The most important part is having the full file paths in a column titled exactly as "FilePath"

DannyDelta Single Analysis Loop
	DannyDelta: This is the master script and will call all other scripts as functions to be performed
		You will change rows 5-9 (between the CHANGE MEs) to specify the inputs
		"ExcelRows" are the rows you want analyzed (will read the file paths from those rows)
		"useScores" is a toggle (0 off, 1 on) for using the sleep scores TXT. Have it set to "1" to do sleep state analysis
		"epochLength" is the length of the sleep scored epochs, thus far this has always been 4 seconds
		"tableName" is the name of the Excel table you want to pull the file paths from
		"inputDir" is the folder you want the data inputted from
		"outputDir" is the folder you want the data outputted to

	DD_Read: Read in EDF and sleep scores, select the RF signal, and expand the array.
	
	normalizeEEG: Performs 60 Hz filtering (sixtyHzFilt_EEG), highpass filtering (0.5 Hz; highPassChebyshev1Filt_EEG), and Gaussian normalization
		All written by Jesse Pfammatter. Starts by removing 60-Hz artifact from the signal, then removes low frequency sound below 0.5 Hz
		Then performs a variation of z-score normalization fitting them to a gaussian curve to make animals directly comparable to one another. In-depth description on page 4 of Pfammatter, J. A., Bergstrom, R. A., Wallace, E. P., Maganti, R. K., & Jones, M. V. (2018). A predictive epilepsy index based on probabilistic classification of interictal spike waveforms. Plos one, 13(11), e0207158.
		Also makes use of the function "fit_gauss"

	DD_Bandpower: Computes the average delta (0.5–4 Hz), theta (6–9 Hz), sigma (10–14 Hz), and gamma (30–70 Hz) powers of the EEG in each epoch using a simple power spectrum (from Sunogawa paper)
		Also computes the average frequency of each epoch in these bandpowers, but I'm 90% sure this is not working properly. Has not been a part of any analysis thus far.

	DD_Align: Realigns all computed bandpowers and frequencies to zeitgeber time (0 = lights turn on)
		One machine was recording with a 6:30 am start/end time, which was correct since the lights come on at 6:30 am
		A second machine was recording with a 5:30 am start/end time, which was an hour before lights come on
		An additional issue was that the lights changed with Daylight Savings Time, but the computers did not, so that was another source of misalignment
		IMPORTANTLY, Jesse and I fixed both of these issues around March 2023. Now both machines are recording with a 6:30 am start time and change with Daylight Savings correctly
		Thus, EEGs recorded after March 2023 are coded not to have the additional shift due to DST

	DD_Scores: Realigns all sleep scores to zeitgeber time (0 = lights turn on)
		Also changes scored artifact between periods of Wake to be Wake, as this would significantly affect the homeostasis calculations if it were left as artifact

	DD_NormHour: Performs bandpower normalization, removes epochs with bandpowers with a z-score ± 3, and computes hourly bandpowers. Also divides results by sleep state
		Does all of this for both delta and gamma bandpowers
		Delta normalization is delta/(theta+sigma+gamma), gamma normalization is gamma/(delta+theta+sigma)
		Bandpowers are first normalized, then removed if ± 3 standard deviations from the mean (separately for each sleep state)
		N denotes normalized bandpowers, NA denotes normalized z-scored (artifact-free) bandpowers
		Makes output Excel sheets for all these bandpowers

	DD_24HrDelta: Create hourly delta gamma graphs for all epochs or a sleep state

	DD_StateTime: Create hourly time spent in Wake/NREM/REM graphs

DannyDeltaGroup Group Analysis Loop
	DannyDeltaGroup: Master script that works with single file outputs to perform grouped analysis and graphing

	DD_24HrDeltaGroup: Grouped 24-hour delta power graph and table

	DD_StateTimeGroup: Grouped sleep state graph and table

Homeostasis Anaylsis
	SleepClusters: Was not used directly in the paper, but it is a useful tool for visualizing the spacing of different sleep states

	DD_Homeostasis: Single animal homeostasis analysis (rise and decline)

	DD_HomeostasisGroup: Pools together the single animal homeostasis analysis to create group rise and decline

	DD_HomeostasisSingleFigure: Generates the figure used in the publication displaying the rise and decline of single animals