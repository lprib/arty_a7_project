# Generate high-level RTL and display it in new vivado GUI window

start_gui

source ./build_scripts/read_sources.tcl

synth_design -rtl -name rtl_1 -top main -part xc7a35ticsg324-1L
show_schematic [get_nets]
