%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Stopfmri %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adam Aron 12-01-2005
%%% Adapted for OSX Psychtoolbox by Jessica Cohen 12/2005
%%% Modified for use with new BMC trigger-same device as button box by JC 1/07
%%% Sound updated and modified for Jess' dissertation by JC 10/08

clear all;
% output version

% BEFORE RUNNING THIS SCRIPT:
% Make sure Psychtoolbox is installed!
% Make sure these directories look correct:
experimentCode = 'SST';

DIR.task = ['~/Desktop/CAPS_Pilot/tasks/' experimentCode '/'];
DIR.input = [DIR.task '/input/'];
DIR.output = [DIR.task '/output/'];
if ~exist(DIR.output)
    mkdir(DIR.output)
end

DIR.dropboxOutput = ['~/Dropbox (Pfeiber Lab)/CAPS_Pilot/tasks/' experimentCode '/output/'];
addpath(genpath(DIR.task))

script_name='Stopfmri: optimized SSD tracker for fMRI';
script_version='1';
revision_date='08-23-18'; 
Screen('Preference', 'SkipSyncTests', 1)

% Updated by LEK to incorporate the following changes:
% Output and log files go to output folder
% Includes colors for slowing (threshes set below)
% Can turn off the colors by setting colorFlags=0
% need to set "DIR.task" to be the appropriate path (the folder with
% output folder inside)

addpath(genpath(DIR.task))

notes={'Design developed by Aron, Newman and Poldrack, based on Aron et al. 2003'};

highThresh = .750; % turns red if rt > this value
lowThresh = .500; % turns orange if rt > this value
colorFlags=1; % Keep this as 1 if you want the circles to change to orange & red for slow responses
red=[255,0,0];  
orange=[255,128,0];

trigger = [52]; % apostrophe
mriLEFT = [91]; % left pointer on button box
mriRIGHT = [94]; % right pointer on button box

% read in subject initials
fprintf('%s %s (revised %s)\n',script_name,script_version, revision_date);
subject_code=input('Enter subject number (integer only): ');
sub_session=input('What SST session number is this? (Enter an integer only): ');
%scannum_temp=input('Enter scan number: ');
%scannum_temp=sub_session;
%scannum=scannum_temp;

if subject_code<10
    placeholder='00';
elseif subject_code<100
    placeholder='0';
else placeholder='';
end
    
outfile=sprintf('sub-%s%d_ses-1_task-%s_run-%d_beh.mat',placeholder,subject_code,experimentCode,sub_session)
%outfile=sprintf('sub%d_run%d_%s_%02.0f-%02.0f.mat',subject_code,sub_session,date,d(4),d(5));
outfile_dropbox = [DIR.dropboxOutput '/' outfile];
outfile = [DIR.output '/' outfile];

if exist(outfile)
    error('You already have an output file for subject %d, session %d.',subject_code,sub_session)
end


MRI=input('Are you scanning? 1 if yes, 0 if no: ');
% MRI = 0; % Use the above line instead if you'd like to have the option to wait for a trigger pulse

if sub_session==1,
    LADDER1IN=250 %input('Ladder1 start val (e.g. 250): ');
    LADDER2IN=350 %input('Ladder2 start val (e.g. 350): ');
    %Ladder Starts (in ms):
    Ladder1=LADDER1IN;
    Ladder(1,1)=LADDER1IN;
    Ladder2=LADDER2IN;
    Ladder(2,1)=LADDER2IN;
else %% this code looks up the last value in each staircase
    sub_session_temp = sub_session;
    trackfile = [DIR.output filesep 'sub-' placeholder num2str(subject_code) '_ses-1_task-SST_run-' num2str(sub_session-1) '_beh.mat'];
    % trackfile=input('Enter name of subject''s previous ''mat'' file to open: ','s');
    load(trackfile);
    clear Seeker; %gets rid of this so it won't interfere with current Seeker
    scannum=sub_session;
    startval=length(Ladder1);
    Ladder(1,1)=Ladder1(startval);
    Ladder(2,1)=Ladder2(startval);
    sub_session = sub_session_temp;
end;


%load relevant input file for scan (there MUST be st1b1.mat & st1b2.mat)
inputfile=sprintf([DIR.input filesep 'ladderFiles' filesep 'st%db%d.mat'],subject_code,sub_session);
if ~exist(inputfile)
    subClone = (-1*mod(subject_code,2))+2;
    warning('cloning subject %d''s input file for sub %d',subClone,subject_code);
    fileToCopy = sprintf('st%db%d.mat',subClone,sub_session);
    fileToCopy = [DIR.input filesep 'ladderFiles' filesep  fileToCopy];
    copyfile(fileToCopy,inputfile)
