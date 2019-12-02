-------------------------------------------------------------------------------
-- File       : SpatialIPWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for SpatialIP
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
      TPD_G             : time    := 1 ns;
      SIMULATION_G      : boolean := false;  -- Currently Unused
      SIM_SELF_CHECK_G  : boolean := true;   -- Currently Unused
      SIM_SPEEDUP_G     : boolean := true;   -- Currently Unused
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      AXIL_BASE_ADDR_G  : slv(31 downto 0));
   port (
      -- BAR0 AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- DMA AXI Stream Interface (dmaClk domain)
      dmaClk          : in  sl;
      dmaRst          : in  sl;
      dmaObMaster     : in  AxiStreamMasterType;
      dmaObSlave      : out AxiStreamSlaveType;
      dmaIbMaster     : out AxiStreamMasterType;
      dmaIbSlave      : in  AxiStreamSlaveType;
      -- DDR AXI Memory Interface (ddrClk domain)
      ddrClk          : in  sl;
      ddrRst          : in  sl;
      ddrReady        : in  sl;
      ddrWriteMaster  : out AxiWriteMasterType;
      ddrWriteSlave   : in  AxiWriteSlaveType;
      ddrReadMaster   : out AxiReadMasterType;
      ddrReadSlave    : in  AxiReadSlaveType);
end SpatialIPWrapper;

