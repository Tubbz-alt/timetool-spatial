-------------------------------------------------------------------------------
-- File       : DdrMemTester.vhd
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

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.MigPkg.all;

entity DdrMemTester is
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
      ddrClk          : in  slv(3 downto 0);
      ddrRst          : in  slv(3 downto 0);
      ddrReady        : in  slv(3 downto 0);
      ddrWriteMasters : out AxiWriteMasterArray(3 downto 0);
      ddrWriteSlaves  : in  AxiWriteSlaveArray(3 downto 0);
      ddrReadMasters  : out AxiReadMasterArray(3 downto 0);
      ddrReadSlaves   : in  AxiReadSlaveArray(3 downto 0));
end DdrMemTester;

architecture top_level of DdrMemTester is

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

   signal axiWriteMasters : AxiWriteMasterArray(3 downto 0) := (others => AXI_WRITE_MASTER_FORCE_C);
   signal axiWriteSlaves  : AxiWriteSlaveArray(3 downto 0)  := (others => AXI_WRITE_SLAVE_FORCE_C);
   signal axiReadMasters  : AxiReadMasterArray(3 downto 0)  := (others => AXI_READ_MASTER_FORCE_C);
   signal axiReadSlaves   : AxiReadSlaveArray(3 downto 0)   := (others => AXI_READ_SLAVE_FORCE_C);

   signal memReady : slv(NUM_AXIL_MASTERS_C-1 downto 0);
   signal memError : slv(NUM_AXIL_MASTERS_C-1 downto 0);

   signal failed : sl := '0';
   signal passed : sl := '0';

   signal axilRstL : sl;
   signal ddrRstL  : slv(3 downto 0);

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

   ------------------------
   -- Memory Tester Modules
   ------------------------
   GEN_VEC : for i in NUM_AXIL_MASTERS_C-1 downto 0 generate
      U_AxiMemTester : entity work.AxiMemTester
         generic map (
            TPD_G        => TPD_G,
            START_ADDR_G => START_ADDR_C,
            STOP_ADDR_G  => ite(SIM_SPEEDUP_G and SIMULATION_G, toSlv(32*4096, MEM_AXI_CONFIG_C.ADDR_WIDTH_C), STOP_ADDR_C),
            AXI_CONFIG_G => MEM_AXI_CONFIG_C)
         port map (
            -- AXI-Lite Interface
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i),
            memReady        => memReady(i),
            memError        => memError(i),
            -- DDR Memory Interface
            axiClk          => axilClk,
            axiRst          => axilRst,
            start           => ddrReady(i),
            axiWriteMaster  => axiWriteMasters(i),
            axiWriteSlave   => axiWriteSlaves(i),
            axiReadMaster   => axiReadMasters(i),
            axiReadSlave    => axiReadSlaves(i));

      U_Clk_Convt : XilinxKcu1500MigClkConvt
         port map (
            -- Slave Ports
            s_axi_aclk     => axilClk,
            s_axi_aresetn  => axilRstL,
            s_axi_awid     => axiWriteMasters(i).awid(3 downto 0),
            s_axi_awaddr   => axiWriteMasters(i).awaddr(31 downto 0),
            s_axi_awlen    => axiWriteMasters(i).awlen(7 downto 0),
            s_axi_awsize   => axiWriteMasters(i).awsize(2 downto 0),
            s_axi_awburst  => axiWriteMasters(i).awburst(1 downto 0),
            s_axi_awlock   => axiWriteMasters(i).awlock(0 downto 0),
            s_axi_awcache  => axiWriteMasters(i).awcache(3 downto 0),
            s_axi_awprot   => axiWriteMasters(i).awprot(2 downto 0),
            s_axi_awregion => axiWriteMasters(i).awregion(3 downto 0),
            s_axi_awqos    => axiWriteMasters(i).awqos(3 downto 0),
            s_axi_awvalid  => axiWriteMasters(i).awvalid,
            s_axi_awready  => axiWriteSlaves(i).awready,
            s_axi_wdata    => axiWriteMasters(i).wdata(511 downto 0),
            s_axi_wstrb    => axiWriteMasters(i).wstrb(63 downto 0),
            s_axi_wlast    => axiWriteMasters(i).wlast,
            s_axi_wvalid   => axiWriteMasters(i).wvalid,
            s_axi_wready   => axiWriteSlaves(i).wready,
            s_axi_bid      => axiWriteSlaves(i).bid(3 downto 0),
            s_axi_bresp    => axiWriteSlaves(i).bresp(1 downto 0),
            s_axi_bvalid   => axiWriteSlaves(i).bvalid,
            s_axi_bready   => axiWriteMasters(i).bready,
            s_axi_arid     => axiReadMasters(i).arid(3 downto 0),
            s_axi_araddr   => axiReadMasters(i).araddr(31 downto 0),
            s_axi_arlen    => axiReadMasters(i).arlen(7 downto 0),
            s_axi_arsize   => axiReadMasters(i).arsize(2 downto 0),
            s_axi_arburst  => axiReadMasters(i).arburst(1 downto 0),
            s_axi_arlock   => axiReadMasters(i).arlock(0 downto 0),
            s_axi_arcache  => axiReadMasters(i).arcache(3 downto 0),
            s_axi_arprot   => axiReadMasters(i).arprot(2 downto 0),
            s_axi_arregion => axiReadMasters(i).arregion(3 downto 0),
            s_axi_arqos    => axiReadMasters(i).arqos(3 downto 0),
            s_axi_arvalid  => axiReadMasters(i).arvalid,
            s_axi_arready  => axiReadSlaves(i).arready,
            s_axi_rid      => axiReadSlaves(i).rid(3 downto 0),
            s_axi_rdata    => axiReadSlaves(i).rdata(511 downto 0),
            s_axi_rresp    => axiReadSlaves(i).rresp(1 downto 0),
            s_axi_rlast    => axiReadSlaves(i).rlast,
            s_axi_rvalid   => axiReadSlaves(i).rvalid,
            s_axi_rready   => axiReadMasters(i).rready,
            -- Master Ports
            m_axi_aclk     => ddrClk(i),
            m_axi_aresetn  => ddrRstL(i),
            m_axi_awid     => ddrWriteMasters(i).awid(3 downto 0),
            m_axi_awaddr   => ddrWriteMasters(i).awaddr(31 downto 0),
            m_axi_awlen    => ddrWriteMasters(i).awlen(7 downto 0),
            m_axi_awsize   => ddrWriteMasters(i).awsize(2 downto 0),
            m_axi_awburst  => ddrWriteMasters(i).awburst(1 downto 0),
            m_axi_awlock   => ddrWriteMasters(i).awlock(0 downto 0),
            m_axi_awcache  => ddrWriteMasters(i).awcache(3 downto 0),
            m_axi_awprot   => ddrWriteMasters(i).awprot(2 downto 0),
            m_axi_awregion => ddrWriteMasters(i).awregion(3 downto 0),
            m_axi_awqos    => ddrWriteMasters(i).awqos(3 downto 0),
            m_axi_awvalid  => ddrWriteMasters(i).awvalid,
            m_axi_awready  => ddrWriteSlaves(i).awready,
            m_axi_wdata    => ddrWriteMasters(i).wdata(511 downto 0),
            m_axi_wstrb    => ddrWriteMasters(i).wstrb(63 downto 0),
            m_axi_wlast    => ddrWriteMasters(i).wlast,
            m_axi_wvalid   => ddrWriteMasters(i).wvalid,
            m_axi_wready   => ddrWriteSlaves(i).wready,
            m_axi_bid      => ddrWriteSlaves(i).bid(3 downto 0),
            m_axi_bresp    => ddrWriteSlaves(i).bresp(1 downto 0),
            m_axi_bvalid   => ddrWriteSlaves(i).bvalid,
            m_axi_bready   => ddrWriteMasters(i).bready,
            m_axi_arid     => ddrReadMasters(i).arid(3 downto 0),
            m_axi_araddr   => ddrReadMasters(i).araddr(31 downto 0),
            m_axi_arlen    => ddrReadMasters(i).arlen(7 downto 0),
            m_axi_arsize   => ddrReadMasters(i).arsize(2 downto 0),
            m_axi_arburst  => ddrReadMasters(i).arburst(1 downto 0),
            m_axi_arlock   => ddrReadMasters(i).arlock(0 downto 0),
            m_axi_arcache  => ddrReadMasters(i).arcache(3 downto 0),
            m_axi_arprot   => ddrReadMasters(i).arprot(2 downto 0),
            m_axi_arregion => ddrReadMasters(i).arregion(3 downto 0),
            m_axi_arqos    => ddrReadMasters(i).arqos(3 downto 0),
            m_axi_arvalid  => ddrReadMasters(i).arvalid,
            m_axi_arready  => ddrReadSlaves(i).arready,
            m_axi_rid      => ddrReadSlaves(i).rid(3 downto 0),
            m_axi_rdata    => ddrReadSlaves(i).rdata(511 downto 0),
            m_axi_rresp    => ddrReadSlaves(i).rresp(1 downto 0),
            m_axi_rlast    => ddrReadSlaves(i).rlast,
            m_axi_rvalid   => ddrReadSlaves(i).rvalid,
            m_axi_rready   => ddrReadMasters(i).rready);

   end generate GEN_VEC;

   GEN_SIM_CHECK : if (SIM_SELF_CHECK_G) and (SIMULATION_G) generate

      process(axilClk)
         variable i : natural;
      begin
         if rising_edge(axilClk) then
            passed <= uAnd(memReady) after TPD_G;
            failed <= uOr(memError)  after TPD_G;
         end if;
      end process;

      process(failed, passed)
      begin
         if passed = '1' then
            assert false
               report "Simulation Passed!" severity failure;
         end if;
         if failed = '1' then
            assert false
               report "Simulation Failed!" severity failure;
         end if;
      end process;

   end generate;

end top_level;