end

load(inputfile); %variable is trialcode

% write trial-by-trial data to a text logfile
d=clock;
logfile=sprintf('sub%d_scan%d_stopsig.log',subject_code,sub_session);
logfile = [DIR.output '/' logfile];
fprintf('A log of this session will be saved to %s\n',logfile);
fid=fopen(logfile,'a');
if fid<1,
    error('could not open logfile!');
end;

fprintf(fid,'Started: %s %2.0f:%02.0f\n',date,d(4),d(5));
WaitSecs(1);

%Seed random number generator
rand('state',subject_code);

try,  % goes with catch at end of script
    
    %% set up input devices
    numDevices=PsychHID('NumDevices');
    devices=PsychHID('Devices');
    if MRI==1,
        for n=1:numDevices,
            if (findstr(devices(n).transport,'USB') & findstr(devices(n).usageName,'Keyboard') & (devices(n).productID==612 | devices(n).vendorID==1523 | devices(n).totalElements==244)),
                inputDevice=n;
                %else,
                %    inputDevice=6; % my keyboard
            end;
            if (findstr(devices(n).transport,'USB') & findstr(devices(n).usageName,'Keyboard') & (devices(n).productID==566 | devices(n).vendorID==1452)),
                controlDevice=n;    
            elseif (findstr(devices(n).transport,'SPI') & findstr(devices(n).usageName,'Keyboard') & (devices(n).productID==657 | devices(n).vendorID==1452)),
                controlDevice=n;
            end
        end;
        fprintf('Using Device #%d (%s)\n',inputDevice,devices(inputDevice).product);
    else,
        for n=1:numDevices,
            if (findstr(devices(n).transport,'USB') & findstr(devices(n).usageName,'Keyboard')),
                inputDevice=[n n];
                break,
            elseif (findstr(devices(n).transport,'Bluetooth') & findstr(devices(n).usageName,'Keyboard')),
                inputDevice=[n n];
                break,
            elseif findstr(devices(n).transport,'ADB') & findstr(devices(n).usageName,'Keyboard'),
                inputDevice=[n n];    
            elseif findstr(devices(n).transport,'SPI') & findstr(devices(n).usageName,'Keyboard'),
                inputDevice=[n n];
            end;
        end;
        fprintf('Using Device #%d (%s)\n',inputDevice,devices(n).product);
    end;
    
    % set up screens
    fprintf('setting up screen\n');
    screens=Screen('Screens');
    screenNumber=max(screens);
    w=Screen('OpenWindow', screenNumber,0,[],32,2);
    [wWidth, wHeight]=Screen('WindowSize', w);
    grayLevel=120;
    Screen('FillRect', w, grayLevel);
    Screen('Flip', w);
    
    black=BlackIndex(w); % Should equal 0.
    white=WhiteIndex(w); % Should equal 255.
    
    xcenter=wWidth/2;
    ycenter=wHeight/2;
    
    theFont='Arial';
    Screen('TextSize',w,36);
    Screen('TextFont',w,theFont);
    Screen('TextColor',w,white);
    
    CircleSize=400;
    CirclePosX=xcenter-92;
    CirclePosY=ycenter-250;
    ArrowSize=150;
    ArrowPosX=xcenter-25;
    ArrowPosY=ycenter-125;
    
    HideCursor;
    
    %Adaptable Constants
    % "chunks", will always be size 64:
    NUMCHUNKS=4;  %gngscan has 4 blocks of 64 (2 scans with 2 blocks of 64 each--but says 128 b/c of interspersed null events)
    %StepSize = 50 ms;
    Step=50;
    %Interstimulus interval (trial time-.OCI) = 2.5s
    ISI=1.5; %set at 1.5
    %BlankScreen Interval is 1.0s
    BSI=1 ;  %NB, see figure in GNG4manual (set at 1 for scan)
    %Only Circle Interval is 0.5s
    OCI=0.5;
    arrow_duration=1; %because stim duration is 1.5 secs in opt_stop
    
    %%% FEEDBACK VARIABLES
    if MRI==1,
        %trigger = KbName('t');
        blue = KbName('b');
        yellow = KbName('y');
        green = KbName('g');
