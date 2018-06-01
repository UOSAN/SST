# Analysis
## Data prep

(1) Pick a code like “REV” as the prefix for all the data files

(2) Make sure the behavioral files are in the appropriate directories 

---------------------------------

## Scripts

(1) Open `prep4analysis.m`, change necessary params, and run. It will move your raw output files into the `analysisReady` directory and rename them.

(2) Open, adjust, and run `initialCheck.m`
You may need to change some parameters (like acceptable key codes, number of subjects, runs, etc)
 
After running this, look at the `wrongGoCount.txt` and `weirdResponseCount.txt` files. You may then have to do some detective work to figure out why you had so many wrong Gos. Often people will switch the buttons, or they'll use different buttons altogether. You will not touch the data files, but you will specify the alternate button rules in the following two scripts.

(3) Run `extractAllSSTresults.m`
Make sure to enter the exceptions to the response key rules in the parameters you fill out at the top of the script. Follow the formatting of the example in the comments. 

If needed, create text files to specify runs on which alternative button rules are required. Save these files in the `info` directory as `systematicWrongButtons.txt` and `inconsistentWrongButtons.txt`.

(4) Run `makeVecs.m` to make vector files (multiple condition files) for single-subject fMRI models [current version won’t work; needs updating]