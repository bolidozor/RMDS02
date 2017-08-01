#!/usr/bin/python
# 
# Utility for setting frequency of Si570 without a frequency measurement.
# The factory calibration is used for changing the frequency.
# This utility reset the Si570 to factory default 10 MHz first and than set a new frequency.
#
# This utility use an USBI2C01A module.
# (c) MLAB 2014

import time
import datetime
import sys
from pymlab import config

import logging 
logging.basicConfig(level=logging.DEBUG) 


#### Script Arguments ###############################################

if (len(sys.argv) != 3):
    sys.stderr.write("Invalid number of arguments.\n")
    sys.stderr.write("Usage: %s PORT_ADDRESS/0 REQUIERED_MHz\n" % (sys.argv[0], ))
    sys.exit(1)

port    = eval(sys.argv[1])
#### Sensor Configuration ###########################################

cfg = config.Config(
    i2c = {
        "port": port,
    },
    bus = [
        {
            "type": "i2chub",
            "address": 0x70,
	       	"children": [
                        { "name":"clkgen", "type":"clkgen01", "channel": 1, },
		    ],
        },
    ],
)
cfg.initialize()

fgen = cfg.get_device("clkgen") 
sys.stdout.write("Frequency will be set to " + sys.argv[2] + " MHz.\r\n")
fgen.route()
time.sleep(3)
fgen.recall_nvm()   # Reload settings for 10 MHz
time.sleep(3)
fgen = cfg.get_device("clkgen") # Reopen CP2112
fgen.set_freq(10., float(eval(sys.argv[2]))) # Set frequency
sys.stdout.write("Done.\r\n")
sys.stdout.flush()
sys.exit(0)

