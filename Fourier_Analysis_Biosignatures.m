Fs = 1000; % Sampling frequency
T = 1/Fs; % Sample time
L = 1000; % Length of signal
t = (0:L-1)*T; % Time vector
k=L/Fs; %Scaling factor for inverse FFT
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
y = x + 2*randn(size(t)); % Sinusoids plus noise


figure
plot(Fs*t(1:50),y(1:50))
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('time (milliseconds)')
%%Calcuate FFT
Y=fft(y,L)/L;
f=Fs/2*linspace(0,1,L/2+1);


figure
plot(f,2*abs(Y(1:L/2+1)))
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
%Calculate IFFT
y1=k*real(ifft(Y))*Fs;


figure
plot(Fs*t(1:50),y1(1:50))
title('Reconstruction of the Signal Corrupted with Zero-Mean Random Noise')
xlabel('time (milliseconds)')


figure
plot(Y)