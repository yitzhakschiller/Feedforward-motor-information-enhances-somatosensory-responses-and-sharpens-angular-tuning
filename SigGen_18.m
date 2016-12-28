function [WaveData,Fs] = SigGen_16(WaveTypes)
% Signal Generator for NIDAQ dual channel
% Create stimulus signas for NIDAQ_SigGen system
% The data is saved in the SigGen_XX.mat files

%%%%%%%%%%%%%%%%%%%%%%%%%
% Ver     Date          Who     Descr:
% =============================
% 15      22/11/11      UD      Sin and Cos cases for circle. 
% 14      08/11/11      UD      Skipping 13. Adding sinus for tests. 
% 12      13/09/11      UD      Slip and stick. 
% 11      05/09/11      UD      Fixing BP filter. 
% 10      05/07/11      UD      Interface for SigGen. 
% 05      05/07/11      UD      Case 95,96 - non - random noise with seed. 
%                               Creating new Data folder - Stimulus.
%                               Adding random pulse position stimulus : case 2001
% 04      28/06/11      UD      new signals and pwd
% 03      06/06/11      UD      Adding Band Path
% 02      05/06/11      UD      Adding back the trapez. Removing normalization. Adding LP noise
% 01      31/05/11      UD      Created
%%%%%%%%%%%%%%%%%%%%%%%%%


%%%
% Params for Pulse generation
%%%
Fs          = 10000;    % sampling rate in Hz (required by NIDAQ)
RepeatNum   = 1;        % number of repetiotions (duration will be Fs*WaveTime*RepeatNum)
WaveTime    = 1;      % waveform time in sec
if nargin < 1,
WaveTypes   = [26];   % waveform types that will be generated
end;

%WaveTypes   = [61 91];   % waveform types that will be generated
                        % could be a vector [1 3 5]
figNum      = 3;        % controls which figure to show
                        
% derived params
WaveNum     = length(WaveTypes);
WaveLen     = WaveTime*Fs;
t           = linspace(0,WaveTime,WaveLen)';
SigGenPath  = 'C:\Users\Uri\Stimulus_12\';

