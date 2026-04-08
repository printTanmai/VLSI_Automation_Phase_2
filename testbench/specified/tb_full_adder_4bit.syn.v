module tb_full_adder_4bit;

  reg  [3:0] a;
  reg  [3:0] b;
  reg        cin;
  wire [3:0] sum;
  wire       cout;

  reg  [4:0] expected;
  integer i, j, k;

  full_adder_4bit dut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_full_adder_4bit);

    $display("Starting full_adder_4bit testbench...");
    $monitor("TIME=%0t a=%b b=%b cin=%b -> sum=%b cout=%b", $time, a, b, cin, sum, cout);

    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        for (k = 0; k < 2; k = k + 1) begin
          a = i[3:0];
          b = j[3:0];
          cin = k[0];
          #1;

          expected = a + b + cin;

          if ({cout, sum} !== expected) begin
            $display("ERROR: a=%b b=%b cin=%b expected={cout,sum}=%b got={cout,sum}=%b",
                     a, b, cin, expected, {cout, sum});
            $fatal(1);
          end
        end
      end
    end

    $display("All tests passed.");
    $finish;
  end

endmodule