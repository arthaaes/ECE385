module alien_map
(
	input logic [5:0] X,
	input logic [3:0] Y,
	output logic pixel
);

	logic [15:0] rom_address;
	logic [15:0] text_slice;
	
	assign pixel = text_slice[15 - X[3:0]];

	alien_rom text_rom(.address(rom_address), .data(text_slice));


	always_comb begin
	
		//empty
		if(X >= 6'd0 && X < 6'd16) begin
			rom_address = 16'd0 + Y;
		end
	
		//Alien
		else if(X >= 6'd16 && X < 6'd32) begin
			rom_address = 16'd15 + Y;
		end
		
		//:
		else begin
			rom_address = 16'd31 + Y;
		end
	
	end
	
endmodule 