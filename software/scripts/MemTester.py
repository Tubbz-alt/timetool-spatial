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

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

# Add arguments
parser.add_argument(
    "--dev", 
    type     = str,
    required = False,
    default  = '/dev/datadev_0',
    help     = "path to device",
)  

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

# Get the arguments
args = parser.parse_args()

#################################################################

class MyRoot(pr.Root):
    def __init__(   self,       
            name        = "MyRoot",
            description = "my root container",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        #################################################################
        
        self.dmaStream = [[None for x in range(args.numVc)] for y in range(args.numLane)]
        self.prbsRx    = [[None for x in range(args.numVc)] for y in range(args.numLane)]
        self.prbTx     = [[None for x in range(args.numVc)] for y in range(args.numLane)]  

        # VCS simulation
        if ( args.dev == 'sim' ):            
        
            self.memMap = rogue.interfaces.memory.TcpClient('localhost',8000)
            
            # Create the DMA loopback channel
            for lane in range(args.numLane):
                for vc in range(args.numVc):
                    self.dmaStream[lane][vc] = rogue.interfaces.stream.TcpClient('localhost',8002+(512*lane)+2*vc)           

        # DataDev PCIe Card
        else:

            # Create PCIE memory mapped interface
            self.memMap = rogue.hardware.axi.AxiMemMap(args.dev)   
            
            # Create the DMA loopback channel
            for lane in range(args.numLane):
                for vc in range(args.numVc):
                    self.dmaStream[lane][vc] = rogue.hardware.axi.AxiStreamDma(args.dev,(0x100*lane)+vc,1)            
            
        # Add the PCIe core device to base
        self.add(pcie.AxiPcieCore(
            memBase = self.memMap ,
            offset  = 0x00000000, 
            expand  = False, 
        ))   
        
        for i in range(4):
            self.add(axi.AxiMemTester(
                name    = f'AxiMemTester[{i}]',
                memBase = self.memMap ,
                offset  = 0x00080000+i*0x10000, 
                expand  = False, 
            ))             

        for lane in range(args.numLane):
            for vc in range(args.numVc):
                # Connect the SW PRBS Receiver module
                self.prbsRx[lane][vc] = pr.utilities.prbs.PrbsRx(name=('SwPrbsRx[%d][%d]'%(lane,vc)),expand=False)
                pyrogue.streamConnect(self.dmaStream[lane][vc],self.prbsRx[lane][vc])
                self.add(self.prbsRx[lane][vc])  
                # Connect the SW PRBS Transmitter module
                self.prbTx[lane][vc] = pr.utilities.prbs.PrbsTx(name=('SwPrbsTx[%d][%d]'%(lane,vc)),expand=False)
                pyrogue.streamConnect(self.prbTx[lane][vc], self.dmaStream[lane][vc])
                self.add(self.prbTx[lane][vc]) 
                
        # Start the system
        self.start(
            pollEn   = False if(args.dev=='sim') else args.pollEn,
            initRead = False if(args.dev=='sim') else args.initRead,
            timeout  = 100.0 if(args.dev=='sim') else 1.0,
        )

# Set base
base = MyRoot(name='pciServer',description='DMA Loopback Testing')

#################################################################

# Create GUI
appTop = pyrogue.gui.application(sys.argv)
guiTop = pyrogue.gui.GuiTop(group='TimeToolDev')
guiTop.addTree(base)
guiTop.resize(800, 1000)

# Run gui
appTop.exec_()
base.stop()
