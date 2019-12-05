# Setup the Xilinx software and licensing
echo "Source settings.sh for Vivado 2018.3..."
#source /afs/slac.stanford.edu/g/reseng/xilinx/vivado_2018.3/Vivado/2018.3/settings64.sha
export XILINX_VIVADO=/local/ssd/opt/Xilinx/Vivado/2018.3
source /local/ssd/opt/Xilinx/Vivado/2018.3/settings64.sh

# Setup VCS simulation environment 
echo "Point \$VCS_VERSION and \$VCS_HOME appropriately..."
#source  /afs/slac.stanford.edu/g/reseng/synopsys/vcs-mx/N-2017.12-1/settings.csh
export VCS_VERSION=2018
export VCS_HOME=/cad/synopsys/vcs-mx/O-2018.09-SP1/
export PATH=${VCS_HOME}/bin:$PATH

echo "Point \$ZMQ_HOME appropriately..."
source /opt/zeromq-4.2.0/settings.sh
