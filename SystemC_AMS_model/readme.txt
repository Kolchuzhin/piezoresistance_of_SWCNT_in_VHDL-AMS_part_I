
Model is divided into three sub-modules 

i) excitation system that consists input force 
ii) theoretical model of CNT, that emulates the piezzoresistive property of a single walled carbon nano tube (SWCNT) 
iii) top level module, which combines different sub-modules to form a complete sensor system. 

For mechanical input excitation TDF model is used. TDF module is used to define discrete time or to embed continuous time behavior. Analytical model of CNT also uses TDF model. In both the TDF modules, set_timestep attribute is used in member function set_attribute to define the time step between two consecutive samples. Sampling period for both the modules is set to 10 ns.  In a top-level module the predefined electrical primitives are defined for resistance, voltage source and current measurement. Child TDF modules like cnt and tri_wave are instantiated and interconnected to form a TDF cluster as in SystemC modules with the help of the macro SC_MODULE. It can also be seen that the necessary nodes a, b and gnd to communicate with the outside world and internal signals like resist, f and i_out_trace for the interconnection of child modules are defined in C++ access specifier public.   
