//4-bit Logic Processor Top Level Module
//for use with ECE 385 Fall 2016
//last modified by Zuofu Cheng


//Always use input/output logic types when possible, prevents issues with tools that have strict type enforcement

module lab5_toplevel (input logic   Clk,     // Internal
                                Reset,   // Push button 0
                                Run,   // Push button 1
                                ClearA_LoadB,   // Push button 2

                  input  logic [7:0]  S,     // input data

                  output logic [7:0]  	Aval,    // DEBUG
													Bval,    // DEBUG
                  output logic [6:0]   AhexL,
													AhexU,
													BhexL,
													BhexU,
						output logic			X,
						output logic 			B_LSB);

	 //local logic variables go here
	 logic Reset_Sync, LoadB_Sync, Run_Sync;
	 logic [7:0] S_data, A_data,B_data;
	 logic [8:0] sum_result;
	 logic cleara_loadb_enbl, shift_enbl, adds, subs;
	 logic Carry_Out, A_to_B_Shift, rst_A, ClearA_HoldB;
	 
	 assign rst_A = Reset_Sync | LoadB_Sync |ClearA_HoldB;
	 assign B_LSB = B_data[0];
	 assign fn_in = subs & B_LSB;
	 
	 assign Aval = A_data;
	 assign Bval = B_data;
	 assign X = Carry_Out;
	 
	 
 
	 //Instantiation of modules here
	 D_FF			X_unit  (
								.Clk(Clk),
								.Load(adds),
								.Reset(rst_A),
								.D_In(sum_result[8]),
								.Q_Out(Carry_Out)
									);
									
	adds_subs_9bit		adder_unit (
								.A(A_data),
								.B(S_data),
								.mode(fn_in),
								.B_active(B_LSB),
								.Sum(sum_result),
								.CO()								
								);							
																		
									
	 reg_8     reg_unitA (
                        .Clk(Clk),
                        .Reset(rst_A),
                        .Shift_In(Carry_Out), //note these are inferred assignments, because of the existence a logic variable of the same name
                        .Load(adds),
                        .Shift_En(shift_enbl),
                        .D(sum_result[7:0]),
                        .Shift_Out(A_to_B_Shift),
                        .Data_Out(A_data)
								);
	reg_8     reg_unitB (
                        .Clk(Clk),
                        .Reset(Reset_Sync),
                        .Shift_In(A_to_B_Shift), //note these are inferred assignments, because of the existence a logic variable of the same name
                        .Load(LoadB_Sync),
                        .Shift_En(shift_enbl),
                        .D(S_data),
                        .Shift_Out(),
                        .Data_Out(B_data)
								);
							
								
	 control          control_unit (
                        .Clk(Clk),
                        .Reset(Reset_Sync),
                        .Run(Run_Sync),
                        .Shift_En(shift_enbl),
                        .adding(adds),
                        .substract(subs),
								.clear_remainder(ClearA_HoldB));
	
								
	 HexDriver        HexAL (
                        .In0(A_data[3:0]),
                        .Out0(AhexL) );
	 HexDriver        HexBL (
                        .In0(B_data[3:0]),
                        .Out0(BhexL) );
								
	 //When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
	 HexDriver        HexAU (
                        .In0(A_data[7:4]),
                        .Out0(AhexU) );	
	 HexDriver        HexBU (
                       .In0(B_data[7:4]),
                        .Out0(BhexU) );
								
	  //Input synchronizers required for asynchronous inputs (in this case, from the switches)
	  //These are array module instantiations
	  //Note: S stands for SYNCHRONIZED, H stands for active HIGH
	  //Note: We can invert the levels inside the port assignments
	  sync button_sync[2:0] (Clk, {~Reset, ~ClearA_LoadB, ~Run}, {Reset_Sync, LoadB_Sync, Run_Sync});
	  sync Din_sync[7:0] (Clk, S, S_data);

	  
endmodule