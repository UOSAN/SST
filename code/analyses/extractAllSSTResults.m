revision_date='7-3-18';

studyFolder = '~/Desktop/REV_scripts/behavioral/REV_SST/';
cd([studyFolder '/output/analysisReady/'])
steps=16; %16 looks at all data, 8 looks at half of the data (LEK recommends using 16)
exclude = [1 3 5 6 17 19 20 25 29]; % If you want to exclude any numbers, put them in this vector (e.g. exclude = [5 20];)
endSub = 29;
startSub = 1;
numSubs = endSub-startSub+1;
runs = [1 2 3 4];
numRuns = length(runs);

% These two codes should reflect what's in the response column of the Seeker variable
% You'll specify exceptions to this rule below
% leftButtonList=[94];
% rightButtonList=[94];
% studyPrefix='INC'; % You'll use this in your analysisReady data filenames
leftButton=94;
rightButton=95;
studyPrefix='ESNP'; % You'll use this in your analysisReady data filenames


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numSubs<10
    placeholder = '00';
elseif numSubs<100
    placeholder = '0';
else placeholder = '';
end

%%%%%%

NRCount = dlmread([studyFolder '/compiledResults/upto' studyPrefix placeholder num2str(numSubs) '/initialCheck/NRCount.txt'],'\t');


% Initialize variables
results = nan(numSubs,numRuns,10);

for s=startSub:endSub
    if find(exclude==s)
        % keep as NaNs
    else
        for r=runs
            filename=[studyPrefix num2str(s) '_r' num2str(r) '_SSRT.mat'];
            
            % Define LEFT and RIGHT *******
            problemSubIdx = find(buttonRuleExceptions(:,1)==s);
            problemRunIdx = find(buttonRuleExceptions(:,2)==r);
            probRow = intersect(problemSubIdx,problemRunIdx);
            
            if length(probRow)>1 % this shouldn't happen
                warning('multiple button exception entries for sub %d run %d',s,r)
            end
            
            if isnan(buttonRuleExceptions(probRow,3))
                % keep this run as NaNs (buttons were too inconsistent)
            else % start with default
                LEFT=leftButton;
                RIGHT=rightButton;
                
                if ~isempty(probRow)
                    LEFT = buttonRuleExceptions(probRow,3);
                    RIGHT = buttonRuleExceptions(probRow,4);
                    sprintf('button exception logged for sub %d run %d',s,r)
                end
            end
                       
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

save([studyFolder '/compiledResults/upTo' studyPrefix placeholder num2str(numSubs) '/varMats/resultVars' num2str(steps)],'GRTmean_results','GRTmedian_results','SSRT_results','GRTquant_results','SSRTquant_results','GRTint_results','SSRTint_results','SSD_results','PctInhib_results','NRCount')