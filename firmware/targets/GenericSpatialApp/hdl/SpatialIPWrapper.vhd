-------------------------------------------------------------------------------
-- File       : SpatialIPWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'PGP PCIe APP DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'PGP PCIe APP DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


use work.SsiPkg.all;
use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.MigPkg.all;
use work.AxiStreamPkg.all;

entity SpatialIPWrapper is
   generic (
      TPD_G            : time    := 1 ns;
      SIMULATION_G     : boolean := false;
      SIM_SELF_CHECK_G : boolean := true;
      SIM_SPEEDUP_G    : boolean := true;
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- BAR0 AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- DDR Interface
      ddrClk          : in  slv(0 downto 0);
      ddrRst          : in  slv(0 downto 0);
      ddrReady        : in  slv(0 downto 0);
      ddrWriteMasters : out AxiWriteMasterArray(0 downto 0);
      ddrWriteSlaves  : in  AxiWriteSlaveArray(0 downto 0);
      ddrReadMasters  : out AxiReadMasterArray(0 downto 0);
      ddrReadSlaves   : in  AxiReadSlaveArray(0 downto 0);
      axiStreamInMaster : in AxiStreamMasterType;
      axiStreamInSlave :  out AxiStreamSlaveType;
      axiStreamOutMaster : out AxiStreamMasterType;
      axiStreamOutSlave  : in AxiStreamSlaveType);

attribute dont_touch : string;
attribute dont_touch of SpatialIPWrapper : entity is "true";

end SpatialIPWrapper;

