module priority_encoder_8bit_tb;

  reg [7:0] data_in;
  wire [2:0] binary_out;
  wire active;

  priority_encoder_8bit uut (
    .data_in(data_in),
    .binary_out(binary_out),
    .active(active)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, priority_encoder_8bit_tb);
  end

  initial begin
    data_in = 8'b10000000;
    #10;
    data_in = 8'b01000000;
    #10;
    data_in = 8'b00100000;
    #10;
    data_in = 8'b00010000;
    #10;
    data_in = 8'b00001000;
    #10;
    data_in = 8'b00000100;
    #10;
    data_in = 8'b00000010;
    #10;
    data_in = 8'b00000001;
    #10;
    data_in = 8'b00000000;
    #10;

    $finish;
  end

endmodule