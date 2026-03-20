// score_tracker.sv
//
// score system for the game.
// tracks when an enemy (or mystery ship) gets hit, and updates the score accordingly.
// Points are based on the row of the enemy:
//   - Top row = +3
//   - Middle row = +2
//   - Bottom row = +1
//   - Mystery = +20

module score_tracker (
    input  logic        frame_tick,            //Clock signal for updating each frame (vsync)
    input  logic        rst_game,              //Reset signal to start from 0
    input  logic [5:0]  X,                     //Pixel X coordinate (used for display)
    input  logic [3:0]  Y,                     //Pixel Y coordinate (used for display)
    input  logic        enemy_collision_flags, //Pulse that goes high when enemy is hit
    input  logic [2:0]  enemy_row,             //Row of enemy that was hit (0=top, 2=bottom)
    input  logic        mystery_hit,           //Goes high when mystery ship is hit
    output logic        score_pixel_data       //Output pixel data for score digits (used in VGA)
);

    //Score is stored as 3 separate digits: hundreds, tens, and ones
    logic [3:0] score_hundreds;
    logic [3:0] score_tens;
    logic [3:0] score_ones;

    //One-shot edge detection for enemy collision pulse
    logic col_sync_0, col_sync_1;
    logic col_edge;

    always_ff @(posedge frame_tick or posedge rst_game) begin
        if (rst_game) begin
            //Reset the synchronizer and edge detector
            col_sync_0 <= 1'b0;
            col_sync_1 <= 1'b0;
            col_edge   <= 1'b0;
        end else begin
            //Sync the input and detect rising edge
            col_sync_0 <= enemy_collision_flags;
            col_sync_1 <= col_sync_0;
            col_edge   <=  col_sync_0 & ~col_sync_1;
        end
    end

    //Temporary math registers for scoring updates
    logic [3:0] delta;           
    logic [4:0] sum_ones;       
    logic [4:0] sum_tens;
    logic [4:0] sum_hundreds;

    //ROM interface for digit display (each number is stored as pixel rows)
    logic [7:0] number_slice;    
    logic [7:0] number_address; 
    digit_rom rom_instance (
        .address(number_address),
        .data(number_slice)
    );

    //Output a single bit of pixel data for current X/Y (used in VGA display)
    assign score_pixel_data = number_slice[3'b111 - X[2:0]];

    //Score updating logic
    always_ff @(posedge frame_tick or posedge rst_game) begin
        if (rst_game) begin
            // Start score at 000
            score_hundreds <= 4'd0;
            score_tens     <= 4'd0;
            score_ones     <= 4'd0;
        end else if (col_edge || mystery_hit) begin
            // Decide how many points to add
            if (mystery_hit)
                delta = 4'd10; // Mystery ship gives +10
            else
                delta = (enemy_row == 3'd0) ? 4'd3 :  
                        (enemy_row == 3'd1) ? 4'd2 :  
                        (enemy_row == 3'd2) ? 4'd1 : 
                        4'd0;

            // Add delta to score, handling carry between digits
            sum_ones     = score_ones     + delta;
            sum_tens     = score_tens     + (sum_ones >= 5'd10 ? 5'd1 : 5'd0);
            sum_hundreds = score_hundreds + (sum_tens >= 5'd10 ? 5'd1 : 5'd0);

            // Wrap each digit to stay within 0–9
            score_ones     <= sum_ones[3:0]     - (sum_ones >= 5'd10 ? 4'd10 : 4'd0);
            score_tens     <= sum_tens[3:0]     - (sum_tens >= 5'd10 ? 4'd10 : 4'd0);
            score_hundreds <= (sum_hundreds >= 5'd10) ? 4'd0 : sum_hundreds[3:0];
        end
    end

    // --- Digit rendering logic ---
    //This selects which digit to draw (hundreds, tens, or ones)
    //based on X pixel position, and picks the correct row using Y
    always_comb begin
        if (X < 6'd8) begin
            //Show hundreds digit
            number_address = {score_hundreds, 4'b0} + Y;
        end else if (X < 6'd16) begin
            //Show tens digit
            number_address = {score_tens, 4'b0} + Y;
        end else begin
            //Show ones digit
            number_address = {score_ones, 4'b0} + Y;
        end
    end

endmodule
