#!/usr/bin/python
# 
# Sample of measuring and frequency correction with ACOUNTER02A

import time
import datetime
import sys
from pymlab import config

req_freq = 286.0788       # required local oscillator frequency in MHz. 

#### Sensor Configuration ###########################################

cfg = config.Config(
    i2c = {
        "port": 1,
    },
    bus = [
        {
            "type": "i2chub",
            "address": 0x70,
	       	"children": [
                        { "name":"counter", "type":"acount02", "channel": 2, },
                        { "name":"clkgen", "type":"clkgen01", "channel": 5, },
		    ],
        },
    ],
)
cfg.initialize()

print "RMDS Station frequency management test software \r\n"
fcount = cfg.get_device("counter")
fgen = cfg.get_device("clkgen")
time.sleep(0.5)
frequency = fcount.get_freq()
rfreq = fgen.get_rfreq()
hsdiv = fgen.get_hs_div()
n1 = fgen.get_n1_div()

'''
# sample GPS configuration
fcount.conf_GPS(0,5)		# length of the GPS configurtion sentence
fcount.conf_GPS(1,ord('a'))	# the first byte of GPS configuration sentence
fcount.conf_GPS(2,ord('b'))	# the second byte of GPS configyration sentence
fcount.conf_GPS(3,ord('c'))
fcount.conf_GPS(4,ord('d'))
fcount.conf_GPS(5,ord('e'))
'''
fcount.set_GPS()	# set GPS configuration

#### Data Logging ###################################################

try:
    with open("frequency.log", "a") as f:
        while True:
            now = datetime.datetime.now()
            if (now.second == 15) or (now.second == 35) or (now.second == 55):
                frequency = fcount.get_freq()
                if (len(sys.argv) == 3):
                    regs = fgen.set_freq(frequency/1e6, float(req_freq))              
                now = datetime.datetime.now()

            rfreq = fgen.get_rfreq()
            hsdiv = fgen.get_hs_div()
            n1 = fgen.get_n1_div()
            fdco = (frequency/1e6) * hsdiv * n1
            fxtal = fdco / rfreq 

            sys.stdout.write("frequency: " + str(frequency) + " Hz  Time: " + str(now.second))
            sys.stdout.write(" RFREQ: " + str(rfreq) + " HSDIV: " + str(hsdiv) + " N1: " + str(n1))
            sys.stdout.write(" fdco: " + str(fdco) + " fxtal: " + str(fxtal) + "\r")
            f.write("%d\t%s\t%.3f\n" % (time.time(), datetime.datetime.now().isoformat(), frequency))

            sys.stdout.flush()
            time.sleep(0.9)
except KeyboardInterrupt:
    sys.stdout.write("\r\n")
    sys.exit(0)
    f.close()
