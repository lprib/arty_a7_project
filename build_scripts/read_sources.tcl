# Read all src/vhdl files and the xdc constraints file

read_vhdl [glob ./src/*.vhd ]
# files specific to artix 7
read_vhdl [glob ./src/platform_specific/artix7/*.vhd ]
read_xdc ./arty_a7_35.xdc
