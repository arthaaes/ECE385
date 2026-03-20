module Mux_FOR_BUS (		// For BUS purpose
        input logic [3:0] S,
        input logic [15:0] in0,
		  input logic [15:0] in1,
		  input logic [15:0] in2,
		  input logic [15:0] in3,
        output logic [15:0] OUT
    );
   always_comb
	begin
			case(S)
			4'b0001: OUT=in0;
			4'b0010: OUT=in1;
			4'b0100: OUT=in2;
			4'b1000: OUT=in3;
			default: OUT = 16'h0000;
			endcase
	end
endmodule

module Mux4IN_16B (		// 4x1 mux with 16 bit inputs
        input logic [1:0]S,
        input logic [15:0] in0,
		  input logic [15:0] in1,
		  input logic [15:0] in2,
		  input logic [15:0] in3,
        output logic [15:0] OUT
    );
   always_comb
	begin
			case(S)
			2'b00: OUT=in0;
			2'b01: OUT=in1;
			2'b10: OUT=in2;
			2'b11: OUT=in3;
			endcase
	end
endmodule


module Mux2IN_3B (	// 2x1 mux with 3 bit inputs
        input logic S,
        input logic [2:0] in0,
		  input logic [2:0] in1,
        output logic [2:0] OUT
    );
   always_comb
	begin
			case(S)
			1'b0: OUT=in0;
			1'b1: OUT=in1;
			endcase
	end
endmodule

module Mux2IN_16B (	// 2x1 mux with 16 bits
        input logic S,
        input logic [15:0] in0,
		  input logic [15:0] in1,
        output logic [15:0] OUT
    );
   always_comb
	begin
			case(S)
			1'b0: OUT=in0;
			1'b1: OUT=in1;
			endcase
	end
endmodule








