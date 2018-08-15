%%%%% Updated 1-3-15 by LEK

% This script takes your SST output and checks to make sure there are no
% strange responses. You will get a bunch of output files of the form N x R
% (N subjects, R runs) telling you how many go trials per run (should always be
% the same number, say, 96) how many stop trials (should be 32)

% and importantly:

% how many NO RESPONSE trials
% (should be as low as possible, but a few isn't worrisome -- lots means
% they may have been responding so slowly that the script wasn't
% recognizing their response and was falsely categorizing them as stops
% which is bad!)

% how many WRONG GO trials
% In the absence of any "weird buttons," lots of wrong gos sometimes means
% they just flipped the buttons, either because they were handed the button
% boxes backwards, or they were thinking about the "open side" of the arrow
% rather than the direction it was pointing.

% how many "WEIRD BUTTON" trials
% This counts how many times they pressed buttons other than the ones you
% specify below (e.g. 91 & 94, 3 & 6, whatever)
% If they consistently pressed 2 & 7, for example, you can still use the
% data. If they flipped half way through, it'll be harder.

cd('/Users/giuliani/Desktop/StopSignal/output/data/analysisReady/')
% This should be the folder where your consistently-named SST output live.
% This script assumed they are named with this format: "INC2_r3_SSRT.mat"
% "INC" should be replaced with your study prefix.
% This would be the 3rd run for the 2nd subject.

% These two codes should reflect what's in the response column of the Seeker variable
% Scanner is usually 91 & 94; Behavioral (keyboard) is 197 & 198

leftButton=94;
rightButton=95;

studyPrefix='ESNP'; % You'll use this in your analysisReady data filenames

% Change these
numSubs = 29;
exclude = [1 3 5 6 17 19 20 25 29];
numRuns = 2;

% Some versions of the SST set up the Seeker variable differently.
% The script should tell you which columns are which and what different
% codes mean, but you can also deduce it from looking at the actual output.
% Change these to reflect your Seeker variable structure.
% trialTypeColumn=3;
% arrowDirColumn=4;
% responseKeyColumn=7;
% goCode=0;
% stopCode=1;
% leftCode=0;
% rightCode=1;
trialTypeColumn=3;
arrowDirColumn=4;
responseKeyColumn=7;
goCode=0;
stopCode=1;
leftCode=0;
rightCode=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
weirdButtonCountMat=nan(numSubs,numRuns);
goCountMat=nan(numSubs,numRuns);
stopCountMat=nan(numSubs,numRuns);
NRCountMat=nan(numSubs,numRuns);
wrongGoCountMat=nan(numSubs,numRuns);

for s=1:numSubs
    if find(exclude==s)
        %leave as NaNs
    else
        for r=1:numRuns
            load([studyPrefix num2str(s) '_r' num2str(r) '_SSRT.mat'])
           
            trialType=Seeker(:,trialTypeColumn); % 0=Go, 1=NoGo, 2=null, 3=notrial
            arrowDir=Seeker(:,arrowDirColumn); % 0=left, 1=right, 2=null
            responseKey=Seeker(:,responseKeyColumn);
            numGoTrials = sum(trialType==goCode);
            numStopTrials = sum(trialType==stopCode);
            isGo = trialType==goCode;
            isCorrectButton = (arrowDir==leftCode&responseKey==leftButton)|(arrowDir==rightCode&responseKey==rightButton);
            numCorrectGoTrials = sum(isGo&isCorrectButton);
            numBadGoTrials = numGoTrials - numCorrectGoTrials;
            numNRTrials = sum(isGo&responseKey==0);
            weirdButtonTrials = ~(responseKey==0|responseKey==leftButton|responseKey==rightButton);
            
            wrongGoCountMat(s,r) = numBadGoTrials - numNRTrials;
            goCountMat(s,r) = numGoTrials;
            stopCountMat(s,r) = numStopTrials;
            NRCountMat(s,r) = numNRTrials;
            weirdButtonCountMat(s,r) = sum(weirdButtonTrials);
        end
    end
end

if numSubs<10
    placeholder = '00';
elseif numSubs<100
    placeholder = '0';
else placeholder = '';
end

% I make a new directory for output each time I check my data, based on how
% many subjects I've run:
mkdir(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs)])
% The output for this initial check goes here:
mkdir(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/initialCheck/'])
% For all the single-var texts, with an N x R matrix of that particular
% variable:
mkdir(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/singleVarTxts/'])
% For collapsing across runs, and getting output of the form N x V where
% V=number of variables you're looking at for each subject:
mkdir(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/collapsed/'])
% For .mat files containing all variables you might want to import at a
% later time (say, while collapsing):
mkdir(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/varMats/'])

dlmwrite(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/initialCheck/wrongGoCount.txt'],wrongGoCountMat,'delimiter','\t');
dlmwrite(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/initialCheck/goCount.txt'],goCountMat,'delimiter','\t');
dlmwrite(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/initialCheck/stopCount.txt'],stopCountMat,'delimiter','\t');
dlmwrite(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/initialCheck/NRCount.txt'],NRCountMat,'delimiter','\t');
dlmwrite(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/initialCheck/weirdButtonCount.txt'],weirdButtonCountMat,'delimiter','\t');
