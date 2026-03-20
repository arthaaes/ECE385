transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/ALU.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/ISDU.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/Mem2IO.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/MUX.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/reg_file.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/register.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/SEXT.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/SLC3_2.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/test_memory.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/tristate.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/datapath.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/memory_contents.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/slc3.sv}
vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/lab6_toplevel.sv}

vlog -sv -work work +incdir+C:/Users/artha/OneDrive/Documents/Lecture/Year\ 2025\ Spring\ Semester/LAB6WEEK1_TEAM44 {C:/Users/artha/OneDrive/Documents/Lecture/Year 2025 Spring Semester/LAB6WEEK1_TEAM44/testbench_week1.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench_week1

add wave *
view structure
view signals
run -all
