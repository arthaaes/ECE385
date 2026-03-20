//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

//for picking the color of every pixel on screen
module color_mapper #(
  parameter PMAX = 3    //must match your player_missile.PMAX
) (
							  input	logic	[3:0]	curr_state,
							  input 	logic			lose_text_pixel,
							  input	logic			win_text_pixel,
							  input	logic			start_text_pixel,
							  
							  input	logic			invincible_flag,

                       input        [9:0] DrawX, DrawY,       	// Current pixel coordinates
							  input	logic	[7:0] enemy_anim_frame,		// Selects which one of the two enemy frames to display
							  input 	logic [9:0] enemy_pos_y,			// offset of the left side of the enemy array
							  input logic        mystery_exists,
							  input logic [9:0]  mysteryX,       
							  input logic [9:0]  mysteryY, 
							  input logic  [9:0] enemy_offset_y,
							  input	logic	[9:0] player_offset,			// left X coord of player's ship
							  input	logic			flash_effect,			// whether or not the player should flash when invincible
							  
							  input 	logic 		enemy_missile_active,		// whether or not enemy missile exists
							  input	logic [9:0] enemy_missile_x,				// enemy missile X position
							  input 	logic [9:0] enemy_missile_y,				// enemy missile Y position
							  
							  input logic [9:0] life_x,
							  input logic [9:0] life_y,
							  input logic			life_visible,
							  
							  input  logic [PMAX-1:0]       player_missile_active,
  input  				  logic [9:0]            player_missile_x   [PMAX],
  input  				  logic [9:0]            player_missile_y   [PMAX],
							  
							  input  logic [2:0] life_count,			// number of player lives left
							  input	logic [9:0][2:0] enemy_active_flags,	// array of enemies still alive
							  
							  input	logic 		score_num_pixel,	//used for drawing score array
							  
							  input 	logic			score_label_pixel,
							  
							  input	logic			lives_icon_pixel, 	//used to print the lives text
							  
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
	 logic [7:0]  sprite_addr0, sprite_addr1, sprite_addr2;
	 logic _sprite_;
	 logic [15:0] sprite_slice0, sprite_slice1, sprite_slice2;
	 
	 logic [7:0] lives_slice, lives_addr;
	 
	 logic [31:0] player_slice;
	 logic [7:0]  player_addr;
	 logic current_player_pixel;
	 logic current_sprite_pixel;
	 
	 logic [9:0] enemy_x_normalized;
	 logic [9:0] player_x_normalized;
	 logic [9:0] mystery_x_normalized;
	 
	   //temp variables for moving‐enemy sprite addressing
	 logic [9:0] relY;       //DrawY relative to enemy block top
    logic [9:0] rowY;       //relY adjusted per‐row (0–31)
	 logic [4:0] rowIndex;   //rowY[4:2], the 0–7 index into the 32-pixel bank
	 logic [9:0] middleRowY;
	 logic [4:0] rowIdx1;
	 
	 //temp variables for drawing moving enemies
	 logic [2:0]  colIdx;
	 logic [9:0]  rY0, rY1, rY2;
	 logic [4:0]  idx0, idx1, idx2;
	
	 //temp row‐local Y for mystery alien
    logic [9:0] mystery_rY;
	 
	 logic life_pixel;

	 assign life_pixel = life_visible &&
                    (DrawX >= life_x && DrawX < life_x + 4'd8) &&
                    (DrawY >= life_y && DrawY < life_y + 4'd8);

	 
	 assign enemy_x_normalized = DrawX - enemy_pos_y;
	 assign player_x_normalized = DrawX - player_offset;
	 assign mystery_x_normalized = DrawX - mysteryX;
	 assign lives_addr = DrawY[9:2];
	 
	 enemy_rom0 ROM_enemy0(.addr(sprite_addr0), .data(sprite_slice0));
	 enemy_rom1 ROM_enemy1(.addr(sprite_addr1), .data(sprite_slice1));
	 enemy_rom2 ROM_enemy2(.addr(sprite_addr2), .data(sprite_slice2));
	 player_rom ROM_player_ship(.addr(player_addr), .data(player_slice));
	 heart_rom ROM_player_heart(.addr(lives_addr), .data(lives_slice));
	 
	 logic [7:0]mystery_addr;
	 logic [31:0] mystery_slice;
	 mystery_rom ROM_mystery(.addr(mystery_addr), .data(mystery_slice));

    
    //Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    //Assign color based on is_ball signal
	 always_comb begin
    Red   = 8'h00;
    Green = 8'h00;
    Blue  = DrawY[9:2];
	 
	 colIdx = 3'd0;
	 rY0    = 10'd0;  idx0 = 5'd0;
    rY1    = 10'd0;  idx1 = 5'd0;
    rY2    = 10'd0;  idx2 = 5'd0;

    current_player_pixel = 1'b0;
    current_sprite_pixel = 1'b0;

    //defaults for sprite ROM addresses
    sprite_addr0 = 8'd0;
    sprite_addr1 = 8'd0;
    sprite_addr2 = 8'd0;

    //defaults for your temps (if you actually need them later)
    relY         = 10'd0;
    rowY         = 10'd0;
    rowIndex     = 5'd0;
    middleRowY   = 10'd0;
	 rowIdx1     = 5'd0;
	 mystery_rY   = 10'd0;
	 mystery_addr  = 8'd0;



		//normalize screen Y into block-local Y
    relY = DrawY - enemy_offset_y;  

    //pick which 32-pixel bank and compute rowY, rowIndex
    if (relY < 10'd32) begin           // top row
      rowY      = relY;
      rowIndex  = rowY[4:2];
      sprite_addr0 = {5'b0, rowIndex} + enemy_anim_frame;
      sprite_addr1 = {5'b0, rowIndex} - enemy_anim_frame;
      sprite_addr2 = {5'b0, rowIndex} + enemy_anim_frame;
    end
    else if (relY < 10'd64) begin      // middle row
      rowY      = relY - 10'd32;
      rowIndex  = rowY[4:2];
      sprite_addr0 = {5'b0, rowIndex} + enemy_anim_frame + 8'd16;
      sprite_addr1 = {5'b0, rowIndex} + enemy_anim_frame + 8'd16;
		current_sprite_pixel = sprite_slice1[enemy_x_normalized[4:2]];
      sprite_addr2 = {5'b0, rowIndex} + enemy_anim_frame + 8'd16;
    end
    else begin                         // bottom row (relY < 96)
      rowY      = relY - 10'd64;
      rowIndex  = rowY[4:2];
      sprite_addr0 = {5'b0, rowIndex} + enemy_anim_frame + 8'd32;
      sprite_addr1 = {5'b0, rowIndex} - enemy_anim_frame - 8'd32;
      sprite_addr2 = {5'b0, rowIndex} + enemy_anim_frame + 8'd32;
    end

		
			player_addr = 	{4'b0, DrawY[5:2]};
		
			
			//some default pixel values
			current_player_pixel = 1'b0;
			current_sprite_pixel = 1'b0;
	 
	 
			//for the starting page
			if(curr_state == 4'd0) begin
		
				if(start_text_pixel &&
				DrawX >= 280 &&
				DrawX < 360 &&
				DrawY >= 208 &&
				DrawY < 272) begin
					Red = 8'hFF;
					Blue = 8'hFF;
					Green = 8'hFF;
				end
				else begin
					Red = 8'h00;
					Blue = 8'h00;
					Green = 8'h00;
				end
		
			end
		
			//for the you win page
			else if(curr_state == 4'd2) begin
				if(win_text_pixel &&
				DrawX >= 296 &&
				DrawX < 344 &&
				DrawY >= 208 &&
				DrawY < 272) begin
					Red = 8'hFF;
					Blue = 8'hFF;
					Green = 8'hFF;
				end
				else begin
					Red = 8'h00;
					Blue = 8'h00;
					Green = 8'h00;
				end

			end
		
			//for the game over page
			else if(curr_state == 4'd3) begin
				if(lose_text_pixel &&
				DrawX >= 288 &&
				DrawX < 352 &&
				DrawY >= 208 &&
				DrawY < 272) begin
					Red = 8'hFF;
					Blue = 8'hFF;
					Green = 8'hFF;
				end
				else begin
					Red = 8'h00;
					Blue = 8'h00;
					Green = 8'h00;
				end
			end
	 
			//make the game logic
			else if(curr_state == 4'd1) begin
		
			//for the player lives (using heart rom)
			if(life_count != 3'd0 &&
			DrawY >= 10'd0 &&
			DrawY < 10'd32 &&
			DrawX >= 10'd64 &&
			DrawX < 10'd160) begin
			
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
						
				if(DrawY < 10'd32 && 
				DrawY >= 10'd0 &&
				DrawX < 10'd96 &&
				DrawX >= 10'd64 &&
				life_count >= 3'd1) begin
					
					if(lives_slice[DrawX[4:2] - 4'd8] == 1'b1) begin
						Red = 8'hff;
						Green = 8'h00;
						Blue = 8'h00;
					end
					
					else begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
					end
				end	
			
				if(DrawY < 10'd32 && 
				DrawY >= 10'd0 &&
				DrawX < 10'd128 &&
				DrawX >= 10'd96 &&
				life_count >= 3'd2) begin
					
					if(lives_slice[DrawX[4:2] - 4'd8] == 1'b1) begin
						Red = 8'hff;
						Green = 8'h00;
						Blue = 8'h00;
					end
					
					else begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
					end
				end
				
				if(DrawY < 10'd32 && 
				DrawY >= 10'd0 &&
				DrawX < 10'd160 &&
				DrawX >= 10'd128 &&
				life_count >= 3'd3) begin
					
					if(lives_slice[DrawX[4:2] - 4'd8] == 1'b1) begin
						Red = 8'hff;
						Green = 8'h00;
						Blue = 8'h00;
					end
					
					else begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
					end
				end
				
				
			end

			//drawing the ship for lives desc
			else if(DrawX >= 10'd0 &&
			DrawX < 10'd64 &&
			DrawY >= 10'd0 &&
			DrawY < 10'd32) begin
			
				if(lives_icon_pixel) begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;			
				end
				
				else begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
			end
		 
			
			//drawiing the alien for score desc
			else if(DrawX >= 10'd496 &&
			DrawX < 10'd592 &&
			DrawY >= 10'd0 &&
			DrawY < 10'd32) begin
			
				if(score_label_pixel) begin
					Red = 8'h00;
					Green = 8'hff;
					Blue = 8'h00;
				end
				
				else begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
			
			end
		 
			//writing score
			else if(DrawX >= 10'd592 &&
			DrawX < 10'd640 &&
			DrawY >= 10'd0 &&
			DrawY < 10'd32) begin
				
				if(score_num_pixel) begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
				
				else begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
				
			end
			
//drawing enemies			
// Top row (row 0)
else if (
    enemy_x_normalized[5]==1'b0 &&
    DrawY >= enemy_offset_y &&
    DrawY <  (enemy_offset_y + 10'd32) &&
    DrawX >= enemy_pos_y &&
    enemy_active_flags[enemy_x_normalized[9:6]][0]
) begin

	 logic [4:0] pixel_index;
	 logic [1:0] pixel_color;
	 
    // compute column and row-local Y
    colIdx = enemy_x_normalized[4:2];
    rY0    = DrawY - enemy_offset_y;
    idx0   = rY0[4:2];

    sprite_addr0         = {5'b0, idx0} + enemy_anim_frame;
    current_sprite_pixel = sprite_slice0[colIdx];
	 
	 pixel_index = enemy_x_normalized[4:2];  // 16 possible pixels (scaled by 4)
	 pixel_color = sprite_slice0[15 - (2 * pixel_index) -: 2];

				case (pixel_color)
					2'b00: begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = DrawY[9:2];  // transparent or background
					end
					2'b01: begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'hff;  // white
					end
					2'b10: begin
						Red = 8'ha8;
						Green = 8'ha8;
						Blue = 8'ha8;  // gray
					end
					2'b11: begin
						Red = 8'h60;
						Green = 8'hf8;
						Blue = 8'hff;  // cyan
					end
					default: begin 
						Red = 8'h00; Green = 8'h00; Blue = DrawY[9:2];
					end

				endcase
end

// Middle row (row 1, +2 points)
else if (
    enemy_x_normalized[5]==1'b0 &&
    DrawY >= (enemy_offset_y + 10'd32) &&
    DrawY <  (enemy_offset_y + 10'd64) &&
    DrawX >= enemy_pos_y &&
    enemy_active_flags[enemy_x_normalized[9:6]][1]
) begin

	 logic [4:0] pixel_index;
	 logic [1:0] pixel_color;
	 
    colIdx = enemy_x_normalized[4:2];
    rY1    = DrawY - enemy_offset_y - 10'd32;
    idx1   = rY1[4:2];

    sprite_addr1         = {5'b0, idx1} + enemy_anim_frame + 8'd32;
    current_sprite_pixel = sprite_slice1[colIdx];

    // Normalize to 0–63 range and get 2-bit pixel index
				pixel_index = enemy_x_normalized[4:2];  // 16 possible pixels (scaled by 4)
				pixel_color = sprite_slice1[15 - (2 * pixel_index) -: 2];

				case (pixel_color)
					2'b00: begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = DrawY[9:2];  // transparent or background
					end
					2'b01: begin
						Red = 8'he5;
						Green = 8'h00;
						Blue = 8'hff;  // red
					end
					2'b10: begin
						Red = 8'h7e;
						Green = 8'h00;
						Blue = 8'h8d;  // dark green
					end
					2'b11: begin
						Red = 8'hf0;
						Green = 8'h71;
						Blue = 8'hff;  // yellow
					end
					default: begin 
						Red = 8'h00; Green = 8'h00; Blue = DrawY[9:2];
					end

				endcase
				
end

// Bottom row (row 2)
else if (
    enemy_x_normalized[5]==1'b0 &&
    DrawY >= (enemy_offset_y + 10'd64) &&
    DrawY <  (enemy_offset_y + 10'd96) &&
    DrawX >= enemy_pos_y &&
    enemy_active_flags[enemy_x_normalized[9:6]][2]
) begin

	 logic [4:0] pixel_index;
	 logic [1:0] pixel_color;
				
    colIdx = enemy_x_normalized[4:2];
    rY2    = DrawY - enemy_offset_y - 10'd64;
    idx2   = rY2[4:2];

    sprite_addr2         = {5'b0, idx2} + enemy_anim_frame + 8'd32;
    current_sprite_pixel = sprite_slice2[colIdx];

				// Normalize to 0–63 range and get 2-bit pixel index
				pixel_index = enemy_x_normalized[4:2];  // 16 possible pixels (scaled by 4)
				pixel_color = sprite_slice2[15 - (2 * pixel_index) -: 2];

				case (pixel_color)
					2'b00: begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = DrawY[9:2];  // transparent or background
					end
					2'b01: begin
						Red = 8'hff;
						Green = 8'h00;
						Blue = 8'h00;  // red
					end
					2'b10: begin
						Red = 8'h00;
						Green = 8'h99;
						Blue = 8'h00;  // dark green
					end
					2'b11: begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'h66;  // yellow
					end
					default: begin 
						Red = 8'h00; Green = 8'h00; Blue = DrawY[9:2];
					end

				endcase
			end
/////////////////////////////////////////////////////////////////////////


//the enemy missile
else if (
    enemy_missile_active &&
    DrawX[9:2] == enemy_missile_x[9:2] &&
    DrawY[9:2] == enemy_missile_y[9:2]
) begin
   Red   = 8'hff;
   Green = 8'h00;
   Blue  = 8'h00;
end
			
//player missile
for (int i = 0; i < PMAX; i++) begin
    if (player_missile_active[i] &&
        DrawX[9:2] == player_missile_x[i][9:2] &&
        DrawY[9:2] == player_missile_y[i][9:2]) begin

        Red   = 8'hff;
        Green = 8'hff;
        Blue  = 8'hff;
    end
end

			
//Mystery alien (worth +10)
if (
    mystery_exists &&  
    DrawX >= mysteryX && DrawX <  (mysteryX + 10'd64) &&
    DrawY >= mysteryY && DrawY <  (mysteryY + 10'd32)
) begin

	 logic [4:0] pixel_index;
	 logic [1:0] pixel_color;
	 
    // 1) row‐local address (0…31)
    // compute row‐local Y (0..31)
    mystery_rY   = DrawY - mysteryY;

    // slice out bits [4:2] to form the 5-bit addr
    mystery_addr = {mystery_rY[4:2]};


    // 2) column‐local bit
    pixel_index = mystery_x_normalized[5:2];  // 16 possible pixels (scaled by 4)
	 pixel_color = mystery_slice[31 - (2 * pixel_index) -: 2];

				case (pixel_color)
					2'b00: begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = DrawY[9:2];  // transparent or background
					end
					2'b01: begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'hff;  // white
					end
					2'b10: begin
						Red = 8'h9a;
						Green = 8'h9a;
						Blue = 8'h9a;  // dark gray
					end
					2'b11: begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'h66;  // yellow
					end
					default: begin 
						Red = 8'h00; Green = 8'h00; Blue = DrawY[9:2];
					end

				endcase
    // else leave defaults (background)
end

			
			//Draw the ship
			else if(DrawY >= 10'd448 &&
			DrawX >= player_offset &&
			DrawX < player_offset + 10'd64 &&
			!flash_effect) begin

				logic [4:0] pixel_index;
				logic [1:0] pixel_color;

				// Normalize to 0–63 range and get 2-bit pixel index
				pixel_index = player_x_normalized[5:2];  // 16 possible pixels (scaled by 4)
				pixel_color = player_slice[31 - 2 * pixel_index -: 2];

				case (pixel_color)
					2'b00: begin
							Red = 8'h00;
							Green = 8'h00;
							Blue = DrawY[9:2];  // transparent or background
					end
					2'b01: begin
							Red = 8'h00;
							Green = 8'hff;
							Blue = 8'hff;  // light blue
					end
					2'b10: begin
							Red = 8'hff;
							Green = 8'h00;
							Blue = 8'h00;  // red
					end
					2'b11: begin
							Red = 8'h80;
							Green = 8'h80;
							Blue = 8'h80;  // grey
					end
				endcase
			end
			else if (
			life_visible &&
			DrawX >= life_x &&
			DrawX < life_x + 8 &&
			DrawY >= life_y &&
			DrawY < life_y + 8
			) begin
				if (life_pixel) begin
						Red   = 8'hFF;
						Green = 8'hff;
						Blue  = 8'h00; // red heart

				end
			end

		end
	end

endmodule