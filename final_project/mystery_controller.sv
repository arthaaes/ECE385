module mystery_controller(
  input  logic        frame_tick,
  input  logic        rst_game,
  input  logic [9:0]  enemy_offset_y,
  input  logic        mystery_hit,

  output logic        missile_activate,
  output logic        spawn_life,
  output logic [9:0]  x_pos,
  output logic [9:0]  y_pos,
  output logic [9:0]  mystery_y_out,
  output logic [9:0]  life_x_pos,
  output logic [9:0]  life_y_pos
);

  // Parameters
  localparam SCREEN_W  = 640;
  localparam SPAWN_T   = 8'd119;
  localparam SPEED     = 1;
  localparam Y_START   = 10'd32;

  // Internals
  logic [7:0] spawn_timer;
  logic       dir;
  logic [3:0] lfsr;
  logic       feedback;

  // Random direction LFSR
  always_ff @(posedge frame_tick or posedge rst_game) begin
    if (rst_game) begin
      lfsr <= 4'b0001;
    end else begin
      feedback = lfsr[3] ^ lfsr[0];
      lfsr <= {lfsr[2:0], feedback};
    end
  end

  // Main UFO logic including spawn_life
  always_ff @(posedge frame_tick or posedge rst_game) begin
    if (rst_game) begin
      missile_activate       <= 1'b0;
      spawn_timer  <= 8'd0;
      x_pos        <= 10'd0;
      dir          <= 1'b0;
      spawn_life   <= 1'b0;
      life_x_pos   <= 10'd0;
      life_y_pos   <= 10'd0;
    end
    else if (enemy_offset_y < 10'd64) begin
      missile_activate       <= 1'b0;
      spawn_timer  <= 8'd0;
      x_pos        <= 10'd0;
      dir          <= 1'b0;
      spawn_life   <= 1'b0;
    end
    else begin
      // Life drop if mystery ship was hit
      if (mystery_hit) begin
        spawn_life <= 1'b1;
        life_x_pos <= x_pos;
        life_y_pos <= Y_START;
      end else begin
        spawn_life <= 1'b0;
      end

      if (!missile_activate) begin
        if (spawn_timer < SPAWN_T) begin
          spawn_timer <= spawn_timer + 1;
        end else begin
          spawn_timer <= 8'd0;
          missile_activate      <= 1'b1;
          dir         <= lfsr[0];
          x_pos       <= (lfsr[0] == 1'b0) ? 10'd0 : SCREEN_W - 1;
        end
      end else begin
        if (dir == 1'b0) begin
          if (x_pos + SPEED >= SCREEN_W) begin
            missile_activate <= 1'b0;
          end else begin
            x_pos <= x_pos + SPEED;
          end
        end else begin
          if (x_pos <= SPEED) begin
            missile_activate <= 1'b0;
          end else begin
            x_pos <= x_pos - SPEED;
          end
        end
      end
    end
  end

  assign y_pos = Y_START;
  assign mystery_y_out = y_pos;

endmodule
