module alsu_unit_tb();
reg [2:0] A, B, opcode;
reg cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst;
reg [5:0] out_expected;
wire [5:0] out;
wire [15:0] leds; 

alsu_unit dut(A, B, opcode, cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst, out, leds);

initial begin
    clk = 0;
    forever 
    #1 clk = ~clk;
end

initial begin
    // test reset functionality
    rst = 1;
    A = 0; B = 0; opcode = 0; cin = 0; serial_in = 0; direction = 0; red_op_A = 0; red_op_B = 0; bypass_A = 0; 
    bypass_B = 0;
    @(negedge clk);
    if(out != 0 )
        $display("wrong output for reset = 1");

    // test bypassing
    rst = 0; bypass_A = 1; bypass_B = 1;
    repeat(10) begin
    A = $random; B = $random; opcode = $urandom_range(0, 5);
    out_expected = A;
    repeat(2) @(negedge clk);
    if(out != out_expected) begin
        $display("wrong output when both bypass_A & bypass_B = 1");
        $stop;
    end
    end

    // test priority for AND
    bypass_A = 0; bypass_B = 0; opcode = 0;
    repeat(10) begin
      A = $random; B = $random; red_op_A = $random; red_op_B = $random;
      case ({red_op_A, red_op_B})
        0: out_expected = A & B;
        1: out_expected = &B;
        default: out_expected = &A;
      endcase
    repeat(2) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when both bypass_A & bypass_B = 0, opcode = 0");
        $stop;
    end
    end

    // test priority for XOR
    opcode = 1;
    repeat(10) begin
      A = $random; B = $random; red_op_A = $random; red_op_B = $random;
      case ({red_op_A, red_op_B})
        0: out_expected = A ^ B;
        1: out_expected = ^B;
        default: out_expected = ^A;
      endcase
    repeat(2) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when both bypass_A & bypass_B = 0, opcode = 1");
        $stop;
    end
    end

    // test functionality of full adder
    opcode = 2; red_op_A = 0; red_op_B = 0;
    repeat(10) begin
      A = $random; B = $random; cin = $random;
      out_expected = A + B + cin;
    repeat(2) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when testing adding function");
        $stop;
    end
    end

    // test functionality of multiplier
    opcode = 3; 
    repeat(10) begin
      A = $random; B = $random; 
      out_expected = A * B;
    repeat(2) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when both bypass_A & bypass_B = 0, opcode = 3");
        $stop;
    end
    end

    opcode = 4; 
    repeat(1) begin
      A = $random; B = $random; direction = $random; serial_in = $random;
      if(direction)
        out_expected = {out_expected[4:0], serial_in};
      else
        out_expected = {serial_in, out_expected[5:1]};
    repeat(2) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when testing shifting funcionality");
        $stop;
    end  
    end

    repeat(10) begin
      A = $random; B = $random; direction = 0; serial_in = 0;
      if(direction)
        out_expected = {out_expected[4:0], serial_in};
      else
        out_expected = {serial_in, out_expected[5:1]};
    repeat(1) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when testing shifting funcionality");
        $stop;
    end

    end

    opcode = 5; 
    repeat(1) begin
      A = $random; B = $random; direction = $random; 
      if(direction)
        out_expected = {out_expected[4:0], out_expected[5]};
      else
        out_expected = {out_expected[0], out_expected[5:1]};
    repeat(2) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when testing shifting funcionality");
        $stop;
    end  
    end

    repeat(10) begin
      A = $random; B = $random; direction = 0; 
      if(direction)
        out_expected = {out_expected[4:0], out_expected[5]};
      else
        out_expected = {out_expected[0], out_expected[5:1]};
    repeat(1) @(negedge clk);
        if(out != out_expected) begin
        $display("wrong output when testing shifting funcionality");
        $stop;
    end

    end

    $stop;
end
endmodule