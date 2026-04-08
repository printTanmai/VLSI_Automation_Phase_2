/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : V-2023.12-SP5-1
// Date      : Mon Apr  6 05:29:02 2026
/////////////////////////////////////////////////////////////


module bin2gray ( bin, gray );
  input [3:0] bin;
  output [3:0] gray;
  wire   gray_3_;
  assign gray[3] = gray_3_;
  assign gray_3_ = bin[3];

  XOR2xp5_ASAP7_75t_R U4 ( .A(bin[1]), .B(bin[0]), .Y(gray[0]) );
  XOR2xp5_ASAP7_75t_R U5 ( .A(bin[2]), .B(bin[1]), .Y(gray[1]) );
  XOR2xp5_ASAP7_75t_R U6 ( .A(bin[2]), .B(gray_3_), .Y(gray[2]) );
endmodule

