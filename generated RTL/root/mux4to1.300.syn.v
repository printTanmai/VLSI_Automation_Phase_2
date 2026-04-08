module tb_mux4to1;

  reg [3:0] in0;
  reg [1:0] sel;
  wire y;

  // Instantiate the DUT
  mux4to1 uut (
    .in0(in0),
    .sel(sel),
    .y(y)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_mux4to1);
  end

  // Test sequence
  initial begin
    // Initialize inputs
    in0 = 4'b0000;
    sel = 2'b00;

    #10; // Wait for output to settle
    assert(y == 1'b0) else $error("Test failed at time %t", $time);

    in0 = 4'b0001;
    sel = 2'b01;

    #10; // Wait for output to settle
    assert(y == 1'b1) else $error("Test failed at time %t", $time);

    in0 = 4'b0010;
    sel = 2'b10;

    #10; // Wait for output to settle
    assert(y == 1'b0) else $error("Test failed at time %t", $time);

    in0 = 4'b0011;
    sel = 2'b11;

    #10; // Wait for output to settle
    assert(y == 1'b1) else $error("Test failed at time %t", $time);

    in0 = 4'b0100;
    sel = 2'b00;

    #10; // Wait for output to settle
    assert(y == 1'b0) else $error("Test failed at time %t", $time);

    in0 = 4'b0101;
    sel = 2'b01;

    #10; // Wait for output to settle
    assert(y == 1'b1) else $error("Test failed at time %t", $time);

    in0 = 4'b0110;
    sel = 2'b10;

    #10; // Wait for output to settle
    assert(y == 1'b0) else $error("Test failed at time %t", $time);

    in0 = 4'b0111;
    sel = 2'b11;

    #10; // Wait for output to settle
    assert(y == 1'b1) else $error("Test failed at time %t", $time);

    $finish;
  end

endmodule