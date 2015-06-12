
// reference: page 21 scams user guide

#ifndef trisrc_h
#define trisrc_h

#include "systemc-ams.h"

SCA_TDF_MODULE(tri_src){

	sca_tdf::sca_out<double> out; // tri output
	double low_voltage, high_voltage, time_akt, time_last, voltage;

	tri_src( sc_core::sc_module_name nm, double ampl_= 2.0, double offset_ = 1.5, 
		 double period_time = 2.5e-3) // previous value 1.0e-7
        : out("out"), ampl(ampl_), offset(offset_), period_time(period_time)
	{ time_akt = 0;//period_time/4;
	  time_last = 0;
	  low_voltage = offset_ - ampl_;
	  high_voltage = offset_ + ampl_;
	  voltage = 0.0;
	  }

	void set_attributes()
	{
	  set_timestep(10, sc_core::SC_NS);
	}

	void initialize()
	{
	  //	out.initialize(3.0);
	}

	void processing();

	private:
		double ampl; // amplitude
		double offset; // offset
		double period_time;
};
#endif
