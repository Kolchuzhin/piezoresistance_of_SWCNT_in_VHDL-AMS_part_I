function [R, Eg]=SWCNT_bandgap(n,m, epsilon,gamma)
%=========================================================================%
% PURPOSE:  band gap of a strained SWCNT
%  
% INPUT:    
%           n,m are the chiral indices
%           epsilon is the axial strain
%           gamma is the torsional strain
%
% OUTPUT:
%           R  is the resistance of a strained SWCNT in Ohm
%           Eg is the bandgap of a strained SWCNT in eV
%
%           
% REFERENCE: 
%       Theory taken from
%       [Michael A. Cullinan and Martin L. Culpepper,
%       Carbon nanotubes as piezoresistive microelectromechanical sensors: 
%       Theory and experiment, PHYSICAL REVIEW B82, 115428,2010]
%-------------------------------------------------------------------------%
% Authors: 
% Kolchuzhin Vladimir, LMGT, TU Chemnitz
% <vladimir.kolchuzhin@etit.tu-chemnitz.de>
% Christian Wagner, ZfM, TU Chemnitz
% <christian.wagner@zfm.tu-chemnitz.de>
%
% www.zfm.tu-chemnitz.de/for1713
% TP1<->TP2
%
% 21.06.2011 16:51
% 02.03.2015 GitHub
%
% STATUS: OK
%=========================================================================%
%=========================================================================%
% data for verification:
% -- (13,0)   semiconducting p=+1 kind=1 Eg0=0.7423 R_002 = 1.5689e+19
% -- (14,0)   semiconducting p=-1 kind=1 Eg0=0.6892 R_002 = 7.4154e+11
% -- (15,0)   semimetallic   p= 0 kind=0 Eg0=0.0292 R_002 = 3.3838e+05
%=========================================================================%
%=========================================================================%
if nargin==0    % selftest
    strain = (-0.05:0.001:0.05); % ***
    gamma=0.0;      % no torsion
    [R_12_0, Eg_12_0]=SWCNT_bandgap(12,0,strain,gamma);
    [R_13_0, Eg_13_0]=SWCNT_bandgap(13,0,strain,gamma);
    [R_14_0, Eg_14_0]=SWCNT_bandgap(14,0,strain,gamma);
    [R_15_0, Eg_15_0]=SWCNT_bandgap(15,0,strain,gamma);
    
    figure(1)
    plot(strain*100,Eg_12_0','m-','linewidth',2); hold on
    plot(strain*100,Eg_13_0','g-','linewidth',2);
    plot(strain*100,Eg_14_0','r-','linewidth',2);
    plot(strain*100,Eg_15_0','b-','linewidth',2);
    axis([-5 5 0 1.2]);
    xlabel('strain, %'); ylabel('E_G, eV');
    legend('(12,0)','(13,0)','(14,0)','(15,0)');

    figure(2)
    semilogy(strain*100,R_12_0','m-','linewidth',2); hold on
    semilogy(strain*100,R_13_0','g-','linewidth',2);
    semilogy(strain*100,R_14_0','r-','linewidth',2);
    semilogy(strain*100,R_15_0','b-','linewidth',2);
    xlabel('strain, %'); ylabel('Resistance R, Ohm');
    legend('(12,0)','(13,0)','(14,0)','(15,0)');
end
%=========================================================================%
%=========================================================================%
h=6.6260695729e-34;             % Plank’s constant, Js
e_charge=1.60217646e-19;        % charge on an electron, coulombs
kB=1.380648813e-23;             % Boltzman’s constant, J/K

%h = 6.626e-34;
%e_charge = 1.602e-19;
%kB = 1.381e-23;
%-------------------------------------------------------------------------%
a0=0.142;      % nm
a0=1.421;      % Å
a=a0*sqrt(3);  % length of lattice vector, Å

t0=2.66;       % the tight-binding overlap integral, eV
t= 1.0;        % transmission probability t^2 of an electron with |E-E_F|>E_G to cross energy barrier
b= 3.5;        % change in transfer integral by changed bond lengths, eV/Å
%-------------------------------------------------------------------------%
% environment parameters
nu=0.2;        % the Poisson’s ratio
Rc=0.0;        % contact resistance, Ohm
T=300.0;       % temperature,K
% s0           % pretension strain
%=========================================================================%
% calculated parameters of CNT
 d = gcd(n,m);                    % greatest common divisor of n,m
 d_r = gcd(2*m+n,2*n+m);

r0 = a*sqrt(n*n+m*m+m*n)/(2*pi); % radius of CNT
theta = atan(sqrt(3)*m/(2*n+m)); % chiral angle

p = abs(mod(n-m,3));             % sign of bandgap-change
p = p - 3*(p>1);
 kind = abs(p);                   % kind of tube

 % three types of SWNTs classified by p:
 %     p =0 => (semi)metallic
 % abs(p)=1 => semiconducting

 % theta=0;  % zigzag   m=0 (n,0)
 % theta=30; % armchair n=m (n,n)
%=========================================================================%
if n~=m
    if p==0             % semimetallic p=0
        Eg0=t0*a^2/(16*r0^2)*cos(3*theta);           % zero strain bandgap
        dEg=-(sqrt(3)/2*a*b*cos(3*theta).*epsilon);   % change of bandgap
        Eg=abs(Eg0+dEg);
    end
    if abs(p)==1        % semiconducting abs(p)=1
        Eg0=t0*a/sqrt(3)/r0;
        dEg=sign(2*p+1)*3*t0*((1+nu)*epsilon*cos(3*theta)+gamma*sin(3*theta));
        Eg=abs(Eg0+dEg);
    end
else                    % metallic: n=m
        Eg=0.0;
end
%-------------------------------------------------------------------------%
R = Rc + 1/abs(t)^2*h/8/e_charge^2*(1+exp(Eg/(kB*T/e_charge)));
%=========================================================================%
return