%         red = KbName('r');
        %LEFT=[98 5 10];   %blue (5) green (10)
        LEFT = [mriLEFT];
        RIGHT=[mriRIGHT];
        %RIGHT=[121 28 21]; %yellow (28) red (21)
    else,
        LEFT=[54];  %<
        RIGHT=[55]; %>
    end;
    
    if sub_session==1;
        error=zeros(1, NUMCHUNKS/2);
        rt = zeros(1, NUMCHUNKS/2);
        count_rt = zeros(1, NUMCHUNKS/2);
    end;
    
    %%%% Setting up the sound stuff
    %%%% Psychportaudio
    load soundfile.mat %%% NEED SOMETHING PERSONALIZED TO ME????? I.E. IF WANT THE SOUND HIGHER??
    %wave=y;
    wave=sin(1:0.25:1000);
    %freq=Fy*1.5; % change this to change freq of tone
    freq=22254;
    nrchannels = size(wave,1);
    % Default to auto-selected default output device:
    deviceid = -1;
    % Request latency mode 2, which used to be the best one in our measurement:
    reqlatencyclass = 2; % class 2 empirically the best, 3 & 4 == 2
    % Initialize driver, request low-latency preinit:
    InitializePsychSound(1);
    % Open audio device for low-latency output:
    pahandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, freq, nrchannels);
    %Play the sound
    PsychPortAudio('FillBuffer', pahandle, wave);
    PsychPortAudio('Start', pahandle, 1, 0, 0);
    WaitSecs(1);
    PsychPortAudio('Stop', pahandle);
    %%%% Old way
    %     Snd('Open');
    %     samp = 22254.545454;
    %     aud_stim = sin(1:0.25:1000);
    %     Snd('Play',aud_stim,samp);
        
    
    %this puts trialcode into Seeker
    % trialcode was generated in opt_stop and is balanced for 4 staircase types every 16 trials, and arrow direction
    %  see opt_stop.m in /gng/optmize/stopping/
    % because of interdigitated null and true trial, there will thus be four staircases per 32 trials in trialcode
    
    for  tc=1:256,                         %go/nogo        arrow dir       staircase    initial staircase value                    duration       timecourse
        if trialcode(tc,5)>0,
            Seeker(tc,:) = [tc sub_session  trialcode(tc,1) trialcode(tc,4) trialcode(tc,5) Ladder(trialcode(tc,5)) 0 0 0 0 0 0 0 0 trialcode(tc,2) trialcode(tc,3)];
        else,
            Seeker(tc,:) = [tc sub_session trialcode(tc,1) trialcode(tc,4) trialcode(tc,5) 0 0 0 0 0 0 0 0 0 trialcode(tc,2) trialcode(tc,3)];
        end;
    end;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% TRIAL PRESENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if MRI==1,
        Screen('DrawText',w,'Waiting for trigger...',xcenter-150,ycenter);
        Screen('Flip',w);
    else,
        Screen('DrawText',w,'Press the left button if you see <',100,175);
        Screen('DrawText',w,'Press the right button if you see >',100,225);
        Screen('DrawText',w,'Press the button as FAST as you can',100,300);
        Screen('DrawText',w,'when you see the arrow.',100,350);
        Screen('DrawText',w,'But if you hear a beep, try very hard',100,425);
        Screen('DrawText',w,'to STOP yourself from pressing the button.',100,475);
        Screen('DrawText',w,'Stopping and Going are equally important.',100,550);
        Screen('DrawText',w,'Press any key to go on.',100,625);
        Screen('Flip',w);
    end;
    
    if MRI==1,
        secs=KbTriggerWait(trigger,inputDevice);
        %secs = KbTriggerWait(KbName('t'),controlDevice);
    else, % If using the keyboard, allow any key as input
        noresp=1;
        while noresp,
            [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
            if keyIsDown & noresp,
                noresp=0;
            end;
        end;
        WaitSecs(0.001);
    end;
    % WaitSecs(0.5);  % prevent key spillover--ONLY FOR BEHAV VERSION
    
    if MRI==1
        DisableKeysForKbCheck(trigger); % So trigger is no longer detected
    end
    
    anchor=GetSecs;
    Pos=1;
    
    FLAG_FASTER=0;
    for block=1:2, %2	  %because of way it's designed, there are two blocks for every scan
        
        for a=1:8, %8     %  now we have 8 chunks of 8 trials (but we use 16 because of the null interspersed trials)
            %for a=1:1,  % short for troubleshooting
            for b=1:16,   %  (but we use 16 because of the null interspersed trials)
                
                if FLAG_FASTER==2
                    circleColor = red;  %red [255,0,0,255]
                    Screen('TextColor',w,red);
                elseif FLAG_FASTER==1
                    circleColor = orange; %orange [255,128,0,255]
                    Screen('TextColor',w,orange);
                else
                    circleColor = white;
                    Screen('TextColor',w,white);
                end
                
                if Seeker(Pos,3)~=2, %% ie this is not a NULL event
                    
                    Screen('TextSize',w,CircleSize);
                    Screen('TextFont',w,'Courier');
                    Screen('DrawText',w,'o', CirclePosX, CirclePosY);
                    Screen('TextSize',w,ArrowSize);
                    Screen('TextFont',w,'Arial');
                    
                    while GetSecs - anchor < Seeker(Pos,16),
                    end; %waits to synch beginning of trial with 'true' start
                    
                    Screen('Flip',w);
                    trial_start_time = GetSecs;
                    Seeker(Pos,12)=trial_start_time-anchor; %absolute time since beginning of task
                    WaitSecs(OCI);
                end;
                
                if Seeker(Pos,3)~=2, %% ie this is not a NULL event
                    Screen('TextSize',w,CircleSize);
                    Screen('TextFont',w,'Courier');
                    Screen('DrawText',w,'o', CirclePosX, CirclePosY);
                    Screen('TextSize',w,ArrowSize);
                    Screen('TextFont',w,'Arial');
                    if (Seeker(Pos,4)==0),
                        Screen('DrawText',w,'<', ArrowPosX, ArrowPosY);
                    else,
                        Screen('DrawText',w,'>', ArrowPosX+10, ArrowPosY);
                    end;
                    noresp=1;
                    notone=1;
                    Screen('Flip',w);
                    arrow_start_time = GetSecs;
                    
                    
                    while (GetSecs-arrow_start_time < arrow_duration & noresp),
                        [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
                        if MRI==1,
                            if keyIsDown & noresp,
                                tmp=KbName(keyCode);
                                Seeker(Pos,7)=KbName(tmp(1));
                                Seeker(Pos,9)=GetSecs-arrow_start_time;
                                noresp=0;
                            end;
                        else,
                            if keyIsDown & noresp,
                                try,
                                    tmp=KbName(keyCode);
                                    if length(tmp) > 1 & (tmp(1)==',' | tmp(1)=='.'),
                                        Seeker(Pos,7)=KbName(tmp(2));
                                    else,
                                        Seeker(Pos,7)=KbName(tmp(1));
                                    end;
                                catch,
                                    Seeker(Pos,7)=9999;
                                end;
                                if b==1 & GetSecs-arrow_start_time<0,
                                    Seeker(Pos,9)=0;
                                    Seeker(Pos,13)=0;
                                else,
                                    Seeker(Pos,9)=GetSecs-arrow_start_time; % RT
                                end;
                                noresp=0;
                            end;
                        end;
                        WaitSecs(0.001);
                        if Seeker(Pos,3)==1 & GetSecs - arrow_start_time >=Seeker(Pos,6)/1000 & notone,
                            %% Psychportaudio
                            PsychPortAudio('FillBuffer', pahandle, wave);
                            PsychPortAudio('Start', pahandle, 1, 0, 0);
                            Seeker(Pos,14)=GetSecs-arrow_start_time;
                            notone=0;
                            %WaitSecs(1); % So sound plays for set amount of time; if .05, plays twice, otherwise doen't really make it last longer
                            %PsychPortAudio('Stop', pahandle);
                            % Try loop to end sound after 1 sec, while
                            % still looking for responses-DOESN"T WORK!!!!!
                            while GetSecs<Seeker(Pos,14)+1,
                                %%% check for escape key %%%
                                [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
                                escapekey = KbName('escape');
                                if keyIsDown & noresp,
                                    try,
                                        tmp=KbName(keyCode);
                                        if length(tmp) > 1 & (tmp(1)==',' | tmp(1)=='.'),
                                            Seeker(Pos,7)=KbName(tmp(2));
                                        else,
                                            Seeker(Pos,7)=KbName(tmp(1));
                                        end;
                                    catch,
                                        Seeker(Pos,7)=9999;
                                    end;
                                    if b==1 & GetSecs-arrow_start_time<0,
                                        Seeker(Pos,9)=0;
                                        Seeker(Pos,13)=0;
                                    else,
                                        Seeker(Pos,9)=GetSecs-arrow_start_time; % RT
                                    end;
                                    noresp=0;
                                end;
                            end;
                            %PsychPortAudio('Stop', pahandle);
                            %% Old way to play sound
                            %Snd('Play',aud_stim,samp);
                            %Seeker(Pos,14)=GetSecs-arrow_start_time;
                            %notone=0;
                        end;
                        % To try to get stopping sound outside of sound
                        % loop so can collect responses as well; if do
                        % this, it doesn't play
                        %                         if GetSecs-Seeker(Pos,14)>=1,
                        %                             % Stop playback:
                        %                             PsychPortAudio('Stop', pahandle);
                        %                         end;
                    end; %end while
                    PsychPortAudio('Stop', pahandle); % If do this,
                    % response doesn't end loop
                end; %end non null
                
                Screen('Flip',w);
                
                while(GetSecs - anchor < Seeker(Pos,16) + Seeker(Pos,15)),
                end;
                
                
                % print trial info to log file
                tmpTime=GetSecs;
                try,
                    fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\n',...
                        Seeker(Pos,1:16));
                catch,   % if sub responds weirdly, trying to print the resp crashes the log file...instead print "ERR"
                    fprintf(fid,'ERROR SAVING THIS TRIAL\n');
                end;
                
                if colorFlags==1
                    trialRT=Seeker(Pos,9)
                    if Seeker(Pos,3)~=2
                        if trialRT > highThresh
                            FLAG_FASTER = 2;
                        elseif trialRT > lowThresh
                            FLAG_FASTER = 1;
                        else
                            FLAG_FASTER = 0;
                        end
                    end
                end
                
                
                Pos=Pos+1;
                
            end; % end of trial loop
            
            % after each 8 trials, this code does the updating of staircases
            %These three loops update each of the ladders
            for c=(Pos-16):Pos-1,
                %This runs from one to two, one for each of the ladders
                for d=1:2,
                    if (Seeker(c,7)~=0&Seeker(c,5)==d),	%col 7 is sub response
                        if Ladder(d,1)>=Step,
                            Ladder(d,1)=Ladder(d,1)-Step;
                            Ladder(d,2)=-1;
                        elseif Ladder(d,1)>0 & Ladder(d,1)<Step,
                            Ladder(d,1)=0;
                            Ladder(d,2)=-1;
                        else,
                            Ladder(d,1)=Ladder(d,1);
                            Ladder(d,2)=0;
                        end;
                        if (d==1),
                            [x y]=size(Ladder1);
                            Ladder1(x+1,1)=Ladder(d,1);
                        else if (d==2),
                                [x y]=size(Ladder2);
                                Ladder2(x+1,1)=Ladder(d,1);
                            end;end;
                    else if (Seeker(c,5)==d & Seeker(c,7)==0),
                            Ladder(d,1)=Ladder(d,1)+Step;
                            Ladder(d,2)=1;
                            if (d==1),
                                [x y]=size(Ladder1);
                                Ladder1(x+1,1)=Ladder(d,1);
                            else if (d==2),
                                    [x y]=size(Ladder2);
                                    Ladder2(x+1,1)=Ladder(d,1);
                                end;end;
                        end;end;
                end;
            end;
            %Updates the time in each of the subsequent stop trials
            for c=Pos:256,
                if (Seeker(c,5)~=0), %i.e. staircase trial
                    Seeker(c,6)=Ladder(Seeker(c,5),1);
                end;
            end;
            %Updates each of the old trials with a +1 or a -1
            for c=(Pos-16):Pos-1,
                if (Seeker(c,5)~=0),
                    Seeker(c,8)=Ladder(Seeker(c,5),2);
                end;
            end;
            
        end; %end of miniblock
        
    end; %end block loop
    
    
    % Close the audio device:
    PsychPortAudio('Close', pahandle);
    
    
    %try,   %dummy try if need to troubleshoot
    
catch,    % (goes with try, line 61)
    rethrow(lasterror);
    
    Screen('CloseAll');
    ShowCursor;
    
end;


%%%%%%%%%%%%%%% FEEDBACK %%%%%%%%%%%%%%%%
for t=1:256
    % go trial   &  left arrow                 respond right   OR  right arrow       respond left
    if (Seeker(t,3)==0 & ((Seeker(t,4)==0 & sum(Seeker(t,7)==RIGHT)==1)|(Seeker(t,4)==1 & sum(Seeker(t,7)==LEFT)==1))),
        error(sub_session)=error(sub_session)+1;  % for incorrect responses
    end;
    % go trial   &   RT (so respond)  & left arrow            respond left    OR  right arrow       respond right
    if (Seeker(t,3)==0 & Seeker(t,9)>0 & ((Seeker(t,4)==0 & sum(Seeker(t,7)==LEFT)==1)|(Seeker(t,4)==1 & sum(Seeker(t,7)==RIGHT)==1))),
        rt(sub_session)=rt(sub_session)+Seeker(t,9);   % cumulative RT
        count_rt(sub_session)=count_rt(sub_session)+1; %number trials
    end;
end;

Screen('TextSize',w,36);
Screen('TextFont',w,'Ariel');

% if sub_session==1;
%     Screen('DrawText',w,sprintf('Scanning Block %d',1),100,100);
%     Screen('DrawText',w,sprintf('Mistakes with arrow direction on Go trials: %d', error(1)),100,140);
%     Screen('DrawText',w,sprintf('Correct average RT on Go trials: %.1f (ms)', rt(1)/count_rt(1)*1000),100,180);
%     %     if MRI~=1,
%     %         Screen('DrawText',w,'Press any button to continue',100,220);
%     %     end;
%     Screen('Flip',w);
% end;
% 
% 
% if sub_session==2,
%     Screen('DrawText',w,sprintf('Scanning Block %d',1),100,100);
%     Screen('DrawText',w,sprintf('Mistakes with arrow direction on Go trials: %d', error(1)),100,140);
%     Screen('DrawText',w,sprintf('Correct average RT on Go trials: %.1f (ms)', rt(1)/count_rt(1)*1000),100,180);
%     
%     Screen('DrawText',w,sprintf('Scanning Block %d',2),100,240);
%     Screen('DrawText',w,sprintf('Mistakes with arrow direction on Go trials: %d', error(2)),100,280);
%     Screen('DrawText',w,sprintf('Correct average RT on Go trials: %.1f (ms)', rt(2)/count_rt(2)*1000),100,320);
%     
%     %     if MRI~=1,
%     %         Screen('DrawText',w,'Press any button to continue',100,360);
%     %     end;
%     Screen('Flip',w);
% end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d=clock;
Snd('Close');

params = cell (7,2);
params{1,1}='NUMCHUNKS';
params{1,2}=NUMCHUNKS;
params{2,1}='Ladder1 start';
params{2,2}=Ladder1(1,1);
params{3,1}='Ladder2 start';
params{3,2}=Ladder2(1,1);
params{4,1}='Step';
params{4,2}=Step;
params{5,1}='ISI';
params{5,2}=ISI;
params{6,1}='BSI';
params{6,2}=BSI;
params{7,1}='OCI';
params{7,2}=OCI;

%%% It's better to access these variables via parameters, rather than
%%% saving them...
try,
    save(outfile, 'Seeker', 'params', 'Ladder1', 'Ladder2', 'error', 'rt', 'count_rt', 'subject_code', 'sub_session');
    if exist(DIR.dropboxOutput)
        save(outfile_dropbox,'Seeker', 'params', 'Ladder1', 'Ladder2', 'error', 'rt', 'count_rt', 'subject_code', 'sub_session');
    else
        warning('Dropbox folder not found. Be sure to manually transfer the output files to dropbox.')
    end
catch,
    fprintf('couldn''t save %s\n saving to stopsig_fmri.mat\n',outfile);
    save stopsig_fmri;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% if MRI==1,
%     WaitSecs(5);
% else,
%     noresp=1;
%     while noresp,
%         [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
%         if keyIsDown & noresp,
%             noresp=0;
%         end;
%         WaitSecs(0.001);
%     end;
%     WaitSecs(0.5);
% end;

WaitSecs(5);

Screen('TextSize',w,36);
Screen('TextFont',w,'Ariel');
Screen('DrawText',w,'Great Job. Thank you!',xcenter-200,ycenter);
Screen('Flip',w);

% if MRI==1,
%     WaitSecs(1);
% else,
%     noresp=1;
%     while noresp,
%         [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
%         if keyIsDown & noresp,
%             noresp=0;
%         end;
%         WaitSecs(0.001);
%     end;
%     WaitSecs(0.5);
% end;

WaitSecs(1);
Screen('Flip',w);
Screen('CloseAll');
ShowCursor;

