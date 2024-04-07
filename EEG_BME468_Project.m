close all

disp('Hello world!')
disp('Matt was here')

%% Matthew Galipeau, Isaac Gonzalez, Taylor Oden
% BME468 EEG MATLAB Project

% First, need to load in the .mat
load S01_3.29.2024.mat

% variables given are x_time_s and y_voltage_uV. Pretty self explanatory.
% We are given six channels of voltage data. Let's split that (want 4).

% Letting the code find the amount of channels there are. 'Height' takes
% row count.
channelNumber = height(y_voltage_uV);

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


