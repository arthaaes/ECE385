module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	  logic C1, C2, C3;       // Declare new variables. C1 is the  carry-in for the second 4-bit full adder, C2 is the  carry-in for the third 4-bit full adder, and C3 is the  carry-in for the fourth 4-bit full adder.
	  full_adder_four_bit FA4B0(.a(A[3 : 0]), .b(B[3 : 0]), .cin(0 ), .sum(Sum[3  :0]),  .cout(C1));   // use 4-bit full adder to perform the addition of A[3 : 0] and B[3 : 0]
	  full_adder_four_bit FA4B1(.a(A[7 : 4]), .b(B[7 : 4]), .cin(C1), .sum(Sum[7  :4]),  .cout(C2));	// use 4-bit full adder to perform the addition of A[7 : 4] and B[7 : 4]
	  full_adder_four_bit FA4B2(.a(A[11: 8]), .b(B[11: 8]), .cin(C2), .sum(Sum[11 :8]),  .cout(C3));	// use 4-bit full adder to perform the addition of A[11: 8] and B[11: 8]
	  full_adder_four_bit FA4B3(.a(A[15:12]), .b(B[15:12]), .cin(C3), .sum(Sum[15 :12]), .cout(C0));	// use 4-bit full adder to perform the addition of A[15:12] and B[15:12]
	 
	  
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
     

