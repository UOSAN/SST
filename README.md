# Stop-Signal Task

The Stop-Signal task (Verbruggen & Logan, 2008) models both action and inhibition processes (going and stopping). The primary outcome measure of interest is the stop-signal response time, which is an estimated measure of the time it takes to enact the 'stopping' process.


## Table of Contents
- [Experiment Scripts](/experiment/README.md)
- [Analysis Scripts](/scripts/README.md)
- [Project Status](#project-status)
- [Glossary of Terms](#glossary-of-terms)
- [Task Description](#task-description)
- [Standard Instructions](#standard-instructions)
- [Task Adaptivity](#task-adaptivity)
- [Outcome Measures](#outcome-measures)


## Glossary of Terms<a name="glossary-of-terms"/>
**SST** - Stop-signal task
**SSRT** - Stop-signal response time
**SSD** - Stop-signal delay

## Task Description<a name="task-description"/>
The SST consists of two trial types: "go" trials and "stop" trials. Every trial began with the presentation of PRC (500 ms), followed by a “go” cue consisting of an arrow pointing left or right (1000 ms; 1:1 ratio) indicating whether the participant should press a button with the left or right index finger. Trials are followed by and intertrial interval of variable duration (M = 1400 ms jittered following a gamma distribution). Each run consists of 128 trials (32 stop trials) and lasts approximately 6 minutes.

## Standard Instructions<a name="standard-instructions"/>
Participants are instructed to press the left or right arrow key as quickly as possible in response to the go signal. On 25% of the trials, an auditory stop signal sounds after the go signal at a variable latency known as the stop-signal delay (SSD). Participants are instructed to withhold their button press on trials in which a stop signal sounded. The SSD adjusts by 50 ms after each stop trial using a staircase function that increases for successful stops and decreases for failed stops. 

## Task Adaptivity<a name="task-adaptivity"/>
Two independent staircases alternate control over the SSD in blocks of 8 trials until 50% response accuracy is reached on stop trials. Because the task adjusts so that accuracy is held constant, the number of successful Stop trials is approximately equal across participants. 

## Outcome Measures<a name="outcome-measures"/>
The critical measure of self-control is the stop-signal response time (SSRT), an index of the efficiency of the inhibitory control process. The SSRT is calculated as the difference between the length of the go process and the SSD. The SSRT is computed separately for each run. Calculation of SSRTs is doene by the integration method, which does not operate under the assumption that the algorithm forces participants to reach exactly 50% success on stop trials. This method has been demonstrated to be less biased than the mean method when the successful stop rate deviates from 50% (Verbruggen, Chambers, & Logan, 2013).
