// Sign-extension unit for 5,6,9,11-bit fields

module SEXT
(
    input logic [15:0] IR,  // Input instruction
	output logic [15:0] SEXT5, SEXT6, SEXT9, SEXT11 //sign-extended
);
	always_comb 
		begin
			if (IR[4]) // 5-bit field sign extension
				SEXT5 = {11'b11111111111,IR[4:0]};
			else 
				SEXT5 = {11'b00000000000,IR[4:0]};
				
			if (IR[5]) // 6-bit field sign extension
				SEXT6 = {10'b1111111111,IR[5:0]};
			else 
				SEXT6 = {10'b0000000000,IR[5:0]};
				
			if (IR[8]) // 9-bit field sign extension
				SEXT9 = {7'b1111111,IR[8:0]};
			else 
				SEXT9 = {7'b0000000,IR[8:0]};
				
			if (IR[10]) // 11-bit field sign extension
				SEXT11 = {5'b11111,IR[10:0]};
			else 
				SEXT11 = {5'b00000,IR[10:0]};
	
	
		end
endmodule