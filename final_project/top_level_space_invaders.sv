//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module top_level_space_invaders( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
				 ///input        [7:0]  keycode,
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [7:0] kbd_code;
	 logic game_start_reset;
	
	logic [7:0] press_R, press_G, press_B;
	logic [7:0] color_R, color_G, color_B;
	logic [7:0] you_R, you_G, you_B;
	logic [7:0] game_R, game_G, game_B;
	logic [7:0] active_R, active_G, active_B;

    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);
    end
	 
	 // This lives alongside your Reset_h always_ff
always_ff @(posedge VGA_VS or posedge Reset_h) begin
  if (Reset_h)
    game_start_reset <= 1'b1;      // global reset or power-up
  else if (curr_state == 4'd0)
    game_start_reset <= 1'b1;      // still on “Press Space” screen
  else
    game_start_reset <= 1'b0;      // released when game actually begins
end

    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 
	 logic [9:0] DrawX, DrawY;
	 logic is_ball;
	 
	 logic [7:0] enemy_anim_frame;
	 logic [9:0] enenmy_pos_y;
	 logic [9:0] player_offset;
	 logic [2:0] life_count;
	 logic flash_effect;
	 
	 logic enemy_missile_active;
	 logic [9:0] enemy_missile_x;
	 logic [9:0] enemy_missile_y;
	 
	 logic [9:0][2:0]	enemy_active_flags;
	 
	 logic player_fire;
	 localparam PMAX = 3;                      // must match your player_missile.PMAX
	 logic [PMAX-1:0]        player_missile_active;  // one bit per slot
	 logic [9:0] player_missile_x [PMAX];        // X array
	 logic [9:0] player_missile_y [PMAX];        // Y array
	 logic [PMAX-1:0]        pmissile_collided;// collision flags out of cd

	 
	 logic [6:0] enemy_got_hit;
	 logic enemy_collision;
	 logic player_collision;
	 
	 logic lives_text_pixel;
	 
	 logic score_num_pixel;
	 
	 logic score_label_pixel;
	 
	 logic [9:0] score_text_x_offset;
	 
    assign score_text_x_offset = DrawX - 10'd496;
	 
	 logic start_text_pixel;
	 logic win_text_pixel;
	 logic lose_text_pixel;
	 
	 logic [3:0] curr_state;
	 
	 logic invincible_flag;
	 logic [9:0] enemy_y_offset;
	 
	 logic        mystery_exists;
	 logic [9:0]  mysteryX, mysteryY;
	 logic        mystery_hit;
	 
	 logic [9:0] life_x, life_y;
	 logic       life_visible;
	 logic       life_collected;
	 
// --- UFO Mystery Controller ---
mystery_controller mystery_ufo (
    .frame_tick         (VGA_VS),
    .rst_game          (Reset_h),
    .enemy_offset_y (enemy_offset_y),
    .mystery_hit    (mystery_hit),  // from collision_detection

    .missile_activate         (mystery_exists),
    .drop_life      (),            // unused
    .x_pos          (mysteryX),
    .y_pos          (mysteryY),
    .mystery_y_out  (),            // unused
    .spawn_life     (spawn_life),
    .life_x_pos     (spawn_x),
    .life_y_pos     (spawn_y)
);

// --- Life Drop Controller ---
life_drop_controller life_drop (
    .frame_tick         (VGA_VS),
    .rst_game         (Reset_h),
    .spawn_life    (spawn_life),
    .spawn_x       (mysteryX),
    .spawn_y       (mysteryY),
    .ship_x        (player_offset),
    .ship_y        (10'd470),  // player's Y-pos is fixed at bottom of screen

    .life_x        (life_x),
    .life_y        (life_y),
    .life_visible  (life_visible),
    .collected     (life_collected)
);

	 
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(kbd_code),  
									  //.keycode_export(),
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(
										.Clk(Clk),
										.Reset(Reset_h),
										.VGA_HS,
										.VGA_VS,
										.VGA_CLK,
										.VGA_BLANK_N,
										.VGA_SYNC_N,
										.DrawX,
										.DrawY
	 );
    
	// enemy_controller is responsible for controlling the location
	// of the enemy array
	enemy_logic enemy_instance(
										.frame_tick(VGA_VS),
										.rst_game(Reset_h),
										.enemy_anim_frame(enemy_anim_frame),
										.enemy_pos_y(enemy_pos_y),
										.enemy_offset_y  (enemy_offset_y)
	);
	
	// allow the user to have control over the player space ship
	player_control player_instance(
										.rst_game(Reset_h),
										.frame_tick(VGA_VS),
										.kbd_input(kbd_code),
										.player_collision(player_collision),
										.collected(life_collected),
										
										.flash_effect(flash_effect),
										.player_fire(player_fire),
										.player_x(player_offset),
										.player_life_count(life_count),
										.invincible_flag(invincible_flag)
	);
	
	// missiles that are shot from the enemies
	enemy_missile_ctrl emissile (
										.rst_game(Reset_h),
										.frame_tick(VGA_VS),
										.player_pos_x(player_offset),
										.enemy_pos_y(enemy_pos_y),
										.enemy_active_flags(enemy_active_flags),
										.enemy_offset_y (enemy_offset_y),
										.curr_state(curr_state),
										
										.missile_active(enemy_missile_active),
										.enemy_missile_x(enemy_missile_x),
										.enemy_missile_y(enemy_missile_y)
	);
	
	// records which enemies are still alive
	enemy_active_flags enemy_flags (
										.rst_game(Reset_h),
										.enemy_got_hit(enemy_got_hit),
										.collision(enemy_collision),
										.enemy_active_flags(enemy_active_flags)
	);

    // keep a running count of how many enemies remain alive
    // ----------------------------------------------------------------
    logic [5:0] remaining_enemies;

    // on reset or game-start, reload to 30; on each kill, decrement
    always_ff @(posedge VGA_VS or posedge Reset_h) begin
      if (Reset_h)
        remaining_enemies <= 6'd30;
      else if (enemy_collision)
        remaining_enemies <= remaining_enemies - 1;
    end
	
	
	// keep track of missiles the player has shot
	player_missile_ctrl pmissile (
										.rst_game(Reset_h),
										.player_pos_x(player_offset),
										.frame_tick(VGA_VS),
										.spawn_player_missile(player_fire),
										.missile_hit_flags(pmissile_collided),
										
										.missile_active(player_missile_active),
										.player_missile_x(player_missile_x),
										.player_missile_y(player_missile_y)
	);
	
	// detect whenever player and enemy missiles collide
	detect_collision cd (
										.rst_game(Reset_h),
										.frame_tick(VGA_VS),
										.player_missile_active(player_missile_active),
										.player_missile_x(player_missile_x),
										.player_missile_y(player_missile_y),
										.pmissile_collided(pmissile_collided),
										
										.enemy_missile_x(enemy_missile_x),
										.enemy_missile_y(enemy_missile_y),
										
										.player_pos_x(player_offset),
										
										.enemy_got_hit(enemy_got_hit),
										
										.enemy_pos_y(enemy_pos_y),
										
										.enemy_offset_y  (enemy_offset_y),
										
										.enemy_active_flags(enemy_active_flags),
										.mystery_exists  (mystery_exists),
										.mysteryX        (mysteryX),
										.mysteryY        (mysteryY),
										.mystery_hit     (mystery_hit),
										
										.player_collision(player_collision),
										.enemy_collision(enemy_collision)
	);
	
	// keep track of the score
	score_tracker scorekeeper (
										.frame_tick(VGA_VS),
										.rst_game(game_start_reset),
										.X(DrawX[6:1] - 6'h028),
										.Y(DrawY[4:1]),
										
										.enemy_collision_flags(enemy_collision_flags),
										.enemy_row        (enemy_got_hit[2:0]),
										.mystery_hit      (mystery_hit),
										.score_pixel_data(score_num_pixel)
	);
	
	ship_health_map lives_text (
										.X(DrawX[6:1]),
										.Y(DrawY[4:1]),
										
										.score_pixel_data(lives_text_pixel)
	);
	
	always_comb begin
    if (curr_state == 4'd3) begin
        active_R = game_R;
        active_G = game_G;
        active_B = game_B;
    end else if (curr_state == 4'd0) begin
        active_R = press_R;
        active_G = press_G;
        active_B = press_B;
    end else if (curr_state == 4'd2) begin
        active_R = you_R;
        active_G = you_G;
        active_B = you_B;
    end else if (win_text_pixel || start_text_pixel || lose_text_pixel) begin
        active_R = color_R;
        active_G = color_G;
        active_B = color_B;
    end else begin
        active_R = color_R;
        active_G = color_G;
        active_B = color_B;
    end
end

	
	lose_page_map (
    .X(DrawX[9:2]),  
    .Y(DrawY[9:2]),  
    .R(game_R),
    .G(game_G),
    .B(game_B)
	);
	
	starting_map (
    .X(DrawX[9:2]),  
    .Y(DrawY[9:2]),  
    .R(press_R),
    .G(press_G),
    .B(press_B)
	);

	
	win_page_map (
    .X(DrawX[9:2]),  
    .Y(DrawY[9:2]),  
    .R(you_R),
    .G(you_G),
    .B(you_B)
	);
	
	
	

	
	alien_map score_text (
										.X(score_text_x_offset[6:1]),
										.Y(DrawY[4:1]),
										
										.pixel(score_label_pixel)
	);
	
	game_fsm gfsm (
										.frame_tick(VGA_VS),
										.enemy_flags({enemy_active_flags[0], enemy_active_flags[1], enemy_active_flags[2]}),
										.life_count(life_count),
										.kbd_code(kbd_code),
										.rst_game(Reset_h),
										.enemy_offset_y (enemy_offset_y),
										.remaining_enemies (remaining_enemies),
										.curr_state(curr_state)
	);
    
	 // draw all elements on screen
    color_mapper color_instance(
										.curr_state(curr_state),
										.lose_text_pixel(lose_text_pixel),
										.win_text_pixel(win_text_pixel),
										.start_text_pixel(start_text_pixel),
										.invincible_flag(player_collision),
										.DrawX,
										.DrawY,
										.enemy_anim_frame(enemy_anim_frame),
										.enemy_pos_y(enemy_pos_y),
										.mystery_exists  (mystery_exists),
										.mysteryX        (mysteryX),
										.mysteryY        (mysteryY),
										.enemy_offset_y      (enemy_offset_y),
										.player_offset(player_offset),
										.flash_effect(flash_effect),										
										.enemy_missile_active(enemy_missile_active),
										.enemy_missile_x(enemy_missile_x),
										.enemy_missile_y(enemy_missile_y),
										.player_missile_active(player_missile_active),
										.player_missile_x(player_missile_x),
										.player_missile_y(player_missile_y),
										
										.life_visible(life_visible),
										.life_x(life_x),
										.life_y(life_y),
										
										.life_count(life_count),
										.enemy_active_flags(enemy_active_flags),	
										.score_num_pixel(score_num_pixel),
										.score_label_pixel(score_label_pixel),
										.lives_icon_pixel(lives_text_pixel),		
	 .VGA_R(color_R),
    .VGA_G(color_G),
    .VGA_B(color_B)
	 );
	 assign VGA_R = active_R;
	 assign VGA_G = active_G;
	 assign VGA_B = active_B;
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (kbd_code[3:0], HEX0);
    HexDriver hex_inst_1 (kbd_code[7:4], HEX1);
	     
endmodule