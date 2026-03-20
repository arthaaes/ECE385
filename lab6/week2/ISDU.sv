//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_CE,
									Mem_UB,
									Mem_LB,
									Mem_OE,
									Mem_WE
				);

	enum logic [4:0] {  	Halted, 
								PauseIR1, 
								PauseIR2, 
								S_18, 		// start
								S_33_1, 		// mdr <- m
								S_33_2, 		// mdr <- m
								S_33_3,		// state 3 -> sync
								S_35, 		// ir <- mdr
								S_32, 		// ben <- nzp & ir[11:9]
								S_00, 		// br1
								S_01,			// add
								S_04,			// jsr1: r7 <- pc
								S_05,			// and
								S_06,			// ldr1: mar <- baser + off6
								S_07,			// str1: mar <- baser + off6
								S_09,			// not
								S_12,			// jmp: pc <- baser
								S_16_1,		// str3.1: m[mar] <- mdr
								S_16_2,		// str3.2: m[mar] <- mdr
								S_20,			// jsr2.2: PC <- baser
								S_21,			// jsr2.1: pc <- pc + off11
								S_22,			// br2: pc <- pc + off9
								S_23,			// str2: mdr <- sr
								S_25_1,		// ldr2.1: mdr <- m[mar]
								S_25_2,		// ldr2.2: mdr <- m[mar]
								S_25_3, 		// 
								S_27			// ldr3: dr <- mdr		
							}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b1;
		Mem_WE = 1'b1;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states invloving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_2;
			S_33_2 : 
				Next_state = S_33_3;
			S_33_3 :
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;
			// PuseIR1 and PauseIR2 are only for Week 1 such that TA can see
			// the values in IR
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			
			
			S_32 : 
				case (Opcode)
					4'b0000 :
						Next_state = S_00; // br
					4'b0001 : 
						Next_state = S_01; // add
					4'b0100 :
						Next_state = S_04; // jsr
					4'b0101 :
						Next_state = S_05; // and
					4'b0110 :
						Next_state = S_06; // ldr
					4'b0111 :
						Next_state = S_07; // str
					4'b1001 :
						Next_state = S_09; // not
					4'b1100 :
						Next_state = S_12; // jmp
					4'b1101 :
						Next_state = PauseIR1; // Pause
					
					// You need to finish the rest of opcodes.....
					
					default : 
						Next_state = S_18;
						
				endcase
				
			S_00 : // br1
				if (BEN)
					Next_state = S_22;
				else
					Next_state = S_18;
			S_01 : // add
				Next_state = S_18; 
			S_04 : // jsr1
				if (IR_11)
					Next_state = S_21;
				else
					Next_state = S_20;
			S_05 : // and
				Next_state = S_18;
			S_06 : // ldr1
				Next_state = S_25_1;
			S_07: // str1
				Next_state = S_23;
			S_09 : // not
				Next_state = S_18;
			S_12 : // jmp
				Next_state = S_18;
			S_16_1: // str3.1
				Next_state = S_16_2;
			S_16_2: // str3.2
				Next_state = S_18;
			S_20 : // jsr2.2
				Next_state = S_18;
			S_21 : // jsr2.1
				Next_state = S_18;
			S_22 : // br2
				Next_state = S_18;		
			S_23: // str2
				Next_state = S_16_1;
			S_25_1: // ldr2.1
				Next_state = S_25_2;
			S_25_2: // ldr2.2
				Next_state = S_25_3;
			S_25_3: // ldr sync
				Next_state = S_27;
			S_27: // ldr3
				Next_state = S_18;
			
			//You need to finish the rest of the states.....
			
			default : ;

		endcase
		
		// Assign control signals based on current state
		case (State)
			// Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;
				end
			S_33_1 : 
				Mem_OE = 1'b0;
			S_33_2 : 
				begin 
					Mem_OE = 1'b0;
					// LD_MDR = 1'b1;
				end
			S_33_3 :
				begin
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			PauseIR1:
				begin
					LD_LED = 1'b1;
				end 
			PauseIR2:
				begin
					LD_LED = 1'b1;
				end

			S_32 : 
				LD_BEN = 1'b1;
				
			S_00 : ; // BR1
			
			S_01 :  // ADD: DR <- SR1 + OP2
				begin 
					SR2MUX = IR_5;	
					DRMUX = 1'b1; 
					SR1MUX = 1'b1; 
					ALUK = 2'b00;
					GateALU = 1'b1;
					LD_REG = 1'b1;
               LD_CC = 1'b1;
				end
				
			S_04 : // JSR1: R7 <- PC
				begin
					DRMUX = 1'b0;
					GatePC = 1'b1;
					LD_REG = 1'b1;
				end
			
			S_05 : // AND: DR <- SR1 & OP2
				begin
					SR2MUX = IR_5;
					DRMUX = 1'b1; 	
					SR1MUX = 1'b1;
					ALUK = 2'b01;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
				
			S_06 : // LDR1: MAR <- BaseR + off6
				begin
					SR1MUX = 1'b1;
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b10;	
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end
			
			S_07 : // STR1: MAR <- BaseR + off6
				begin
					SR1MUX = 1'b1;	
					ADDR1MUX = 1'b0;	
					ADDR2MUX = 2'b10;
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end

			S_09 : // NOT: DR <- NOT(SR)
				begin
					DRMUX = 1'b1;
					SR1MUX = 1'b1;
					ALUK = 2'b10;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
				
			S_12 : // JMP: PC <- BaseR
				begin
					SR1MUX = 1'b1;	
					ADDR1MUX = 1'b0;	
					ADDR2MUX = 2'b11;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
				
			S_16_1: // M[MAR] <- MDR
				begin
					Mem_WE = 1'b0;
				end
			S_16_2: // M[MAR] <- MDR
				begin
					Mem_WE = 1'b0;
					// incomplete...
				end
			
			S_20 : ;
			
			S_21 : // JSR2.1: PC <- PC + off11
				begin
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b00;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
			
			S_22 : // BR2: PC <- PC + off9	
				begin
					ADDR1MUX = 1'b1; 
					ADDR2MUX = 2'b01;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
			
			S_23 : // STR2: MDR <- SR
				begin
					SR1MUX = 1'b0;
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b11;
					GateMARMUX = 1'b1;
					LD_MDR = 1'b1;
				end
				
			S_25_1: // LDR2.1: MDR <- M[MAR]
				begin
					Mem_OE = 1'b0;
				end
			S_25_2: // LDR2.2: MDR <= M[MAR]
				begin
					Mem_OE = 1'b0;
				end
			S_25_3:
				begin
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
			S_27 : // LDR3: DR <- MDR
				begin
					DRMUX = 1'b1;	
					GateMDR = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
			
			// You need to finish the rest of states.....

			default : ;
		endcase
	end 

	 // These should always be active
	assign Mem_CE = 1'b0;
	assign Mem_UB = 1'b0;
	assign Mem_LB = 1'b0;
	
endmodule
