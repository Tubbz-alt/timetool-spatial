-------------------------------------------------------------------------------
-- File       : TimetoolSpatialPipTester.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top-Level HDL
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

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity TimetoolSpatialPipTester is
   generic (
      TPD_G          : time    := 1 ns;
      ROGUE_SIM_EN_G : boolean := false;
      BUILD_INFO_G   : BuildInfoType);
   port (
      ---------------------
      --  Application Ports
      ---------------------
      -- QSFP[0] Ports
      qsfp0RefClkP : in  slv(1 downto 0);
      qsfp0RefClkN : in  slv(1 downto 0);
      qsfp0RxP     : in  slv(3 downto 0);
      qsfp0RxN     : in  slv(3 downto 0);
      qsfp0TxP     : out slv(3 downto 0);
      qsfp0TxN     : out slv(3 downto 0);
      -- QSFP[1] Ports
      qsfp1RefClkP : in  slv(1 downto 0);
      qsfp1RefClkN : in  slv(1 downto 0);
      qsfp1RxP     : in  slv(3 downto 0);
      qsfp1RxN     : in  slv(3 downto 0);
      qsfp1TxP     : out slv(3 downto 0);
      qsfp1TxN     : out slv(3 downto 0);
      --------------
      --  Core Ports
      --------------
      -- System Ports
      emcClk       : in  sl;
      userClkP     : in  sl;
      userClkN     : in  sl;
      -- QSFP[0] Ports
      qsfp0RstL    : out sl;
      qsfp0LpMode  : out sl;
      qsfp0ModSelL : out sl;
      qsfp0ModPrsL : in  sl;
      -- QSFP[1] Ports
      qsfp1RstL    : out sl;
      qsfp1LpMode  : out sl;
      qsfp1ModSelL : out sl;
      qsfp1ModPrsL : in  sl;
      -- Boot Memory Ports 
      flashCsL     : out sl;
      flashMosi    : out sl;
      flashMiso    : in  sl;
      flashHoldL   : out sl;
      flashWp      : out sl;
      -- PCIe Ports
      pciRstL      : in  sl;
      pciRefClkP   : in  sl;
      pciRefClkN   : in  sl;
      pciRxP       : in  slv(7 downto 0);
      pciRxN       : in  slv(7 downto 0);
      pciTxP       : out slv(7 downto 0);
      pciTxN       : out slv(7 downto 0));
end TimetoolSpatialPipTester;

architecture top_level of TimetoolSpatialPipTester is

   constant ROGUE_SIM_PORT_NUM_C : natural range 1024 to 49151 := 8000;

   constant DMA_SIZE_C        : positive            := 1;
   constant DMA_WIDTH_C       : positive            := 8;  -- Units of bytes
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(DMA_WIDTH_C, TKEEP_COMP_C, TUSER_FIRST_LAST_C, 8, 2);

   constant CLK_FREQUENCY_C : real := 125.0E+6;  -- units of Hz

   constant NUM_AXIL_MASTERS_C : natural := 4;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      0               => (
         baseAddr     => x"0010_0000",
         addrBits     => 20,
         connectivity => x"FFFF"),
      1               => (
         baseAddr     => x"0020_0000",
         addrBits     => 21,
         connectivity => x"FFFF"),
      2               => (
         baseAddr     => x"0040_0000",
         addrBits     => 22,
         connectivity => x"FFFF"),
      3               => (
         baseAddr     => x"0080_0000",
         addrBits     => 23,
         connectivity => x"FFFF"));

   signal userClk156       : sl;
   signal axilClk          : sl;
   signal axilRst          : sl;
   signal axilReadMaster   : AxiLiteReadMasterType;
   signal axilReadSlave    : AxiLiteReadSlaveType;
   signal axilWriteMaster  : AxiLiteWriteMasterType;
   signal axilWriteSlave   : AxiLiteWriteSlaveType;
   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaObMasters : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaObSlaves  : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal dmaIbMasters : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaIbSlaves  : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal pipIbMaster : AxiWriteMasterType;
   signal pipIbSlave  : AxiWriteSlaveType;
   signal pipObMaster : AxiWriteMasterType;
   signal pipObSlave  : AxiWriteSlaveType;

