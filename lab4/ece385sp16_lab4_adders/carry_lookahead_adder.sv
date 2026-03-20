module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	  logic C4, C8, C12;            // Declare new variables. C4 is the carry-in for the second 4-bit CLA, C2 is the carry-in for the third 4-bit CLA, and C3 is the  carry-in for the fourth 4-bit CLA.
	  logic [3:0] P16, G16;
	  
	  CLA4 LA0(.a(A[3 : 0]), .b(B[3 : 0]), .c0(0  ), .sum(Sum[3 : 0]), .PG(P16[0]), .GG(G16[0]));	// use 4-bit CLA to perform the addition of A[3 : 0] and B[3 : 0]
	  CLA4 LA1(.a(A[7 : 4]), .b(B[7 : 4]), .c0(C4 ), .sum(Sum[7 : 4]), .PG(P16[1]), .GG(G16[1]));	// use 4-bit CLA to perform the addition of A[7 : 4] and B[7 : 4]
	  CLA4 LA2(.a(A[11: 8]), .b(B[11: 8]), .c0(C8 ), .sum(Sum[11: 8]), .PG(P16[2]), .GG(G16[2]));	// use 4-bit CLA to perform the addition of A[11: 8] and B[11: 8]
	  CLA4 LA3(.a(A[15:12]), .b(B[15:12]), .c0(C12), .sum(Sum[15:12]), .PG(P16[3]), .GG(G16[3]));	// use 4-bit CLA to perform the addition of A[15:12] and B[15:12]
	  
	  always_comb
	  begin

			C4  = (0 & P16[0])                            |  G16[0];																													// the carry-in for the second 4-bit CLA
			C8  = (0 & P16[0] & P16[1])                   | (G16[0] & P16[1])			           | G16[1];																	// the carry-in for the third 4-bit CLA
			C12 = (0 & P16[0] & P16[1] & P16[2])          | (G16[0] & P16[1] & P16[2])          | G16[1] & P16[2]          | G16[2];							// the carry-in for the fourth 4-bit CLA
			CO  = (0 & P16[0] & P16[1] & P16[2] & P16[3]) | (G16[0] & P16[1] & P16[2] & P16[3]) | G16[1] & P16[2] & P16[3] | G16[2] & P16[3] | G16[3];	// the carry-out of the 4x4-bit CLA
			
			
		
	  end
     
endmodule


module CLA4(
	input logic [3:0] a,
	input logic [3:0] b,
	input c0,
	output logic [3:0] sum,
	output logic PG, GG
);											// 4-bit CLA
	logic [3:0] P;						// declare propagated (P) logic
	logic [3:0] G;						// declare generated (G) logic
	logic c1, c2, c3;					// Declare new variables. c4 is the carry-in for the second full-adder, c2 is the carry-in for the third full-adder, and c3 is the  carry-in for the fourth full-adder.
	
	always_comb
	begin
		G = a & b;				// "generated" logic
		P = a ^ b;				// "propagated" logic
		c1 = (c0 & P[0])               |  G[0];													// the carry-in of the second full-adder
		c2 = (c0 & P[0] & P[1])        | (G[0] & P[1])			| G[1];						// the carry-in of the third full-adder
		c3 = (c0 & P[0] & P[1] & P[2]) | (G[0] & P[1] & P[2]) | G[1] & P[2] | G[2];   // the carry-in of the fourth full-adder
		
		PG = P[0] & P[1] & P[2] & P[3]; 																// group "propagate"
		GG = G[3] | G[2] & P[3] | G[1] & P[3] & P[2] | G[0] & P[3] & P[2] & P[1]; 		// group "generate"
	end
	
	
	full_adder FA0(.x(a[0]), .y(b[0]), .z(c0), .s(sum[0]));	// use full-adder to perform the addition of a[0] and b[0]
	full_adder FA1(.x(a[1]), .y(b[1]), .z(c1), .s(sum[1]));	// use full-adder to perform the addition of a[1] and b[1]
	full_adder FA2(.x(a[2]), .y(b[2]), .z(c2), .s(sum[2]));	// use full-adder to perform the addition of a[2] and b[2]
	full_adder FA3(.x(a[3]), .y(b[3]), .z(c3), .s(sum[3]));	// use full-adder to perform the addition of a[3] and b[3]
	
endmodule