# Incrementally synthesize the project and save reports to out/reports

source ./build_scripts/read_sources.tcl

set out_dir ./out
file mkdir $out_dir

set report_dir ./${out_dir}/reports
file mkdir $report_dir

read_checkpoint -incremental -quiet $out_dir/synthed.dcp

synth_design -top main -name synt_1 -part xc7a35ticsg324-1L
opt_design

write_checkpoint -force $out_dir/synthed.dcp

read_checkpoint -incremental -quiet $out_dir/routed.dcp

place_design
phys_opt_design
route_design

write_checkpoint -force $out_dir/routed.dcp

report_timing_summary -file $report_dir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $report_dir/post_route_timing.rpt
report_clock_utilization -file $report_dir/clock_utilization.rpt
report_utilization -file $report_dir/utilization.rpt
report_incremental_reuse -file $report_dir/incremental_reuse.rpt

write_bitstream -force $out_dir/bitstream.bit
