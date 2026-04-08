module tb_mux4to1;

// Inputs
reg [3:0] in0;
reg [1:0] sel;

// Outputs
wire y;

// Instantiate the DUT
mux4to1 uut (
  .in0(in0),
  .sel(sel),
  .y(y)
);

// Self-checking logic
initial begin
  // Initialize variables
  $dumpfile("dump.vcd");
  $dumpvars(0, tb_mux4to1);
  
  // Test vectors
  for (int i = 0; i < 4; i++) begin
    in0 = i;
    for (int j = 0; j < 4; j++) begin
      sel = j;
      
      #10; // Wait a cycle to allow DUT to update output
      
      // Calculate expected value
      reg expected_y;
      case (sel)
        2'b00: expected_y = in0[0];
        2'b01: expected_y = in0[1];
        2'b10: expected_y = in0[2];
        default: expected_y = in0[3];
      endcase
      
      // Check if output matches expectation
      if (y !== expected_y) begin
        $display("ERROR: Expected y=%b, got %b for in0=%b, sel=%b", expected_y, y, in0, sel);
        $fatal(1);
      end
    end
  end
  
  // All tests passed
  $display("All tests passed!");
  $finish;
end

endmodule