print('BEGINNING OF SCRIPT')

from scipy.io import wavfile #import WAV file
import numpy as np 
import matplotlib.pyplot as plt

fs, data = wavfile.read('2255279C.wav') 

#First off, we want to use the tool 'Linspace' to create numeric sequences
x = np.linspace(0,len(data)/fs,len(data)) #Creates a 'time' sequence  
y = np.linspace(0,fs,len(data)/2) #isolate frequencies WAS FS/2
#y2 = np.linspace(0,fs/2,len(data)) #have mirrored values also

# We want to generate a plot in the time domain
plt.figure(1)
plt.plot(x,data)
plt.grid(True) 
plt.title('Audio Plot in the Time Domain')
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')
#
dataf = np.fft.fft(data) #We use this to perform a Fourier Transform of the data
#
normalise_dataf = dataf / len(dataf) # Normalises the data
datak = dataf[0:int(len(data)/2)] # Takes out the mirror of the data set 
datakdb = 20*np.log10(datak) # Convert the amplitude into dB
#
# Now we can plot the audio signal in the Frequency Domain
plt.figure(2)
plt.semilogx(y,datakdb) #convert frequencies into logarithmic scale using semilog command #REMOVED ABS
plt.grid(True)
plt.title('Audio Plot in Frequency Domain') 
plt.xlabel('Log Frequency (Hz)')
plt.ylabel('Amplitude in dB')

# *However, we want to get rid of the DC signal (from 0 to ~55Hz)

ratio = int(len(data)/fs) #This allows us to relate frequencies into their sample number
k1 = ratio*0
k2 = ratio*55 
datak[k1:k2+1] = 0 #This zeroes any signal between 0 and 55Hz
##datakdb[len(datakdb)-k2: len(datakdb)-k1+1] = 0 
#
## Now we can plot the audio signal with the DC signal removed
#
plt.figure(3)
plt.semilogx(y,abs(datak))
plt.grid(True)
plt.title('Audio Plot in Frequency Domain with DC signal removed') 
plt.xlabel('Log Frequency (Hz)') 
plt.ylabel('Amplitude')
#
## Now we want to amplify the harmonic frequencies of the signal
#
datak[1000*ratio:5000*ratio] = datak[1000*ratio:5000*ratio]*2.5 # Here the harmonic range has been identified as occuring between 100-5000 Hz and this range has been amplified
plt.figure(4)
plt.semilogx(y,20*np.log10(dataf[0:int(len(dataf)/2)])) # Here the log is taken of dataf as this is the fft of the full spectrum, using datakdb would not use full spectrum
plt.grid(True)
plt.title('Audio Plot in Frequency Domain with Amplified Harmonics')
plt.xlabel('Log Frequency (Hz)') 
plt.ylabel('Amplitude')
#
outputSound = np.fft.ifft(datak) # This takes the ifft of the data to return it into ?????????
outputSound = np.real(outputSound) # Here the imaginary parts of the data are taken out. The code commented out below ensures that doing this is valid as it shows the imaginary values to be negligible
plt.figure(5)
plt.plot(outputSound)
plt.title('Improved Audio Plot')
#plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')
#
#outputSound16 = np.array(outputSound, dtype = 'int16') # here the output is made into an array and then exported as a wav file
#
#wavfile.write("filteredaudio.wav", fs, outputSound16)