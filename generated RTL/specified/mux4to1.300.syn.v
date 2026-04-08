module mux4to1 (
  input [3:0] in0,
  input [1:0] sel,
  output reg y
);

always @(*) begin
  if (sel == 2'b00) begin
    y = in0[0];
  end else if (sel == 2'b01) begin
    y = in0[1];
  end else if (sel == 2'b10) begin
    y = in0[2];
  end else begin
    y = in0[3];
  end
end

endmodule