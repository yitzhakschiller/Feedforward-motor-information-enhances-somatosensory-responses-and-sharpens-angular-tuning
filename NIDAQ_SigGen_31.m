% NIDAQ_SigGen
% Dual chanell signalgenerator for NI -  DAQ board
% Urilizes discrete inputs for trigger synchronization 

%%%%%%%%%%%%%%%%%%%%%%%%%
% Ver   Date      Who     Descr:
% =============================
% 31    17/07/12  UD      fixing ranges. 
% 30    03/07/12  UD      NI Board came back. 
% 17    23/11/11  UD      Fixing noiuse start and stop - new SigGen. 
% 16    22/11/11  UD      Direct signal generation. 
% 15    15/11/11  UD      Add override trigger function. 
% 14    08/11/11  UD      Adding sinus for tests. 
% 13    19/09/11  UD      fixing Fs bug and new SigGen and stimulus end goes to zero
% 12    13/09/11  UD      slip and stick
% 11    06/09/11  UD      Checking trigger bug for Liora (trigCount=0)
% 10    05/07/11  UD      Using SigGen to create output signals
% 02    05/07/11  UD      Adding discrete line sensing for trigger - -working
% 01    28/06/11  UD      Created and working
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% IMPORTANT %%%%%%%%%%%
% The AdaptorDLL version that is returned by the DAQHWINFO command is the version of the adaptor that is registered. 
% If you have an adaptor from a certain release of MATLAB registered, 
% then when you run the DAQHWINFO command in a different release of MATLAB, 
% it will still return the version of the adaptor that is registered. 
% In order to use the adaptor version from a release that you desire, 
% you can register it using the following steps:
% 
% 1. Execute the following code to unregister the adaptor that is currently registered.
% daqregister('nidaq','unload');
% 
% 2. Restart MATLAB.
% 
% 3. Execute the following code to register the adaptor from the release of MATLAB that you are running.
% daqregister('nidaq');
% 
% After registering the adaptor from the correct release, you may verify this by running DAQHWINFO.
%%%% IMPORTANT %%%%%%%%%%%

%%
% Global params
%%
% connect to the generated stimulus : dual channels
SigGenPath          = 'C:\Users\Uri\SigGen_30\'; 
% SigGenFileName0     = 'SigGen_31.mat'; % proximal
% SigGenFileName1     = 'SigGen_32.mat'; % distal
WaveTypeChan0       = 30; % proximal
WaveTypeChan1       = 31; % distal
% WaveTypeChan0       = 26; % proximal
% WaveTypeChan1       = 27; % distal
% WaveTypeChan0       = 38; % proximal
% WaveTypeChan1       = 39; % distal
% SigGenFileName0     = 'SigGen_0.mat';
% SigGenFileName1     = 'SigGen_0.mat';

% the following parameters must be compatible with generated stimulus files
SampleRate          = 10e3; % output sample frequency in Hz
SweepRepeatNum      = 10;    % number of repetitions 
SweepDuration       = 1;  % number of seconds for single sweep
DelayBetweenSweep   = 1;  % number of seconds between consecutive sweeps 
%TimeOutTime         = 10;   % time out time - 
DoNotUseTrigger     = 1;   % if 0 - waits for external trigger, 1 - immediate

numPoints           = SampleRate*SweepDuration;


% turn off NI warnings
warning('off','daq:analogoutput:adaptorobsolete');
%%
% Load Output Signals
%%
% LoadName = fullfile(SigGenPath,SigGenFileName0);
% load(LoadName,'totalstim');
% if numel(totalstim) < numPoints,
%     error('Selected file %s contains signal that is less in duration then %d sec',SigGenFileName0,SweepDuration)
% end;
[waveData0,Fs]  = SigGen_16(WaveTypeChan0);

% LoadName = fullfile(SigGenPath,SigGenFileName1);
% load(LoadName,'totalstim');
% if numel(totalstim) < numPoints,
%     error('Selected file %s contains signal that is less in duration then %d sec',SigGenFileName1,SweepDuration)
% end;
%waveData1  = totalstim(1:numPoints);
[waveData1,Fs]  = SigGen_16(WaveTypeChan1);
SweepDuration   = floor(numel(waveData1)/Fs);  % number of seconds for single sweep
TimeOutTime     = 30;   % time out time - 


% % Generate the signal.
% amplitude  = .5;
% offset     = 0;
% phase      = 0;
% 
% t           = linspace(0,2*pi,numPoints+1);
% t           = t(1:end-1);
% waveData0    = offset + amplitude*sin(3*t+((phase*pi)/180));
% waveData1    = offset + amplitude*sin(4*t+((phase*pi)/180));

