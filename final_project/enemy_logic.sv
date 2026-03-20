// enemy_controller.sv
//
// controls the movement and animation of the enemy array.
// handles side-to-side motion, downward steps, and switches between
// animation frames to create a basic animated effect.
// The output values track both the X (horizontal) and Y (vertical) offset
// of the enemy block on the screen.

module enemy_logic (
    input  logic        frame_tick,         //Vsync signal (used as game clock)
    input  logic        rst_game,           //Active-high reset to start game over
    output logic [7:0]  enemy_anim_frame,   //Which animation frame to use (toggles between 2)
    output logic [9:0]  enemy_pos_y,        //Horizontal offset of the whole enemy block
    output logic [9:0]  frog_y_offset,      //Y offset for top row enemies (if needed)
    output logic [9:0]  jelly_y_offset,     //Y offset for middle row enemies (if needed)
    output logic [9:0]  other_y_offset,     //Y offset for bottom row enemies (if needed)
    output logic [9:0]  enemy_offset_y      //Y offset of the full enemy block
);

    // Used to determine when to flip horizontal direction
    localparam logic [9:0] ALIEN_WIDTH_PX = 10'd16;

    //Internal control signals and counters
    logic [7:0]  counter;           //Used for animation timing
    logic        count_up_offset;  //Direction of horizontal movement
    logic [11:0] subpixel_offset;  //Finer-grain X movement (fractional movement for smooth motion)
    logic [7:0]  frame_counter;    //Controls how often enemies step downward
    logic [9:0]  enemy_y_position; //Y position of the entire enemy block

    //Main logic for movement and animation
    always_ff @ (posedge frame_tick or posedge rst_game) begin
        if (rst_game) begin
            //Reset everything to default values
            count_up_offset   <= 1'b1;       //Start by moving right
            subpixel_offset   <= 12'd0;      //No horizontal offset yet
            counter           <= 8'd0;       //Animation timer
            frame_counter     <= 7'd0;       //Vertical movement timer
            enemy_y_position  <= 10'd32;     //Start a bit down from top
        end
        else begin
            //Increment animation timer
            counter <= counter + 8'd1;
            if (counter >= 8'd120)
                counter <= 8'd0;

            //Move left or right by a small step
            if (count_up_offset)
                subpixel_offset <= subpixel_offset + 12'h001;
            else
                subpixel_offset <= subpixel_offset - 12'h001;

            //If we hit the right edge, reverse direction
            if (subpixel_offset[11:2] >= 10'd16) begin
                //Cap the offset so it doesn't grow out of bounds
                subpixel_offset   <= {10'd16, subpixel_offset[1:0]};
                count_up_offset   <= 1'b0;
            end
            //If we hit the left edge, reverse direction
            else if (subpixel_offset[11:2] == 10'd0) begin
                count_up_offset   <= 1'b1;
            end

            //Vertical stepping every ~90 frames (~1.5s @ 60Hz)
            if (frame_counter == 8'd89) begin
                enemy_y_position <= enemy_y_position + 10'd8; 
                frame_counter    <= 8'd0;
            end
            else begin
                frame_counter    <= frame_counter + 8'd1;
            end
        end
    end

    //Assign horizontal and vertical positions for use in drawing
    assign enemy_pos_y     = subpixel_offset[11:2];       //Pixel-level X position
    assign enemy_offset_y  = enemy_y_position;            //Top Y position of enemy block

    //If using row-based enemies, you can use these separate Y values
    assign frog_y_offset   = enemy_y_position;            //Top row
    assign jelly_y_offset  = enemy_y_position + 10'd32;   //Middle row
    assign other_y_offset  = enemy_y_position + 10'd64;   //Bottom row

    //Simple animation toggle between two frames
    always_comb begin
        if (counter < 8'd50)
            enemy_anim_frame = 8'd8;  
        else
            enemy_anim_frame = 8'd0; 
    end

endmodule
