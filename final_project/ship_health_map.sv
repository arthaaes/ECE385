module ship_health_map
(
	input logic [5:0] X,
	input logic [3:0] Y,
	output logic score_pixel_data
);

	logic [15:0] rom_address;
	logic [15:0] text_slice;
	
	assign pixel = text_slice[15 - X[3:0]];

	ship_health_rom text_rom(.address(rom_address), .data(text_slice));
	
	always_comb begin
		
		//Ship
		if(X >= 6'd0 && X < 6'd16) begin
			rom_address = 16'd0 + Y;
		end
		
		//:
		else begin
			rom_address = 16'd15 + Y;
		end
		
	end

endmodule 