#!/usr/bin/env python3
import pyrogue as pr

import rogue.protocols

import surf.axi               as axi
import surf.protocols.batcher as batcher

import numpy as np

import rogue.interfaces.stream

class FrameMaster(rogue.interfaces.stream.Master):

    # Init method must call the parent class init
    def __init__(self):
        super().__init__()

    # Method for generating a frame
    def sendFrame(self,data):
        #print('TODO: Streaming data is hacky because it sends each element twice instead of properly using a clock converter IP!!!!!')
        #frame = self._reqFrame(len(data.tobytes()*2), True)
        #frame.write(np.hstack([[i,i] for i in data]),0)
        frame = self._reqFrame(len(data.tobytes()), True)
        frame.write(data,0)
        self._sendFrame(frame)
        print('sent data frame of size %d' % len(data))
        print(data)
