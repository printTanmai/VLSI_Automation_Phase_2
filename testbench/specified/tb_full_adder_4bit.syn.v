module tb_full_adder_4bit;

reg [3:0] a;
reg [3:0] b;
wire [3:0] sum;
reg cin;
wire cout;

// Instantiate the DUT
full_adder_4bit uut (
  .a(a),
  .b(b),
  .sum(sum),
  .cin(cin),
  .cout(cout)
);

initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, tb_full_adder_4bit);
end

// Test vectors
integer i;
for (i = 0; i < 16; i = i + 1) begin
  for (cin = 0; cin <= 1; cin = cin + 1) begin
    a = i[3:0];
    b = (i >> 4)[3:0];

    #10;

    // Expected sum and cout calculation
    reg [3:0] expected_sum;
    wire expected_cout;
    always @(*) begin
      expected_sum[0] = a[0] ^ b[0] ^ cin;
      expected_sum[1] = (a[0] & b[0]) | (a[0] & cin) | (b[0] & cin);
      expected_sum[2] = (a[1] & b[1]) | ((a[1] ^ b[1]) & expected_sum[1]);
      expected_sum[3] = (a[2] & b[2]) | ((a[2] ^ b[2]) & expected_sum[2]);
      
      expected_cout = (a[0] & b[0]) | (a[0] & cin) | (b[0] & cin);
    end

    if (sum != expected_sum || cout != expected_cout) begin
      $display("ERROR: a=%d, b=%d, cin=%d; Expected sum=%d, cout=%d; Got sum=%d, cout=%d",
                a, b, cin, expected_sum, expected_cout, sum, cout);
      $fatal(1);
    end
  end
end

initial begin
  // Finish simulation after all tests pass
  #100;
  $finish;
end

endmodule