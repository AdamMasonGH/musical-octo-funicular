# -*- coding: utf-8 -*-
"""
Created on Sun Aug  8 14:18:41 2021

@author: adamj
"""

import threading

from time import sleep
import sys
import scipy.signal as signal
import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtGui

import numpy as np

import pyusbdux as c

# create a global QT application object
app = QtGui.QApplication(sys.argv)

# signals to all threads in endless loops that we'd like to run these
running = True

channel_of_window1 = 0
channel_of_window2 = 0

fs =1000
f1 =45
f2 =55
f3 = 10
f4 = 499

#sos = signal.butter(4, 40/fs*2, 'lp', output='sos')
n = 4
sos1 = signal.butter(4, [f1/fs,f2/fs], btype = 'bandstop', analog = True, output = 'sos')
sos2 = signal.butter(4, [f3/fs,f4/fs], btype = 'bandpass',  analog = True, output = 'sos')
#sos1 = signal.butter(n, [0.01/fs*2], btype='high' , output = 'sos')
#sos2 = signal.butter(n, [40/fs*2], btype='low' , output = 'sos')
#sos1= signal.butter(n, [f1/fs*2,f2/fs*2 ], btype='stop' , output = 'sos')
#sos2= signal.butter(n, [0.01/fs*2,0.1/fs*2 ], btype='stop' , output = 'sos')

class IIR2Filter:
    def __init__(self,s):
        self.b0 = s[0]
        self.b1 = s[1]
        self.b2 = s[2]
        self.a0 = s[3]
        self.a1 = s[4]
        self.a2 = s[5]
        self.buffer1 = 0
        self.buffer2 = 0

       
    def filter(self,v):
       
        #print("b1= ",self.buffer1)
        #change filter to fixed point
        #put in scaling
       
        acc_input =v- self.buffer1*self.a1 - self.buffer2*self.a2
        acc_output = acc_input*self.b0 + self.buffer1*self.b1 +self.buffer2*self.b2
        self.buffer2 = self.buffer1
        self.buffer1 = acc_input

        return acc_output


class IIRFilter:

    def __init__(self, sos):
        print("master")
        self.iir2 = []
        for s in sos:
            #print(s)
            self.iir2.append(IIR2Filter(s))
           #print(self.iir2)

    def  doFilter(self,v):
        for f in self.iir2:
            v = f.filter(v)
            #print("v=", v)
            #print("buffer1=", buffer1)
            #print("buffer2=", buffer2)
       
        return v


class QtPanningPlot:

    def __init__(self,title):
        self.win = pg.GraphicsLayoutWidget()
        self.win.setWindowTitle(title)
        self.plt = self.win.addPlot()
        self.plt.setYRange(-1,1)
        self.plt.setXRange(0,1000)
        self.curve = self.plt.plot()
        self.data = []
        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(self.update)
        self.timer.start(100)
        self.layout = QtGui.QGridLayout()
        self.win.setLayout(self.layout)
        self.win.show()
       
    def update(self):
        self.data=self.data[-1000:]
        if self.data:
            self.curve.setData(np.hstack(self.data))

    def addData(self,d):
        self.data.append(d)


def getDataThread(qtPanningPlot1,qtPanningPlot2):
    # endless loop which sleeps not for timing but for multitasking
    t=IIRFilter(sos1)
    t1 = IIRFilter(sos2)

   
    while running:
        # loop as fast as we can to empty the kernel buffer
        while c.hasSampleAvailable():
            sample = c.getSampleFromBuffer()
            v1 = sample[channel_of_window1]
            v2 = sample[channel_of_window2]
            y=t.doFilter(v1)
            y1=t1.doFilter(y)
         
            qtPanningPlot1.addData(y1)
            qtPanningPlot2.addData(v1)
           
            if y1 > 1:
                print("Tensed")
             
               
        # let Python do other stuff and sleep a bit
        sleep(0.1)
       

# open comedi
c.open()

# info about the board
print("ADC board:",c.get_board_name())

# Let's create two instances of plot windows
qtPanningPlot1 = QtPanningPlot("FILTERED EMG "+str(channel_of_window1))
qtPanningPlot2 = QtPanningPlot("UNFILTERED EMG "+str(channel_of_window2))

# create a thread which gets the data from the USB-DUX
t = threading.Thread(target=getDataThread,args=(qtPanningPlot1,qtPanningPlot2,))

# start data acquisition
c.start(8,1000)

# start the thread getting the data
t.start()

# showing all the windows
app.exec_()

# no more data from the USB-DUX
c.stop()

# Signal the Thread to stop
running = False

# Waiting for the thread to stop
t.join()

c.close()

print("finished")
