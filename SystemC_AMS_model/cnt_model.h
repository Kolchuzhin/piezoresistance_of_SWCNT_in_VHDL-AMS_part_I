#ifndef gcd_h
#define gcd_h
#include "systemc-ams.h"
#include "systemc.h"
#include "functions.h"
#include <iostream>
#define PI 3.14159

using namespace sc_core;


SCA_TDF_MODULE(cnt_model) 

{
    // sca_tdf :: sca_in<double> in; // applied strain
    sca_tdf :: sca_in<double> in; // applied strain
    sca_tdf :: sca_out<double> out; // change in resistance

    static const double v  = 0.2;	   //Poisson's ration = E=(2*G)-1
    static const double tp = 1.0; // transmission probability of electrons = t^2
        
    //Physical Constants
    static const double h  = 6.626e-34;	// Plancks Constant
    static const double e  = 1.602e-19;	// Charge on an electron
    static const double k  = 1.381e-23;	// Boltzmann's Constant
    
    static const double T  = 300.0;		// Temperature in Kelvin
    static const double b  = 3.5;		// Change in transfer integral by changed bond length
    static const double s0 = 0.0;		// Pretension strain
    static const double s  = 0.05;      // strain variable
    static const double Rc = 100.0e3;	// Contact resistance
    
    // Parameters of the CNT tube
    static const double t0 = 2.66;		//eV, tight binding overlap ->E(k-kf)=+/- 1.5*t0*r0*|k-kf|
    static const double Lo = 2.0e-6;    // initial length of tube in meter
    static const double c1 = 0.5e6;     // cnt stiffness in N/m 
    static const int n		= 13;		// chiral index (13, 1)
    static const int m		= 1;

    
    //    double strain, disp, DE_G, Eg0, Egs, R_cnt; 
    sca_tdf::sca_trace_variable<double> strain_trace, disp_trace, DE_G_tr, Egs_tr, Eg0_tr;

	SCA_CTOR(cnt_model) 
    :in("in"), out("out") 

	{
	}

	void set_attributes() 	

	{
		set_timestep(10, sc_core::SC_NS); // previous timestep 100.0 NS
	}
   
	void initialize()
    {
    }

	void processing()
    {
        
        double force, strain, disp, DE_G, Eg0, Egs, R_cnt;

        double a = 1.421 * sqrt(3); 	         // Length of lattice vector
        double d = gcd(n,m);                     //gcd of n, m
        double d_r = gcd(2*m+n, 2*n+m); 
        double r0 = a*sqrt(n*n+m*m+m*n)/(2*PI);	 // cnt tube radious
        double theta = atan(sqrt(3)*m/(2*n+m));  //  chiral angle
       
        int  q = abs((n-m)%3);	                 // sign of bandgap-change, p=0 -> metallic
        int p, kind;
        //     int x = 1000;
        
        force = in.read();    //ref: page 19 scams user guide          
        disp  = force / c1;
       
        strain= disp / Lo;

        if (q <= 1)
            p = q;
        else 
            p = q-3;
        kind = abs(p);

            
        // kind of tube, 0 metallic, >0 semiconducting
        if (kind ==1) {
            Eg0 = (2*t0*a)/(sqrt(3)*2*r0); // bandgap - semiconducting or metallic
            DE_G = sign((2*p+1)*3*t0*((1+v)*strain*cos(3*theta))); // change in bandgap
            //dDE_G = sign((2*p+1)*3*t0*((1+v)*cos(3*theta))); // derivative of change in bandgap wrt s
            Egs = abs(Eg0+DE_G);
        }
        
        else {
            Eg0 = t0*pow(a,2)/(16*pow(r0,2)*cos(3*theta)); // bandgap - semiconducting or metallic, eqn from VHDL-AMS, MatLab Model
            // Eg0 = t0*pow(a,2)/(16*pow(r0,2)); actual equation from the ref paper
            DE_G = (sqrt(3)/2)*a*b*cos(3*theta)*strain;
            Egs = abs(Eg0-DE_G);
        }
		
        R_cnt = (h/(8*pow((tp*e),2)))*(1+exp(Egs/(k*T/e)));
        
        // R_cnt = h/(8*(pow(tp*e),2)*(1+exp(Egs/(k*T/e))));
        // R_cnt = R0(1+G.S);  R0 = Initial Resistance, G = strain gauge = 2.0, S = strain
        out.write ( Rc + R_cnt );
        disp_trace = disp;
        strain_trace = strain;
        DE_G_tr = DE_G;
        Eg0_tr = Eg0;
        Egs_tr = Egs;
        
        //  sca_core::sca_time local_time = get_time().to_NS;  
        //    if(local_time<11){
        // std::cout << "a = " << a << endl << "d = " << d << endl << "r0 = " << r0 << endl << "theta = " << theta << endl;
        //    std::cout << "p = " << p << endl << "q = " << q << endl << "kind = " << kind << endl; 
        
        //  } 
        
    }
    
//  public:
//     double force_in;
    
};

#endif


    // use of sign function for calculation of change in band gap for metalic CNT is there in (Cullinan, Culpepper) paper
    // but sign function is omitted in VHDL-AMS model

    // Not clear: while calculating Eg0 for metalic and semimetallic CNT, from where comes the term cos(3*theta)

    // Not clear: in the exponetial term in R_cnt, no e factor is there, while in VHDL-AMS model and Matlab model, it is there
    
