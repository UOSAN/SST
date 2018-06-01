%%%%% Updated 1-3-15 by LEK

cd('~/Desktop/REV_SST/output/')
prefix = 'REV';
startSub = 19;
endSub = 21
startRun = 1;
endRun = 14;

for s=startSub:endSub
    cd pre
    copyfile(['sub' num2str(s) '*.mat'],'../analysisReady')
    cd ..
    
    cd post
    copyfile(['sub' num2str(s) '*.mat'],'../analysisReady')
    cd ..
    
    cd train
    copyfile(['sub' num2str(s) '*.mat'],'../analysisReady')
    cd ..
    
    cd analysisReady
    
    for r=startRun:endRun
        filename = ls(['sub' num2str(s) '_run' num2str(r) '_*.mat']);
        filename = strtrim(filename);
        if exist(filename,'file')
            movefile(filename,[prefix '_sub' num2str(s) '_run' num2str(r) '.mat'])
        else
            fprintf('Multiple files for subject %d run %d\n',s,r)
        end
    end
    cd ..
end

