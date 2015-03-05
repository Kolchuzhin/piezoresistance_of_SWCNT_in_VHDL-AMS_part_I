-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Model: piezoresistance of single walled carbon nanotube in hAMSter
--
-- Authors: Vladimir Kolchuzhin, LMGT, TU Chemnitz
-- <vladimir.kolchuzhin@etit.tu-chemnitz.de>
--
-- Date: 07.06.2011 16:03
-- Library: kvl in hAMSter
-------------------------------------------------------------------------------
-- ID: pr_swcnt.vhd
-------------------------------------------------------------------------------
-- Modification History:
--
-- Revision 1.0  25.04.2012 official release for ForGr1713: www.zfm.tu-chemnitz.de/for1713  
-- Revision 1.1  02.03.2015 verification for (13.0), (14,0), (15,0)
--               05.03.2015 GitHub
--
-- Dependencies: 
--   			mod_ad	== modulus after division 
--				sign  == signum function (Returns 0.0 if X < 0.0) :( e.g. (14,0)
--				floor
--
-- Status: Compile OK, model was compiled with hAMSter simulator
-------------------------------------------------------------------------------
-- Reference:
-- Theory taken from M. A. Cullinan and M.L. Culpepper
-- Carbon nanotubes as piezoresistive microelectromechanical sensors: Theory and experiment
-- Phys Rev. B, American Physical Society, 82, 115428, 2010
-- *********************************************************
-- three types of SWNTs classified by:
--     p =0 => (semi)metallic
-- abs(p)=1 => semiconducting
--      n=m => metallic
-- *********************************************************
-- theta=0;  % zigzag   m=0 (n,0)
-- theta=30; % armchair n=m (n,n)
-- *********************************************************
-- data for verification (SWCNT_bandgap.m):
-- (13,0)   semiconducting p=+1 kind=1 Eg0=0.7423 R_002 = 1.5689e+19
-- (14,0)   semiconducting p=-1 kind=1 Eg0=0.6892 R_002 = 7.4154e+11
-- (15,0)   semimetallic   p= 0 kind=0 Eg0=0.0292 R_002 = 3.3838e+05
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;

use ieee.math_real.all;
use work.electromagnetic_system.all;
use work.all;
-------------------------------------------------------------------------------
entity pr_swcnt is

-- input parameters:
  -- n  -- chiral parameter for CNT
  -- m  -- chiral parameter for CNT

  -- c1 -- stiffness, N/m
  -- L0 -- initial length of tube, m
  -- Rc -- contact resistance, Ohm

-- environment parameters
  -- T  -- temperature, K
  -- s0 -- pretension strain
  -- s  -- strain = (L-L0)/L0 = f/c1/L0; (L-L0=u; f=c1*u)
  -- g  -- torsional strain


generic(Rc,T,n,m,s0,g,c1,L0:real); -- given as a generic parameter

  port (terminal m1,m2:translational; -- structural ports
        terminal e1,e2:electrical);	  -- electrical ports 

end entity pr_swcnt;
--===========================================================================--
--===========================================================================--
architecture analytic of pr_swcnt is

  quantity u across f through m1 to m2;
  quantity v across i through e1 to e2;
 -- 
   quantity strain:real;
   quantity p1:real;
   quantity p:real;
   quantity Eg0:real;
   quantity Egs:real;
   quantity kind:real;
   quantity Rcnt:real;

-- physical constants
  constant      h:real:=6.6260695729e-34; -- Plancks constant, Js
  constant e_charge:real:=1.60217646e-19; -- charge on an electron, As = C
  constant      kB:real:=1.380648813e-23; -- Boltzmanns constant, J/K

-- parameters of CNT
  constant tp:real:=1.0;			      -- transmission probability t^2 of an electron
  constant  a:real:=1.421*sqrt(3.0);      -- length of lattice vector, Å
  constant t0:real:=2.66;			      -- the tight-binding overlap integral, eV  
  constant  b:real:=3.5;			      -- change in transfer integral by changed bond lengths, eV/Å
  constant nu:real:=0.2;			      -- Poisson's ratio = E/(2*G)-1

-- calculated parameters of CNT from m,n
constant r0:real:=(a*sqrt(n*n+m*m+m*n)/(2.0*MATH_PI)); -- radius
constant theta:real:=arctan(sqrt(3.0)*m/(2.0*n+m));    -- chiral angle
--===========================================================================--
FUNCTION mod_ad(x:real;y:real) RETURN real is
variable result:real:= 0.0;

-- Modulus after division
-- the inputs must be real scalars
--      MOD(x,0) is x.
--      MOD(x,x) is 0.
--      MOD(x,y) for x~=y and y~=0, has the same sign as y.
--      MOD(x,y) is x - n.*y where n = floor(x./y) if y ~= 0.

begin

	if    x = y   then
		result:=0.0;	 -- x = y
    elsif y = 0.0 then   -- y = 0
        result:=x;
	else				 -- x ~= y
		result:=x - y*floor(x/y);
    end if;

RETURN result;
END FUNCTION mod_ad;
--===========================================================================--
begin

    f == c1*u; -- linear spring
	strain == u/L0;
    ---------------
    p1 == abs(mod_ad(n-m,3.0));
	if p1 <= 1.0 use
		p == p1;
	else
		p == p1 - 3.0; 	-- p = p - 3*(p>1)
	end use;

	if n = m use
		kind == 2.0;	  -- metallic
	else
		kind == abs(p); -- semimetallic / semiconducting classified by p
	end use;
    ---------------
	if    kind = 0.0 use   -- kind = 0 (semimetallic)
			Eg0==t0*a**2/(16.0*r0**2.0)*cos(3.0*theta);	-- zero strain band gap
	    	Egs==abs(Eg0-(sqrt(3.0)/2.0)*a*b*cos(3.0*theta)*strain);
	elsif kind = 1.0 use   -- kind = 1 (semiconducting)
			Eg0==t0*a/(sqrt(3.0)*r0);										-- zero strain band gap
		    --Egs==abs(Eg0+sign(2.0*p+1.0)*3.0*t0*((1.0+nu)*cos(3.0*theta)*strain+sin(3.0*theta)*g));
			if p < 1.0 use
			Egs==abs(Eg0+(-1.0)*3.0*t0*((1.0+nu)*cos(3.0*theta)*strain+sin(3.0*theta)*g));
			else
			Egs==abs(Eg0+(+1.0)*3.0*t0*((1.0+nu)*cos(3.0*theta)*strain+sin(3.0*theta)*g));
			end use;
	else 				           -- kind = 2 (metallic)
			Eg0==0.0;
			Egs==0.0;
	end use;
    ---------------
	Rcnt == h/(8.0*(tp*e_charge)**2)*(1.0+exp(Egs/(kB*T/e_charge))); -- resistance of a strained SWCNT, Ohm
    ---------------
	v == i*(Rc + Rcnt);
end architecture analytic;
--===========================================================================--
--===========================================================================--
