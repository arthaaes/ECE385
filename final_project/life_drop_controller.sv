module life_drop_controller (
  input  logic        frame_tick,
  input  logic        rst_game,
  input  logic        spawn_life,
  input  logic [9:0]  spawn_x,
  input  logic [9:0]  spawn_y,
  input  logic [9:0]  ship_x,
  input  logic [9:0]  ship_y,

  output logic [9:0]  life_x,
  output logic [9:0]  life_y,
  output logic        life_visible,
  output logic        collected
);

  localparam SPEED = 1;
  localparam SCREEN_HEIGHT = 480;

  logic [9:0] drop_x, drop_y;
  logic       falling;
  logic [1:0] collect_counter;

  assign life_x = drop_x;
  assign life_y = drop_y;
  assign life_visible = falling;
  assign collected = (collect_counter > 0);

  always_ff @(posedge frame_tick or posedge rst_game) begin
    if (rst_game) begin
      falling         <= 1'b0;
      collect_counter <= 2'd0;
      drop_x          <= 10'd0;
      drop_y          <= 10'd0;
    end
    else begin
      // Life spawned by UFO hit
      if (spawn_life) begin
        drop_x  <= spawn_x;
        drop_y  <= spawn_y;
        falling <= 1'b1;
      end

      // Animate falling
      if (falling) begin
        drop_y <= drop_y + SPEED;

        // Collision detection with player ship
        if ((drop_x >= ship_x && drop_x <= ship_x + 32) &&
            (drop_y >= ship_y && drop_y <= ship_y + 16)) begin
          falling <= 1'b0;
          collect_counter <= 2'd1;  // Short pulse for collection
        end

        // Remove if falls off screen
        if (drop_y >= SCREEN_HEIGHT) begin
          falling <= 1'b0;
        end
      end

      // Countdown the collected pulse
      if (collect_counter > 0) begin
        collect_counter <= collect_counter - 1;
      end
    end
  end
endmodule
