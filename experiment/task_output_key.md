# Task Output
## Stimuli and Response on same matrix, pre-determined

    - The first column is trial number;
    - The second column is numchunks number (1-NUMCHUNKS);
    - The third column is 0 = Go, 1 = NoGo; 2 is null, 3 is notrial (kluge, see opt_stop.m)
    - The fourth column is 0=left, 1=right arrow; 2 is null
    - The fifth column is ladder number (1-2);
    - The sixth column is the value currently in "LadderX", corresponding to SSD
    - The seventh column is subject response (no response is 0);
    - The eighth column is ladder movement (-1 for down, +1 for up, 0 for N/A)
    - The ninth column is their reaction time (sec)
    - The tenth column is their actual SSD (for error-check)
    - The 11th column is their actual SSD plus time taken to run the command
    - The 12th column is absolute time since beginning of task that trial begins
    - The 13th column is the time elapsed since the beginning of the block at moment when arrows are shown
    - The 14th column is the actual SSD for error check (time from arrow displayed to beep played)
    - The 15th column is the duration of the trial from trialcode
    - The 16th column is the time_course from trialcode