if ~exist(SigGenPath,'dir'),mkdir(SigGenPath); end;
addpath(SigGenPath) ;   
                        
                        
%%%
% Waveform Generation
%%%
WaveData    = zeros(WaveLen,1);
for m = 1:WaveNum,
    
    switch WaveTypes(m)
  
        case 0,     % nothing
            X           = zeros(WaveLen,1);

        case 333,     % sinus 3 Hz
            amplitude  = 4;
            offset     = 0;
            phase      = 0;
            
            X           = offset + amplitude*sin(3*2*pi*t+((phase*pi)/180));
            
        case 51,     % sinus 25 Hz
            amplitude  = .5;
            offset     = 0;
            phase      = 0;
            
            X           = offset + amplitude*sin(25*2*pi*t+((phase*pi)/180));
            
            
            
        case 11,   % single sawtooth
            start_time  = 0.5;         % start time in sec
            rise_time   = 0.04;         % rise time in sec
            fall_time   = 0.04;         % fall time in sec
            max_ampl    = 1;         % max amplitude
            X1          = linspace(0,max_ampl,ceil(rise_time*Fs));
            X2          = linspace(max_ampl,0,ceil(fall_time*Fs));
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1;
            X(start_sampl + numel(X1)+(1:numel(X2))) = X2;
            
            
        case 20,  % (2Hz) multiple sleep and stick trapez shape
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.001;        % rise time in sec
            hold_time   = 0.001;        % hold time in sec
            fall_time   = 0.001;        % fall time in sec
            delay_time  = 0.5;         % delay between pulses in sec
            repeat_num  = 5;           % number of pulses to replicate
            max_ampl    = .3;          % max amplitude of the pulse
            
            if delay_time < rise_time + hold_time + fall_time,
               errordlg('Sum of rize, fall and hold times is greater than between pulse delay');
               return;
            end
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs+eps); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                p       = p + ceil(delay_time*Fs);
                cnt     = cnt + 1;
            end;
            
            
       
        case 21,   % single trapez
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.2;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.2;         % fall time in sec
            max_ampl    = 8;         % max amplitude
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            
        case 22,   % smooth trapez
            start_time  = 0.4;         % start time in sec
            rise_time   = 0.2;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.2;         % fall time in sec
            smooth_fact = 0.01;        % smoothing factor
            max_ampl    = -8 ;         % max amplitude
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
 
        case 23,   % smooth trapez
            start_time  = 0.4;         % start time in sec
            rise_time   = 0.2;         % rise time in sec
            hold_time   = 0.1;         % hold time in sec
            fall_time   = 0.1;         % fall time in sec
            smooth_fact = 0.01;        % smoothing factor
            max_ampl    = 8;         % max amplitude
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            
        case 26,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = 0;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);

                    
        case 27,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = 0;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);

        case 28,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);

                    
        case 29,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = -pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);
  
        case 30,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = -pi/2;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);

                    
        case 31,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = -pi/2;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);
            
        case 32,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = 3*pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);

                    
        case 33,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = -3*pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);
            
        case 34,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = pi;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);
                    
        case 35,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = pi;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);
        
        case 36,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = -3*pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);

                    
        case 37,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = 3*pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);
        
        case 38,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = pi/2;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);

                    
        case 39,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = pi/2;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);
            
        case 40,   % smooth trapez - proximal channel 0 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 3.5;           % max amplitude
            dir_angle   = -pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*cos(dir_angle);
                 
        case 41,   % smooth trapez - distal channel 1 with direction
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.01;         % rise time in sec
            hold_time   = 0.2;         % hold time in sec
            fall_time   = 0.01;         % fall time in sec
            smooth_fact = 0.03;        % smoothing factor
            max_ampl    = 6.5;           % max amplitude
            dir_angle   = pi/4;         % direction of 2D move in radians
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = filtfilt(smooth_fact, [1 -(1-smooth_fact)],X);
            X           = X.*sin(dir_angle);
        
        case 42,   % sinus proximal channel 0
            Fo          = 5;          % sinus frequency in Hz
            amplitude   = 5;
            offset      = 0;
            phase       = 0;
            dir_angle   = -1*pi/3;         % direction of 2D move in radians
            X           = offset + amplitude*sin(3*Fo*pi*t+((phase*pi)/180));
            X           = X.*sin(dir_angle);
            
        case 43,   % cosinus distal channel 1
            Fo          = 5;          % sinus frequency in Hz
            amplitude   = 8;
            offset      = 0;
            phase       = 0;
            dir_angle   = -1*pi/3;         % direction of 2D move in radians
            X           = offset + amplitude*sin(3*Fo*pi*t+((phase*pi)/180));
            X           = X.*cos(dir_angle);
            
 
        case 46,   % sinus proximal channel 0
            Fo          = 5;          % sinus frequency in Hz
            amplitude   = 3;
            offset      = 0;
            phase       = 0;
            
            X           = offset + amplitude*sin(3*Fo*pi*t+((phase*pi)/180));
            
       case 47,   % cosinus distal channel 1
            Fo          = 5;          % sinus frequency in Hz
            amplitude   = 8;
            offset      = 0;
            phase       = 0;
            
            X           = offset + amplitude*cos(3*Fo*pi*t+((phase*pi)/180));
            
            
        case 44,   % sinus modulated by single trapez
            Fsin        = 10;          % sinus frequency in Hz
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.1;         % rise time in sec
            hold_time   = 0.4;         % hold time in sec
            fall_time   = 0.1;         % fall time in sec
            max_ampl    = 1;         % max amplitude
            Y           = sin(2*pi*Fsin*(1:WaveLen)'/WaveLen);
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1(:);
            X           = X.*Y;
            
            
        case 53,   % single sinc
            start_time  = 1;         % start time in sec
            sinc_time   = 1;         % sinc time in sec
            max_ampl    = 1;         % max amplitude
            X1          = max_ampl*sinc(linspace(-3,sinc_time*3,sinc_time*Fs));
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1;
          
            
        case 54,   % single gaussian
            centr_time  = 0.5;      % center time in sec
            spread_time = .2;        % gaussian spread time in sec
            max_ampl    = 0.5;         % max amplitude
            %X1          = max_ampl*gausswin(spread_time*Fs*3,1/spread_time);
            X           = max_ampl*exp(-(t - centr_time).^2./spread_time^2);
       
            
        case 48,   % single gaussian
            start_time  = 0.1;      % start time in sec
            spread_time = .6;        % gaussian spread time in sec
            max_ampl    = 1;         % max amplitude
            X1          = max_ampl*gausswin(spread_time*Fs*3,1/spread_time);
            X           = zeros(WaveLen,1);
            start_sampl = ceil(start_time*Fs);
            X(start_sampl+(1:numel(X1))) = X1;
         
            
        case 50,  % multiple sleep and stick sawtooth
            start_time  = 0.01;         % start time in sec
            rise_time   = .005;        % rise time in sec
            fall_time   = .001;       % fall time in sec
            delay_time  = .01;         % delay between pulses in sec
            repeat_num  = 4;         % number of pulses to replicate
            max_ampl    = 2;         % max amplitude of the pulse
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                p       = p + ceil(delay_time*Fs);
                cnt     = cnt + 1;
            end;
 
        case 52,  % multiple sleep and stick sawtooth fast rise time
            start_time  = 0.01;         % start time in sec
            rise_time   = .0005;        % rise time in sec
            fall_time   = .0025;       % fall time in sec
            delay_time  = .003;         % delay between pulses in sec
            repeat_num  = 5;         % number of pulses to replicate
            max_ampl    = 5;         % max amplitude of the pulse
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                p       = p + ceil(delay_time*Fs);
                cnt     = cnt + 1;
            end;
            
            
        case 56,  % multiple sleep and stick sawtooth - random location
            rand('state',52);  % keeps the noise to be the same pattern
            
            start_time  = 0.01;         % start time in sec
            rise_time   = .001;        % rise time in sec
            fall_time   = .005;       % fall time in sec
            delay_time  = .03;         % delay between pulses in sec
            repeat_num  = 4;         % number of pulses to replicate
            max_ampl    = 2;         % max amplitude of the pulse
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                rand_delay = rand(1,1)*delay_time;
                p       = p + ceil(rand_delay*Fs);
                cnt     = cnt + 1;
            end;
 
 
        case 61,  % multiple sleep and stick sawtooth - random location + sinus
            rand('state',55);  % keeps the noise to be the same pattern
            
            start_time  = 0.01;         % start time in sec
            rise_time   = .001;        % rise time in sec
            fall_time   = .008;       % fall time in sec
            delay_time  = .03;         % delay between pulses in sec
            repeat_num  = 4;         % number of pulses to replicate
            max_ampl    = 1;         % max amplitude of the pulse
            
            offset      = 0;        % sinu
            freq        = 2000;     % Freq in Hz
            amplitude   = 1;        % sinus amplitud
            phase       = -90;        % phase in degree
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                rand_delay = rand(1,1)*delay_time;
                p       = p + ceil(rand_delay*Fs);
                cnt     = cnt + 1;
            end;
            
            % add sinus
            t           = (1:WaveLen)'/Fs;
            Y           = offset + amplitude*sin(freq*t+((phase*pi)/180));
            X           = X.*Y;

            
            

        case 12,  % (10Hz) multiple sleep and stick trapez shape
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.001;        % rise time in sec
            hold_time   = 0.001;        % hold time in sec
            fall_time   = 0.001;        % fall time in sec
            delay_time  = 0.1;        % delay between pulses in sec
            repeat_num  = 10;           % number of pulses to replicate
            max_ampl    = .3;          % max amplitude of the pulse
            
            if delay_time < rise_time + hold_time + fall_time,
               errordlg('Sum of rize, fall and hold times is greater than between pulse delay');
               return;
            end
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                p       = p + ceil(delay_time*Fs);
                cnt     = cnt + 1;
            end;
   
        case 100,   % single sawtooth
            width       = 0.75;         % affects shape rise and fall times
            freq        = 1;            % affects number of repetiotions
            ampl        = 1;            % amplitude
            X           = sawtooth(2*pi*freq*t/WaveTime,width) * ampl;
            
            
        case 101,  % (100Hz) multiple sleep and stick trapez shape
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.001;        % rise time in sec
            hold_time   = 0.001;        % hold time in sec
            fall_time   = 0.001;        % fall time in sec
            delay_time  = 0.01;        % delay between pulses in sec
            repeat_num  = 10;           % number of pulses to replicate
            max_ampl    = .3;          % max amplitude of the pulse
            
            if delay_time < rise_time + hold_time + fall_time,
               errordlg('Sum of rize, fall and hold times is greater than between pulse delay');
               return;
            end
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                p       = p + ceil(delay_time*Fs);
                cnt     = cnt + 1;
            end;
            
        case 200,  % (200Hz) multiple sleep and stick trapez shape
            start_time  = 0.1;         % start time in sec
            rise_time   = 0.001;        % rise time in sec
            hold_time   = 0.001;        % hold time in sec
            fall_time   = 0.001;        % fall time in sec
            delay_time  = 0.005;        % delay between pulses in sec
            repeat_num  = 10;           % number of pulses to replicate
            max_ampl    = .3;          % max amplitude of the pulse
            
            if delay_time < rise_time + hold_time + fall_time,
               errordlg('Sum of rize, fall and hold times is greater than between pulse delay');
               return;
            end
            
            X1          = [linspace(0,max_ampl,ceil(rise_time*Fs)) max_ampl*ones(1,ceil(hold_time*Fs)) linspace(max_ampl,0,ceil(fall_time*Fs))];
            X1          = X1(:);
            
            pulse_width = numel(X1);
            X           = zeros(WaveLen,1);
            p           = ceil(start_time*Fs); % intial location
            cnt         = 1;
            while p < WaveLen-pulse_width && cnt <= repeat_num,
                X(p + (0:pulse_width-1)) = X1;
                p       = p + ceil(delay_time*Fs);
                cnt     = cnt + 1;
            end;
            
        
        case 90, % gaussian noise
            
            Amp     = 0.01;
            X       = Amp*randn(WaveLen,1);
                    
        
        case 96, % gaussian noise
            
            randn('state',1);  % keeps the noise to be the same pattern
            Amp     = 0.05;
            X       = Amp*randn(WaveLen,1);

        case 97, % gaussian noise
            
            randn('state',1);  % keeps the noise to be the same pattern
            Amp     = 0.09;
            X       = Amp*randn(WaveLen,1);
            
        case 102, % gaussian noise with LP filter
            
            Amp     = 0.05;
            Fcut    = 1e3;          % Max frequency in Hz of LP filter
            H       = fir1(16,Fcut/Fs*2);
            X       = Amp*randn(WaveLen,1);
            X       = filtfilt(H,1,X);
 
       case 555, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 0.8;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
        
        case 1, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 1;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
      
        case 15, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 1.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 2, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 2;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 25, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 2.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 3, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 3;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 305, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 3.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 4, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 4;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 45, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 4.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 5, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 55, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 5.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 6, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 6;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 65, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 6.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 7, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 7;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 75, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 7.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 8, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 8;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 85, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 8.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 9, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 9;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 95, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 9.5;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 10, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 10;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 1000, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 1;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
 
        case 1001, % gaussian noise with BP filter
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 2;
            Fband   = [500 1000];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
 
        case 1002, % gaussian noise with amp cut
            
            randn('state',25);  % keeps the noise to be the same pattern
            Amp     = 0.3;
            AmpCut  = 0.6;
            X       = Amp*randn(WaveLen+100,1);
            X       = X.*(abs(X) > AmpCut);
            X       = filter(hamming(16),1,X);
            X       = X(50 + (1:WaveLen));
            
     
        case 1129, % gaussian noise with BP filter, noise with state
            
            %randn('state',101);  % keeps the noise to be the same pattern
            Amp     = 1;
            Fband   = [50 200];          % min and Max frequency in Hz of BP filter
            H       = fir1(16,Fband/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(H,1,X);
            X       = X(50 + (1:WaveLen));
      
              
            
        case 1130, % gaussian noise with BP filter
            
            Amp     = 1;
            Fband   = [150 250];          % min and Max frequency in Hz of BP filter
            Hlp     = fir1(64,Fband(2)/Fs*2);
            Hhp     = fir1(64,Fband(1)/Fs*2);
            X       = Amp*randn(WaveLen+100,1);
            X       = filtfilt(Hlp,1,X) - filtfilt(Hhp,1,X);
            X       = X(50 + (1:WaveLen));
            
        case 1131, % gaussian noise with BP filter
            
            Amp     = 0.2;
            Fband   = [150 250];          % min and Max frequency in Hz of BP filter
            H       = fir1(16,Fband/Fs*2);
            X       = Amp*randn(WaveLen,1);
            X       = filtfilt(H,1,X);
            
        case 1132, % gaussian noise with BP filter
            
            Amp     = 0.3;
            Fband   = [150 250];          % min and Max frequency in Hz of BP filter
            H       = fir1(16,Fband/Fs*2);
            X       = Amp*randn(WaveLen,1);
            X       = filtfilt(H,1,X);
            
        case 1133, % gaussian noise with BP filter
            
            Amp     = 0.4;
            Fband   = [150 250];          % min and Max frequency in Hz of BP filter
            H       = fir1(16,Fband/Fs*2);
            X       = Amp*randn(WaveLen,1);
            X       = filtfilt(H,1,X);
            
        case 1134, % gaussian noise with BP filter
            
            Amp     = 0.5;
            Fband   = [150 250];          % min and Max frequency in Hz of BP filter
            H       = fir1(16,Fband/Fs*2);
            X       = Amp*randn(WaveLen,1);
            X       = filtfilt(H,1,X);
            
            
        case 2001,  % random position of small bumps
            
            %randn('state',101);         % keeps the noise to be the same pattern
            pulse_num   = 5;            % number of pulse in different locations
            pulse_time  = 0.01;        %  pulses width in sec
            max_ampl    = .1;          % max amplitude of the pulse in Volt
     
            pulse_width = ceil(pulse_time*Fs);
            pulse_shape = gausswin(pulse_width)*max_ampl;
            
            X           = zeros(WaveLen,1);
            [tmpRand,tmpInd]     = sort(randn(1,WaveLen));
            pulse_indx  = tmpInd(1:pulse_num);
            X(pulse_indx) = 1;
  
            X           = filter(pulse_shape,1,X);

        case 3001,  % handel
            
            pulse_time  = 0.1;        %  pulses width in sec
            pulse_width = ceil(pulse_time*Fs);
            max_ampl    = 1;          % max amplitude of the pulse in Volt
            
            load handel;                
            X           = zeros(WaveLen,1);
            X(1:pulse_width) = y(20500 +(1:pulse_width));
            
        otherwise
            error('Unknown WaveType')
    end;
    
    WaveData = WaveData + X(1:WaveLen);
    
end
% scale back
%WaveData  = WaveData ./ WaveNum;

% % show
% figure(1),
% plot(t,WaveData)
% xlabel('Time [sec]'),ylabel('Amp'),title('Single Waveform')


%%%
% Repetion
%%%
totalstim = WaveData;         % this name is required by PGA
% for k = 1:RepeatNum,
%     totalstim = [totalstim; WaveData];
% end;
tm      = linspace(0,RepeatNum*WaveTime,numel(totalstim))';

% show
figure(figNum),
plot(tm,totalstim)
xlabel('Time [sec]'),ylabel('Amp'),title('Replicated Waveform')

%%%
% save
%%%
SaveName = fullfile(SigGenPath,sprintf('SigGen_%d',WaveTypes*(100.^(numel(WaveTypes)-1:-1:0))'));
save(SaveName,'totalstim')