architecture mapping of SpatialIPWrapper is

   constant APP_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => (64/8),         -- 64-bit TDATA bus
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 8,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 8,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);


   -- Declare SpatialIP interface to be backed by Verilog --
   component SpatialIP
      port (
         clock              : in  std_logic;
         reset              : in  std_logic;
         -- AXI Lite --
         io_S_AXI_AWADDR    : in  std_logic_vector(31 downto 0);
         io_S_AXI_AWPROT    : in  std_logic_vector(2 downto 0);
         io_S_AXI_AWVALID   : in  std_logic;
         io_S_AXI_AWREADY   : out std_logic;
         io_S_AXI_ARADDR    : in  std_logic_vector(31 downto 0);
         io_S_AXI_ARPROT    : in  std_logic_vector(2 downto 0);
         io_S_AXI_ARVALID   : in  std_logic;
         io_S_AXI_ARREADY   : out std_logic;
         io_S_AXI_WDATA     : in  std_logic_vector(31 downto 0);
         io_S_AXI_WSTRB     : in  std_logic_vector(3 downto 0);
         io_S_AXI_WVALID    : in  std_logic;
         io_S_AXI_WREADY    : out std_logic;
         io_S_AXI_RDATA     : out std_logic_vector(31 downto 0);
         io_S_AXI_RRESP     : out std_logic_vector(1 downto 0);
         io_S_AXI_RVALID    : out std_logic;
         io_S_AXI_RREADY    : in  std_logic;
         io_S_AXI_BRESP     : out std_logic_vector(1 downto 0);
         io_S_AXI_BVALID    : out std_logic;
         io_S_AXI_BREADY    : in  std_logic;
         -- DRAM --
         io_M_AXI_0_AWID    : out std_logic_vector(3 downto 0)  := (others => '-');
         io_M_AXI_0_AWUSER  : out std_logic_vector(3 downto 0)  := (others => '-');
         io_M_AXI_0_AWADDR  : out std_logic_vector(31 downto 0);
         io_M_AXI_0_AWLEN   : out std_logic_vector(7 downto 0);
         io_M_AXI_0_AWSIZE  : out std_logic_vector(2 downto 0);
         io_M_AXI_0_AWBURST : out std_logic_vector(1 downto 0);
         io_M_AXI_0_AWLOCK  : out std_logic;
         io_M_AXI_0_AWCACHE : out std_logic_vector(3 downto 0);
         io_M_AXI_0_AWPROT  : out std_logic_vector(2 downto 0);
         io_M_AXI_0_AWQOS   : out std_logic_vector(3 downto 0);
         io_M_AXI_0_AWVALID : out std_logic;
         io_M_AXI_0_AWREADY : in  std_logic;
         io_M_AXI_0_ARID    : out std_logic_vector(3 downto 0)  := (others => '-');
         io_M_AXI_0_ARUSER  : out std_logic_vector(3 downto 0)  := (others => '-');
         io_M_AXI_0_ARADDR  : out std_logic_vector(31 downto 0);
         io_M_AXI_0_ARLEN   : out std_logic_vector(7 downto 0);
         io_M_AXI_0_ARSIZE  : out std_logic_vector(2 downto 0);
         io_M_AXI_0_ARBURST : out std_logic_vector(1 downto 0);
         io_M_AXI_0_ARLOCK  : out std_logic;
         io_M_AXI_0_ARCACHE : out std_logic_vector(3 downto 0);
         io_M_AXI_0_ARPROT  : out std_logic_vector(2 downto 0);
         io_M_AXI_0_ARQOS   : out std_logic_vector(3 downto 0);
         io_M_AXI_0_ARVALID : out std_logic;
         io_M_AXI_0_ARREADY : in  std_logic;
         io_M_AXI_0_WDATA   : out std_logic_vector(511 downto 0);
         io_M_AXI_0_WSTRB   : out std_logic_vector(63 downto 0);
         io_M_AXI_0_WLAST   : out std_logic;
         io_M_AXI_0_WVALID  : out std_logic;
         io_M_AXI_0_WREADY  : in  std_logic;
         io_M_AXI_0_RID     : in  std_logic_vector(3 downto 0)  := (others => '-');
         io_M_AXI_0_RUSER   : in  std_logic_vector(31 downto 0) := (others => '-');
         io_M_AXI_0_RDATA   : in  std_logic_vector(511 downto 0);
         io_M_AXI_0_RRESP   : in  std_logic_vector(1 downto 0);
         io_M_AXI_0_RLAST   : in  std_logic;
         io_M_AXI_0_RVALID  : in  std_logic;
         io_M_AXI_0_RREADY  : out std_logic;
         io_M_AXI_0_BID     : in  std_logic_vector(3 downto 0)  := (others => '-');
         io_M_AXI_0_BUSER   : in  std_logic_vector(3 downto 0)  := (others => '-');
         io_M_AXI_0_BRESP   : in  std_logic_vector(1 downto 0);
         io_M_AXI_0_BVALID  : in  std_logic;
         io_M_AXI_0_BREADY  : out std_logic;
         -- AXI Stream --
         io_AXIS_IN_TVALID  : in  std_logic;
         io_AXIS_IN_TREADY  : out std_logic;
         io_AXIS_IN_TDATA   : in  std_logic_vector(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_IN_TSTRB   : in  std_logic_vector(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_IN_TKEEP   : in  std_logic_vector(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_IN_TLAST   : in  std_logic;
         io_AXIS_IN_TID     : in  std_logic_vector(APP_AXIS_CONFIG_C.TID_BITS_C-1 downto 0);
         io_AXIS_IN_TDEST   : in  std_logic_vector(APP_AXIS_CONFIG_C.TDEST_BITS_C-1 downto 0);
         io_AXIS_IN_TUSER   : in  std_logic_vector(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_OUT_TVALID : out std_logic;
         io_AXIS_OUT_TREADY : in  std_logic;
         io_AXIS_OUT_TDATA  : out std_logic_vector(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_OUT_TSTRB  : out std_logic_vector(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_OUT_TKEEP  : out std_logic_vector(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_OUT_TLAST  : out std_logic;
         io_AXIS_OUT_TID    : out std_logic_vector(APP_AXIS_CONFIG_C.TID_BITS_C-1 downto 0);
         io_AXIS_OUT_TUSER  : out std_logic_vector(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0);
         io_AXIS_OUT_TDEST  : out std_logic_vector(APP_AXIS_CONFIG_C.TDEST_BITS_C-1 downto 0)
         );
   end component;

   constant NUM_AXIL_MASTERS_C : natural := 1;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 19, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal axiWriteMasters : AxiWriteMasterArray(0 downto 0) := (others => AXI_WRITE_MASTER_FORCE_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(0 downto 0)  := (others => AXI_WRITE_SLAVE_FORCE_C);
   signal axiReadMasters  : AxiReadMasterArray(0 downto 0)  := (others => AXI_READ_MASTER_FORCE_C);
   signal axiReadSlaves   : AxiReadSlaveArray(0 downto 0)   := (others => AXI_READ_SLAVE_FORCE_C);

   signal appIbMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal appIbSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal appObMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal appObSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal appObMasterSof : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal appObSlaveSof  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

begin

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

   ----------------
   -- DMA->APP FIFO
   ----------------
   U_AXIS_FIFO_IN : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,      -- Help with making timing
         PIPE_STAGES_G       => 1,      -- Help with making timing          
         -- FIFO configurations
         BRAM_EN_G           => true,   -- Implement with BRAM
         GEN_SYNC_FIFO_G     => false,  -- false = ASYNC FIFO
         FIFO_ADDR_WIDTH_G   => 9,      -- 2**9 = 512 deep 
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => APP_AXIS_CONFIG_C)
      port map (
         -- DMA Interface
         sAxisClk    => dmaClk,
         sAxisRst    => dmaRst,
         sAxisMaster => dmaObMaster,
         sAxisSlave  => dmaObSlave,
         -- APP Interface
         mAxisClk    => axilClk,
         mAxisRst    => axilRst,
         mAxisMaster => appIbMaster,
         mAxisSlave  => appIbSlave);

   ------------------------------------
   --  Stitch SpatialIP into wrapper --
   ------------------------------------
   U_SpatialIP : SpatialIP
      port map (
         -- Common Clock/Reset for all AXI4, AXIS and AXI-Lite Interfaces
         clock              => axilClk,
         reset              => axilRst,
         -- AXI-Lite "io_S_AXI" Interface
         io_S_AXI_AWADDR    => axilWriteMasters(0).awaddr,
         io_S_AXI_AWPROT    => axilWriteMasters(0).awprot,
         io_S_AXI_AWVALID   => axilWriteMasters(0).awvalid,
         io_S_AXI_AWREADY   => axilWriteSlaves(0).awready,
         io_S_AXI_ARADDR    => axilReadMasters(0).araddr,
         io_S_AXI_ARPROT    => axilReadMasters(0).arprot,
         io_S_AXI_ARVALID   => axilReadMasters(0).arvalid,
         io_S_AXI_ARREADY   => axilReadSlaves(0).arready,
         io_S_AXI_WDATA     => axilWriteMasters(0).wdata,
         io_S_AXI_WSTRB     => axilWriteMasters(0).wstrb,
         io_S_AXI_WVALID    => axilWriteMasters(0).wvalid,
         io_S_AXI_WREADY    => axilWriteSlaves(0).wready,
         io_S_AXI_RDATA     => axilReadSlaves(0).rdata,
         io_S_AXI_RRESP     => axilReadSlaves(0).rresp,
         io_S_AXI_RVALID    => axilReadSlaves(0).rvalid,
         io_S_AXI_RREADY    => axilReadMasters(0).rready,
         io_S_AXI_BRESP     => axilWriteSlaves(0).bresp,
         io_S_AXI_BVALID    => axilWriteSlaves(0).bvalid,
         io_S_AXI_BREADY    => axilWriteMasters(0).bready,
         -- AXI4 Memory "io_M_AXI" Interface
         io_M_AXI_0_AWUSER  => open,
         io_M_AXI_0_ARUSER  => open,
         io_M_AXI_0_BUSER   => open,
         io_M_AXI_0_RUSER   => open,
         io_M_AXI_0_AWID    => axiWriteMasters(0).awid(MEM_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         io_M_AXI_0_ARID    => axiReadMasters(0).arid(MEM_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         io_M_AXI_0_BID     => axiWriteSlaves(0).bid(MEM_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         io_M_AXI_0_RID     => axiReadSlaves(0).rid(MEM_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         io_M_AXI_0_AWADDR  => axiWriteMasters(0).awaddr(MEM_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         io_M_AXI_0_AWLEN   => axiWriteMasters(0).awlen(MEM_AXI_CONFIG_C.LEN_BITS_C-1 downto 0),
         io_M_AXI_0_AWSIZE  => axiWriteMasters(0).awsize,
         io_M_AXI_0_AWBURST => axiWriteMasters(0).awburst,
         io_M_AXI_0_AWLOCK  => axiWriteMasters(0).awlock(0),
         io_M_AXI_0_AWCACHE => axiWriteMasters(0).awcache,
         io_M_AXI_0_AWPROT  => axiWriteMasters(0).awprot,
         io_M_AXI_0_AWQOS   => axiWriteMasters(0).awqos,
         io_M_AXI_0_AWVALID => axiWriteMasters(0).awvalid,
         io_M_AXI_0_AWREADY => axiWriteSlaves(0).awready,
         io_M_AXI_0_ARADDR  => axiReadMasters(0).araddr(MEM_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         io_M_AXI_0_ARLEN   => axiReadMasters(0).arlen(MEM_AXI_CONFIG_C.LEN_BITS_C-1 downto 0),
         io_M_AXI_0_ARSIZE  => axiReadMasters(0).arsize,
         io_M_AXI_0_ARBURST => axiReadMasters(0).arburst,
         io_M_AXI_0_ARLOCK  => axiReadMasters(0).arlock(0),
         io_M_AXI_0_ARCACHE => axiReadMasters(0).arcache,
         io_M_AXI_0_ARPROT  => axiReadMasters(0).arprot,
         io_M_AXI_0_ARQOS   => axiReadMasters(0).arqos,
         io_M_AXI_0_ARVALID => axiReadMasters(0).arvalid,
         io_M_AXI_0_ARREADY => axiReadSlaves(0).arready,
         io_M_AXI_0_WDATA   => axiWriteMasters(0).wdata(8*MEM_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0),
         io_M_AXI_0_WSTRB   => axiWriteMasters(0).wstrb(MEM_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0),
         io_M_AXI_0_WLAST   => axiWriteMasters(0).wlast,
         io_M_AXI_0_WVALID  => axiWriteMasters(0).wvalid,
         io_M_AXI_0_WREADY  => axiWriteSlaves(0).wready,
         io_M_AXI_0_RDATA   => axiReadSlaves(0).rdata(8*MEM_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0),
         io_M_AXI_0_RRESP   => axiReadSlaves(0).rresp,
         io_M_AXI_0_RLAST   => axiReadSlaves(0).rlast,
         io_M_AXI_0_RVALID  => axiReadSlaves(0).rvalid,
         io_M_AXI_0_RREADY  => axiReadMasters(0).rready,
         io_M_AXI_0_BRESP   => axiWriteSlaves(0).bresp,
         io_M_AXI_0_BVALID  => axiWriteSlaves(0).bvalid,
         io_M_AXI_0_BREADY  => axiWriteMasters(0).bready,
         -- AXI Stream "io_AXIS" Interface
         io_AXIS_IN_TVALID  => appIbMaster.tValid,
         io_AXIS_IN_TREADY  => appIbSlave.tReady,
         io_AXIS_IN_TDATA   => appIbMaster.tData(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0),
         io_AXIS_IN_TSTRB   => appIbMaster.tStrb(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0),
         io_AXIS_IN_TKEEP   => appIbMaster.tKeep(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0),
         io_AXIS_IN_TLAST   => appIbMaster.tLast,
         io_AXIS_IN_TID     => appIbMaster.tId(APP_AXIS_CONFIG_C.TID_BITS_C-1 downto 0),
         io_AXIS_IN_TDEST   => appIbMaster.tDest(APP_AXIS_CONFIG_C.TDEST_BITS_C-1 downto 0),
         io_AXIS_IN_TUSER   => appIbMaster.tUser(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0),
         io_AXIS_OUT_TVALID => appObMaster.tValid,
         io_AXIS_OUT_TREADY => appObSlave.tReady,
         io_AXIS_OUT_TDATA  => appObMaster.tData(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0),
         io_AXIS_OUT_TSTRB  => appObMaster.tStrb(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0),
         io_AXIS_OUT_TKEEP  => appObMaster.tKeep(APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0),
         io_AXIS_OUT_TLAST  => appObMaster.tLast,
         io_AXIS_OUT_TID    => appObMaster.tId(APP_AXIS_CONFIG_C.TID_BITS_C-1 downto 0),
         io_AXIS_OUT_TDEST  => appObMaster.tDest(APP_AXIS_CONFIG_C.TDEST_BITS_C-1 downto 0),
         io_AXIS_OUT_TUSER  => appObMaster.tUser(8*APP_AXIS_CONFIG_C.TDATA_BYTES_C-1 downto 0));

   -----------------------------------
   -- APP<->DDR Clock Domain Converter
   -----------------------------------
   U_MigClkConvt : entity work.MigClkConvtWrapper
      generic map (
         TPD_G => TPD_G)
      port map (
         -- USER AXI Memory Interface (axiClk domain)
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiWriteMaster => axiWriteMasters(0),
         axiWriteSlave  => axiWriteSlaves(0),
         axiReadMaster  => axiReadMasters(0),
         axiReadSlave   => axiReadSlaves(0),
         -- DDR AXI Memory Interface (ddrClk domain)
         ddrClk         => ddrClk,
         ddrRst         => ddrRst,
         ddrWriteMaster => ddrWriteMaster,
         ddrWriteSlave  => ddrWriteSlave,
         ddrReadMaster  => ddrReadMaster,
         ddrReadSlave   => ddrReadSlave);

   ------------------------------
   -- Insert SOF into tUser field
   ------------------------------
   U_SSI_SOF_INSERT : entity work.SsiInsertSof
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,      -- Help with making timing
         PIPE_STAGES_G       => 1,      -- Help with making timing      
         -- FIFO configurations         
         COMMON_CLK_G        => true,
         SLAVE_FIFO_G        => true,
         MASTER_FIFO_G       => false,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => APP_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => APP_AXIS_CONFIG_C)
      port map (
         -- APP Interface
         sAxisClk    => axilClk,
         sAxisRst    => axilRst,
         sAxisMaster => appObMaster,
         sAxisSlave  => appObSlave,
         -- DMA Interface
         mAxisClk    => axilClk,
         mAxisRst    => axilRst,
         mAxisMaster => appObMasterSof,
         mAxisSlave  => appObSlaveSof);

   ----------------
   -- DMA->APP FIFO
   ----------------
   U_AXIS_FIFO_OUT : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,         -- Help with making timing
         PIPE_STAGES_G       => 1,         -- Help with making timing     
         INT_WIDTH_SELECT_G  => "NARROW",  -- Help with making timing     
         -- FIFO configurations
         BRAM_EN_G           => true,      -- Implement with BRAM
         GEN_SYNC_FIFO_G     => false,     -- false = ASYNC FIFO
         FIFO_ADDR_WIDTH_G   => 9,         -- 2**9 = 512 deep 
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => APP_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         -- APP Interface
         sAxisClk    => axilClk,
         sAxisRst    => axilRst,
         sAxisMaster => appObMasterSof,
         sAxisSlave  => appObSlaveSof,
         -- DMA Interface
         mAxisClk    => dmaClk,
         mAxisRst    => dmaRst,
         mAxisMaster => dmaIbMaster,
         mAxisSlave  => dmaIbSlave);

end mapping;
