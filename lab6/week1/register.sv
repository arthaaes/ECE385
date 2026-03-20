module register_1B // 1-bit register with async reset
(
    input logic Clk, Reset, Load,
    input logic Data_in,
    output logic Data_out
);
	always_ff @ (posedge Clk) begin
		if (~Reset) 
        Data_out <= 1'b0; // Reset clears register
		else if (Load)
        Data_out <= Data_in;  // Load new value when enabled
	end
endmodule

module register_3B // 3-bit register with async reset
(
    input logic Clk, Reset, Load,
    input logic [2:0] Data_in,
    output logic [2:0] Data_out
);
	always_ff @ (posedge Clk) begin
		if (~Reset) 
        Data_out <= 3'b0;  // Reset clears register
		else if (Load)
        Data_out <= Data_in[2:0]; // Load new value when enabled
	end
endmodule

module register_12B // 12-bit register with async reset
(
    input logic Clk, Reset, Load,
    input logic[11:0] Data_in,
    output logic[11:0] Data_out
);
	always_ff @ (posedge Clk) begin
		if (~Reset) 
        Data_out <= 12'b0; // Reset clears register
		else if (Load)
        Data_out <= Data_in[11:0];  // Load new value when enabled
	end
endmodule

module register_16B // 16-bit register with async reset
(
    input logic Clk, Reset, Load,
    input logic [15:0] Data_in,
    output logic [15:0] Data_out
);
	always_ff @ (posedge Clk) begin
		if (~Reset) 
        Data_out <= 16'h0;  // Reset clears register
		else if (Load)
        Data_out <= Data_in[15:0];  // Load new value when enabled
	end
endmodule



