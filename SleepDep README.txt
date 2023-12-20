SleepDep
Sleep analysis code developed in the Jones and Maganti Labs

The following toolboxes are required to run the scripts:
	Signal Processing Toolbox
	Statistics and Machine Learning Toolbox
	Econometrics Toolbox (only for Hayden's Markov Model code)

Hello! Welcome to the README for the sleep analysis scripts. This will explain the expectations for data being read into these scripts
and how to use them correcty. Feel free to reach me at djlasky@ucdavis.edu or dannyjlasky@gmail.com if you require necessary assistance.

Danny Lasky, 2023

IMPORTANT: DD_Align is for EGGs recorded before March 2023 and will only function on these files. If it were to function on files recorded after this date it would MISALIGN them.
	The script accounts for computer based issues that were unique to the Maganti lab and this script should not be run on data from other labs without these unique problems.

Matlab basics
- I strongly recommend taking Matlab Onramp, a free online 2-hour course, before using the script at all
- I strongly recommend taking Matlab Fundamentals, a free online 16 hour course, before intending to make any significant changes to the script
- You need all related files in your Matlab path before running. On the "HOME" tab click "Set Path"
- Add folders/subfolders until all the code, input files, and Excel spreadsheet are in your Matlab path and save
- Path names will be different on a Mac compared to Windows, keep this in mind
- You will get errors! View these errors as challenges, not as impedences. Stack Overflow, Matlab answers, and Matlab documentation will be your best friends
- Google errors exactly as they pop up. These issues have been encountered before and are all online

Expectations for input files
- You require an EDF to run the script. So far they have been 24-hour files
- If the mice are sleep scored, you can have an additional TXT file to analyze the sleep scores
- These two files must have the same name other than the extension (Example: Animal_1_day_2.edf and Animal_1_day_2.txt, the capitalization and characters must all match exactly)
	
To prepare a TXT file to run:
1. Open Sirenia Sleep Pro
2. File > Open > (Load in sleep scored EDF)
3. File > Export > Scores To TSV > (Name it the same as the EDF)

Preparing the Excel sheet
- Enter the data in an Excel spreadsheet in a similar way as Master Sheet Sleep Dep (C57sDBAs tab) 
- The path to this Excel sheet is: "P:\Jones_Maganti_Shared\Sleep Dep\Master Sheet Sleep Dep.xlsx"
- In this spreadsheet, you want to format your data like the "C57sDBAs" tab. The most important part is having the full file paths in a column titled exactly as "FilePath"

Running the single file analysis
1. Open DannyDelta: This is the master script and will call all other scripts as functions to be performed
	- You will change rows 5-9 (between the CHANGE MEs) to specify the inputs
	- "ExcelRows" are the rows you want analyzed (will read the file paths from those rows)
	- "useScores" is a toggle (0 off, 1 on) for using the sleep scores TXT. Have it set to "1" to do sleep state analysis
	- "epochLength" is the length of the sleep scored epochs, thus far this has always been 4 seconds
	- "tableName" is the name of the Excel table you want to pull the file paths from
	- "inputDir" is the folder you want the data inputted from
	- "outputDir" is the folder you want the data outputted to

2. The data will be read in and some unnecessary warnings turned off to remove clutter. The looping section of the script will then begin with the first file and proceed through one by one

Single Analysis Loop
3. DD_Read: The EDF and TXT files are read into Matlab.
	- We select the right frontal lobe signal to perform the analysis on (except for one animal where the right frontal and left parietal signals were swapped)
	- We also check that the signal was sampled at the rate we expect (512 Hz)
	- After this, the number of points in an epoch and total number of epochs are calculated in the main DannyDelta script

4. normalizeEEG: Performs 60 Hz filtering (sixtyHzFilt_EEG), highpass filtering (highPassChebyshev1Filt_EEG), and gaussian normalization
	- All written by Jesse Pfammatter. Starts by removing 60-Hz artifact from the signal, then removes low frequency sound below 0.5 Hz
	- Then performs a variation of z-score normalization fitting them to a gaussian curve to make animals directly comparable to one another. In-depth description on page 4 of Pfammatter, 
		J. A., Bergstrom, R. A., Wallace, E. P., Maganti, R. K., & Jones, M. V. (2018). A predictive epilepsy index based on probabilistic classification of interictal spike waveforms. 
		Plos one, 13(11), e0207158.

5. DD_Bandpower: Computes the average delta (0.5–4 Hz), theta (6–9 Hz), sigma (10–14 Hz), and gamma (30–70 Hz) powers of the EEG in each epoch using a simple power spectrum (from Sunogawa paper)
	- Also computes the average frequency of each epoch in these bandpowers, but I'm 90% sure this is not working properly. Has not been a part of any analysis thus far.

6. DD_Align: Realigns all computed bandpowers and frequencies to zeitgeber time (0 = lights turn on)
	- One machine was recording with a 6:30 am start/end time, which was correct since the lights come on at 6:30 am
	- A second machine was recording with a 5:30 am start/end time, which was an hour before lights come on
	- An additional issue was that the lights changed with Daylight Savings Time, but the computers were not, so that was another source of misalignment
	- IMPORTANTLY, Jesse and I fixed both of these issues around March 2023. Now both machines are recording with a 6:30 am start time and change with Daylight Savings correctly
	- IMPORTANTLY, these means that EEGs recorded after March 2023 do not need to use DD_Align, and would actually become misaligned by it's hard-coded Daylight Savings adjustment

7. DD_Scores: Realigns all sleep scores to zeitgeber time (0 = lights turn on)
	- Also changes scored artifact between periods of Wake to be Wake, as this would significantly affect the homeostasis calculations if it were left as artifact

8. DD_NormHour: Performs bandpower normalization, removes epochs with bandpowers with a z-score ± 3, and computes hourly bandpowers. Also divides results by sleep state
	- Does all of this for both delta and gamma bandpowers
	- Delta normalization is delta/(theta+sigma+gamma), gamma normalization is gamma/(delta+theta+sigma)
	- Bandpowers are first normalized, then removed if ± 3 standard deviations from the mean (separately for each sleep state)
	- N denotes normalized bandpowers, NA denotes normalized z-scored (artifact-free) bandpowers
	- Makes output Excel sheets for all these bandpowers
	- Back in main script, the output directory is made and the Excel sheets are written to it












Good Luck,
Danny
