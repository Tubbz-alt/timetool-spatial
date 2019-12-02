import numpy as np
import rogue.interfaces.stream

class FrameSlave(rogue.interfaces.stream.Slave):

    # Init method must call the parent class init
    def __init__(self):
        super().__init__()
        self.frame = []

    # Method which is called when a frame is received
    def _acceptFrame(self,frame):
        # First it is good practice to hold a lock on the frame data.
        with frame.lock():

            # Next we can get the size of the frame payload
            size = frame.getPayload()

            # To access the data we need to create a byte array to hold the data
            fullData = bytearray(size)

            # Next we read the frame data into the byte array, from offset 0
            frame.read(fullData,0)

        # Since the data is coped into the passed byte arrays we are free to
        # access the copied data outside of the lock
        print('Received frame of size %d' % size)
        self.frame = fullData

    def getFrame(self):
        return self.frame
