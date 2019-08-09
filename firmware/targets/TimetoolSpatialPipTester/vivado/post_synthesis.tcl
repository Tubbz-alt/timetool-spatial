##############################################################################
## This file is part of 'ATLAS RD53 DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

##############################
# Get variables and procedures
##############################
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# # Bypass the debug chipscope generation
# return

############################
## Open the synthesis design
############################
open_run synth_1

###############################
## Set the name of the ILA core
###############################
set ilaName u_ila_1

##################
## Create the core
##################
CreateDebugCore ${ilaName}

#######################
## Set the record depth
#######################
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_Core/U_REG/U_XBAR/axiClk}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbWriteMaster[awaddr][*]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbWriteMaster[wstrb][*]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[obMasters][0][tUser][1]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[obMasters][1][tUser][1]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[state][*]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/obCtrl[overflow]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/obCtrl[pause]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbMaster[tLast]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbMaster[tValid]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbSlave[tReady]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbWriteMaster[awvalid]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbWriteMaster[wlast]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbWriteMaster[wvalid]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbWriteSlave[awready]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/pipIbWriteSlave[wready]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[obMasters][0][tLast]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[obMasters][1][tLast]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[obMasters][0][tValid]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[obMasters][1][tValid]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[pipIbWriteSlave][awready]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[pipIbWriteSlave][bvalid]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[pipIbWriteSlave][wready]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[rxDropFrame]}
# ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[rxFrame]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[tFirst]}
# ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[tLast]}
ConfigProbe ${ilaName} {U_AxiPciePipCore/U_AxiPciePipRx/r[tValid]}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName} 

