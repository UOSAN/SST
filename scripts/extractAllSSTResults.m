revision_date='1-3-15';

cd('/Users/giuliani/Desktop/StopSignal/output/data/analysisReady/');
steps=16; %16 looks at all data, 8 looks at half of the data (LEK recommends using 16)
exclude = [1 3 5 6 17 19 20 25 29]; % If you want to exclude any numbers, put them in this vector (e.g. exclude = [5 20];)
numSubs = 29;
numRuns = 2;

% These two codes should reflect what's in the response column of the Seeker variable
% You'll specify exceptions to this rule below
% leftButtonList=[94];
% rightButtonList=[94];
% studyPrefix='INC'; % You'll use this in your analysisReady data filenames
leftButton=94;
rightButton=95;
studyPrefix='ESNP'; % You'll use this in your analysisReady data filenames

%% DEFINE EXCEPTIONS TO BUTTON RULE
% Make each exception a string for what subject (s) and what run (2) it
% applies
% problemSubjects = [2,12];
% problemRuns= {2,{3,4,5}};
% alternativeRules={'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'};
problemSubjects = [7 8 10 18 23 24 26];
problemRuns= {[1 2] [1 2] [2] [1 2] [2] [1 2] [1]};
alternativeRules={
    {'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = 95;RIGHT = 96;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;','LEFT = rightButton;RIGHT = leftButton;'}
    {'LEFT = rightButton;RIGHT = leftButton;'}
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numSubs<10
    placeholder = '00';
elseif numSubs<100
    placeholder = '0';
else placeholder = '';
end

%%%%%%

NRCount = dlmread(['../../compiledResults/upto' studyPrefix placeholder num2str(numSubs) '/initialCheck/NRCount.txt'],'\t');


% Initialize variables
results = nan(numSubs,numRuns,10);

for s=1:numSubs
    if find(exclude==s)
        % keep as NaNs
    else
        for r=1:numRuns
            filename=[studyPrefix num2str(s) '_r' num2str(r) '_SSRT.mat'];

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
            
            
            %             if (s==2&&r==2) || (s==12&&r>2) % Change these to reflect your exceptions
            %                 LEFT = rightButton;
            %                 RIGHT = leftButton;
            %             else
            %                 LEFT = leftButton;
            %                 RIGHT = rightButton;
            %             end
            %
            
            [GRTmean GRTmedian StDevGRT SSRT GRTquant SSRTquant GRTint SSRTint PctInhib SSDfifty] = extractSSTResults(filename,RIGHT,LEFT,steps);
            results(s,r,1:10) = [GRTmean GRTmedian StDevGRT SSRT GRTquant SSRTquant GRTint SSRTint mean(PctInhib) SSDfifty];
            
        end
        
    end
end


GRTmean_results = results(:,:,1);
GRTmedian_results = results(:,:,2);
GRTmedian_GoOnly_results = results(:,:,3);
SSRT_results = results(:,:,4);
GRTquant_results = results(:,:,5);
SSRTquant_results = results(:,:,6);
GRTint_results = results(:,:,7);
SSRTint_results = results(:,:,8);
PctInhib_results = results(:,:,9);
SSD_results = results(:,:,10);
NRCount_results = NRCount;

%%%%%%%% SAVE VARIABLES (txt & mat)

varList = {'GRTmean','GRTmedian','SSRT','GRTquant','GRTint','SSRTint','PctInhib','SSD','NRCount'};

for v=1:length(varList)
    currentVar = varList{v};
    command1 = ['dlmwrite([''../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/singleVarTxts/' studyPrefix '_'' varList{v} num2str(steps) ''.txt''],' currentVar '_results,''delimiter'',''\t'');'];
    eval(command1);
end

save(['../../compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/varMats/resultVars' num2str(steps)],'GRTmean_results','GRTmedian_results','SSRT_results','GRTquant_results','SSRTquant_results','GRTint_results','SSRTint_results','SSD_results','PctInhib_results','NRCount')