/************************************************************************
Avalon-MM Interface VGA Text mode display

Modified for DE2-115 board

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
// `define NUM_REGS 601 //80*30 characters / 4 characters per register
// `define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,				// Avalon-MM Read
	input  logic AVL_WRITE,				// Avalon-MM Write
	input  logic AVL_CS,				// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,		// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,				// VGA HS/VS
	output logic sync, blank, pixel_clk		// Required by DE2-115 video encoder
);

// logic [31:0] LOCAL_REG       [`NUM_REGS]; 		// Registers
//put other local variables here
logic [11:0] address_b;					// Address to VRAM
logic [6:0] CODEn;					// Character glyph code
logic [9:0] DrawX, DrawY;				// Current pixel position from VGA controller
logic [3:0] FGD_IDXn, BKG_IDXn;				// Foreground/background palette indices
logic IVn;						// Invert glyph flag
logic [11:0] num;					// Character index in screen (0–2399)
logic [10:0] sprite_addr;				// Address to fetch row of font sprite
logic [7:0] sprite_data;				// 8-pixel-wide sprite row data
logic [31:0] q_a, q_b;					// Dual-port memory read data
logic [31:0] Palette [8];				// 8-entry color palette memory

//Declare submodules..e.g. VGA controller, ROMS, etc

vga_controller vga_controller_instance(
    .Clk(CLK),
    .Reset(RESET),
    .*
);

font_rom font_rom_instance(.addr(sprite_addr), .data(sprite_data));	// ROM that stores character sprites (8x16 bitmap per character)

dualport on_chip_memory(				// Dual-port RAM to store characters and attributes
	.address_a(AVL_ADDR),				// Port A is Avalon-MM interface
	.address_b(address_b),				// Port B is for VGA renderer
	.byteena_a(AVL_BYTE_EN),			// Byte enables for writes
	.clock(CLK),					// clock
	.data_a(AVL_WRITEDATA),				// Write data from host
	.data_b(32'b0),					// Unused data input for Port B
	.rden_a(AVL_READ),				// Read enable for Port A
	.rden_b(1'b1),					// Always read for Port B
	.wren_a(AVL_WRITE & AVL_CS),			// Write when both write and chip select are asserted
	.wren_b(1'b0),					// Port B is read-only
	.q_a(q_a),					// Port A output (for Avalon read)
	.q_b(q_b)					// Port B output (used for VGA display)
);

// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff


always_ff @(posedge CLK) begin
	if (AVL_WRITE && AVL_CS)  begin			// If address MSB is 1, write to Palette memory
		if (AVL_ADDR[11])
			Palette[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
	end

	
	AVL_READDATA <= 32'b0;				// Default read value is 0
	if(AVL_READ)					// On read, check if reading Palette or character memory
		if(AVL_ADDR[11])			// Read from palette
		begin
			AVL_READDATA <= Palette[AVL_ADDR[2:0]];
		end else
		begin
			AVL_READDATA <= q_a;		// Read from character VRAM
		end
end


//handle drawing (may either be combinational or sequential - or both).

always_comb
begin
	num = DrawY[9:4] * 80 + DrawX[9:3];		// Get character index (row*80 + col)
	address_b = {1'b0, num[11:1]};			// Form memory address (2 characters per word)
end

always_comb						// Glyph decoding (pulls out correct character, inversion bit, and color index)
begin
	case(num[0])
		1'b0:
		begin
			IVn = q_b[15];		// Invert bit for char 0
			CODEn = q_b[14:8];	// Glyph code for char 0
			FGD_IDXn = q_b[7:4];	// Foreground palette index for char 0
			BKG_IDXn = q_b[3:0];	// Background palette index for char 0
		end
		1'b1:
		begin
			IVn = q_b[31];		// Invert bit for char 1
			CODEn = q_b[30:24];	// Glyph code for char 1
			FGD_IDXn = q_b[23:20];	// Foreground palette index for char 1
			BKG_IDXn = q_b[19:16];	// Background palette index for char 1
		end
		default: ;
	endcase
	sprite_addr = {CODEn, DrawY[3:0]};	// Address to fetch specific row from glyph
end

always_ff @(posedge CLK)			// Set color outputs based on sprite pixel and inverse bit
begin
	if(sprite_data[3'b111 - DrawX[2:0]] ^ IVn) begin
		// Foreground pixel
		case(FGD_IDXn[0])
			1'b0: begin		// Lower color of palette entry
				red <= Palette[FGD_IDXn[3:1]][12:9];
				green <= Palette[FGD_IDXn[3:1]][8:5];
				blue <= Palette[FGD_IDXn[3:1]][4:1];
			end
			1'b1: begin		// Upper color of palette entry
				red <= Palette[FGD_IDXn[3:1]][24:21];
				green <= Palette[FGD_IDXn[3:1]][20:17];
				blue <= Palette[FGD_IDXn[3:1]][16:13];
			end
			default: ;
		endcase
	end else
	begin
		// background pixel
		case(BKG_IDXn[0])
			1'b0: begin		// Lower color
				red <= Palette[BKG_IDXn[3:1]][12:9];
				green <= Palette[BKG_IDXn[3:1]][8:5];
				blue <= Palette[BKG_IDXn[3:1]][4:1];
			end
			1'b1: begin		// Upper color
				red <= Palette[BKG_IDXn[3:1]][24:21];
				green <= Palette[BKG_IDXn[3:1]][20:17];
				blue <= Palette[BKG_IDXn[3:1]][16:13];
			end
			default: ;
		endcase
	end
end

endmodule