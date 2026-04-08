module tb_mux4to1;

  reg  [3:0] in0;
  reg  [1:0] sel;
  wire       y;

  reg        expected_y;
  integer    i;
  integer    j;

  mux4to1 dut (
    .in0(in0),
    .sel(sel),
    .y(y)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_mux4to1);
  end

  initial begin
    $display("Starting mux4to1 testbench");
    $monitor("TIME=%0t in0=%b sel=%b y=%b expected_y=%b", $time, in0, sel, y, expected_y);

    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        in0 = i[3:0];
        sel = j[1:0];
        #1;

        case (sel)
          2'b00: expected_y = in0[0];
          2'b01: expected_y = in0[1];
          2'b10: expected_y = in0[2];
          2'b11: expected_y = in0[3];
          default: expected_y = 1'bx;
        endcase

        #1;
        if (y !== expected_y) begin
          $display("ERROR: Mismatch detected. in0=%b sel=%b expected_y=%b actual_y=%b", in0, sel, expected_y, y);
          $fatal(1);
        end
      end
    end

    $display("All tests passed.");
    $finish;
  end

endmodule