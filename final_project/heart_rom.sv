module heart_rom
(
	input 	[7:0] addr,
	output 	[7:0] data
); 

	parameter[0:7][7:0] ROM = {
	
		8'b00000000,	//0         
		8'b01000100,	//1  █   █
		8'b11101110,	//2 ███ ███   
		8'b11111110,	//3 ███████
		8'b11111110,	//4 ███████
		8'b01111100,	//5  █████
		8'b00111000,	//6   ███
		8'b00010000 	//7    █
	
	};
	
	assign data = ROM[addr];

endmodule 