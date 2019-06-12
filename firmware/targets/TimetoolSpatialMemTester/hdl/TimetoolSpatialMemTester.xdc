##############################################################################
## This file is part of 'PGP PCIe APP DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'PGP PCIe APP DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[0]}] -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[1]}] -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[2]}] -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {userClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ddrClkP[3]}] -group [get_clocks -include_generated_clocks {pciRefClkP}] -group [get_clocks -include_generated_clocks {userClkP}]
