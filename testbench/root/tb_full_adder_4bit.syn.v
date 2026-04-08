module testbench;

// Declare signals for module inputs and outputs
reg [3:0] a, b;
reg cin;
wire [3:0] sum;
wire cout;

// Instantiate the full_adder_4bit module
full_adder_4bit uut (
  .a(a),
  .b(b),
  .sum(sum),
  .cin(cin),
  .cout(cout)
);

initial begin
  // Initialize signals to zero
  a = 0;
  b = 0;
  cin = 0;

  // Set up waveform dump file
  $dumpfile("dump.vcd");
  $dumpvars(0, testbench);

  // Test case: a=4'b1010, b=4'b1100, cin=1
  a = 4'b1010;
  b = 4'b1100;
  cin = 1;

  #10; // Wait for output to settle

  $display("Test case: a=%b, b=%b, cin=%b", a, b, cin);
  $display("Output: sum=%b, cout=%b", sum, cout);

  // Test case: a=4'b0001, b=4'b0010, cin=0
  a = 4'b0001;
  b = 4'b0010;
  cin = 0;

  #10; // Wait for output to settle

  $display("Test case: a=%b, b=%b, cin=%b", a, b, cin);
  $display("Output: sum=%b, cout=%b", sum, cout);

  // Finish simulation
  $finish;
end

endmodule