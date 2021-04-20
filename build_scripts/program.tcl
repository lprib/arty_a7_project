# find the device and program out/bitstream.bit

set out_dir ./out
set device_type xc7a35t_0

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
set_property PROGRAM.FILE $out_dir/bitstream.bit [get_hw_devices $device_type]
current_hw_device [get_hw_devices $device_type]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $device_type] 0]
program_hw_devices [get_hw_devices $device_type]
refresh_hw_device [lindex [get_hw_devices $device_type] 0]
