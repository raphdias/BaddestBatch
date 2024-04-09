close all

% The script needs these two lines of codes to run. Please don't remove.
% - Matt
[y, Fs] = audioread('TotallyNecessary.mp3');
sound(y, Fs, 16);

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
% six, for six channels. Then, we title them accordingly using sprintf.
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

sound(y, Fs, 16);

%% A. Bandpass filter 1-30Hz, cutting everything else out.
% We zero-phase bandpass in time by using filtfilt.
% Need to design bandpass by designfilt. Initialize first.

bandFiltered = zeros(desiredNumber, length(y_voltage_uV));

% n = 20th order filter. 
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

sound(y, Fs, 16);

%% B. View the data in the time series, preferably the filtered series,
% and determine where there are major changes, not just an aberrant spike,
% but consistent, prolonged, level changes, in the characteristics of the
% signals (note those times for your report and further processing below). 
% [You should be able to identify 10 segments/regions that are distinct. 
% There are 5 segments with higher amplitude than the other 5 segments.]


%% C. Perform FFT on each entire channel data before and after filtering
% First will do general fft, then PSD

% Initialization for the filtered signal transform
filteredSpec = zeros(desiredNumber, fs);

% Initializing original transform size, and var for desired max freq.
Spec = zeros(height(y_voltage_uV), fs);
desiredFreq = 100;

% This is for FFT, not PSD!
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

sound(y, Fs, 16);

% Initialize PSD matrices
filtPSD = zeros(desiredNumber,fs);
unfiltPSD = zeros(desiredNumber,fs);

% This is for PSD!
for i = 1:desiredNumber
    % Create figure with appropriate name
    figure("Name", sprintf('Unfilt & Filt PSD, Channel No. %d', i))

    % Compute PSD, FFT^2*(1/length)*(1/fs)
    filtPSD(i,:) = filteredSpec(i,:).^2.*(1./length(bandFiltered))*(1/fs);
    unfiltPSD(i,:) = Spec(i,:).^2.*(1./length(bandFiltered))*(1/fs);
    
    % Plot!
    subplot(2,1,1)
    plot(0:desiredFreq, 10*log10(unfiltPSD(i,1:desiredFreq+1)))
    xlabel("Frequency (Hz)"); 
    ylabel("Power, dB");
    title(sprintf('Log of Unfiltered PSD of EEG Channel No. %d, 0-100Hz',i))

    subplot(2,1,2)
    plot(0:desiredFreq, 10*log10(filtPSD(i,1:desiredFreq+1)))
    xlabel("Frequency (Hz)"); 
    ylabel("Power, dB");
    title(sprintf('Log of Filtered PSD of EEG Channel No. %d, 0-100Hz',i))
end

sound(y, Fs, 16);

%% Questions to ask:
    % 1. Should we multiply our plot amplitudes by 2? Reasoning: with the
    % current plotting methods, we are ignoring negative freq.
    % 2. Is PSD just amplitude squared? We have taken the log of this. Of
    % course, made sure to modify amplitude due to nature of fft.
    % 3. What should we limit ourselves to for the bandpass filter?
    % Choosing such a high order filter will negate the need for a notch
    % filter. At what point does it become unreasonable?

%% D. Notch filter, 60Hz, Zero-phase.
% Going to design another filter using designfilt. Cut out from 59-61Hz.

notchFiltered = zeros(desiredNumber, length(x_time_s));
notchSpec = zeros(desiredNumber, fs);
notchPSD = zeros(desiredNumber, fs);
notchFilt = designfilt('bandstopiir', ...
    'FilterOrder', 2,'HalfPowerFrequency1',59, ...
    'HalfPowerFrequency2', 61, 'DesignMethod', 'butter', ...
    'SampleRate',1000);

for i = 1:desiredNumber    
    % Filtering, getting fft, then PSD.
    notchFiltered(i,:) = filtfilt(notchFilt, bandFiltered(i,:));
    notchSpec(i,:) = abs(fft(notchFiltered(i,:), fs));
    notchPSD(i,:) = notchSpec(i,:).^2.*(1./length(bandFiltered))*(1/fs);

    % Generating figures
    figure("Name", sprintf('PSD, Before & After Notch, Ch. No. %d', i))

    % Plotting it!
    subplot(2,1,1)
    plot(0:desiredFreq, 10*log10(filtPSD(i,1:desiredFreq+1)))
    xlabel("Frequency (Hz)"); 
    ylabel("Power, dB");
    title(sprintf('Log of BP Filt PSD of EEG Channel No. %d, 0-100Hz',i))

    subplot(2,1,2)
    plot(0:desiredFreq, 10*log10(notchPSD(i,1:desiredFreq+1)))
    xlabel("Frequency (Hz)"); 
    ylabel("Power, dB");
    title(sprintf('Log of BP&BS Filt PSD of EEG Channel No. %d, 0-100Hz',i))
end

sound(y, Fs, 16);
