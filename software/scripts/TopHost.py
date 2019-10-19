#!/usr/bin/env python3
import setupLibPaths

import sys
import argparse
import rogue
import rogue.hardware.axi
import rogue.interfaces.stream
import rogue.interfaces.memory

import pyrogue as pr
import pyrogue.gui
import pyrogue.utilities.prbs
import pyrogue.interfaces.simulation

import axipcie  as pcie
# import rogue.axi as axi

import time
import math
import random
import struct
import numpy as np

def execute(base, cliargs):
  accel = base.Fpga.SpatialBox
  accel.Reset.set(1)
  accel.Enable.set(0)
  time.sleep(0.01)
  accel.Reset.set(0)
  print("Starting TopHost.py...")
  x53 = base.frameIn
  x54 = np.array([50462976,117835012,185207048,252579084,319951120,387323156,454695192,522067228], dtype='uint64')
  base.frameIn.sendFrame(x54)
  x57 = base.frameIn
  done = accel.Done.get()
  ctr = 0
  accel.Enable.set(1)
  while (done == 0):
    done = accel.Done.get()
    time.sleep(0.01)
    ctr = ctr + 1
    if (ctr % 75 == 0): print("  Polled flag %d times..." % ctr)
  
  print("Finished executing TopHost.py for HostFrameExchange!") 
  instrumentation = open('./instrumentation.txt','w+')
  # Need to instrument List((x7,1))
  print('ArgIns: %d, ArgIOs: %d' % (1,2)) #( " " ,  " " ))
   # immediate parent hashmap now Map(1 -> x7), current node x7 is at depth 1
  x7_cycles = accel.X7_cycles_arg.get()
  time.sleep(0.0001)
  x7_iters = accel.X7_iters_arg.get()
  time.sleep(0.0001)
  x7_iters_per_parent = x7_iters / max(1,x7_iters)
  time.sleep(0.0001)
  x7_avg = x7_cycles / max(1,x7_iters)
  time.sleep(0.0001)
  print('  x7 - %d ( %d / %d ) [%d iters/parent execution]' % (x7_avg,x7_cycles,x7_iters,x7_iters_per_parent), end='')
  #instrumentation.write('  x7 - %d ( %d / %d ) [%d iters/parent execution]' % (x7_avg,x7_cycles,x7_iters,x7_iters_per_parent), end='')
  print('')
  instrumentation.write('')
  instrumentation.close();
  x58 = np.zeros(8, dtype='uint64')
  x59 = base.frameOut.getFrame()
  x60 = (str("Wanted:") + str("\n"));
  print(x60)
  x62 = len(x54)
  for b13 in range(0,x62,1):
    x63 = x54[b13]
    x64 = str(x63)
    x65 = (x64 + str(" "));
    print(x65)
  
  print(str("\n"))
  x69 = (str("Got:") + str("\n"));
  print(x69)
  x71 = len(x58)
  for b23 in range(0,x71,1):
    x72 = x58[b23]
    x73 = str(x72)
    x74 = (x73 + str(" "));
    print(x74)
  
  print(str("\n"))
  x81 = np.zeros(len(x58), dtype=bool)
  for b30 in range(len(x58)):
    x78 = x58[b30]
    x79 = x54[b30]
    x80 = x78 == x79;
    x81[b30] = x80
  
  x83 = np.zeros(len(x81),dtype='bool')
  for b35 in range(0,len(x81)):
    x82 = x81[b35]
    x83[b35] = x82
  
  x86 = 0
  if (len(x83) > 0): # Hack to handle reductions on things of length 0
    x86 = x83[0]
  else:
    x86 = 0
  
  for b38 in range(1,len(x83)):
    b39 = x83[b38]
    b40 = x86;
    x85 = b39 & b40;
    x86 = x85;
  
  x87 = ("\n=================\n" + (str("LoadStoreUnitTests.scala:60:11: Assertion failure") + "\n=================\n"));
  if (True): assert(x86), "%s" % x87

