// enemy_missile_ctrl.sv
//
// the closest enemy column to the left edge of the player's ship will
// fire a missile—if it hasn't already. The missile is spawned from the
// lowest active enemy in that column and moves downward until it either
// hits something or leaves the screen.

module enemy_missile_ctrl (
    input  logic             rst_game,           //Reset signal for starting a new game
    input  logic [9:0]       player_pos_x,       //Player's X coordinate (left side of the ship)
    input  logic [9:0][2:0]  enemy_active_flags, //Which enemies are still alive (10 columns × 3 rows)
    input  logic             frame_tick,         //Vsync signal — update once per frame
    input  logic [9:0]       enemy_pos_y,        //Offset for where the enemy block starts (horizontal)
    input  logic [3:0]       curr_state,         //Current game state (we only spawn missiles during gameplay)
    input  logic [9:0]       enemy_offset_y,     //Vertical offset of enemy block (it moves down slowly)

    output logic             missile_active,     //Is the enemy missile currently on screen?
    output logic [9:0]       enemy_missile_x,    //Current X position of the missile
    output logic [9:0]       enemy_missile_y     //Current Y position of the missile
);

    logic [7:0] missile_timer;   //Timer to control how often enemies can shoot (every 120 frames)
    logic [2:0] enemy_column;    //Row-wise status of enemies in the selected column (3 bits)
    logic [3:0] column_index;    //Column index closest to the player

    //Runs every frame tick or when the game resets
    always_ff @ (posedge frame_tick or posedge rst_game) begin
        if (rst_game) begin
            //On reset, clear everything
            missile_timer   = 8'd0;
            missile_active  = 1'b0;
        end
        else if (curr_state != 4'd1) begin
            //Only run missile logic during actual gameplay (state == 1)
            missile_timer   = 8'd0;
            missile_active  = 1'b0;
        end
        else begin
            //Hold current X
            enemy_missile_x = enemy_missile_x;

            //Wait 2 seconds before allowing another missile
            if (missile_timer < 8'd120 && !missile_active) begin
                missile_timer = missile_timer + 8'd1;
            end
            //Time to fire a missile!
            else if (!missile_active && missile_timer >= 8'd120) begin
                //Determine X position of the missile based on column and enemy block offset
                enemy_missile_x = {column_index, 6'b0} + enemy_pos_y + 10'd16;
                missile_timer   = 8'd0;

                //spawn missile from the lowest alive enemy in the column
                if      (enemy_column[2]) begin
                    missile_active  = 1;
                    enemy_missile_y = enemy_offset_y + 10'd96; 
                end
                else if (enemy_column[1]) begin
                    missile_active  = 1;
                    enemy_missile_y = enemy_offset_y + 10'd64; 
                end
                else if (enemy_column[0]) begin
                    missile_active  = 1;
                    enemy_missile_y = enemy_offset_y + 10'd32; 
                end
            end
            //If the missile falls below the screen, deactivate it
            else if (enemy_missile_y >= 480) begin
                missile_active = 1'b0;
            end
            //Otherwise, keep moving the missile down each frame
            else if (missile_active) begin
                enemy_missile_y = enemy_missile_y + 10'd3;
            end
        end
    end

    //This combinational block figures out which enemy column is closest to the player
    always_comb begin
        column_index  = player_pos_x[9:6];              
        enemy_column  = enemy_active_flags[column_index]; 
    end

endmodule
