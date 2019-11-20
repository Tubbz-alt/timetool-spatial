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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;

library axi_pcie_core;
use axi_pcie_core.MigPkg.all;

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

begin

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
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
      U_AxiMemTester : entity surf.AxiMemTester
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

      U_MigClkConvtWrapper : entity axi_pcie_core.MigClkConvtWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
            -- USER AXI Memory Interface (axiClk domain)
            axiClk         => axilClk,
            axiRst         => axilRst,
            axiWriteMaster => axiWriteMasters(i),
            axiWriteSlave  => axiWriteSlaves(i),
            axiReadMaster  => axiReadMasters(i),
            axiReadSlave   => axiReadSlaves(i),
            -- DDR AXI Memory Interface (ddrClk domain)
            ddrClk         => ddrClk(i),
            ddrRst         => ddrRst(i),
            ddrWriteMaster => ddrWriteMasters(i),
            ddrWriteSlave  => ddrWriteSlaves(i),
            ddrReadMaster  => ddrReadMasters(i),
            ddrReadSlave   => ddrReadSlaves(i));

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
