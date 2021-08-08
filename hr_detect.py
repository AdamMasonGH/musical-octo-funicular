import numpy as np
import matplotlib.pyplot as plt

plt.close("all")

class FIR_filter:    #Question 1 complete
    
    def __init__(self,_coeff): 
        self.coeff = _coeff           
        self.ntaps = len(self.coeff)     #number of data points
        self.buffer = np.zeros(len(self.coeff))   #initialises the buffer
        self.pointer = self.ntaps-1         #initialses starting point 
        
    def dofilter(self,a):
        self.buffer[self.pointer] = a
        result = 0
        result += np.inner(self.buffer[self.pointer:self.ntaps],self.coeff[0:self.ntaps-self.pointer])
        result += np.inner(self.buffer[0:self.pointer],self.coeff[self.ntaps-self.pointer:self.ntaps])
        self.pointer -= 1 #one round ring
        if self.pointer < 0:
            self.pointer = self.ntaps-1
        
        return result

class MF:
    
    def __init__(self,type):
        if type == 'mex':
            f1 = 10                
            length1 = 0.128
            dt1 = 0.001
            t1 = np.arange(-length1/2,(length1-dt1)/2,dt1)
            template = (1.0-2.0*(np.pi**2)*(f1**2)*(t1**2))*np.exp(-(np.pi**2)*(f1**2)*(t1**2))

        if type == 'fakemex':
            f2 = 100              
            length2 = 0.128
            dt2 = 0.001
            t2 = np.arange(-length2/2,(length2-dt2)/2,dt2)
            template = (1.0-2.0*(np.pi**2)*(f2**2)*(t2**2))*np.exp(-(np.pi**2)*(f2**2)*(t2**2))
            
        self.f = FIR_filter(template)

all = np.loadtxt('ecg2.dat')

data = all[:,3]

data_1 = np.fft.fft(data) #to find if theres noise

fs = 1000
a = np.max (data, 0)

fmin = 0.5
ntaps = int(fs/fmin)
x = np.ones(ntaps)

f1 = 45
f2 = 55
k1 = int(45/fs*ntaps)
k2 = int(55/fs*ntaps)
x[k1:k2+1] = 0
x[ntaps-k2:ntaps-k1+1] = 0

x[0] = 0

x = np.fft.ifft(x)      

x = np.real(x)       #make real
y = np.empty(ntaps)

y[int(ntaps/2):ntaps] = x[0:int(ntaps/2)]       #+1
y[0:int(ntaps/2)] = x[int(ntaps/2):ntaps]

result = np.zeros(len(data))
myfilter = FIR_filter(y)    
for i in range (len(data)):
    result[i] = myfilter.dofilter(data[i])
   
mymatchfilter = MF('mex')    
for i in range (len(data)):
    result[i] = mymatchfilter.f.dofilter(data[i])
   
plt.plot(result)
#result2 = result*result
#
#time = np.linspace(0,len(data)/fs,len(data))
#
#plt.figure()
#plt.plot(time,result2)
#
#threshold = 0.15*10**16
#for i in range(len(data)):
#    if result2[i] > threshold:
#        result2[i] = 1
#    else: result2[i] = 0
#     
#plt.figure()
#plt.plot(time,result2)
#plt.show()

#z = 1
#def countX(result2,z):
#    count = 0
#    for ele in result2:
#        if (ele == z):
#            count = count + 1
#    return count
#print('{} has occured {} times'.format(z,countX(result2,z)))
#plt.figure()

#plt.plot(result)
#
#t= np.linspace(13600,13800 ,fs)
#damping=-0.048
#
#template= np.sin(t)
#template_1= template[13600:13600]
#template_2= template_1*np.exp(damping*t)

#120b/m changes to2/s to  2/1000
# 
#for 
#if MFresult[i]>threshold and samplenumber is past:
#    


