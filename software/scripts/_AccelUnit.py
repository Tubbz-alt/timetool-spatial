#!/usr/bin/env python
import pyrogue as pr
import rogue.protocols
import numpy as np

class AccelUnit(pr.Device,rogue.interfaces.stream.Slave):
    def __init__(   self,
            name        = 'AccelUnit',
            description = 'Spatial Top Module SW',
            **kwargs):
        rogue.interfaces.stream.Slave.__init__(self)
        super().__init__(name=name, description=description, **kwargs)
        self.add(pr.RemoteVariable(
            name         = 'Enable',
            description  = 'Enable signal for App',
            offset       =  0x000,
            bitSize      =  1,
            bitOffset    =  0,
            mode         = 'RW',
        ))
        self.add(pr.RemoteVariable(
            name         = 'Reset',
            description  = 'Reset signal for App',
            offset       =  0x000,
            bitSize      =  1,
            bitOffset    =  1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'Done',
            description  = 'App Done',
            offset       =  0x004,
            bitSize      =  32,
            bitOffset    =  0,
            mode         = 'RO',
        ))


##### ArgIns

##### DRAM Ptrs:
#        self.add(pr.RemoteVariable(name = 'IN_ptr', description = 'dram ptr', offset = 8, bitSize = 32, bitOffset = 0, mode = 'RW',))
#        self.add(pr.RemoteVariable(name = 'OUT_ptr', description = 'dram ptr', offset = 12, bitSize = 32, bitOffset = 0, mode = 'RW',))

##### ArgIOs

##### ArgOuts

##### Instrumentation Counters
        self.add(pr.RemoteVariable(name = 'X21_cycles_arg', description = 'cycs', offset = 12, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X21_iters_arg', description = 'numiters', offset = 16, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X132_cycles_arg', description = 'cycs', offset = 20, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X132_iters_arg', description = 'numiters', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X106_cycles_arg', description = 'cycs', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X106_iters_arg', description = 'numiters', offset = 32, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X105_cycles_arg', description = 'cycs', offset = 36, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X105_iters_arg', description = 'numiters', offset = 40, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X105_stalled_arg', description = 'stalled', offset = 44, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X105_idle_arg', description = 'idle', offset = 48, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X116_cycles_arg', description = 'cycs', offset = 52, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X116_iters_arg', description = 'numiters', offset = 56, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X116_stalled_arg', description = 'stalled', offset = 60, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X116_idle_arg', description = 'idle', offset = 64, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X131_cycles_arg', description = 'cycs', offset = 68, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X131_iters_arg', description = 'numiters', offset = 72, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X130_cycles_arg', description = 'cycs', offset = 76, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X130_iters_arg', description = 'numiters', offset = 80, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X130_stalled_arg', description = 'stalled', offset = 84, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X130_idle_arg', description = 'idle', offset = 88, bitSize = 32, bitOffset = 0, mode = 'RO',))

##### Early Exits
    # Unused code for testing how to receive a frame in SW
    def _acceptFrame(self,frame):
        p = bytearray(frame.getPayload())
        frame.read(p,0)
        print(len(p))
        my_mask = np.arange(36)
        if(len(p)>100):
              my_mask = np.append(my_mask,np.arange(int(len(p)/2),int(len(p)/2)+36))
              my_mask = np.append(my_mask,np.arange(len(p)-36,len(p)))

        to_print = np.array(p)[-1:]
        #print(np.array(p)[:96],to_print) #comment out for long term test
        print(np.array(p)[my_mask])
        print('--------------------------')
