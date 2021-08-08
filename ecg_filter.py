#Assignment 2
import numpy as np
import pylab as plt


plt.close("all")
data = np.loadtxt('ecg1.dat')
print(data)


C1 = np.max(data[1,:])
print(C1)

C2 = np.max(data[2,:])
print(C2)

C3 = np.max(data[3,:])
print(C3)



y1 = data[:,1]
y2 = data[:,2]
y3 = data[:,3]
time = data[:,0]


#plt.figure(1)
#plt.plot(time,np.abs(np.fft.fft(y1)))
#plt.title('ECG data C1')
#plt.show()

plt.figure(2)
plt.plot(time,y2)
plt.title('ECG data C2')
plt.show()

plt.figure(3)
plt.plot(time,y3)
plt.title('ECG data C3')
plt.show()


#from plots can be shown data C2 has the highest amplitude

fs = 1000 #recalculated from the graph, sheet shows you the caclulations

m = int(fs/0.8)+1 # +1 to account for final interval, need 4 samples to show 3 intervals etc

#Define impulse response which is coefficients
#using fft and ifft
h = np.ones(m) # array of all ones with 1250 samples
f1 = 0 #cutoff frequency 1 dealing with DC signal
f2 = 0.8 #cutoff frequency 2 dealing with DC signal
#DC range is 0-0.8Hz
index1 = int(f1*(m-1)/fs)
index2 = int(f2*(m-1)/fs)
f3 = 45 #cutoff frequency 3 dealing with 50Hz noise
f4 = 55 #cutoff frequency 4 dealing with 50Hz noise
index3 = int(f3*(m-1)/fs)
index4 = int(f4*(m-1)/fs)
h[index1:index2 +1]=0 #any value between 0-0.8Hz is zero
#sometimes in python does not reach final value but will go to one before hence add 1
h[index3:index4 +1]=0 # any value between 45-55Hz is zero  

#now map the mirror
h[m-index2:m-index1 +1]=0
h[m-index4:m-index3 +1]=0

#plt.figure(4)
#plt.scatter(np.linspace(0,fs,m),h)


hifft = np.real(np.fft.ifft(h))
#plt.figure(5)
#plt.plot(hifft)

hifft_reorder = np.ones(m)
hifft_reorder[m-int(m/2)-1:m]= hifft[0:int(m/2)+1] # when turn it into integer is reduced by 0.5 also python wont reach final so we plus 2 to return to midpoint
hifft_reorder[0:m-int(m/2)-1] = hifft[int(m/2)+1:m]

#plt.figure(6)
#plt.scatter(np.linspace(0,m,m),hifft_reorder)

#plt.figure(7)
#plt.plot(hifft_reorder)

#we have now found the coefficients


class FIR_filter:
    def __init__(self,_coeff):
        self.coeff = _coeff
        self.ntaps = len(self.coeff)
        self.buffer = np.zeros(self.ntaps)
        self.pointer = self.ntaps-1
    def dofilter(self,v): #no black colour means reserved for function so need to give it specific name  
        self.buffer[self.pointer] = v
        result = 0
        result += np.inner(self.buffer[self.pointer:self.ntaps],self.coeff[0:self.ntaps-self.pointer])
        result += np.inner(self.buffer[0:self.pointer],self.coeff[self.ntaps-self.pointer:self.ntaps])
        self.pointer -=1 #increments of one round ring
        if self.pointer < 0:
            self.pointer = self.ntaps-1
       
        return result
       

filtered_y2 = np.zeros(len(y2))
   
myfilter = FIR_filter(hifft_reorder)
for i in range(len(y2)):
        filtered_y2[i] = myfilter.dofilter(y2[i]) # [i] corresponding index value
       
plt.figure(8)
plt.plot(filtered_y2)
plt.show()