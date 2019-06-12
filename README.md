# timetool-spatial

<!--- ######################################################## -->

# Before you clone the GIT repository

1) Create a github account:
> https://github.com/

2) On the Linux machine that you will clone the github from, generate a SSH key (if not already done)
> https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

3) Add a new SSH key to your GitHub account
> https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

4) Setup for large filesystems on github

```
$ git lfs install
```

5) Verify that you have git version 2.13.0 (or later) installed 

```
$ git version
git version 2.13.0
```

6) Verify that you have git-lfs version 2.1.1 (or later) installed 

```
$ git-lfs version
git-lfs/2.1.1
```

# Clone the GIT repository

```
$ git clone --recursive git@github.com:slaclab/timetool-spatial
```

<!--- ######################################################## -->

# How to build the PCIe firmware

1) Setup Xilinx licensing
```
$ source timetool-spatial/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd timetool-spatial/firmware/targets/TimetoolSpatialMemTester/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

<!--- ######################################################## -->

# How to run the Rogue PyQT GUI with VCS firmware simulator

1) Start up two terminal

2) In the 1st terminal, launch the VCS simulation
```
$ source timetool-spatial/firmware/setup_env_slac.sh
$ cd timetool-spatial/firmware/targets/TimetoolSpatialMemTester/
$ make vcs
$ cd ../../build/TimetoolSpatialMemTester/TimetoolSpatialMemTester_project.sim/sim_1/behav/
$ source setup_env.sh
$ ./sim_vcs_mx.sh
$ ./simv -gui &
```

3) When the VCS GUI pops up, start the simulation run

4) In the 2nd terminal, launch the PyQT GUI in simulation mode
```
$ cd cd timetool-spatial/software
$ source setup_env_template.sh
$ python scripts/MemTester.py --dev sim
```

<!--- ######################################################## -->

# How to load the driver

```
# Confirm that you have the board the computer with VID=1a4a ("SLAC") and PID=2030 ("AXI Stream DAQ")
$ lspci -nn | grep SLAC
04:00.0 Signal processing controller [1180]: SLAC National Accelerator Lab TID-AIR AXI Stream DAQ PCIe card [1a4a:2030]

# Clone the driver github repo:
$ git clone --recursive https://github.com/slaclab/aes-stream-drivers

# Go to the driver directory
$ cd aes-stream-drivers/data_dev/driver/

# Build the driver
$ make

# Load the driver
$ sudo /sbin/insmod ./datadev.ko cfgSize=0x50000 cfgRxCount=256 cfgTxCount=16

# Give appropriate group/permissions
$ sudo chmod 666 /dev/data_dev*

# Check for the loaded device
$ cat /proc/datadev_0

```
Note: There is a bug (we think in the PCIe IP core) that bricks the DMA when using `rmmod` to unload the driver.
If you want to reconfigure the PCIe card with different buffering allocation, then do a `reboot` before doing the `insmod`


<!--- ######################################################## -->
