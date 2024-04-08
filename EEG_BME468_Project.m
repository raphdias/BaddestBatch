close all

disp('Hello world!')
disp('Matt was here')

%% Matthew Galipeau, Isaac Gonzalez, Taylor Oden
% BME468 EEG MATLAB Project

% First, need to load in the .mat... sampling rate = 1000
load S01_3.29.2024.mat
fs = 1000;

% variables given are x_time_s and y_voltage_uV. Pretty self explanatory.
% We are given six channels of voltage data. Let's split that (want 4).

% Letting the code find the amount of channels there are. 'Height' takes
% row count.
channelNumber = height(y_voltage_uV);
desiredNumber = channelNumber - 2;

% Opening a properly named figure for this.
figure("Name", "Unmodified EEG Data, first 4 Channels")

% Here, we are plotting each individual row of the voltage array. There are
% six, for six channels. Then, we title then accordingly using sprintf.
for i = 1:channelNumber
  subplot(3,2,i)
  plot(x_time_s, y_voltage_uV(i, :))
  xlabel("Time (sec)");
  ylabel("Voltage, uV");
  if i < channelNumber-1
    title(sprintf('EEG Channel No. %d',i))
  else 
    title(sprintf('EEG Channel No. %d, negligible.', i))
  end
end

%% Part a: bandpass filter 1-30Hz, cutting everything else out.
% We zero-phase bandpass in time by using filtfilt.
% Need to design bandpass by designfilt. Initialize first.

bandFiltered = zeros(desiredNumber, length(y_voltage_uV));

bpFilt = designfilt('bandpassfir', ...
    'FilterOrder',20,'CutoffFrequency1',1, ...
    'CutoffFrequency2', 30,'SampleRate',1000);

for i = 1:desiredNumber
  % Zero-phase filtering and creating figure titles
  bandFiltered(i,:) = filtfilt(bpFilt, y_voltage_uV(i,:));
  figure("Name", sprintf('Unfilt vs. Filt (Time), Channel No. %d', i))

  % just plotting filtered and unfiltered from here on out
  subplot(2,1,1)
  plot(x_time_s, y_voltage_uV(i,:))
  xlabel("Time (sec)");
  ylabel("Voltage, uV");
  title(sprintf('Unfiltered EEG Channel No. %d',i))  
  
  subplot(2,1,2)
  plot(x_time_s, bandFiltered(i,:))
  xlabel("Time (sec)");
  ylabel("Voltage, uV");
  title(sprintf('Filtered EEG Channel No. %d',i))
end

% Initialization for the filtered signal transform
filteredSpec = zeros(desiredNumber, fs);

% Initializing original transform size, and var for desired max freq.
Spec = zeros(height(y_voltage_uV), fs);
desiredFreq = 100;

for i = 1:desiredNumber
  % Create figure with appropriate name
  figure("Name", sprintf('Unfilt & Filt FFT, Channel No. %d', i))

  % Filtering & filtered FFT of EEG channels 1-4
  filteredSpec(i,:) = abs(fft(bandFiltered(i,:), fs));

  % Unfiltered FFT of EEG channels 1-4
  Spec(i,:) = abs(fft(y_voltage_uV(i,:), fs));

  % Plotting and labels for unfiltered
  subplot(2,1,1)
  plot(0:desiredFreq, Spec(i,1:desiredFreq+1))
  xlabel("Frequency (Hz)"); 
  ylabel("Amplitude");
  title(sprintf('Unfiltered FFT of EEG Channel No. %d, 0-100Hz',i))

  % Plotting and labels for filtered
  subplot(2,1,2)
  plot(0:desiredFreq, filteredSpec(i,1:desiredFreq+1))
  xlabel("Frequency (Hz)"); 
  ylabel("Amplitude");
  title(sprintf('1-30Hz BP Filtered FFT of EEG Channel No. %d, 0-100Hz',i))
end

