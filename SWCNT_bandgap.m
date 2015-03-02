function [R, Eg]=SWCNT_bandgap(n,m, epsilon,gamma)
%=========================================================================%
% PURPOSE:  band gap of a strained SWCNT
%  
% INPUT:    
%           n,m are the chiral indices
%           epsilon is the axial strain
%           gammais is the torsional strain
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
