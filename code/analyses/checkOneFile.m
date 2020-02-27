function [GRTmean GRTmedian StDevGRT SSRT GRTquant SSRTquant GRTint SSRTint PctInhib SSDfifty] = checkOneFile();

RIGHT=198;
LEFT=197;
num_steps=16;
filename = input('Filename (in single quotes, with .mat extension): ');

%%%%% Stopbehav Tracking Version analysis program
%%%% works with stopbehavOSX and stopfmriOSX
%%%%% Must load desired program first
%%%%% for use with stopsig_new (JRC 7/25/07)
%%%%% Updated 12-6-08 to fix calculations and use quantile

%%%% reads in the scans

% num_steps=input('How many steps of the ladder do you want included in the SSRT estimation? 8 is half the run, 16 is entire run: ');
% num_steps=16;

% analyze=input('Is this to put the data in the behavioral spreadsheet? 1 if yes, 0 if no: ');
analyze=0;

while isempty(find(analyze==[0 1])),
    analyze=input('Must enter 1 or 0 - please re-enter: ');
end;

load(filename);
tmp = zeros(256,16);

tmp(1:256,:)=Seeker;
clear Seeker,
Seeker = tmp;

% % Determine which keys to count as correct
% if ~isempty(find(Seeker(:,7)==197)),
%     LEFT = 197;
% elseif ~isempty(find(Seeker(:,7)==5)),
%     LEFT = 5;
% elseif ~isempty(find(Seeker(:,7)==89)),
%     LEFT = 89;
% else,
%     LEFT=input('What is the ASCII key code the subject pushed for left? ');
% end;
% if ~isempty(find(Seeker(:,7)==198)),
%     RIGHT = 198;
% elseif ~isempty(find(Seeker(:,7)==28)),
%     RIGHT = 28;
% elseif ~isempty(find(Seeker(:,7)==90)),
%     RIGHT = 90;
% else,
%     RIGHT=input('What is the ASCII key code the subject pushed for right? ');
% end;


%%%% Make SSD graphs
%
% a = max(Ladder1);
% b = max(Ladder2);
% ymax=max([a b]);
% a = min(Ladder1);
% b = min(Ladder2);
% ymin=min([a b]);
% if ymin>0,
% 	ymin=0;
% end;
%
%
% xmax=length(Ladder1)+1;
%
% for a=1:size(Ladder1),
% 	Ladder1Plot(2*a-1)=Ladder1(a);
% 	Ladder2Plot(2*a-1)=Ladder2(a);
% 	Ladder1Plot(2*a)=Ladder1(a);
% 	Ladder2Plot(2*a)=Ladder2(a);
% end;
%
%
%
% subplot(2,2,1);
% for a=1:size(Ladder1)-1;
% 	hold on;
% 	plot(a:a+1,Ladder1Plot(2*a-1:2*a), 'b');
% 	plot([a+1 a+1],Ladder1Plot(2*a:2*a+1), 'b');
% end;
% axis([1 xmax ymin ymax]);
% subplot(2,2,2);
% for a=1:size(Ladder2)-1;
% 	hold on;
% 	plot(a:a+1,Ladder2Plot(2*a-1:2*a), 'b');
% 	plot([a+1 a+1],Ladder2Plot(2*a:2*a+1), 'b');
% end;
% axis([1 xmax ymin ymax]);


%%%% Actual Analysis...

% Note this only uses GRT from last half of run if only use 8 steps of
% ladder, and uses GRT from entire run if use all 16 steps
GRTmedian=median(Seeker(find(Seeker(:,1)>(16-num_steps)*16 & Seeker(:,3)==0 & ((Seeker(:,4)==0 & Seeker(:,7)==LEFT) | (Seeker(:,4)==1 & Seeker(:,7)==RIGHT))),9))*1000;
GRTmean=mean(Seeker(find(Seeker(:,1)>(16-num_steps)*16 & Seeker(:,3)==0 & ((Seeker(:,4)==0 & Seeker(:,7)==LEFT) | (Seeker(:,4)==1 & Seeker(:,7)==RIGHT))),9))*1000;
StDevGRT=std(Seeker(find(Seeker(:,1)>(16-num_steps)*16 & Seeker(:,3)==0 & ((Seeker(:,4)==0 & Seeker(:,7)==LEFT) | (Seeker(:,4)==1 & Seeker(:,7)==RIGHT))),9))*1000;

