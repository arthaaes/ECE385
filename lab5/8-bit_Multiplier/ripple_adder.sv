module adds_subs_9bit
(
    input   logic[7:0]     A,
    input   logic[7:0]     B,
	 input						mode,
	 input						B_active,
    output  logic[8:0]     Sum,
    output  logic           CO
);


	  logic C1,C2;
	  logic A_MSB,B_Mod_MSB;
	  logic [7:0] B_Mod;
	  
	  always_comb
	  begin
			case(B_active)
				1'b0:	B_Mod = 8'b0;
				1'b1: B_Mod = (B ^ {8{mode}});
				default: B_Mod = 8'b0;
			endcase
	  end
	  
		assign B_Mod_MSB = B_Mod[7];
		assign A_MSB = A[7];
		
		full_adder_four_bit 	  FA0(.a(A[3:0]), .b(B_Mod[3:0]), .cin(mode), .sum(Sum[3:0]), .cout(C1)) ;
		full_adder_four_bit 	  FA1(.a(A[7:4]), .b(B_Mod[7:4]), .cin(C1),   .sum(Sum[7:4]), .cout(C2)) ;
		full_adder	 			  FA3(.x(A_MSB),     .y(B_Mod_MSB),     .z(C2),      .s(Sum[8]),   .c());
endmodule


module full_adder (
	input logic x , y, z,
	output logic s, c
	);										// 1-bit full adder
	
	assign s = x^y^z;					// sum
	assign c = (x&y)|(y&z)|(x&z);	// carry-out
	
endmodule


module full_adder_four_bit (		// 4-bit full adder
	input logic [3:0] a, b,
	input logic cin,
	output logic [3:0] sum,
	output logic cout
);


	logic c1,c2,c3; // Declare new variables. c1 is the  carry-in for the second 1-bit full adder, c2 is the  carry-in for the third 1-bit full adder, and c3 is the  carry-in for the fourth 1-bit full adder.
	
	full_adder FA0(.x(a[0]), .y(b[0]), .z(cin), .s(sum[0]), .c(c1));		// use 1-bit full adder to perform the addition of a[0] and b[0]
	full_adder FA1(.x(a[1]), .y(b[1]), .z(c1 ), .s(sum[1]), .c(c2));		// use 1-bit full adder to perform the addition of a[1] and B[1]
	full_adder FA2(.x(a[2]), .y(b[2]), .z(c2 ), .s(sum[2]), .c(c3));		// use 1-bit full adder to perform the addition of a[2] and B[2]
	full_adder FA3(.x(a[3]), .y(b[3]), .z(c3 ), .s(sum[3]), .c(cout));	// use 1-bit full adder to perform the addition of a[3] and B[3]
	
	
endmodule
		
		
		
		
		
		
		
		
		
		
		
		
		