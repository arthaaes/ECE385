// enemy_active_flags.sv
//
// tracks which enemies are still alive.
// It listens for hits (collision flag + enemy index) and updates the status array.
// When an enemy is hit, we turn off its flag so it won't be rendered or checked again.

module enemy_active_flags (
    input  logic              rst_game,           //Reset signal to re-enable all enemies
    input  logic [6:0]        enemy_got_hit,      //Encoded enemy index [6:3]=column, [2:0]=row
    input  logic              collision,          //Goes high for 1 frame when a hit is detected
    output logic [9:0][2:0]   enemy_active_flags  //Output array: 1 = alive, 0 = dead
);

    //Decode the 7-bit index into separate column and row values
    wire [3:0] col = enemy_got_hit[6:3];  
    wire [2:0] row = enemy_got_hit[2:0]; 

    integer i, j; 

    always_ff @ (posedge rst_game or posedge collision) begin
        if (rst_game) begin
            //Reset all enemies to "alive"
            for (i = 0; i < 10; i = i + 1)
                for (j = 0; j < 3; j = j + 1)
                    enemy_active_flags[i][j] <= 1'b1;
        end
        else if (collision) begin
            //Turn off the flag for the enemy that was hit
            enemy_active_flags[col][row] <= 1'b0;
        end
    end

endmodule
