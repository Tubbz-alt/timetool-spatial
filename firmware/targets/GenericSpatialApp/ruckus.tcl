# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load base sub-modules
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/axi-pcie-core/hardware/XilinxKcu1500/ddr
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/axi-pcie-core/hardware/XilinxKcu1500
loadRuckusTcl $::env(PROJ_DIR)/../../common

add_files -norecurse $::env(PROJ_DIR)/hdl/SpatialIP.v
add_files -norecurse $::env(PROJ_DIR)/hdl/RetimeShiftRegister.sv
add_files -norecurse $::env(PROJ_DIR)/hdl/AXI4LiteToRFBridgeVerilog.v


# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/hdl"

# Load Simulation
loadSource -sim_only -dir "$::DIR_PATH/tb"
set_property top {SpatialAppTb} [get_filesets sim_1]

# Updating impl_1 strategy
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# Top-level HDL doesn't match target dirname
set_property top {SpatialApp} [get_filesets sources_1]
