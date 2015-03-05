-------------------------------------------------------------------------------
-- Model: testbench for piezoresistance of SWCNT in hAMSter
--
-- Author: Vladimir Kolchuzhin, LMGT, TU Chemnitz
-- <vladimir.kolchuzhin@etit.tu-chemnitz.de>
-- Date: 06.01.2012
--
-- Library: 	
--			    pr_swcnt.vhd (cnt.vhd)
--             v_dc.vhd
--          f_pulse.vhd 
-- 
--
-- Euler solver, Tend=2.0m, dt=1u (Tend=2.5m, dt=1u)
-- Output: u_ext1; cnt: i.cnt1, strain.cnt1, rcnt.cnt1;
-- The CNT is driven by a force source Fs1
-------------------------------------------------------------------------------
-- ID: testbench_cnt.vhd
--
-- Modification History:
-- Revision 1.0  12.04.2012 official release for ForGr1713, www.zfm.tu-chemnitz.de/for1713
-- Revision      07.10.2014 github
-------------------------------------------------------------------------------
library ieee;

use work.electromagnetic_system.all;
use work.all;
use ieee.math_real.all;


entity testbench_cnt is
end;


architecture behav of testbench_cnt is
  terminal struc1_ext,struc2_ext: translational;      -- structural nodes
  terminal elec1_ext,elec2_ext: electrical;           -- electrical ports
  --
  quantity u_ext1 across f_ext1 through struc1_ext;   -- node 1
  quantity u_ext2 across f_ext2 through struc2_ext;   -- node 2
  --
  quantity v_ext1 across i_ext1  through elec1_ext;   -- electrode 1
  quantity v_ext2 across i_ext2  through elec2_ext;   -- electrode 2

-- CNT parameters
  constant    Rc:real:=100.0e3;
  constant     T:real:=300.0;
  constant     n:real:=13.0;
  constant     m:real:= 1.0;
  constant stiff:real:= 0.54;
  constant    L0:real:= 2.0e-6;

  constant    s0:real:=0.0;
  constant  smax:real:=0.05;
  constant     g:real:=0.0;

-- Voltage source: dc
  constant dc_value:real:=1.0;
-- Force source: triangular pulse
  constant ac_value:real:=smax*L0*stiff; -- N
  constant period:real:=2.0e-3; 	 -- s


begin
-------------------------------------------------------------------------------
-- BC for ports:
i_ext1==0.0;   -- input
v_ext2==0.0;   -- ground

f_ext1==0.0;   -- external nodal force
u_ext2==0.0;   -- external nodal displacement (ground)
-------------------------------------------------------------------------------
--                       
--     nodal ports          electrical ports
--
-- f_ext1=0 ->>- o---o      o---o -<<- i_ext1=0
--               |   |      |   |
--               |   <      -   |
--               ^   <     | |  |
--           Fs1 ^   <     | |  ^ Vs1
--               |   <      -   |
--               |   |      |   |
--      u_ext2=0 o---o      o---o v_ext2=0 
--
--                                             electrical_ground
--
-- ASCII-Schematic of the circuit
-------------------------------------------------------------------------------
 CNT1:
	entity pr_swcnt(analytic)
	generic map(Rc,T,n,m,s0,g,stiff,L0)
	port map(struc1_ext,struc2_ext,elec1_ext,elec2_ext);

 Vs1:    
	entity v_dc(basic)
	generic map(dc_value)
	port map(elec1_ext,elec2_ext);
                     
 Fs1:    
	entity f_pulse(basic)
	generic map(0.0,ac_value,period)
	port map(struc1_ext,struc2_ext);

end;
