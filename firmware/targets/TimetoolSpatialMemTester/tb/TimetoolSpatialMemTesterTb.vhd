-------------------------------------------------------------------------------
-- File       : TimetoolSpatialMemTesterTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the FPGA module
-------------------------------------------------------------------------------
-- This file is part of 'Camera link gateway'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Camera link gateway', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.BuildInfoPkg.all;
use work.MigPkg.all;

entity TimetoolSpatialMemTesterTb is end TimetoolSpatialMemTesterTb;

architecture testbed of TimetoolSpatialMemTesterTb is

   constant TPD_G : time := 1 ns;

   constant DDR_WIDTH_C : PositiveArray(3 downto 0) := (0 => 72, 1 => 64, 2 => 72, 3 => 72);

   component Ddr4ModelWrapper
      generic (
         DDR_WIDTH_G : positive);
      port (
         c0_ddr4_dq       : inout slv;
         c0_ddr4_dqs_c    : inout slv;
         c0_ddr4_dqs_t    : inout slv;
         c0_ddr4_adr      : in    slv(16 downto 0);
         c0_ddr4_ba       : in    slv(1 downto 0);
         c0_ddr4_bg       : in    slv(0 to 0);
         c0_ddr4_reset_n  : in    sl;
         c0_ddr4_act_n    : in    sl;
         c0_ddr4_ck_c     : in    slv(0 to 0);
         c0_ddr4_ck_t     : in    slv(0 to 0);
         c0_ddr4_cke      : in    slv(0 to 0);
         c0_ddr4_cs_n     : in    slv(0 to 0);
         c0_ddr4_dm_dbi_n : inout slv;
         c0_ddr4_odt      : in    slv(0 to 0));
   end component;

   signal userClkP : sl := '0';
   signal userClkN : sl := '1';

   signal ddrClockP : sl := '0';
   signal ddrClockN : sl := '1';
   signal ddrClkP   : slv(3 downto 0);
   signal ddrClkN   : slv(3 downto 0);
   signal ddrOut    : DdrOutArray(3 downto 0);
   signal ddrInOut  : DdrInOutArray(3 downto 0);

begin

   U_UserClk : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,   -- 156.25 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => userClkP,
         clkN => userClkN);

   U_ClkDdr : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 3.333 ns,  -- 300 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => ddrClockP,
         clkN => ddrClockN);

   ddrClkP <= (others => ddrClockP);
   ddrClkN <= (others => ddrClockN);

   GEN_VEC : for i in 3 downto 0 generate
      U_Ddr4Model : entity work.Ddr4ModelWrapper
         generic map (
            DDR_WIDTH_G => DDR_WIDTH_C(i))
         port map (
            c0_ddr4_dq       => ddrInOut(i).dq(DDR_WIDTH_C(i)-1 downto 0),
            c0_ddr4_dqs_t    => ddrInOut(i).dqsT((DDR_WIDTH_C(i)/8)-1 downto 0),
            c0_ddr4_dqs_c    => ddrInOut(i).dqsC((DDR_WIDTH_C(i)/8)-1 downto 0),
            c0_ddr4_adr      => ddrOut(i).addr,
            c0_ddr4_ba       => ddrOut(i).ba,
            c0_ddr4_bg       => ddrOut(i).bg,
            c0_ddr4_reset_n  => ddrOut(i).rstL,
            c0_ddr4_act_n    => ddrOut(i).actL,
            c0_ddr4_ck_c(0)  => ddrOut(i).ckC,
            c0_ddr4_ck_t(0)  => ddrOut(i).ckT,
            c0_ddr4_cke      => ddrOut(i).cke,
            c0_ddr4_cs_n     => ddrOut(i).csL,
            c0_ddr4_dm_dbi_n => ddrInOut(i).dm((DDR_WIDTH_C(i)/8)-1 downto 0),
            c0_ddr4_odt      => ddrOut(i).odt);
   end generate GEN_VEC;

   U_Fpga : entity work.TimetoolSpatialMemTester
      generic map (
         TPD_G          => TPD_G,
         ROGUE_SIM_EN_G => true,
         BUILD_INFO_G   => BUILD_INFO_C)
      port map (
         ---------------------
         --  Application Ports
         ---------------------
         -- QSFP[0] Ports
         qsfp0RefClkP => (others => '0'),
         qsfp0RefClkN => (others => '1'),
         qsfp0RxP     => (others => '0'),
         qsfp0RxN     => (others => '1'),
         qsfp0TxP     => open,
         qsfp0TxN     => open,
         -- QSFP[1] Ports
         qsfp1RefClkP => (others => '0'),
         qsfp1RefClkN => (others => '1'),
         qsfp1RxP     => (others => '0'),
         qsfp1RxN     => (others => '1'),
         qsfp1TxP     => open,
         qsfp1TxN     => open,
         -- DDR Ports
         ddrClkP      => ddrClkP,
         ddrClkN      => ddrClkN,
         ddrOut       => ddrOut,
         ddrInOut     => ddrInOut,
         --------------
         --  Core Ports
         --------------
         -- System Ports
         emcClk       => '0',
         userClkP     => userClkP,
         userClkN     => userClkN,
         -- QSFP[0] Ports
         qsfp0RstL    => open,
         qsfp0LpMode  => open,
         qsfp0ModSelL => open,
         qsfp0ModPrsL => '1',
         -- QSFP[1] Ports
         qsfp1RstL    => open,
         qsfp1LpMode  => open,
         qsfp1ModSelL => open,
         qsfp1ModPrsL => '1',
         -- Boot Memory Ports 
         flashCsL     => open,
         flashMosi    => open,
         flashMiso    => '1',
         flashHoldL   => open,
         flashWp      => open,
         -- PCIe Ports
         pciRstL      => '1',
         pciRefClkP   => '0',
         pciRefClkN   => '1',
         pciRxP       => (others => '0'),
         pciRxN       => (others => '1'),
         pciTxP       => open,
         pciTxN       => open);

end testbed;
