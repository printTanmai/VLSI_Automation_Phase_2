module priority_encoder_8bit ( data_in, binary_out, active );
  input [7:0] data_in;
  output reg [2:0] binary_out;
  output reg active;

  always @(*) begin
    active = |data_in;
    binary_out = 3'b000;

    casex (data_in)
      8'b1xxxxxxx: binary_out = 3'b111;
      8'b01xxxxxx: binary_out = 3'b110;
      8'b001xxxxx: binary_out = 3'b101;
      8'b0001xxxx: binary_out = 3'b100;
      8'b00001xxx: binary_out = 3'b011;
      8'b000001xx: binary_out = 3'b010;
      8'b0000001x: binary_out = 3'b001;
      8'b00000001: binary_out = 3'b000;
      default:    binary_out = 3'b000;
    endcase
  end

endmodule