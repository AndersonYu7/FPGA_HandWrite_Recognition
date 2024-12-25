create_clock -name "iCLK_50" -period 20.000ns [get_ports {iCLK_50}]
create_clock -name "iCLK_50_2" -period 20.000ns [get_ports {iCLK_50}]
create_clock -name "iCLK_50_3" -period 20.000ns [get_ports {iCLK_50}]
create_clock -name "iCLK_50_4" -period 20.000ns [get_ports {iCLK_50}]
create_clock -name "iCLK_28" -period 35.714ns [get_ports {iCLK_50}]


derive_pll_clocks
derive_clock_uncertainty