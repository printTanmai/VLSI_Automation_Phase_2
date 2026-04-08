module priority_encoder_8bit (
  input [7:0] data_in,
  output reg [2:0] binary_out,
  output reg active
);

always @(*) begin
  if (data_in[7])
    binary_out = 3'b111;
  else if (data_in[6])
    binary_out = 3'b110;
  else if (data_in[5])
    binary_out = 3'b101;
  else if (data_in[4])
    binary_out = 3'b100;
  else if (data_in[3])
    binary_out = 3'b011;
  else if (data_in[2])
    binary_out = 3'b010;
  else if (data_in[1])
    binary_out = 3'b001;
  else
    binary_out = 3'b000;

  active = data_in[7] | data_in[6] | data_in[5] | data_in[4] |
           data_in[3] | data_in[2] | data_in[1] | data_in[0];
end

endmodule