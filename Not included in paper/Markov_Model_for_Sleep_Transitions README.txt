This is the README for the Markov_Model_for_Sleep_Transitions.mlx script

Created by Hayden Kosiara, 2023

Description: 

This script is designed to read text files of scored EEG data. Sections of EEG data will be scored as Wake, NREM, and REM sleep (labeled as 1, 2, and 3 respectively).
This script will count the number of observed transitions that actually occured during the period of interest. The matrix of observed transitions between states
is then fed to the dtmc function (requires MATLAB Econometrics Toolbox) which creates a discrete time Markov chain that attempts to construct a matrix of
the probabilites of certain transitions occurring from each initial state given the set of transitions that actually occurred. The flow of the script is as follows:

-specify the file save path and filters for desired mouse strain, injection, and day
-load in relevant data (txt files that correspond to your filters)
-count each type of transition that occurs by comparing the scored number between two data points e.g. 1 to 2 is a Wake to NREM transition. There are n^2 total transtition types
-save the observed counts of transitions for all mice in the selected group in a cell variable
-average the counts
-arrange the averaged counts in an nState x nState matrix (variable name P)
-create dtmc using P (in code this is literally dtmc(P))
-visualize the Markov chain through various figures
-save figures to file path

**Note: 

The standard 3x3 Markov model cannot be created if a transition is not observed. For example, if all mice were only awake or in NREM sleep during the specified period of time,
then REM sleep was never encountered. As such, the matrix P that will be fed to dtmc will read something like:

*  *  *  *  *  *  *
Wake 0.98  0.02 0
NREM 0.04  0.96 0
REM  0     0    0
     Wake NREM REM
*  *  *  *  *  *  *

Notice that the entire third row is empty, this will produce an error as you are attempting to ask MATLAB to create a 3 state markov model when only two states were ever encountered. To
deal with this issue, the code contains multiple conditional checks to assess if any of the states were not visited, and create a Markov model with the appropriate dimensions that agree with
the observed number of transitions.

I ran into this issue more often during the development of the script because I was not yet averaging the transition counts. Averaging among multiple subjects drastically reduces 
the likelihoodof a situation like this being encountered. Nonetheless, I have still encountered one or two cases where it does happen, so this portion of the code is still 
necessary, while cumbersome to look at.





If you have any questions about this script, please feel free to contact me at the following email address:

haydenkosiara@comcast.net



