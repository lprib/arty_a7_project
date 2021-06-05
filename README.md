## TODO
* generalize ghdl_sim

## Build system
`./build <name>` will run `build_scripts/<name>.tcl` in vivado TCL batch mode.

Available TCL build scripts:
* `check` - check syntax
* `rtl` - perform an RTL synthesis and show the RTL shematic in vivado UI
* `synth` - synthesize the design to a bitstream and write relevent reports to `out/reports`
* `program` - program the synthesized bitstream to the device
* `synth_program` - same as running `synth` and then `program`
* `synth_schematic` - synthesize and then show the synthesized device schematic. If you want a synthesized RTL view, run `show_schematic [get_nets]` in the Vivado GUI TCL Console
* `read_sources` - not useful on it's own, loads all vhd files from `src` and loads the XDC contraints file

Other scripts:
* `./ghdl_check` - analyise all VHDL files in source with GHDL to do a fast syntax check. May need to run multiple times since dependency order is not respected.