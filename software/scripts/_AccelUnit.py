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
        self.add(pr.RemoteVariable(name = 'IN_ptr', description = 'dram ptr', offset = 8, bitSize = 32, bitOffset = 0, mode = 'RW',))
        self.add(pr.RemoteVariable(name = 'OUT_ptr', description = 'dram ptr', offset = 12, bitSize = 32, bitOffset = 0, mode = 'RW',))

##### ArgIOs

##### ArgOuts

##### Instrumentation Counters
        self.add(pr.RemoteVariable(name = 'X7_cycles_arg', description = 'cycs', offset = 16, bitSize = 32, bitOffset = 0, mode = 'RO',))
        self.add(pr.RemoteVariable(name = 'X7_iters_arg', description = 'numiters', offset = 20, bitSize = 32, bitOffset = 0, mode = 'RO',))

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
