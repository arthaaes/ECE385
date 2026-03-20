module win_page_map
(
	input logic [7:0] X, Y,
	output logic [7:0] R, G, B
);

    logic [13:0] address;

    always_comb begin
        if (X < 160 && Y < 90)
            address = Y * 160 + X;
		  else 
            address = 160 * 89 + X;
		  end

    win_page_rom rom (
        .address(address),
        .R(R), .G(G), .B(B)
    );
	 



endmodule

module win_page_rom
(
    input logic [13:0] address, //0 to 23039 (160 x 144)
    output logic [7:0] R, G, B
);

    logic [23:0] mem [0:14399]; //24-bit per pixel: R[23:16], G[15:8], B[7:0]

    initial begin
        $readmemh("you_win.txt", mem);  
    end

    assign R = mem[address][23:16];
    assign G = mem[address][15:8];
    assign B = mem[address][7:0];

endmodule