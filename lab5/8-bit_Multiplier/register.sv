module reg_8 (input  logic Clk, Reset, Shift_In, Load, Shift_En,
              input  logic [7:0]  D,
              output logic Shift_Out,
              output logic [7:0]  Data_Out);

    always_ff @ (posedge Clk) begin
	 	 if (Reset) //Synchronous reset
			  Data_Out <= 8'h0;
		 else if (Load)
			  Data_Out <= D;
		 else if (Shift_En) begin //shift operation
			  //shift left by 1 bit, and shift in the new value at the (LSB) Least Significant Bit
			  Data_Out <= { Shift_In, Data_Out[7:1] }; 
	    end
    end
	
    assign Shift_Out = Data_Out[0];

endmodule


module D_FF 
(
	input		Clk, Load, Reset, D_In,
	output	logic Q_Out
);

	// Basically D flip-flop with synchronous reset
	always_ff @ (posedge Clk)
	begin
			if (Reset)
				Q_Out <= 1'b0;
			else
				if (Load)
					Q_Out<=D_In;
				else
					Q_Out <= Q_Out;
	end 
endmodule






