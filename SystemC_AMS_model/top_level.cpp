//ref: page 77 scams user guide

#include <systemc-ams.h>
#include "cnt_model.h"
#include "tri_src.h"

SC_MODULE (top_level)
{
    
    sca_eln :: sca_tdf_r rx;
    sca_eln :: sca_vsource vcc ; // ref: page 87 scams user guide
    sca_eln :: sca_tdf_isink i_out;
    
    
    cnt_model cnt;
    tri_src triwave;
    
    
    top_level(sc_core :: sc_module_name nm, double vcc_= 1.0)
      : a("a"), gnd("gnd"), rx("rx"), cnt("cnt"), vcc("vcc"), i_out("i_out"), triwave("triwave", 50.0e-3, 0.0, 2.5e-3) 
        
        {
            rx.p(a);
            rx.n(gnd); 
            rx.inp(resist); 

            triwave.out(f);
	    
            cnt.in(f);
            cnt.out(resist);

            vcc.offset = vcc_;           // ref: page 87 scams user guide
            vcc.p(b);
            vcc.n(gnd);

            i_out.p(a);
            i_out.n(b);
            i_out.outp(i_out_trace);
           
        }

 public:
    sca_eln :: sca_node a, b;
    sca_eln :: sca_node_ref gnd;
    sca_tdf :: sca_signal<double> resist, i_out_trace;
    sca_tdf :: sca_signal<double> f;
};


int sc_main(int argc, char* argv[]) {

  //sc_core :: sc_set_time_resolution (10, sc_core :: SC_NS); // previous timestep 100.0 NS

    top_level i_top_level("i_top_level");

    
	/********* tracing signals *************************/

    sca_util :: sca_trace_file* atfs = sca_util :: sca_create_tabular_trace_file( "cnt.dat" ); // ref: page 79
    sca_util :: sca_trace(atfs, i_top_level.a, "node_a");// 2
    sca_util :: sca_trace(atfs, i_top_level.cnt.in, "force");// 3
    sca_util :: sca_trace(atfs, i_top_level.cnt.disp_trace, "displacement");// 4
    sca_util :: sca_trace(atfs, i_top_level.cnt.strain_trace, "strain");// 5
    sca_util :: sca_trace(atfs, i_top_level.cnt.DE_G_tr, "DE_G");// 6
    sca_util :: sca_trace(atfs, i_top_level.cnt.Eg0_tr, "Eg0");// 7
    sca_util :: sca_trace(atfs, i_top_level.cnt.Egs_tr, "Egs"); // 8
    sca_util :: sca_trace(atfs, i_top_level.cnt.out, "resistance"); // 9
    sca_util :: sca_trace(atfs, i_top_level.i_out.outp, "I_output"); // 10
    sca_util :: sca_trace(atfs, i_top_level.triwave.out, "triwave_out"); // 11
    
    sc_start(2.5, SC_MS);

	// setup initial values for simulation
	//printf("initializing simulation");

    sca_util :: sca_close_tabular_trace_file( atfs );

	//printf("simulation done");
	return 0;

} 
