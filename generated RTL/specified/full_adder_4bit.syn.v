module full_adder_4bit (
  input [3:0] a,
  input [3:0] b,
  output reg [3:0] sum,
  input cin,
  output reg cout
);

always @(*) begin
  // Sum calculation
  sum[0] = a[0] ^ b[0] ^ cin;
  sum[1] = (a[0] & b[0]) | (a[0] & cin) | (b[0] & cin);
  sum[2] = (a[1] & b[1]) | ((a[1] ^ b[1]) & sum[1]);
  sum[3] = (a[2] & b[2]) | ((a[2] ^ b[2]) & sum[2]);
  
  // Carry-out calculation
  cout = (a[0] & b[0]) | (a[0] & cin) | (b[0] & cin);
end

endmodule