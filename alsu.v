module alsu_unit(A, B, opcode, cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst, out, leds);
// Legal Values are only "A" & "B"
parameter INPUT_PRIORITY = "A";

// Legal Values are only "ON" and "OFF"
parameter FULL_ADDER = "ON";

//define inputs & outputs
input [2:0] A, B, opcode;
input cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst; // direction = 1 -> left 
output reg [5:0] out;
output reg [15:0] leds; 

// internal signals
reg [2:0] A_reg, B_reg, op_reg;
reg cin_reg, serial_in_reg, direction_reg, red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg; 

always @(posedge clk or posedge rst) begin
    if(rst) begin
      out <= 0;
      leds <= 0;
    end
    else begin
        // Get Registered Inputs
        A_reg <= A; 
        B_reg <= B;
        op_reg <= opcode;
        cin_reg <= cin;
        serial_in_reg <= serial_in;
        direction_reg <= direction;
        red_op_A_reg <= red_op_A;
        red_op_B_reg <= red_op_B;
        bypass_A_reg <= bypass_A;
        bypass_B_reg <= bypass_B;

        case ({bypass_A_reg, bypass_B_reg})
            2'b00: begin
                 case (op_reg)
                    3'b000: begin
                        case ({red_op_A_reg, red_op_B_reg})
                        2'b00: out <= A_reg & B_reg;
                        2'b10: out <= &A_reg;
                        2'b01: out <= &B_reg;
                        2'b11: begin
                            if(INPUT_PRIORITY == "A")
                                out <= &A_reg;
                            else if(INPUT_PRIORITY == "B")
                                out <= &B_reg;
                            end
                        endcase
                        end
                    3'b001: begin
                        case ({red_op_A_reg, red_op_B_reg})
                        2'b00: out <= A_reg ^ B_reg;
                        2'b10: out <= ^A_reg;
                        2'b01: out <= ^B_reg;
                        2'b11: begin
                            if(INPUT_PRIORITY == "A")
                                out <= ^A_reg;
                            else if(INPUT_PRIORITY == "B")
                                out <= ^B_reg;
                            end
                        endcase
                    end
                    3'b010: begin
                    if(red_op_A_reg && red_op_B_reg) begin
                      leds <= ~leds;
                      out <= 0;
                    end
                    else if(FULL_ADDER == "ON")
                        out <= A_reg + B_reg + cin_reg;
                    else if(FULL_ADDER == "OFF")
                        out <= A_reg + B_reg;
                    end
                    3'b011: begin
                    if(red_op_A_reg && red_op_B_reg) begin
                      leds <= ~leds;
                      out <= 0;
                    end
                    else
                        out <= A_reg * B_reg;
                    end
                    3'b100: begin
                    if(red_op_A_reg && red_op_B_reg) begin
                      leds <= ~leds;
                      out <= 0;
                    end
                    else if(direction_reg)
                        out <= {out[4:0], serial_in_reg};
                    else
                        out <= {serial_in_reg, out[5:1]};
                    end
                    3'b101: begin
                    if(red_op_A_reg && red_op_B_reg) begin
                      leds <= ~leds;
                      out <= 0;
                    end
                    else if(direction_reg)
                        out <= {out[4:0], out[5]};
                    else
                        out <= {out[0], out[5:1]};
                    end
                    default: begin
                      leds <= ~leds;
                      out <= 0;
                    end
                endcase
            end
        2'b10: out <= A_reg;
        2'b01: out <= B_reg;
        2'b11: begin
            if(INPUT_PRIORITY == "A")
                out <= A_reg;
            else if(INPUT_PRIORITY == "B")
                out <= B_reg;
        end
        endcase
    end
end

endmodule