architecture top_level of SpatialIPWrapper is



    -- Declare SpatialIP interface to be backed by verilog --
    component SpatialIP
      port (
        clock           : in std_logic;
        reset           : in std_logic;
        -- AXI Lite --
        io_S_AXI_AWADDR           : in std_logic_vector(31 downto 0);
        io_S_AXI_AWPROT           : in std_logic_vector(2 downto 0);
        io_S_AXI_AWVALID          : in std_logic;
        io_S_AXI_AWREADY          : out std_logic;
        io_S_AXI_ARADDR           : in std_logic_vector(31 downto 0);
        io_S_AXI_ARPROT           : in std_logic_vector(2 downto 0);
        io_S_AXI_ARVALID          : in std_logic;
        io_S_AXI_ARREADY          : out std_logic;
        io_S_AXI_WDATA            : in std_logic_vector(31 downto 0);
        io_S_AXI_WSTRB            : in std_logic_vector(3 downto 0);
        io_S_AXI_WVALID           : in std_logic;
        io_S_AXI_WREADY           : out std_logic;
        io_S_AXI_RDATA            : out std_logic_vector(31 downto 0);
        io_S_AXI_RRESP            : out std_logic_vector(1 downto 0);
        io_S_AXI_RVALID           : out std_logic;
        io_S_AXI_RREADY           : in std_logic;
        io_S_AXI_BRESP            : out std_logic_vector(1 downto 0);
        io_S_AXI_BVALID           : out std_logic;
        io_S_AXI_BREADY           : in std_logic;
        -- DRAM --
        io_M_AXI_0_AWID           : out std_logic_vector(3 downto 0) := (others => '-');
        io_M_AXI_0_AWUSER         : out std_logic_vector(3 downto 0) := (others => '-');
        io_M_AXI_0_AWADDR         : out std_logic_vector(31 downto 0);
        io_M_AXI_0_AWLEN          : out std_logic_vector(7 downto 0);
        io_M_AXI_0_AWSIZE         : out std_logic_vector(2 downto 0);
        io_M_AXI_0_AWBURST        : out std_logic_vector(1 downto 0);
        io_M_AXI_0_AWLOCK         : out std_logic;
        io_M_AXI_0_AWCACHE        : out std_logic_vector(3 downto 0);
        io_M_AXI_0_AWPROT         : out std_logic_vector(2 downto 0);
        io_M_AXI_0_AWQOS          : out std_logic_vector(3 downto 0);
        io_M_AXI_0_AWVALID        : out std_logic;
        io_M_AXI_0_AWREADY        : in std_logic;
        io_M_AXI_0_ARID           : out std_logic_vector(3 downto 0) := (others => '-');
        io_M_AXI_0_ARUSER         : out std_logic_vector(3 downto 0) := (others => '-');
        io_M_AXI_0_ARADDR         : out std_logic_vector(31 downto 0);
        io_M_AXI_0_ARLEN          : out std_logic_vector(7 downto 0);
        io_M_AXI_0_ARSIZE         : out std_logic_vector(2 downto 0);
        io_M_AXI_0_ARBURST        : out std_logic_vector(1 downto 0);
        io_M_AXI_0_ARLOCK         : out std_logic;
        io_M_AXI_0_ARCACHE        : out std_logic_vector(3 downto 0);
        io_M_AXI_0_ARPROT         : out std_logic_vector(2 downto 0);
        io_M_AXI_0_ARQOS          : out std_logic_vector(3 downto 0);
        io_M_AXI_0_ARVALID        : out std_logic;
        io_M_AXI_0_ARREADY        : in std_logic;
        io_M_AXI_0_WDATA          : out std_logic_vector(511 downto 0);
        io_M_AXI_0_WSTRB          : out std_logic_vector(63 downto 0);
        io_M_AXI_0_WLAST          : out std_logic;
        io_M_AXI_0_WVALID         : out std_logic;
        io_M_AXI_0_WREADY         : in std_logic;
        io_M_AXI_0_RID            : in std_logic_vector(3 downto 0) := (others => '-');
        io_M_AXI_0_RUSER          : in std_logic_vector(31 downto 0) := (others => '-');
        io_M_AXI_0_RDATA          : in std_logic_vector(511 downto 0);
        io_M_AXI_0_RRESP          : in std_logic_vector(1 downto 0);
        io_M_AXI_0_RLAST          : in std_logic;
        io_M_AXI_0_RVALID         : in std_logic;
        io_M_AXI_0_RREADY         : out std_logic;
        io_M_AXI_0_BID            : in std_logic_vector(3 downto 0) := (others => '-');
        io_M_AXI_0_BUSER          : in std_logic_vector(3 downto 0) := (others => '-');
        io_M_AXI_0_BRESP          : in std_logic_vector(1 downto 0);
        io_M_AXI_0_BVALID         : in std_logic;
        io_M_AXI_0_BREADY         : out std_logic;
	-- AXI Stream --
 	io_AXIS_IN_TVALID				: in std_logic;
 	io_AXIS_IN_TREADY				: out std_logic;
 	io_AXIS_IN_TDATA					: in std_logic_vector(511 downto 0);
 	io_AXIS_IN_TSTRB					: in std_logic_vector(63 downto 0);
 	io_AXIS_IN_TKEEP					: in std_logic_vector(63 downto 0);
 	io_AXIS_IN_TLAST					: in std_logic;
 	io_AXIS_IN_TID					: in std_logic_vector(7 downto 0);
 	io_AXIS_IN_TDEST					: in std_logic_vector(7 downto 0);
 	io_AXIS_IN_TUSER					: in std_logic_vector(511 downto 0);
 	io_AXIS_OUT_TVALID				: out std_logic;
 	io_AXIS_OUT_TREADY				: in std_logic;
 	io_AXIS_OUT_TDATA				: out std_logic_vector(511 downto 0);
 	io_AXIS_OUT_TSTRB				: out std_logic_vector(63 downto 0);
 	io_AXIS_OUT_TKEEP				: out std_logic_vector(63 downto 0);
 	io_AXIS_OUT_TLAST				: out std_logic;
 	io_AXIS_OUT_TID					: out std_logic_vector(7 downto 0);
 	io_AXIS_OUT_TUSER				: out std_logic_vector(511 downto 0); 
 	io_AXIS_OUT_TDEST				: out std_logic_vector(7 downto 0)
	);
   end component;

   component XilinxKcu1500MigClkConvt
      port (
         s_axi_aclk     : in  std_logic;
         s_axi_aresetn  : in  std_logic;
         s_axi_awid     : in  std_logic_vector(3 downto 0);
         s_axi_awaddr   : in  std_logic_vector(31 downto 0);
         s_axi_awlen    : in  std_logic_vector(7 downto 0);
         s_axi_awsize   : in  std_logic_vector(2 downto 0);
         s_axi_awburst  : in  std_logic_vector(1 downto 0);
         s_axi_awlock   : in  std_logic_vector(0 downto 0);
         s_axi_awcache  : in  std_logic_vector(3 downto 0);
         s_axi_awprot   : in  std_logic_vector(2 downto 0);
         s_axi_awregion : in  std_logic_vector(3 downto 0);
         s_axi_awqos    : in  std_logic_vector(3 downto 0);
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_wdata    : in  std_logic_vector(511 downto 0);
         s_axi_wstrb    : in  std_logic_vector(63 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bid      : out std_logic_vector(3 downto 0);
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_arid     : in  std_logic_vector(3 downto 0);
         s_axi_araddr   : in  std_logic_vector(31 downto 0);
         s_axi_arlen    : in  std_logic_vector(7 downto 0);
         s_axi_arsize   : in  std_logic_vector(2 downto 0);
         s_axi_arburst  : in  std_logic_vector(1 downto 0);
         s_axi_arlock   : in  std_logic_vector(0 downto 0);
         s_axi_arcache  : in  std_logic_vector(3 downto 0);
         s_axi_arprot   : in  std_logic_vector(2 downto 0);
         s_axi_arregion : in  std_logic_vector(3 downto 0);
         s_axi_arqos    : in  std_logic_vector(3 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_rid      : out std_logic_vector(3 downto 0);
         s_axi_rdata    : out std_logic_vector(511 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_aclk     : in  std_logic;
         m_axi_aresetn  : in  std_logic;
         m_axi_awid     : out std_logic_vector(3 downto 0);
         m_axi_awaddr   : out std_logic_vector(31 downto 0);
         m_axi_awlen    : out std_logic_vector(7 downto 0);
         m_axi_awsize   : out std_logic_vector(2 downto 0);
         m_axi_awburst  : out std_logic_vector(1 downto 0);
         m_axi_awlock   : out std_logic_vector(0 downto 0);
         m_axi_awcache  : out std_logic_vector(3 downto 0);
         m_axi_awprot   : out std_logic_vector(2 downto 0);
         m_axi_awregion : out std_logic_vector(3 downto 0);
         m_axi_awqos    : out std_logic_vector(3 downto 0);
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_wdata    : out std_logic_vector(511 downto 0);
         m_axi_wstrb    : out std_logic_vector(63 downto 0);
         m_axi_wlast    : out std_logic;
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bid      : in  std_logic_vector(3 downto 0);
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_arid     : out std_logic_vector(3 downto 0);
         m_axi_araddr   : out std_logic_vector(31 downto 0);
         m_axi_arlen    : out std_logic_vector(7 downto 0);
         m_axi_arsize   : out std_logic_vector(2 downto 0);
         m_axi_arburst  : out std_logic_vector(1 downto 0);
         m_axi_arlock   : out std_logic_vector(0 downto 0);
         m_axi_arcache  : out std_logic_vector(3 downto 0);
         m_axi_arprot   : out std_logic_vector(2 downto 0);
         m_axi_arregion : out std_logic_vector(3 downto 0);
         m_axi_arqos    : out std_logic_vector(3 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_rid      : in  std_logic_vector(3 downto 0);
         m_axi_rdata    : in  std_logic_vector(511 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rlast    : in  std_logic;
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic
         );
   end component;

   constant START_ADDR_C : slv(MEM_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0) := (others => '0');
   constant STOP_ADDR_C  : slv(MEM_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0) := (others => '1');

   constant NUM_AXIL_MASTERS_C : natural := 4;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 19, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal axiWriteMasters : AxiWriteMasterArray(0 downto 0) := (others => AXI_WRITE_MASTER_FORCE_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(0 downto 0)  := (others => AXI_WRITE_SLAVE_FORCE_C);
   signal axiReadMasters  : AxiReadMasterArray(0 downto 0)  := (others => AXI_READ_MASTER_FORCE_C);
   signal axiReadSlaves   : AxiReadSlaveArray(0 downto 0)   := (others => AXI_READ_SLAVE_FORCE_C);

   signal axiStreamInCnvtMaster : AxiStreamMasterType;
   signal axiStreamInCnvtSlave  :  AxiStreamSlaveType;
   signal axiStreamOutCnvtMaster  : AxiStreamMasterType;
   signal axiStreamOutCnvtSlave   :  AxiStreamSlaveType;

   signal memReady : slv(NUM_AXIL_MASTERS_C-1 downto 0);
   signal memError : slv(NUM_AXIL_MASTERS_C-1 downto 0);

   signal failed : sl := '0';
   signal passed : sl := '0';

   signal axilRstL : sl;
   signal ddrRstL  : slv(0 downto 0);

begin

   axilRstL <= not(axilRst);
   ddrRstL  <= not(ddrRst);

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   --  Stitch SpatialIP into wrapper --
   U_SpatialIP :  SpatialIP
      port map (
         -- AXI-Lite Interface
         clock         => axilClk,
         reset         => axilRst,
         
         io_S_AXI_AWADDR     =>  axilWriteMasters(0).awaddr(31 downto 0), 
         io_S_AXI_AWPROT     =>  axilWriteMasters(0).awprot(2 downto 0), 
         io_S_AXI_AWVALID    =>  axilWriteMasters(0).awvalid, 
         io_S_AXI_AWREADY    =>   axilWriteSlaves(0).awready,
         io_S_AXI_ARADDR     =>   axilReadMasters(0).araddr(31 downto 0), 
         io_S_AXI_ARPROT     =>   axilReadMasters(0).arprot(2 downto 0), 
         io_S_AXI_ARVALID    =>   axilReadMasters(0).arvalid, 
         io_S_AXI_ARREADY    =>    axilReadSlaves(0).arready, 
         io_S_AXI_WDATA      =>  axilWriteMasters(0).wdata(31 downto 0), 
         io_S_AXI_WSTRB      =>  axilWriteMasters(0).wstrb(3 downto 0), 
         io_S_AXI_WVALID     =>  axilWriteMasters(0).wvalid, 
         io_S_AXI_WREADY     =>   axilWriteSlaves(0).wready, 
         io_S_AXI_RDATA      =>    axilReadSlaves(0).rdata(31 downto 0), 
         io_S_AXI_RRESP      =>    axilReadSlaves(0).rresp, 
         io_S_AXI_RVALID     =>    axilReadSlaves(0).rvalid, 
         io_S_AXI_RREADY     =>   axilReadMasters(0).rready, 
         io_S_AXI_BRESP      =>   axilWriteSlaves(0).bresp, 
         io_S_AXI_BVALID     =>   axilWriteSlaves(0).bvalid, 
         io_S_AXI_BREADY     =>  axilWriteMasters(0).bready,      

         -- What is this signal doing? --
         --start           => ddrReady(i),

         -- TODO: USER == REGION?
         io_M_AXI_0_AWUSER => axiWriteMasters(0).awregion(3 downto 0),
         io_M_AXI_0_ARUSER =>  axiReadMasters(0).arregion(3 downto 0),
         io_M_AXI_0_BUSER => open,
         io_M_AXI_0_RUSER => open,

         io_M_AXI_0_AWID =>    axiWriteMasters(0).awid(3 downto 0),
         io_M_AXI_0_ARID =>     axiReadMasters(0).arid(3 downto 0),
         io_M_AXI_0_BID =>      axiWriteSlaves(0).bid(3 downto 0),
         io_M_AXI_0_RID =>       axiReadSlaves(0).rid(3 downto 0),
         io_M_AXI_0_AWADDR  => axiWriteMasters(0).awaddr(31 downto 0),
         io_M_AXI_0_AWLEN =>   axiWriteMasters(0).awlen(7 downto 0), 
         io_M_AXI_0_AWSIZE =>  axiWriteMasters(0).awsize(2 downto 0),
         io_M_AXI_0_AWBURST => axiWriteMasters(0).awburst(1 downto 0),
         io_M_AXI_0_AWLOCK =>  axiWriteMasters(0).awlock(0),
         io_M_AXI_0_AWCACHE => axiWriteMasters(0).awcache(3 downto 0),
         io_M_AXI_0_AWPROT =>  axiWriteMasters(0).awprot(2 downto 0),
         io_M_AXI_0_AWQOS =>   axiWriteMasters(0).awqos(3 downto 0),
         io_M_AXI_0_AWVALID => axiWriteMasters(0).awvalid,
         io_M_AXI_0_AWREADY =>  axiWriteSlaves(0).awready,
         io_M_AXI_0_ARADDR =>   axiReadMasters(0).araddr(31 downto 0), 
         io_M_AXI_0_ARLEN =>    axiReadMasters(0).arlen(7 downto 0), 
         io_M_AXI_0_ARSIZE =>   axiReadMasters(0).arsize(2 downto 0),
         io_M_AXI_0_ARBURST =>  axiReadMasters(0).arburst(1 downto 0), 
         io_M_AXI_0_ARLOCK =>   axiReadMasters(0).arlock(0),
         io_M_AXI_0_ARCACHE =>  axiReadMasters(0).arcache(3 downto 0), 
         io_M_AXI_0_ARPROT =>   axiReadMasters(0).arprot(2 downto 0),
         io_M_AXI_0_ARQOS =>    axiReadMasters(0).arqos(3 downto 0),
         io_M_AXI_0_ARVALID =>  axiReadMasters(0).arvalid,
         io_M_AXI_0_ARREADY =>   axiReadSlaves(0).arready,
         io_M_AXI_0_WDATA =>   axiWriteMasters(0).wdata(511 downto 0),
         io_M_AXI_0_WSTRB =>   axiWriteMasters(0).wstrb(63 downto 0),
         io_M_AXI_0_WLAST =>   axiWriteMasters(0).wlast,
         io_M_AXI_0_WVALID =>  axiWriteMasters(0).wvalid,
         io_M_AXI_0_WREADY =>   axiWriteSlaves(0).wready, 
         io_M_AXI_0_RDATA =>     axiReadSlaves(0).rdata(511 downto 0),
         io_M_AXI_0_RRESP =>     axiReadSlaves(0).rresp(1 downto 0),
         io_M_AXI_0_RLAST =>     axiReadSlaves(0).rlast,
         io_M_AXI_0_RVALID =>    axiReadSlaves(0).rvalid,
         io_M_AXI_0_RREADY =>   axiReadMasters(0).rready,
         io_M_AXI_0_BRESP =>    axiWriteSlaves(0).bresp(1 downto 0),
         io_M_AXI_0_BVALID =>   axiWriteSlaves(0).bvalid,
         io_M_AXI_0_BREADY =>  axiWriteMasters(0).bready,
         io_AXIS_IN_TVALID =>    axiStreamInCnvtMaster.tValid, 
         io_AXIS_IN_TREADY =>    axiStreamInCnvtSlave.tReady,
         io_AXIS_IN_TDATA  =>    axiStreamInCnvtMaster.tData,                            
         io_AXIS_IN_TSTRB  =>    axiStreamInCnvtMaster.tStrb,
         io_AXIS_IN_TKEEP  =>    axiStreamInCnvtMaster.tKeep,                           
         io_AXIS_IN_TLAST  =>    axiStreamInCnvtMaster.tLast,                            
         io_AXIS_IN_TID    =>    axiStreamInCnvtMaster.tId, 
         io_AXIS_IN_TDEST  =>    axiStreamInCnvtMaster.tDest, 
         io_AXIS_IN_TUSER  =>    axiStreamInCnvtMaster.tUser, 
         io_AXIS_OUT_TVALID =>   axiStreamOutCnvtMaster.tValid,                                                 
         io_AXIS_OUT_TREADY =>   axiStreamOutCnvtSlave.tReady,                                                  
         io_AXIS_OUT_TDATA  =>   axiStreamOutCnvtMaster.tData,                                                  
         io_AXIS_OUT_TSTRB  =>   axiStreamOutCnvtMaster.tStrb,                                                  
         io_AXIS_OUT_TKEEP  =>   axiStreamOutCnvtMaster.tKeep,                                                  
         io_AXIS_OUT_TLAST  =>   axiStreamOutCnvtMaster.tLast,                                                  
         io_AXIS_OUT_TID    =>   axiStreamOutCnvtMaster.tId,                                                    
         io_AXIS_OUT_TDEST  =>   axiStreamOutCnvtMaster.tDest,                                                  
         io_AXIS_OUT_TUSER  =>   axiStreamOutCnvtMaster.tUser
);

   ------------------------
   -- MIG
   ------------------------

      U_Clk_Convt : XilinxKcu1500MigClkConvt
         port map (
            -- Slave Ports
            s_axi_aclk     => axilClk,
            s_axi_aresetn  => axilRstL,
            s_axi_awid     => axiWriteMasters(0).awid(3 downto 0),
            s_axi_awaddr   => axiWriteMasters(0).awaddr(31 downto 0),
            s_axi_awlen    => axiWriteMasters(0).awlen(7 downto 0),
            s_axi_awsize   => axiWriteMasters(0).awsize(2 downto 0),
            s_axi_awburst  => axiWriteMasters(0).awburst(1 downto 0),
            s_axi_awlock   => axiWriteMasters(0).awlock(0 downto 0),
            s_axi_awcache  => axiWriteMasters(0).awcache(3 downto 0),
            s_axi_awprot   => axiWriteMasters(0).awprot(2 downto 0),
            s_axi_awregion => axiWriteMasters(0).awregion(3 downto 0),
            s_axi_awqos    => axiWriteMasters(0).awqos(3 downto 0),
            s_axi_awvalid  => axiWriteMasters(0).awvalid,
            s_axi_awready  => axiWriteSlaves(0).awready,
            s_axi_wdata    => axiWriteMasters(0).wdata(511 downto 0),
            s_axi_wstrb    => axiWriteMasters(0).wstrb(63 downto 0),
            s_axi_wlast    => axiWriteMasters(0).wlast,
            s_axi_wvalid   => axiWriteMasters(0).wvalid,
            s_axi_wready   => axiWriteSlaves(0).wready,
            s_axi_bid      => axiWriteSlaves(0).bid(3 downto 0),
            s_axi_bresp    => axiWriteSlaves(0).bresp(1 downto 0),
            s_axi_bvalid   => axiWriteSlaves(0).bvalid,
            s_axi_bready   => axiWriteMasters(0).bready,
            s_axi_arid     => axiReadMasters(0).arid(3 downto 0),
            s_axi_araddr   => axiReadMasters(0).araddr(31 downto 0),
            s_axi_arlen    => axiReadMasters(0).arlen(7 downto 0),
            s_axi_arsize   => axiReadMasters(0).arsize(2 downto 0),
            s_axi_arburst  => axiReadMasters(0).arburst(1 downto 0),
            s_axi_arlock   => axiReadMasters(0).arlock(0 downto 0),
            s_axi_arcache  => axiReadMasters(0).arcache(3 downto 0),
            s_axi_arprot   => axiReadMasters(0).arprot(2 downto 0),
            s_axi_arregion => axiReadMasters(0).arregion(3 downto 0),
            s_axi_arqos    => axiReadMasters(0).arqos(3 downto 0),
            s_axi_arvalid  => axiReadMasters(0).arvalid,
            s_axi_arready  => axiReadSlaves(0).arready,
            s_axi_rid      => axiReadSlaves(0).rid(3 downto 0),
            s_axi_rdata    => axiReadSlaves(0).rdata(511 downto 0),
            s_axi_rresp    => axiReadSlaves(0).rresp(1 downto 0),
            s_axi_rlast    => axiReadSlaves(0).rlast,
            s_axi_rvalid   => axiReadSlaves(0).rvalid,
            s_axi_rready   => axiReadMasters(0).rready,
            -- Master Ports
            m_axi_aclk     => ddrClk(0),
            m_axi_aresetn  => ddrRstL(0),
            m_axi_awid     => ddrWriteMasters(0).awid(3 downto 0),
            m_axi_awaddr   => ddrWriteMasters(0).awaddr(31 downto 0),
            m_axi_awlen    => ddrWriteMasters(0).awlen(7 downto 0),
            m_axi_awsize   => ddrWriteMasters(0).awsize(2 downto 0),
            m_axi_awburst  => ddrWriteMasters(0).awburst(1 downto 0),
            m_axi_awlock   => ddrWriteMasters(0).awlock(0 downto 0),
            m_axi_awcache  => ddrWriteMasters(0).awcache(3 downto 0),
            m_axi_awprot   => ddrWriteMasters(0).awprot(2 downto 0),
            m_axi_awregion => ddrWriteMasters(0).awregion(3 downto 0),
            m_axi_awqos    => ddrWriteMasters(0).awqos(3 downto 0),
            m_axi_awvalid  => ddrWriteMasters(0).awvalid,
            m_axi_awready  => ddrWriteSlaves(0).awready,
            m_axi_wdata    => ddrWriteMasters(0).wdata(511 downto 0),
            m_axi_wstrb    => ddrWriteMasters(0).wstrb(63 downto 0),
            m_axi_wlast    => ddrWriteMasters(0).wlast,
            m_axi_wvalid   => ddrWriteMasters(0).wvalid,
            m_axi_wready   => ddrWriteSlaves(0).wready,
            m_axi_bid      => ddrWriteSlaves(0).bid(3 downto 0),
            m_axi_bresp    => ddrWriteSlaves(0).bresp(1 downto 0),
            m_axi_bvalid   => ddrWriteSlaves(0).bvalid,
            m_axi_bready   => ddrWriteMasters(0).bready,
            m_axi_arid     => ddrReadMasters(0).arid(3 downto 0),
            m_axi_araddr   => ddrReadMasters(0).araddr(31 downto 0),
            m_axi_arlen    => ddrReadMasters(0).arlen(7 downto 0),
            m_axi_arsize   => ddrReadMasters(0).arsize(2 downto 0),
            m_axi_arburst  => ddrReadMasters(0).arburst(1 downto 0),
            m_axi_arlock   => ddrReadMasters(0).arlock(0 downto 0),
            m_axi_arcache  => ddrReadMasters(0).arcache(3 downto 0),
            m_axi_arprot   => ddrReadMasters(0).arprot(2 downto 0),
            m_axi_arregion => ddrReadMasters(0).arregion(3 downto 0),
            m_axi_arqos    => ddrReadMasters(0).arqos(3 downto 0),
            m_axi_arvalid  => ddrReadMasters(0).arvalid,
            m_axi_arready  => ddrReadSlaves(0).arready,
            m_axi_rid      => ddrReadSlaves(0).rid(3 downto 0),
            m_axi_rdata    => ddrReadSlaves(0).rdata(511 downto 0),
            m_axi_rresp    => ddrReadSlaves(0).rresp(1 downto 0),
            m_axi_rlast    => ddrReadSlaves(0).rlast,
            m_axi_rvalid   => ddrReadSlaves(0).rvalid,
            m_axi_rready   => ddrReadMasters(0).rready);


            U_AXIS_FIFO_OUT : entity work.AxiStreamFifoV2
               generic map (
                  -- General Configurations
                  TPD_G               => TPD_G,
                  -- FIFO configurations
                  BRAM_EN_G           => true,  -- Implement with BRAM
                  GEN_SYNC_FIFO_G     => false, -- false = ASYNC FIFO
                  FIFO_ADDR_WIDTH_G   => 9,     -- 2**9 = 512 deep 
                  -- AXI Stream Port Configurations
                  SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(64), -- SLAVE.TDATA 64-bytes width
                  MASTER_AXI_CONFIG_G => ssiAxiStreamConfig(64)) -- MASTER.TDATA 64-bytes width
               port map (
                  -- External Side
                  mAxisClk    => ddrClk(0),
                  mAxisRst    => ddrRst(0),
                  mAxisMaster => axiStreamOutMaster, 
                  mAxisSlave  => axiStreamOutSlave,
                  -- SpatialIP Side
                  sAxisClk    => axilClk,
                  sAxisRst    => axilRst,
                  sAxisMaster => axiStreamOutCnvtMaster,
                  sAxisSlave  => axiStreamOutCnvtSlave);
            
            U_AXIS_FIFO_IN : entity work.AxiStreamFifoV2
               generic map (
                  -- General Configurations
                  TPD_G               => TPD_G,
                  -- FIFO configurations
                  BRAM_EN_G           => true,  -- Implement with BRAM
                  GEN_SYNC_FIFO_G     => false, -- false = ASYNC FIFO
                  FIFO_ADDR_WIDTH_G   => 9,     -- 2**9 = 512 deep 
                  -- AXI Stream Port Configurations
                  SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(64), -- SLAVE.TDATA 64-bytes width
                  MASTER_AXI_CONFIG_G => ssiAxiStreamConfig(64)) -- MASTER.TDATA 64-bytes width
               port map (
                  -- External Side
                  sAxisClk    => ddrClk(0),
                  sAxisRst    => ddrRst(0),
                  sAxisMaster => axiStreamInMaster,
                  sAxisSlave  => axiStreamInSlave,
                  -- App Side
                  mAxisClk    =>axilClk,
                  mAxisRst    =>axilRst,
                  mAxisMaster => axiStreamInCnvtMaster,
                  mAxisSlave  => axiStreamInCnvtSlave);

end top_level;

