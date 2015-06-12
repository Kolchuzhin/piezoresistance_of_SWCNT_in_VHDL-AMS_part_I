#include "tri_src.h"
#include <iostream>
// #include <string>
// #include <fstream>
// #include <cstdlib>
// using namespace std;

void tri_src::processing()
	{
		double t = get_time().to_seconds(); // actual time
		//med_volt = low_voltage + (high_voltage - low_voltage)/2.0;
		time_akt = time_akt + t-time_last; //this->get_timestep().to_seconds();
		if (time_akt >= period_time) time_akt = 0;
		if (time_akt < period_time/2){
		  voltage =low_voltage + (high_voltage-low_voltage)*2.0*time_akt/period_time;
		  //cout <<time_akt<< "rising "<<high_voltage<<" " << low_voltage << " makes: "<<voltage<<endl;
		 }
		
		else{
		  voltage = high_voltage - (high_voltage-low_voltage)*2.0*(time_akt-period_time/2)/period_time;
		  //cout <<time_akt<< "falling "<<high_voltage<<" " << low_voltage<< " makes: "<<voltage << endl;
		 }
		out.write(voltage);
		time_last = t;
		//out.write(1);
	}  
