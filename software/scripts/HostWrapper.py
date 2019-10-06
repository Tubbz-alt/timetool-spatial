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
import surf.axi as axi
from _AccelTop import AccelTop
from TopHost import execute

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

# Add arguments
parser.add_argument(
    "--dev", 
    nargs    = '+',
    required = False,
    default  = ['/dev/datadev_0'],
    # default  = ['/dev/datadev_0','/dev/datadev_1'],
    help     = 'List of devices',
)  

parser.add_argument(
    "--script",
    dest     = 'noninteractive',
    action   = 'store_true'
)
parser.set_defaults(noninteractive=False)
parser.add_argument(
    "--numLane", 
    type     = int,
    required = False,
    default  = 1,
    help     = "# of DMA Lanes",
) 

parser.add_argument(
    "--numVc", 
    type     = int,
    required = False,
    default  = 1,
    help     = "# of VC (virtual channels)",
) 

parser.add_argument(
    "--pollEn", 
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable auto-polling",
) 

parser.add_argument(
    "--initRead", 
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable read all variables at start",
)  

parser.add_argument(
    "--cliargs",
    nargs    = "*",
    default = [],
    help    = "Command line args for Spatial app"
)
# Get the arguments
args = parser.parse_args()

#################################################################

class Fpga(pr.Device):
    def __init__(   
        self,       
        name        = 'Fpga',
        description = 'Container for FPGA registers',
            **kwargs):
        
        super().__init__(name=name,description=description,**kwargs)

        self.add(pcie.AxiPcieCore(
            offset       = 0x00000000, 
            numDmaLanes  = args.numLane, 
            expand       = False, 
        ))   
        
        self.add(AccelTop(
            name    = f'SpatialBox',
            offset  = 0x00100000, 
            expand  = False, 
        ))                    
            
#        self.add(pcie.AxiPipCore(
#            offset  = 0x00200000, 
#            expand  = False, 
#        ))
        
#################################################################

class MyRoot(pr.Root):
    def __init__(   self,       
            name        = "MyRoot",
            description = "my root container",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        #################################################################
        
        self.numPciDev  = len(args.dev) if (args.dev[0] != 'sim') else 1
        
        self.memMap    =                                                             [None for z in range(self.numPciDev)]
        self.dmaStream = [[[None for x in range(args.numVc)] for y in range(args.numLane)] for z in range(self.numPciDev)]
#        self.prbsRx    = [[[None for x in range(args.numVc)] for y in range(args.numLane)] for z in range(self.numPciDev)]
#        self.prbTx     = [[[None for x in range(args.numVc)] for y in range(args.numLane)] for z in range(self.numPciDev)]  

        
        #################################################################
        # VCS simulation
        if ( args.dev[0] == 'sim' ):            
        
            self.memMap[0] = rogue.interfaces.memory.TcpClient('localhost',8000)
            
            # Create the DMA loopback channel
            for lane in range(args.numLane):
                for vc in range(args.numVc):
                    self.dmaStream[0][lane][vc] = rogue.interfaces.stream.TcpClient('localhost',8002+(512*lane)+2*vc)           

        # DataDev PCIe Card
        else:

            for i in range(self.numPciDev):
            
                # Create PCIE memory mapped interface
                self.memMap[i] = rogue.hardware.axi.AxiMemMap(args.dev[i])   
                
                # Create the DMA loopback channel
                for lane in range(args.numLane):
                    for vc in range(args.numVc):
                        self.dmaStream[i][lane][vc] = rogue.hardware.axi.AxiStreamDma(args.dev[i],(0x100*lane)+vc,1)            
                
        #################################################################
        

        # Add the FPGA device class
        self.add(Fpga(
            name    = f'Fpga',
            memBase = self.memMap[0],
            expand  = True, 
        ))                    
	    	

        # Start the system
        self.start(
            pollEn   = False if(args.dev[0]=='sim') else args.pollEn,
            initRead = False if(args.dev[0]=='sim') else args.initRead,
            timeout  = 5.0 if(args.dev[0]=='sim') else 1.0,
        )
        
                   
#################################################################

# Set base
base = MyRoot(name='pciServer',description='Generic Spatial Application Wrapper')

#################################################################

if (args.noninteractive):
    execute(base.Fpga.SpatialBox, args.cliargs)
    base.stop()
else:
    # Create GUI
    appTop = pyrogue.gui.application(sys.argv)
    guiTop = pyrogue.gui.GuiTop()
    guiTop.addTree(base)
    guiTop.resize(800, 1000)

    # Run gui
    appTop.exec_()
    base.stop()


