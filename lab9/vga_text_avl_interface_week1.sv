/************************************************************************
Avalon-MM Interface VGA Text Mode Display - mode display

Modified for DE2-115 board

Register Map:
0x000 - 0x0257 : VRAM, 80x30 (2400 bytes, 600 words) in raster order
0x258          : control register

VRAM Format:
(one 32-bit word holds 4 characters):
[31]   [30:24]  [23]   [22:16]  [15]   [14:8]   [7]    [6:0]  
 IV3    CODE3    IV2    CODE2    IV1    CODE1    IV0    CODE0

IVn   = Inverse bit for character n
CODEn = 7-bit glyph code (IBM codepage 437 subset)

Control Register Format (word #600):
Bits [24:21] = FGD_R, [20:17] = FGD_G, [16:13] = FGD_B
Bits [12:9]  = BKG_R, [8:5]   = BKG_G, [4:1]   = BKG_B

************************************************************************/

`define NUM_REGS 601 	// Total number fo registers (600 VRAM + 1 control)
'define CTRL_REG 600 	// Address of control register

module vga_text_avl_interface (
    input  logic        CLK,		// Clock Input
    input  logic        RESET,		// Reset input
    input  logic        AVL_READ,	// Avalon-MM read enable
    input  logic        AVL_WRITE,	// Avalon-MM write enable
    input  logic        AVL_CS,		// Avalon-MM chip select
    input  logic [3:0]  AVL_BYTE_EN,	// Byte-enable signals (write mask)
    input  logic [9:0]  AVL_ADDR,	// Avalon-MM address (word index)
    input  logic [31:0] AVL_WRITEDATA,	// Data to write
    output logic [31:0] AVL_READDATA,	// Data to read
    output logic [3:0]  red, green, blue,	// VGA COLOR OUTPUS (4-BIT rgb)
    output logic        hs, vs,			// VGA sync signal
    output logic        sync, blank, pixel_clk	// VGA control signs
);

//------------------------------------------------------------------------------
// Local parameters
localparam int VRAM_WORDS = 600;		// Number of VRAM words
localparam int CTRL_ADDR   = VRAM_WORDS;	// Address of control register
localparam int NUM_REGS    = VRAM_WORDS + 1;	// Total number of register

//------------------------------------------------------------------------------
// Internal signals
logic [1:0]    byte_sel;			// Which byte (character) in the word
logic [9:0]    char_addr;			// Address of word in VRAM
logic [6:0]    CODEn;				// Glyph code for current character
logic [9:0]    DrawX, DrawY;			// Current pixel coordinates from VGA controller
logic          IVn;				// Inverse bit for current character
logic [11:0]   num;				// Flattened character index (0-2399)
logic [31:0]   regs [0:NUM_REGS-1];		// Register file (VRAM + control)
logic [31:0]   readdata_reg;			// Latched read data for Avalon-MM read
logic [10:0]   sprite_addr;			// Address into font ROM
logic [7:0]    sprite_data;			// Glyph row data from font ROM
logic [31:0]   word_data;			// The fetched VRAM word

//------------------------------------------------------------------------------
// Submodule instantiations
vga_controller vga_inst (
    .Clk    (CLK),				// Connect clock
    .Reset  (RESET),				// Connect reset
    .*            				// Connect other VGA signals automatically
);

font_rom font_rom_inst (
    .addr (sprite_addr),			// Font ROM address input
    .data (sprite_data)				// Glyph row output
);

//------------------------------------------------------------------------------
// Avalon-MM Write & Read (register file)
always_ff @(posedge CLK) begin
    if (RESET) begin				// On reset, clear all registers and output data
        for (int i = 0; i < NUM_REGS; i++)
            regs[i] <= 32'b0;
        readdata_reg <= 32'b0;
    end else begin				// Handle Avalon write (0-cycle latency)
        if (AVL_CS && AVL_WRITE) begin
            if (AVL_BYTE_EN[0]) regs[AVL_ADDR][ 7: 0] <= AVL_WRITEDATA[ 7: 0];
            if (AVL_BYTE_EN[1]) regs[AVL_ADDR][15: 8] <= AVL_WRITEDATA[15: 8];
            if (AVL_BYTE_EN[2]) regs[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
            if (AVL_BYTE_EN[3]) regs[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
        end					// Handle Avalon read (1-cycle latency)
        if (AVL_CS && AVL_READ) begin
            readdata_reg <= regs[AVL_ADDR];
        end else begin
            readdata_reg <= 32'b0;
        end
    end
end
assign AVL_READDATA = readdata_reg;

//------------------------------------------------------------------------------
// Character lookup and sprite address calculation
always_comb begin				
    num       = DrawY[9:4] * 80 + DrawX[9:3];	// Compute character index from X, Y position
    char_addr = num[11:2];			// Get word-aligned address
    byte_sel  = num[1:0];			// Select which character in word (0-3)
    word_data = regs[char_addr];		// Fetch the 32-bit word from VRAM

// Extract glyph code and inverse bit based on byte_sel
    case (byte_sel)
        2'd0: begin IVn = word_data[7];    CODEn = word_data[6:0];   end
        2'd1: begin IVn = word_data[15];   CODEn = word_data[14:8];  end
        2'd2: begin IVn = word_data[23];   CODEn = word_data[22:16]; end
        2'd3: begin IVn = word_data[31];   CODEn = word_data[30:24]; end
        default: begin IVn = 1'b0; CODEn = 7'd0; end
    endcase

    sprite_addr = {CODEn, DrawY[3:0]};		// Form ROM address from glyph code and row offset
end

//------------------------------------------------------------------------------
// Pixel color generation
always_ff @(posedge CLK) begin
    // Sample sprite bit (MSB first) and invert if needed
    if (sprite_data[7 - DrawX[2:0]] ^ IVn) begin
        // Foreground color
        red   <= regs[CTRL_ADDR][24:21];
        green <= regs[CTRL_ADDR][20:17];
        blue  <= regs[CTRL_ADDR][16:13];
    end else begin
        // Background color
        red   <= regs[CTRL_ADDR][12:9];
        green <= regs[CTRL_ADDR][8:5];
        blue  <= regs[CTRL_ADDR][4:1];
    end
end

endmodule
