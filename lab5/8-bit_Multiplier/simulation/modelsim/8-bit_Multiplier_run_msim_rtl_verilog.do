transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/ECE\ 385/Lab/8-bit_Multiplier {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/ECE 385/Lab/8-bit_Multiplier/control.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/ECE\ 385/Lab/8-bit_Multiplier {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/ECE 385/Lab/8-bit_Multiplier/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/ECE\ 385/Lab/8-bit_Multiplier {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/ECE 385/Lab/8-bit_Multiplier/register.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/ECE\ 385/Lab/8-bit_Multiplier {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/ECE 385/Lab/8-bit_Multiplier/Synchronizers.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/ECE\ 385/Lab/8-bit_Multiplier {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/ECE 385/Lab/8-bit_Multiplier/ripple_adder.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/ECE\ 385/Lab/8-bit_Multiplier {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/ECE 385/Lab/8-bit_Multiplier/lab5_toplevel.sv}

vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/ECE\ 385/Lab/8-bit_Multiplier {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/ECE 385/Lab/8-bit_Multiplier/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
