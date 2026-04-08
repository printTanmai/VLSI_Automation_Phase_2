module full_adder_4bit (
  input [3:0] a,
  input [3:0] b,
  output reg [3:0] sum,
  input cin,
  output reg cout
);

always @(*) begin
  // Full adder logic for each bit
  sum[0] = a[0] ^ b[0] ^ cin;
  cout = (a[0] & b[0]) | (cin & (a[0] ^ b[0]));

  sum[1] = a[1] ^ b[1] ^ cout;
  cout = (a[1] & b[1]) | (cout & (a[1] ^ b[1]));

  sum[2] = a[2] ^ b[2] ^ cout;
  cout = (a[2] & b[2]) | (cout & (a[2] ^ b[2]));

  sum[3] = a[3] ^ b[3] ^ cout;
  cout = (a[3] & b[3]) | (cout & (a[3] ^ b[3]));
end

endmodule