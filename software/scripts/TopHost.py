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
  x91 = base.frameIn
  x93 = np.zeros(64, dtype='uint32')
  for b3 in range(0,64):
    x92 = b3;
    x93[b3] = x92
  
  base.frameIn.sendFrame(x93.astype(dtype='uint64'))
  x96 = base.frameOut
  done = accel.Done.get()
  ctr = 0
  accel.Enable.set(1)
  while (done == 0):
    done = accel.Done.get()
    time.sleep(0.01)
    ctr = ctr + 1
    if (ctr % 75 == 0): print("  Polled flag %d times..." % ctr)
  
  print("Finished executing TopHost.py for FrameLoadStoreTest!") 
  instrumentation = open('./instrumentation.txt','w+')
  # Need to instrument List((x21,1), (x132,2), (x106,3), (x105,4), (x116,3), (x131,3), (x130,4))
  print('ArgIns: %d, ArgIOs: %d' % (1,2)) #( " " ,  " " ))
   # immediate parent hashmap now Map(1 -> x21), current node x21 is at depth 1
  x21_cycles = accel.X21_cycles_arg.get()
  time.sleep(0.0001)
  x21_iters = accel.X21_iters_arg.get()
  time.sleep(0.0001)
  x21_iters_per_parent = x21_iters / max(1,x21_iters)
  time.sleep(0.0001)
  x21_avg = x21_cycles / max(1,x21_iters)
  time.sleep(0.0001)
  print('  x21 - %d ( %d / %d ) [%d iters/parent execution]' % (x21_avg,x21_cycles,x21_iters,x21_iters_per_parent), end='')
  #instrumentation.write('  x21 - %d ( %d / %d ) [%d iters/parent execution]' % (x21_avg,x21_cycles,x21_iters,x21_iters_per_parent), end='')
  print('')
  instrumentation.write('')
   # immediate parent hashmap now Map(2 -> x132, 1 -> x21), current node x132 is at depth 2
  x132_cycles = accel.X132_cycles_arg.get()
  time.sleep(0.0001)
  x132_iters = accel.X132_iters_arg.get()
  time.sleep(0.0001)
  x132_iters_per_parent = x132_iters / max(1,x21_iters)
  time.sleep(0.0001)
  x132_avg = x132_cycles / max(1,x132_iters)
  time.sleep(0.0001)
  print('    x132 - %d ( %d / %d ) [%d iters/parent execution]' % (x132_avg,x132_cycles,x132_iters,x132_iters_per_parent), end='')
  #instrumentation.write('    x132 - %d ( %d / %d ) [%d iters/parent execution]' % (x132_avg,x132_cycles,x132_iters,x132_iters_per_parent), end='')
  print('')
  instrumentation.write('')
   # immediate parent hashmap now Map(2 -> x132, 1 -> x21, 3 -> x106), current node x106 is at depth 3
  x106_cycles = accel.X106_cycles_arg.get()
  time.sleep(0.0001)
  x106_iters = accel.X106_iters_arg.get()
  time.sleep(0.0001)
  x106_iters_per_parent = x106_iters / max(1,x132_iters)
  time.sleep(0.0001)
  x106_avg = x106_cycles / max(1,x106_iters)
  time.sleep(0.0001)
  print('      x106 - %d ( %d / %d ) [%d iters/parent execution]' % (x106_avg,x106_cycles,x106_iters,x106_iters_per_parent), end='')
  #instrumentation.write('      x106 - %d ( %d / %d ) [%d iters/parent execution]' % (x106_avg,x106_cycles,x106_iters,x106_iters_per_parent), end='')
  print('')
  instrumentation.write('')
   # immediate parent hashmap now Map(2 -> x132, 4 -> x105, 1 -> x21, 3 -> x106), current node x105 is at depth 4
  x105_cycles = accel.X105_cycles_arg.get()
  time.sleep(0.0001)
  x105_iters = accel.X105_iters_arg.get()
  time.sleep(0.0001)
  x105_iters_per_parent = x105_iters / max(1,x106_iters)
  time.sleep(0.0001)
  x105_avg = x105_cycles / max(1,x105_iters)
  time.sleep(0.0001)
  print('        x105 - %d ( %d / %d ) [%d iters/parent execution]' % (x105_avg,x105_cycles,x105_iters,x105_iters_per_parent), end='')
  #instrumentation.write('        x105 - %d ( %d / %d ) [%d iters/parent execution]' % (x105_avg,x105_cycles,x105_iters,x105_iters_per_parent), end='')
  x105_stalled = accel.X105_stalled_arg.get()
  x105_idle = accel.X105_idle_arg.get()
  print(' <# stalled: %d, #idle: %d>' % (x105_stalled,x105_idle), end='')
  #instrumentation.write(' <# stalled: %d, #idle: %d>' % (x105_stalled,x105_idle), end='')
  print('')
  instrumentation.write('')
   # immediate parent hashmap now Map(2 -> x132, 4 -> x105, 1 -> x21, 3 -> x116), current node x116 is at depth 3
  x116_cycles = accel.X116_cycles_arg.get()
  time.sleep(0.0001)
  x116_iters = accel.X116_iters_arg.get()
  time.sleep(0.0001)
  x116_iters_per_parent = x116_iters / max(1,x132_iters)
  time.sleep(0.0001)
  x116_avg = x116_cycles / max(1,x116_iters)
  time.sleep(0.0001)
  print('      x116 - %d ( %d / %d ) [%d iters/parent execution]' % (x116_avg,x116_cycles,x116_iters,x116_iters_per_parent), end='')
  #instrumentation.write('      x116 - %d ( %d / %d ) [%d iters/parent execution]' % (x116_avg,x116_cycles,x116_iters,x116_iters_per_parent), end='')
  x116_stalled = accel.X116_stalled_arg.get()
  x116_idle = accel.X116_idle_arg.get()
  print(' <# stalled: %d, #idle: %d>' % (x116_stalled,x116_idle), end='')
  #instrumentation.write(' <# stalled: %d, #idle: %d>' % (x116_stalled,x116_idle), end='')
  print('')
  instrumentation.write('')
   # immediate parent hashmap now Map(2 -> x132, 4 -> x105, 1 -> x21, 3 -> x131), current node x131 is at depth 3
  x131_cycles = accel.X131_cycles_arg.get()
  time.sleep(0.0001)
  x131_iters = accel.X131_iters_arg.get()
  time.sleep(0.0001)
  x131_iters_per_parent = x131_iters / max(1,x132_iters)
  time.sleep(0.0001)
  x131_avg = x131_cycles / max(1,x131_iters)
  time.sleep(0.0001)
  print('      x131 - %d ( %d / %d ) [%d iters/parent execution]' % (x131_avg,x131_cycles,x131_iters,x131_iters_per_parent), end='')
  #instrumentation.write('      x131 - %d ( %d / %d ) [%d iters/parent execution]' % (x131_avg,x131_cycles,x131_iters,x131_iters_per_parent), end='')
  print('')
  instrumentation.write('')
   # immediate parent hashmap now Map(2 -> x132, 4 -> x130, 1 -> x21, 3 -> x131), current node x130 is at depth 4
  x130_cycles = accel.X130_cycles_arg.get()
  time.sleep(0.0001)
  x130_iters = accel.X130_iters_arg.get()
  time.sleep(0.0001)
  x130_iters_per_parent = x130_iters / max(1,x131_iters)
  time.sleep(0.0001)
  x130_avg = x130_cycles / max(1,x130_iters)
  time.sleep(0.0001)
  print('        x130 - %d ( %d / %d ) [%d iters/parent execution]' % (x130_avg,x130_cycles,x130_iters,x130_iters_per_parent), end='')
  #instrumentation.write('        x130 - %d ( %d / %d ) [%d iters/parent execution]' % (x130_avg,x130_cycles,x130_iters,x130_iters_per_parent), end='')
  x130_stalled = accel.X130_stalled_arg.get()
  x130_idle = accel.X130_idle_arg.get()
  print(' <# stalled: %d, #idle: %d>' % (x130_stalled,x130_idle), end='')
  #instrumentation.write(' <# stalled: %d, #idle: %d>' % (x130_stalled,x130_idle), end='')
  print('')
  instrumentation.write('')
  instrumentation.close();
  x133 = np.zeros(64, dtype='uint32')
  x134 = base.frameOut.getFrame()
  x133 = np.frombuffer(x134, dtype='uint64').astype(dtype='uint32')
  x137 = np.zeros(len(x93),dtype='uint32')
  for b24 in range(0,len(x93)):
    x135 = x93[b24]
    x136 = x135 + 5;
    x137[b24] = x136
  
  x138 = (str("Wanted:") + str("\n"));
  print(x138)
  x140 = len(x137)
  for b31 in range(0,x140,1):
    x141 = x137[b31]
    x142 = str(x141)
    x143 = (x142 + str(" "));
    print(x143)
  
  print(str("\n"))
  x147 = (str("Got:") + str("\n"));
  print(x147)
  x149 = len(x133)
  for b41 in range(0,x149,1):
    x150 = x133[b41]
    x151 = str(x150)
    x152 = (x151 + str(" "));
    print(x152)
  
  print(str("\n"))
  x159 = np.zeros(len(x133), dtype=bool)
  for b48 in range(len(x133)):
    x156 = x133[b48]
    x157 = x137[b48]
    x158 = x156 == x157;
    x159[b48] = x158
  
  x161 = np.zeros(len(x159),dtype='bool')
  for b53 in range(0,len(x159)):
    x160 = x159[b53]
    x161[b53] = x160
  
  x164 = 0
  if (len(x161) > 0): # Hack to handle reductions on things of length 0
    x164 = x161[0]
  else:
    x164 = 0
  
  for b56 in range(1,len(x161)):
    b57 = x161[b56]
    b58 = x164;
    x163 = b57 & b58;
    x164 = x163;
  
  x165 = ("\n=================\n" + (str("LoadStoreUnitTests.scala:80:11: Assertion failure") + "\n=================\n"));
  if (True): assert(x164), "%s" % x165

