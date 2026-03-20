//player_missile_ctrl.sv
//
//controls the missile fired by the player.
//can only have one on the screen at any
//given time.

module player_missile_ctrl #(
  parameter PMAX = 3
)(
  input  logic             rst_game,
  input  logic      [9:0]  player_pos_x,
  input  logic             frame_tick,
  input  logic             spawn_player_missile,
  input  logic [PMAX-1:0]  missile_hit_flags,      // one per slot
  output logic [PMAX-1:0]  missile_active,            // one per slot
  output logic [9:0]       player_missile_x [PMAX],
  output logic [9:0]       player_missile_y [PMAX]
);

	logic [PMAX-1:0] creation_flag;
	logic             prev_create;

always_ff @(posedge frame_tick or posedge rst_game) begin
  if (rst_game) begin
    missile_active        <= '0;
    creation_flag  <= '0;
	 prev_create    <= 1'b0;
    for (int i = 0; i < PMAX; i++) begin
      player_missile_x[i] <= 10'd0;
      player_missile_y[i] <= 10'd0;
    end
  end
  else begin
    // clear creation flags each frame
    creation_flag <= '0;

    /// on the rising edge of SPACE, grab first free slot
    if (spawn_player_missile && !prev_create) begin
      for (int i = 0; i < PMAX; i++) begin
        if (!missile_active[i]) begin
          creation_flag[i] <= 1;
          break;
        end
      end
    end
	
	 prev_create <= spawn_player_missile;
	 
    // update every missile slot
    for (int i = 0; i < PMAX; i++) begin
      if (creation_flag[i]) begin
        missile_active[i]         <= 1;
        player_missile_x[i] <= player_pos_x + 10'd30;
        player_missile_y[i] <= 10'd448;
      end
      else if (missile_active[i]) begin
        player_missile_y[i] <= player_missile_y[i] - 10'd4;
        // retire on off‐screen or collision
        if (player_missile_y[i] == 0 || missile_hit_flags[i])
          missile_active[i] <= 0;
      end
    end
  end
end

	
	always_comb begin
	
	
	
	end

endmodule