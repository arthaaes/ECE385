module datapath(
	input logic Clk, Reset,
	input logic GateMARMUX, GateMDR, GatePC, GateALU,
	input logic [1:0] PCMUX, ALUK, ADDR2MUX,
	input logic LD_LED, LD_MDR, LD_IR, LD_CC, LD_MAR, LD_BEN, LD_REG, LD_PC,
	input logic SR1MUX, SR2MUX, ADDR1MUX, DRMUX, 
	input logic [15:0]MDR_In,
	input logic MIO_EN,
	output logic BEN,
	output logic [11:0]LED,
	output logic [15:0]IR, MAR, MDR, PC
);

	logic [2:0] SR1, DR_Input, new_NZP, NZP;
	logic new_BEN;
	logic [15:0] input_PC, bus,input_MAR,ADDR_SUM,MDR_NEXT,MDR_DATA, O_SR1,O_SR2,RESULT_ALU, ALU_operandB, SEXT5, SEXT6, SEXT9,SEXT11,PC_next, ADDR_OFFSET, ADDR_BASE;
	
	// REGISTERS:
	register_16B MDR_reg(.*,.Load(LD_MDR),.Data_in(MDR_NEXT),.Data_out(MDR));
	register_16B MAR_reg(.*,.Load(LD_MAR),.Data_in(bus),.Data_out(MAR));
	register_16B PC_reg(.*,.Load(LD_PC),.Data_in(input_PC),.Data_out(PC));
	register_16B IR_reg(.*,.Load(LD_IR),.Data_in(bus),.Data_out(IR));
	register_12B LED_reg(.*,.Load(LD_LED),.Data_in(IR[11:0]),.Data_out(LED));
	register_3B NZP_reg(.*,.Load(LD_CC),.Data_in(new_NZP),.Data_out(NZP));
	register_1B BEN_reg(.*,.Load(LD_BEN),.Data_in(new_BEN),.Data_out(BEN));
	
	//REGISTER FILE
	register_file REGISTER(.Clk (Clk),.Reset(Reset),.LD_REG(LD_REG ),.input_DR(DR_Input),.SR2(IR[2:0]),.SR1(SR1),.INPUT_BUS (bus),.O_SR1(O_SR1),.O_SR2(O_SR2));
	
	// SEXT
	SEXT u_SEXT(.IR(IR),.SEXT11(SEXT11),.SEXT9(SEXT9),.SEXT6(SEXT6),.SEXT5(SEXT5));
	
	//MULTIPLEXERS
	Mux4IN_16B PC_mux	(.S(PCMUX),	.in0(PC_next),.in1(bus),	.in2(ADDR_SUM),	.in3(16'h0000),.OUT(input_PC));
	Mux2IN_16B MDR_mux(.S(MIO_EN),.in0(bus),	  .in1(MDR_In),.OUT(MDR_NEXT)); 
	Mux_FOR_BUS  bus_mux(.S({GatePC, GateMDR, GateALU, GateMARMUX}),.in0(ADDR_SUM),.in1(RESULT_ALU),.in2(MDR),.in3(PC),.OUT(bus));
	Mux4IN_16B ADDR2_Mux(.S(ADDR2MUX), .in0(16'h0000),.in1(SEXT6),.in2(SEXT9),.in3(SEXT11),.OUT(ADDR_OFFSET));
	Mux2IN_16B ADDR1_Mux(.S(ADDR1MUX),.in0(PC),.in1(O_SR1),.OUT(ADDR_BASE));
	Mux2IN_16B SR2_Mux(.S( SR2MUX),.in0(O_SR2),.in1(SEXT5),.OUT(ALU_operandB));
	Mux2IN_3B Mux_SR1(.S (SR1MUX),.in0(IR[11:9]),.in1(IR[8:6]),.OUT(SR1));
	Mux2IN_3B Mux_DR(.S(DRMUX),.in0(IR[11:9]),.in1(3'b111),.OUT(DR_Input));
	
	// ALU
	ALU u_ALU(.A(O_SR1),.B(ALU_operandB),.ALUK(ALUK),.O_ALU(RESULT_ALU));
	
	
	always_comb
	begin	 
		ADDR_SUM=ADDR_BASE + ADDR_OFFSET;
		PC_next=PC+1;
		if(bus == 16'h0000)
			new_NZP = 3'b010;
		else if(bus[15] == 1'b1)
			new_NZP = 3'b100;
		else
			new_NZP = 3'b001;
		new_BEN = (IR[11]&NZP[2])+(IR[10]&NZP[1])+(IR[9]&NZP[0]);
	end
	
endmodule