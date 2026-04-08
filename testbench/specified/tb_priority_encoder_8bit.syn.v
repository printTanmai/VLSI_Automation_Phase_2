module tb_priority_encoder_8bit;

  reg  [7:0] data_in;
  wire [2:0] binary_out;
  wire       active;

  reg  [2:0] expected_binary_out;
  reg        expected_active;
  integer    i;

  priority_encoder_8bit dut (
    .data_in(data_in),
    .binary_out(binary_out),
    .active(active)
  );

  task check_outputs;
    begin
      expected_active = |data_in;
      expected_binary_out = 3'b000;

      if (data_in[7])
        expected_binary_out = 3'b111;
      else if (data_in[6])
        expected_binary_out = 3'b110;
      else if (data_in[5])
        expected_binary_out = 3'b101;
      else if (data_in[4])
        expected_binary_out = 3'b100;
      else if (data_in[3])
        expected_binary_out = 3'b011;
      else if (data_in[2])
        expected_binary_out = 3'b010;
      else if (data_in[1])
        expected_binary_out = 3'b001;
      else if (data_in[0])
        expected_binary_out = 3'b000;
      else
        expected_binary_out = 3'b000;

      if ((active !== expected_active) || (binary_out !== expected_binary_out)) begin
        $display("ERROR: data_in=%b expected active=%b binary_out=%b, got active=%b binary_out=%b",
                 data_in, expected_active, expected_binary_out, active, binary_out);
        $fatal(1);
      end
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_priority_encoder_8bit);

    $display("Starting priority_encoder_8bit testbench");
    $monitor("time=%0t data_in=%b active=%b binary_out=%b", $time, data_in, active, binary_out);

    for (i = 0; i < 256; i = i + 1) begin
      data_in = i[7:0];
      #1;
      check_outputs;
    end

    $display("All tests passed.");
    $finish;
  end

endmodule