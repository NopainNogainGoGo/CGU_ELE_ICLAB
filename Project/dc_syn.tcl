read_verilog CORDIC_fixedpoint.v 
current_design cordic_fixedpoint

link

source -echo -verbose CORDIC.sdc

#Synthesis 
compile -map_effort high -area_effort high

write -format ddc     -hierarchy -output "CORDIC_syn.ddc"
write_sdf CORDIC_syn.sdf 
write_file -format verilog -hierarchy -output CORDIC_syn.v
report_area > CORDIC_area.log
report_timing > CORDIC_timing.log
report_qor   >  CORDIC_syn.qor

