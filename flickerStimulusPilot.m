% Written by IHT June 2024

%% --- SSVEP flicker stimulus pilot experiment --- %%

clear all;

% Skip internal self-tests and calibrations
Screen('Preference', 'SkipSyncTests', 1);

% Setup PTB 
PsychDefaultSetup(2);

% Set the screen number to external monitor (if there is one)    
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;  
 
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, ...
    [], 32, 2, [], [],  kPsychNeed32BPCFloat);

%% --- Gabor information --- %%

% Dimension of region where gabor is drawn
gaborDimPix = windowRect(4) / 2;    % in pixels
 
% Sigma of gaussian
sigma = gaborDimPix / 7;    % size of gaussian envelope = gabor patch size

% Gabor parameters
orientationLeft = 0;    % left gabor orientation (deg)
orientationRight = 0;    % right gabor orientation (deg)
contrast = 1;
aspectRatio = 1.0;    % shape of patch, <1 wide oval, 1 = circle, >1 tall oval
phase = 0; 

% Define spatial frequency (cycles/pixel)
numCycles = 8;    % one cycle = one black and one white lobe
freq = numCycles / gaborDimPix;    

% Build a procedural gabor texture
backgroundOffset = [0.5 0.5 0.5 0.0];    % grey
disableNorm = 1;    % 1 = normalisation is disabled
preContrastMultiplier = 0.5;    % <1 reduced cont, =1 unchanged, >1 increase
gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
    backgroundOffset, disableNorm, preContrastMultiplier);

% Randomise the phase of the gabors and make a properties matrix
propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

%% --- Draw stimuli --- %%

% Calculate the x and y coordinates for the center of the screen
centerX = windowRect(3) / 2;
centerY = windowRect(4) / 2;

% Define position for left gabor
gaborLeft = [centerX - 1.25 * gaborDimPix, centerY - 0.5 * gaborDimPix, ...
    centerX - 0.25 * gaborDimPix, centerY + 0.5 * gaborDimPix];

% Define position for right gabor
gaborRight = [centerX + 0.25 * gaborDimPix, centerY - 0.5 * gaborDimPix, ...
    centerX + 1.25 * gaborDimPix, centerY + 0.5 * gaborDimPix];
  
% Draw left gabor
Screen('DrawTextures', window, gabortex, [], gaborLeft, orientationLeft, ...
    [], [], [], [], kPsychDontDoRotation, propertiesMat');

% Draw right gabor
Screen('DrawTextures', window, gabortex, [], gaborRight, orientationRight, ...
    [], [], [], [], kPsychDontDoRotation, propertiesMat');  

% Add fixation dot
fixationColor = [1 0 0];    % colour (red)
fixationSize = 7; 

%% --- Flicker the gabors on and off --- %%

% Define flicker parameters (will play around with these)
flickerFreqLeft = 2;    % in Hz
flickerFreqRight = 1;    % in Hz
numFlickers = 20;    % total on AND off cycles (on+off=1)

% Calculate duration of one cycle (on and off)
cycleDurationLeft = 1 / flickerFreqLeft;
cycleDurationRight = 1 / flickerFreqRight;

% Calculate total duration of the flickering
totalDuration = numFlickers / flickerFreqLeft;

startTime = GetSecs;    % PTB uses GetSecs to time gabor on/off phase
while GetSecs - startTime < totalDuration
    
    [keyIsDown, ~, ~] = KbCheck;    % Lets you exit with key press at any time
    if keyIsDown
        break;
    end
    
    currentTime = GetSecs - startTime;    % Get current time
    
    % Calculate current phase of flicker for each gabor
    phaseLeft = mod(currentTime, cycleDurationLeft) / cycleDurationLeft;
    phaseRight = mod(currentTime, cycleDurationRight) / cycleDurationRight;
    
    % Draw left gabor during "on" phase
    if phaseLeft < 0.5
        Screen('DrawTextures', window, gabortex, [], gaborLeft, orientationLeft, ...
            [], [], [], [], kPsychDontDoRotation, propertiesMat');
    end
    
    % Draw right gabor during "on" phase
    if phaseRight < 0.5
        Screen('DrawTextures', window, gabortex, [], gaborRight, orientationRight, ...
            [], [], [], [], kPsychDontDoRotation, propertiesMat');
    end
    
    % Keep fixation dot on 
    Screen('DrawDots', window, [centerX centerY], fixationSize, fixationColor, [], 2);
    
    % Flip to the screen
    Screen('Flip', window);
end

%% Exit PTB

% Wait for a button press to exit
KbStrokeWait;

% Clear screen
sca; 
