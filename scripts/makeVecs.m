cd('/Volumes/research/esnp/ssrt/output/data/analysisReady');
exclude = [1 3 25]; % If you want to exclude any numbers, put them in this vector (e.g. exclude = [5 20];)
numSubs = 29;
numRuns = 2;

% These two codes should reflect what's in the response column of the Seeker variable
% You'll specify exceptions to this rule below
% leftButton=91;
% rightButton=94;
% studyPrefix='INC'; % You'll use this in your analysisReady data filenames
leftButton=94;
rightButton=95;
studyPrefix='ESNP'; % You'll use this in your analysisReady data filenames
% jitterListFile='jitter.txt';
% postjitter = textread(jitterListFile, '%n','delimiter', '\t', 'whitespace', '', 'commentstyle', 'matlab' );

%% DEFINE EXCEPTIONS TO BUTTON RULE
% Make each exception a string for what subject (s) and what run (2) it
% applies
% problemSubjects = [2,12];
% problemRuns= {2,{3,4,5}};
% alternativeRules={'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'};
problemSubjects = [5 7 8 10 17 18 20 23 24 26];
problemRuns= {[1 2] [1 2] [1 2] [2] [1 2] [1 2] [1 2] [2] [1 2] [1]};
alternativeRules={{'LEFT = 90;RIGHT = 91;','LEFT = 89;RIGHT = 91;'},
    {'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = 95;RIGHT = 96;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = 90;RIGHT = 91;','LEFT = 90;RIGHT = 91;'}
    {'LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;'}
    };
% Some versions of the SST set up the Seeker variable differently.
% The script should tell you which columns are which and what different
% codes mean, but you can also deduce it from looking at the actual output.
% Change these to reflect your Seeker variable structure.
% trialTypeColumn=3;
% arrowDirColumn=4;
% responseKeyColumn=7;
% trialTimeColumn=12;
% trialLengthColumn=15;
% goCode=0;
% stopCode=1;
% leftCode=0;
% rightCode=1;
trialTypeColumn=3;
arrowDirColumn=4;
responseKeyColumn=7;
trialTimeColumn=12;
goCode=0;
stopCode=1;
leftCode=0;
rightCode=1;

trialLength=1;

% Initialize variable
trashCount = nan(numSubs,numRuns);

for s=1:numSubs
    
    if find(exclude==s)
        % keep as NaNs
    else
        % Create subjectCode
        if s<10
            placeholder = '00';
        elseif s<100
            placeholder = '0';
        else
            placeholder = '';
        end
        
        subjectCode = [studyPrefix placeholder num2str(s)];
        
        
        % for each of the four SSRT runs
        for r=1:numRuns
            
            names = {'CorrectGo' 'CorrectStop' 'FailedStop' 'Cue'}; % will append trash as necessary
            onsets = cell(1,4);
            durations = cell(1,4);
            
            load([studyPrefix num2str(s) '_r' num2str(r) '_SSRT.mat'])
                        
            % define button responses
            LEFT = leftButton;
            RIGHT = rightButton;
            
            for e=1:length(problemSubjects)
                problemRunList = problemRuns{e};
                alternativeRuleList = alternativeRules{e};
                switch s
                    case problemSubjects(e) %only run code below if current sub is a problem sub
                        
                        for f = 1:length(problemRunList)
                            switch r
                            case problemRunList(f) %only run code below if current run is a problem run for this sub
                                eval(alternativeRuleList{f})
                            otherwise
                                LEFT = leftButton;
                                RIGHT = rightButton;
                            end
                        end
                end
            end
            
            % Get vectors of trial info
            trialType = Seeker(:,trialTypeColumn); % 0=Go, 1=NoGo, 2=null, 3=notrial`
            arrowDir = Seeker(:,arrowDirColumn); % 0=left, 1=right, 2=null
            responseKey = Seeker(:,responseKeyColumn);
            trialTime = Seeker(:,trialTimeColumn);
%             trialLength = Seeker(:,trialLengthColumn);
            
            % To Beep Or Not To Beep
            isGo = trialType==goCode;
            isStop = trialType==stopCode;
            
            % Arrow presented
            isLeft = arrowDir==leftCode;
            isRight = arrowDir==rightCode;
            
            % Button response
            isLeftKey = responseKey==LEFT;
            isRightKey = responseKey==RIGHT;
            isNoResponse = responseKey==0;
            
            
            isCorrect = isLeft&isLeftKey | isRight&isRightKey;
            isPressed = isLeftKey|isRightKey;
            
            %%%%% Find Important Trial Types
            isCorrectGo = isGo&isCorrect; % Hits
            isCorrectStop = isStop&isNoResponse; % Correct Rejections
            isFailedStop = isStop&isPressed; % False Alarms (even if it's the wrong button)
            isIncorrectGo = (isGo&isNoResponse)|(isGo&(~isCorrect));% Misses or "wrong" hits - will be trashed
           
            
            %%%%% The Important Variables %%%%%
            onsets{1} = trialTime(isCorrectGo)+.5;
            onsets{2} = trialTime(isCorrectStop)+.5;
            onsets{3} = trialTime(isFailedStop)+.5;
            onsets{4} = trialTime(isCorrectGo|isCorrectStop|isFailedStop|isIncorrectGo);
            
            durations{1} = 1;
            durations{2} = 1;
            durations{3} = 1;
            durations{4} = nan(length(onsets{4}),1);
            durations{4}(:) = .5;
            
            % Trash?
            if find(isIncorrectGo) % If there's trash, trash it
                names{5} = 'Trash';
                onsets{5} = trialTime(isIncorrectGo)+.5;
                durations{5} = 1;
                trashCount(s,r)=sum(isIncorrectGo);
            end
            
            fxFolder = ['../../../subjects/' subjectCode '/fx/vecs/'];
            mkdir(fxFolder)
            save([fxFolder 'SSRT' num2str(r) '_onsets.mat'],'names','onsets','durations');
            
        end % run loop
    end % subject loop
end

dlmwrite(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/initialCheck/trashCount.txt'],trashCount,'delimiter','\t');

clear