% look at last X steps of ladder, subtract 1 because want to include actual
% SSDs on each trial, and if don't -1 then includes what the next SSD will be
BOTT=length(Ladder1)-num_steps+1-1; TOP=length(Ladder1)-1; % look at last X steps of ladder
if exist('scannum'),
    %     if subject_code<11 & scannum==2, % because took wrong starting value for these 10 subjects
    %         tmpLadd1=Seeker(find(Seeker(:,5)==1),6);
    %         Ladder1mean=mean([tmpLadd1(1) Ladder1(BOTT+1:TOP)']);
    %         tmpLadd2=Seeker(find(Seeker(:,5)==2),6);
    %         Ladder2mean=mean([tmpLadd2(1) Ladder2(BOTT+1:TOP)']);
    %     else,
    Ladder1mean=mean(Ladder1(BOTT:TOP));
    Ladder2mean=mean(Ladder2(BOTT:TOP));
    %     end;
else,
    Ladder1mean=mean(Ladder1(BOTT:TOP));
    Ladder2mean=mean(Ladder2(BOTT:TOP));
end;
SSDfifty=mean([Ladder1mean Ladder2mean]);
SSRT=GRTmedian-SSDfifty;

% Percent Inhibition from bottom to top (so last X steps); do separately
% for each ladder and then average
for ladder=1:2,
    tmp=Seeker(find(Seeker(:,5)==ladder),7);
    tmp2=tmp(length(tmp)-num_steps+1:length(tmp)); % last X steps of ladder
    PctInhib(ladder)=100*sum(tmp2(:)==0)/length(tmp2);
end;

% Checks to make sure doing task appropriately across entire run
PctDimErrors=100*sum((Seeker(:,3)==0 & ((Seeker(:,4)==0 & Seeker(:,7)==RIGHT) | (Seeker(:,4)==1 & Seeker(:,7)==LEFT))))/sum(Seeker(:,3)==0);
PctGoResp=100*(sum(Seeker(:,3)==0 & Seeker(:,7) ~= 0) / sum(Seeker(:,3)==0));

%Analysis to get SSRT using quantile based on actual PctInhib as opposed to assuming 50% like above
corr_rt=Seeker(find(Seeker(:,1)>(16-num_steps)*16 & Seeker(:,3)==0 & ((Seeker(:,4)==0 & Seeker(:,7)==LEFT) | (Seeker(:,4)==1 & Seeker(:,7)==RIGHT))),9)*1000;
GRTquant=quantile(corr_rt,mean(100-PctInhib)/100);
SSRTquant=GRTquant-SSDfifty;

GRTint=prctile(corr_rt,mean(100-PctInhib));
SSRTint=GRTint-SSDfifty;

% Calculates number of TRs until task actually ended
% Last trial starts + Last trial duration + Last null duration
% Divide by 2 to get TRs, and round to nearest whole number
numTRs=ceil((Seeker(255,12)+Seeker(255,15) + Seeker(256,15))/2);
%
fprintf('Median Go Reaction Time at 50 pct inhib(ms): %f\n',GRTmedian);
fprintf('Median Go Reaction Time at %0.2f pct inhib (ms): %f\n',mean(PctInhib),GRTquant);
% fprintf('StDev Go Reaction Time: %f\n',StDevGRT);
% fprintf('Mean SSD Ladder 1 (ms): %f\n',Ladder1mean);
% fprintf('Mean SSD Ladder 2 (ms): %f\n',Ladder2mean);
fprintf('Subject mean SSD (ms): %f\n', SSDfifty);
% fprintf('Percent discrimination errors: %f\n',PctDimErrors);
fprintf('Percent responding on go trials (should be close to 100): %f\n',PctGoResp);
fprintf('Subject SSRT assuming 50 pct inhib (ms): %f\n', SSRT);
fprintf('Subject SSRT at %0.2f pct inhib (ms): %f\n',mean(PctInhib),SSRTquant);
fprintf('Percent Inhibition Ladder 1: %0.1f\n',PctInhib(1));
fprintf('Percent Inhibition Ladder 2: %0.1f\n',PctInhib(2));

% Print relevant output to a text file
if analyze==1,
    if exist('scannum'),
        fid=fopen(sprintf('stopsig_analysis_mri_%dsteps.txt',num_steps),'a');
    else,
        fid=fopen(sprintf('stopsig_analysis_behav_%dsteps.txt',num_steps),'a');
    end;
    fprintf(fid,'%s\t',filename);
    if exist('scannum'),
        fprintf(fid,'MRI Data\t');
    else,
        fprintf(fid,'Behav Data\t');
    end;

    fprintf(fid,'%0.1f\t%0.1f\t%0.1f\t%0.1f\t%0.1f\t%0.1f\t%0.2f\t%0.2f\t%0.1f\t%0.1f\t%0.1f\t%0.1f\t%d\t',GRTmedian, GRTquant, StDevGRT, Ladder1mean, Ladder2mean, SSDfifty, PctDimErrors, PctGoResp, SSRT, SSRTquant, PctInhib,numTRs);
    %fprintf('%0.1f\t%0.1f\t%0.1f\t%0.1f\t%0.1f\t%0.2f\t%0.2f\t%0.1f\t%0.1f\t%0.1f\t%0.1f\t',GRTmedian, GRTquant, Ladder1mean, Ladder2mean, SSDfifty, PctDimErrors, PctGoResp, SSRT, SSRTquant, PctInhib);

    if exist('scannum'),
        if scannum==2,
            fprintf(fid,'\n');
        end;
    elseif run_num==3,
        fprintf(fid,'\n');
    end;

    fclose(fid);
end;

end
