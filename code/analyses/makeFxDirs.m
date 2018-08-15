studyPrefix='INC';
numSubs = 2;
fxSuffix = '_basic';
studyDir = '~/Desktop/SST/';

for s=1:numSubs
    
    % Create subjectCode
    if s<10
        placeholder = '00';
    elseif s<100
        placeholder = '0';
    else
        placeholder = '';
    end
    
    subjectCode = [studyPrefix placeholder num2str(s)];
    mkdir([studyDir '/subjects/' subjectCode '/fx/fx' fxSuffix])
end