% Create the matrix for putdata.
%allout      = repmat(waveData',1,length(channels));
allout      = [waveData0 waveData1];

% show Lissajous curve
figure(101),
plot(waveData0,waveData1,'.')
title('2D- Wisker motion in space')
xlabel('Chan 0 [Volt]'),ylabel('Chan 1 [Volt]')
drawnow;

% show single curve
figure(102),
t = (1:numel(waveData0))'./SampleRate;
plot(t,waveData0)
title('Wisker motion in space - channel 0')
xlabel('Time [sec]'),ylabel('Chan 0 [Volt]')
drawnow;

% show single curve
figure(103),
t = (1:numel(waveData0))'./SampleRate;
plot(t,waveData1)
title('Wisker motion in space - channel 1')
xlabel('Time [sec]'),ylabel('Chan 1 [Volt]')
drawnow;


%%
% Configure HW
%%
%ainfo           = daqhwinfo('nidaq')
if (~isempty(daqfind)),     stop(daqfind), end;


% Create input object for trigger
di              = digitalio('nidaq','Dev1');
% add trigger sensing line 1 - see the connection
addline(di,1,'in');

% Create output object 
ao              = analogoutput('nidaq','Dev1');
channels        = [0 1];
chan0           = addchannel(ao,[0 1]);


% add trigger from HW line 
% ao.TriggerType              = 'HwDigital';
% ao.HwDigitalTriggerSource   = 'RTSI0';
% ao.TriggerCondition         = 'PositiveEdge';
ao.TriggerType              = 'Immediate'; % Immediate
ao.RepeatOutput             = 0;
% ao.TriggerType              = 'Manual'; % Immediate
% ao.RepeatOutput             = 3;
%set(ao,'TriggerFcn','fprintf(''.'')')

% adding range
set(ao.Channel(1),'OutputRange',[-10 10]);
set(ao.Channel(2),'OutputRange',[-10 10]);
set(ao.Channel(1),'UnitsRange',[-10 10]);
set(ao.Channel(2),'UnitsRange',[-10 10]);


% Get the sample rate for the new object.
set(ao, 'SampleRate',SampleRate);
ActualRate = get(ao,'SampleRate');
if ActualRate ~= SampleRate, warning('Actual Rate does not equal Requested'); end;


% Put the data calculated from the local waveform function and start 
% the device.
putdata(ao, allout);

%        

%%
% Wait for Trigger
%%
% check the line - if connected
portval = getvalue(di);
if portval == true,
    fprintf('Check the trigger line. Call 991 :-). The line is high - check the connection! \n')
    fprintf('The system will explode in 3 sec ! \n')
    return;
else
    fprintf(' Systems is ready for the trigger ... ')
end;
%start(ao);


%To see the samples output, type:
%get (ao, 'SamplesOutput');

% Output data — Start AO, issue a manual trigger, and wait for the device object to stop running.
% reset(AO)
% start(AO)
% trigger(ao)

%TimeOutTime = (SweepDuration + DelayBetweenSweep) * SweepRepeatNum;
startTime   = tic;
elapsedTime = toc(startTime);    
trigCount   = 0;
%while ao.TriggersExecuted < SweepRepeatNum || elapsedTime < TimeOutTime, 
while trigCount < SweepRepeatNum && elapsedTime < TimeOutTime, 
    
    portval = getvalue(di);
    if portval == true || DoNotUseTrigger == 1,
        startTime   = tic;
        start(ao);
        %trigger(ao);
        wait(ao,TimeOutTime);
        %get(ao, 'SamplesOutput')
        stop(ao);
        putdata(ao, allout);
        %elapsedTime1 = toc(startTime)
        pause(DelayBetweenSweep);
        %elapsedTime = toc(startTime)
        trigCount = trigCount + 1;
        fprintf('.')

    end;
    
    elapsedTime = toc(startTime);


end;
fprintf(' Done\n')

if elapsedTime >= TimeOutTime, 
    fprintf('\n Time Out : only %d triggers has been received, Expected %d\n',trigCount,SweepRepeatNum)
end;
if trigCount == SweepRepeatNum,
    fprintf(' %d Trigger events has been produced\n',trigCount)
end;

%%
% Clean up 
%%
% When you no longer need AO, you should remove it from memory and from the MATLAB workspace.
stop(ao);
stop(di);

% CLOSE
if ~isempty(ao)
   if isvalid(ao) && isrunning(ao)
      % Stop the device and delete it.
      stop(ao);
   end

   % Delete the object.
   delete(ao);
   clear ao;
end
% CLOSE
if ~isempty(di)
   if isvalid(di) && isrunning(di)
      % Stop the device and delete it.
      stop(di);
   end

   % Delete the object.
   delete(di);
   clear di;
end


fprintf(' Done\n')
