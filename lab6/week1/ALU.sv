module ALU( 
		input logic  [15:0] A,B,
		input logic  [1:0]ALUK,
		output logic [15:0] O_ALU
);
	always_comb
	begin
		case(ALUK)
			2'b00: O_ALU=A+B;	// OPERATION ADD
			2'b01: O_ALU=A&B;	// OPERATION AND
			2'b10: O_ALU=~A;	// OPERATION NOT
			2'b11: O_ALU=A;	// OPERATION PASS A	
		endcase
	end

endmodule
