module tb_bin2gray;
  reg  [3:0] bin;
  wire [3:0] gray;
  reg  [3:0] expected;

  bin2gray dut (.bin(bin), .gray(gray));

  always @* begin
    expected[3] = bin[3];
    expected[2] = bin[3] ^ bin[2];
    expected[1] = bin[2] ^ bin[1];
    expected[0] = bin[1] ^ bin[0];
  end

  integer i;
  initial begin
    $dumpfile("tb_bin2gray.vcd");
    $dumpvars(0, tb_bin2gray);
    for (i = 0; i < 16; i = i + 1) begin
      bin = i[3:0];
      #10;
    end
    #10 $finish;
  end

  initial begin
    $display(" time  bin  gray exp");
    $monitor("%4t   %b   %b   %b", $time, bin, gray, expected);
  end
endmodule