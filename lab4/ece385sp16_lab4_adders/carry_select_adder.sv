module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	 logic C4, C8, C12; // Declare new variables. C4 is the carry-in for the second 4-bit CSA, C2 is the carry-in for the third 4-bit CSA, and C3 is the  carry-in for the fourth 4-bit CSA.
	 
	full_adder_four_bit     FA4B(.a (A[3 : 0]), .b (B[3 : 0]), .cin(1'b0), .sum(Sum[3 : 0]),  .cout(C4)) ;	// use 4-bit full-adder to perform the addition of A[3 : 0] and B[3 : 0]
	carry_select_adder_4bit CSA1(.A4(A[7 : 4]), .B4(B[7 : 4]), .c_in(C4),  .sum(Sum[7 : 4]),  .cout(C8)) ;	// use 4-bit CLA 			to perform the addition of A[7 : 4] and B[7 : 4]
	carry_select_adder_4bit CSA2(.A4(A[11: 8]), .B4(B[11: 8]), .c_in(C8),  .sum(Sum[11: 8]),  .cout(C12));	// use 4-bit CLA 			to perform the addition of A[11: 8] and B[11: 8]
	carry_select_adder_4bit CSA3(.A4(A[15:12]), .B4(B[15:12]), .c_in(C12),  .sum(Sum[15:12]),  .cout(CO));	// use 4-bit CLA 			to perform the addition of A[15:12] and B[15:12]
	 
     
endmodule

module multiplexor(
	input logic L0, L1,
	input logic Y,
	output logic OUT
);										// 2x1 multiplexer

	always_comb
	begin
		if (Y == 1'b1)				// OUT = L1 if the select input Y is high, OUT = L0 otherwise. 
			OUT = L1;
		else           
			OUT = L0;
	end
	
endmodule


module carry_select_adder_4bit(
	input logic [3:0] A4,
	input logic [3:0] B4,
	input logic c_in,
	output logic [3:0] sum,
	output logic cout
 );										// 4-bit CSA
 
	logic [3:0] sum0, sum1;			// Declare the variables. [3:0] sum0 is the sum for carry-in = 0 and [3:0] sum1 is the sum for carry-in = 1.
	logic cout0, cout1;				// Declare the variables. cout0 is the carry-out for carry-in = 0 and cout is the carry-out for carry-in = 1.
	
	full_adder_four_bit FA4B0(.a(A4), .b(B4), .cin(1'b0), .sum(sum0),  .cout(cout0));	// use 4-bit full-adder to perform the addition by assuming carry-in = 0 
	full_adder_four_bit FA4B1(.a(A4), .b(B4), .cin(1'b1), .sum(sum1),  .cout(cout1));	// use 4-bit full-adder to perform the addition by assuming carry-in = 1
	
	// Use 2x1 Multiplexer to choose the final result based on the actual carry-in 
	multiplexor MUX0(.L0(sum0[0]), .L1(sum1[0]), .Y(c_in), .OUT(sum[0]));
	multiplexor MUX1(.L0(sum0[1]), .L1(sum1[1]), .Y(c_in), .OUT(sum[1]));
	multiplexor MUX2(.L0(sum0[2]), .L1(sum1[2]), .Y(c_in), .OUT(sum[2]));
	multiplexor MUX3(.L0(sum0[3]), .L1(sum1[3]), .Y(c_in), .OUT(sum[3]));
	
	multiplexor MUXOUT(.L0(cout0), .L1(cout1), .Y(c_in), .OUT(cout));
 
 
endmodule
