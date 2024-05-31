%% SSVEP flicker stimulus test experiment 

sca;
close all;
clear;

% Skip internal self-tests and calibrations
Screen('Preference', 'SkipSyncTests', 1);

% Setup PTB 
PsychDefaultSetup(2);

% Set screen to the external monitor
screenNumber = max(Screen('Screens'));

% Define stimulus/screen colour to use
white = WhiteIndex(screenNumber);
grey = white / 2;

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2, [], [], kPsychNeed32BPCFloat);

%% Gabor properties

% Where to draw the Gabor
gaborDimPix = windowRect(4) / 2;

% Sigma of Gaussian
sigma = gaborDimPix / 7;

% Parameters
orientation = 0;
numCycles = 5; %(b&w per pixel)
freq = numCycles / gaborDimPix;
phase = 0;
contrast = 0.8;
aspectRatio = 1.0;

% Build a procedural gabor texture
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;
gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [], backgroundOffset, disableNorm, preContrastMultiplier);

% Randomize the phase of the Gabors and make a properties matrix.
propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];


%% Draw stuff - button press to exit

% Calculate positions for the two Gabors
centerX = windowRect(3) / 2;
centerY = windowRect(4) / 2;
gaborSpacing = 100; % Adjust this value as needed

leftGaborX = centerX - gaborSpacing;
rightGaborX = centerX + gaborSpacing;

% Draw left&right Gabors
Screen('DrawTextures', window, gabortex, [], [leftGaborX, centerY], ...
    orientation, [], [], [], kPsychDontDoRotation, propertiesMat);
Screen('DrawTextures', window, gabortex, [], [rightGaborX, centerY], ...
    orientation, [], [], [], kPsychDontDoRotation, propertiesMat);

% Flip to the screen
Screen('Flip', window);

% Wait for button press to exit
KbStrokeWait;

% Clear screen
sca;

