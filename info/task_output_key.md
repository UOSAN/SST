# Task Output
This tasks writes output to a file named `sub-<subject code>_ses-1_task-SST_run-<session number>_beh.mat`.
The output contains several named variables: `Seeker`, `params`, `Ladder1`, `Ladder2`, `error`, `rt`, `count_rt`, `subject_code`, `sub_session`.
The `Seeker` variable contains the subject responses and task output described below:

## Stimuli and Response on same matrix, pre-determined

- **Column 1**: trial number
- **Column 2**: the numchunks number (1-NUMCHUNKS)
- **Column 3**: trial type. 0 = Go, 1 = NoGo, 2 = null trial, 3 = no-trial.
- **Column 4**: stimulus presented. 0 = cue followed by left arrow, 1 = cue followed by right arrow, 2 = blank screen (null trial)
- **Column 5**: the ladder number (1 or 2)
- **Column 6**: the value currently in "LadderX", corresponding to SSD (msec)
- **Column 7**: the subject response as a keycode (no response is 0)
- **Column 8**: the ladder movement (-1 = Stop Signal Delay decreased, +1 = Stop Signal Delay increased, 0 for N/A)
- **Column 9**: the reaction time (sec)
- **Column 10**: the actual SSD (for error-check) (this value appears to be always 0)
- **Column 11**: the actual SSD plus time taken to run the command (this value appears to be always 0)
- **Column 12**: the absolute time since beginning of task that trial begins (sec)
- **Column 13**: the elapsed time since the beginning of the block at moment when arrows are shown (this value appears to be always 0)
- **Column 14**: the actual SSD for error check (time from arrow displayed to beep played) (sec)
- **Column 15**: the duration of the trial from trialcode (sec). The duration is prepopulated from the ladder/input files and is not logged in real time during the task.
- **Column 16**: the start time of the trial (sec)