begin

   -----------------------
   -- AXI-Lite Clock/Reset
   -----------------------
   U_axilClk : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => true,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         CLKIN_PERIOD_G     => 6.4,     -- 156.25 MHz
         CLKFBOUT_MULT_G    => 8,       -- 1.25GHz = 8 x 156.25 MHz
         CLKOUT0_DIVIDE_F_G => 10.0)    -- 125MHz (must match CLK_FREQUENCY_C)
      port map(
         -- Clock Input
         clkIn     => userClk156,
         rstIn     => dmaRst,
         -- Clock Outputs
         clkOut(0) => axilClk,
         -- Reset Outputs
         rstOut(0) => axilRst);

   -----------------------         
   -- axi-pcie-core module
   -----------------------         
   U_Core : entity work.XilinxKcu1500Core
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
         ROGUE_SIM_PORT_NUM_G => ROGUE_SIM_PORT_NUM_C,
         BUILD_INFO_G         => BUILD_INFO_G,
         DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_C,
         DMA_SIZE_G           => DMA_SIZE_C)
      port map (
         ------------------------      
         --  Top Level Interfaces
         ------------------------   
         userClk156     => userClk156,
         -- DMA Interfaces
         dmaClk         => dmaClk,
         dmaRst         => dmaRst,
         dmaObMasters   => dmaObMasters,
         dmaObSlaves    => dmaObSlaves,
         dmaIbMasters   => dmaIbMasters,
         dmaIbSlaves    => dmaIbSlaves,
         -- PIP Interface [0x00080000:0008FFFF] (dmaClk domain)
         pipIbMaster    => pipIbMaster,
         pipIbSlave     => pipIbSlave,
         pipObMaster    => pipObMaster,
         pipObSlave     => pipObSlave,
         -- Application AXI-Lite Interfaces [0x00100000:0x00FFFFFF]
         appClk         => axilClk,
         appRst         => axilRst,
         appReadMaster  => axilReadMaster,
         appReadSlave   => axilReadSlave,
         appWriteMaster => axilWriteMaster,
         appWriteSlave  => axilWriteSlave,
         --------------
         --  Core Ports
         --------------   
         -- System Ports
         emcClk         => emcClk,
         userClkP       => userClkP,
         userClkN       => userClkN,
         -- QSFP[0] Ports
         qsfp0RstL      => qsfp0RstL,
         qsfp0LpMode    => qsfp0LpMode,
         qsfp0ModSelL   => qsfp0ModSelL,
         qsfp0ModPrsL   => qsfp0ModPrsL,
         -- QSFP[1] Ports
         qsfp1RstL      => qsfp1RstL,
         qsfp1LpMode    => qsfp1LpMode,
         qsfp1ModSelL   => qsfp1ModSelL,
         qsfp1ModPrsL   => qsfp1ModPrsL,
         -- Boot Memory Ports 
         flashCsL       => flashCsL,
         flashMosi      => flashMosi,
         flashMiso      => flashMiso,
         flashHoldL     => flashHoldL,
         flashWp        => flashWp,
         -- PCIe Ports 
         pciRstL        => pciRstL,
         pciRefClkP     => pciRefClkP,
         pciRefClkN     => pciRefClkN,
         pciRxP         => pciRxP,
         pciRxN         => pciRxN,
         pciTxP         => pciTxP,
         pciTxN         => pciTxN);

   -------------------------
   -- Unused QSFP interfaces
   -------------------------
   U_UnusedQsfp : entity work.TerminateQsfp
      generic map (
         TPD_G => TPD_G)
      port map (
         axilClk      => axilClk,
         axilRst      => axilRst,
         ---------------------
         --  Application Ports
         ---------------------         
         -- QSFP[0] Ports
         qsfp0RefClkP => qsfp0RefClkP,
         qsfp0RefClkN => qsfp0RefClkN,
         qsfp0RxP     => qsfp0RxP,
         qsfp0RxN     => qsfp0RxN,
         qsfp0TxP     => qsfp0TxP,
         qsfp0TxN     => qsfp0TxN,
         -- QSFP[1] Ports
         qsfp1RefClkP => qsfp1RefClkP,
         qsfp1RefClkN => qsfp1RefClkN,
         qsfp1RxP     => qsfp1RxP,
         qsfp1RxN     => qsfp1RxN,
         qsfp1TxP     => qsfp1TxP,
         qsfp1TxN     => qsfp1TxN);

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

   -------------
   -- PIP Module
   -------------
   U_AxiPciePipCore : entity work.AxiPciePipCore
      generic map (
         TPD_G             => TPD_G,
         NUM_AXIS_G        => DMA_SIZE_C,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C)
      port map (
         -- AXI4-Lite Interfaces (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(1),
         axilReadSlave   => axilReadSlaves(1),
         axilWriteMaster => axilWriteMasters(1),
         axilWriteSlave  => axilWriteSlaves(1),                  
         -- AXI Stream Interface (axisClk domain)
         axisClk         => dmaClk,
         axisRst         => dmaRst,
         sAxisMasters    => dmaObMasters,
         sAxisSlaves     => dmaObSlaves,
         mAxisMasters    => dmaIbMasters,
         mAxisSlaves     => dmaIbSlaves,
         -- AXI4 Interfaces (axiClk domain)
         axiClk          => dmaClk,
         axiRst          => dmaRst,
         sAxiWriteMaster => pipIbMaster,
         sAxiWriteSlave  => pipIbSlave,
         mAxiWriteMaster => pipObMaster,
         mAxiWriteSlave  => pipObSlave);   
         
   U_Version0 : entity work.AxiVersion
      generic map (
         TPD_G           => TPD_G,
         BUILD_INFO_G    => BUILD_INFO_G,
         CLK_PERIOD_G    => (1.0/CLK_FREQUENCY_C))
      port map (
         -- AXI-Lite Interface
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(0),
         axiReadSlave   => axilReadSlaves(0),
         axiWriteMaster => axilWriteMasters(0),
         axiWriteSlave  => axilWriteSlaves(0));   

end top_level;
