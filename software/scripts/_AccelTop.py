#!/usr/bin/env python
import pyrogue as pr

class AccelTop(pr.Device):
    def __init__(   self,
            name        = 'AccelTop',
            description = 'Spatial Top Module SW',
            **kwargs):
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
        self.add(pr.RemoteVariable(name = 'SIZE_arg', description = 'argIn', offset = 8, bitSize = 32, bitOffset = 0, mode = 'RW',))
        self.add(pr.RemoteVariable(name = 'X_arg', description = 'argIn', offset = 12, bitSize = 32, bitOffset = 0, mode = 'RW',))

##### DRAM Ptrs:
        self.add(pr.RemoteVariable(name = 'SRCFPGA_ptr', description = 'dram ptr', offset = 16, bitSize = 32, bitOffset = 0, mode = 'RW',))
        self.add(pr.RemoteVariable(name = 'DSTFPGA_ptr', description = 'dram ptr', offset = 20, bitSize = 32, bitOffset = 0, mode = 'RW',))

##### ArgIOs

##### ArgOuts

###### Instrumentation Counters
#        self.add(pr.RemoteVariable(name = 'X39_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X39_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X218_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X218_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X176_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X176_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X164_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X164_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X164_stalled_arg', description = 'stalled', offset = 32, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X164_idle_arg', description = 'idle', offset = 36, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X175_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X175_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X175_stalled_arg', description = 'stalled', offset = 32, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X175_idle_arg', description = 'idle', offset = 36, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X189_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X189_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X217_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X217_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X201_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X201_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X201_stalled_arg', description = 'stalled', offset = 32, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X201_idle_arg', description = 'idle', offset = 36, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X212_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X212_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X212_stalled_arg', description = 'stalled', offset = 32, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X212_idle_arg', description = 'idle', offset = 36, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X216_cycles_arg', description = 'cycs', offset = 24, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X216_iters_arg', description = 'numiters', offset = 28, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X216_stalled_arg', description = 'stalled', offset = 32, bitSize = 32, bitOffset = 0, mode = 'RO',))
#        self.add(pr.RemoteVariable(name = 'X216_idle_arg', description = 'idle', offset = 36, bitSize = 32, bitOffset = 0, mode = 'RO',))
#
###### Early Exits
