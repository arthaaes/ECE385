// detect_collision.sv
//
// checks for collisions between missiles and game objects.
// It detects:
// Player missiles hitting enemies (in 3 rows)
// Player missiles hitting the mystery ship
// Enemy missiles hitting the player
// When a hit is detected, it raises a signal for just one frame (1 clock cycle of vsync).
// This lets other parts of the system respond without latching onto it too long.

module detect_collision #(
   parameter PMAX = 3  //Number of player missile slots (set to match player_missile_ctrl)
) (
	input  logic rst_game,                   //Reset signal
	input  logic frame_tick,                //Frame clock (vsync)
	input  logic [PMAX-1:0] player_missile_active,  //Which player missiles are currently active
	input  logic [9:0] player_missile_x [PMAX],     //X positions for each missile
	input  logic [9:0] player_missile_y [PMAX],     //Y positions for each missile
	output logic [PMAX-1:0] pmissile_collided,      //Flags if each missile hit something

	input  logic [9:0] enemy_missile_x,     //X of enemy missile
	input  logic [9:0] enemy_missile_y,     //Y of enemy missile

	input  logic [9:0] player_pos_x,        //X position of player (left side)
	output logic [6:0] enemy_got_hit,       //Output: ID of the enemy that got hit

	input  logic [9:0] enemy_pos_y,         //Left side of the whole enemy block
	input  logic [9:0] enemy_offset_y,      //Top Y offset of enemy block

	input  logic [9:0][2:0] enemy_active_flags,  //Tracks which enemies are still alive

	output logic player_collision,          //Goes high for 1 frame when player is hit
	output logic enemy_collision,           //Goes high for 1 frame when enemy is hit

	//Mystery ship stuff
	input  logic        mystery_exists,
	input  logic [9:0]  mysteryX,
	input  logic [9:0]  mysteryY,
	output logic        mystery_hit         //One-frame pulse when mystery ship is hit
);

	logic [9:0] player_xmax;  //Right edge of the player ship

always_ff @(posedge frame_tick or posedge rst_game) begin
  if (rst_game) begin
    //Clear all collision flags on reset
    player_collision    <= 1'b0;
    enemy_collision     <= 1'b0;
    pmissile_collided   <= '0;
    mystery_hit         <= 1'b0;
  end else begin
    logic [9:0] normX, normY;
    pmissile_collided <= '0;

    //Ensure all one-cycle signals are cleared
    if (player_collision)  player_collision  <= 1'b0;
    if (enemy_collision)   enemy_collision   <= 1'b0;
    if (mystery_hit)       mystery_hit       <= 1'b0;

    //Loop through all player missiles to check for hits
    for (int i = 0; i < PMAX; i++) begin
      if (player_missile_active[i]) begin
        // Adjust missile coordinates relative to enemy block
        normX = player_missile_x[i] - enemy_pos_y;
        normY = player_missile_y[i] - enemy_offset_y;

        //Check collision with each row of enemies

        //Top row (Y: 0–31)
        if (normY < 10'd32 &&
            normX[5] == 1'b0 &&                       //Pixel is within enemy sprite range (0–31)
            enemy_active_flags[normX[9:6]][0]) begin  //That enemy is still alive
          enemy_got_hit      <= {normX[9:6], 3'd0};    //Report which enemy got hit
          enemy_collision    <= 1'b1;
          pmissile_collided[i] <= 1'b1;
        end

        //Middle row (Y: 32–63)
        else if (normY >= 10'd32 && normY < 10'd64 &&
                 normX[5] == 1'b0 &&
                 enemy_active_flags[normX[9:6]][1]) begin
          enemy_got_hit      <= {normX[9:6], 3'd1};
          enemy_collision    <= 1'b1;
          pmissile_collided[i] <= 1'b1;
        end

        //Bottom row (Y: 64–95)
        else if (normY >= 10'd64 && normY < 10'd96 &&
                 normX[5] == 1'b0 &&
                 enemy_active_flags[normX[9:6]][2]) begin
          enemy_got_hit      <= {normX[9:6], 3'd2};
          enemy_collision    <= 1'b1;
          pmissile_collided[i] <= 1'b1;
        end

        //Check collision with mystery ship
        else if (mystery_exists &&
                 player_missile_x[i] >= mysteryX &&
                 player_missile_x[i] < (mysteryX + 10'd64) &&
                 player_missile_y[i] >= mysteryY &&
                 player_missile_y[i] < (mysteryY + 10'd32)) begin
          mystery_hit        <= 1'b1;
          pmissile_collided[i] <= 1'b1;
        end
      end
    end

    //Check if enemy missile hits the player
    if (enemy_missile_y >= 10'd452 && enemy_missile_y < 10'd480 &&
        enemy_missile_x >= player_pos_x && enemy_missile_x <= player_xmax) begin
      player_collision <= 1'b1;
    end
  end
end

//Simple block to calculate player right edge
always_comb begin
  player_xmax = player_pos_x + 10'd64;
end

endmodule
