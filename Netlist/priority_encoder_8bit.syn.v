/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : V-2023.12-SP5-1
// Date      : Mon Apr  6 05:17:49 2026
/////////////////////////////////////////////////////////////


module priority_encoder_8bit ( data_in, binary_out, active );
  input [7:0] data_in;
  output [2:0] binary_out;
  output active;
  wire   n13, n14, n15, n16, n17, n18, n19, n20, n21, n22;

  NOR2xp33_ASAP7_75t_R U19 ( .A(data_in[5]), .B(data_in[4]), .Y(n15) );
  NOR2xp33_ASAP7_75t_R U20 ( .A(data_in[7]), .B(data_in[6]), .Y(n17) );
  NAND2xp5_ASAP7_75t_R U21 ( .A(n15), .B(n17), .Y(binary_out[2]) );
  NOR2xp33_ASAP7_75t_R U22 ( .A(data_in[3]), .B(data_in[2]), .Y(n14) );
  NOR3xp33_ASAP7_75t_R U23 ( .A(binary_out[2]), .B(data_in[1]), .C(data_in[0]), 
        .Y(n13) );
  NAND2xp33_ASAP7_75t_R U24 ( .A(n14), .B(n13), .Y(active) );
  OAI21xp33_ASAP7_75t_R U25 ( .A1(data_in[3]), .A2(data_in[2]), .B(n15), .Y(
        n16) );
  NAND2xp33_ASAP7_75t_R U26 ( .A(n17), .B(n16), .Y(binary_out[1]) );
  INVxp33_ASAP7_75t_R U27 ( .A(data_in[2]), .Y(n18) );
  OAI22xp33_ASAP7_75t_R U28 ( .A1(data_in[1]), .A2(data_in[3]), .B1(n18), .B2(
        data_in[3]), .Y(n19) );
  NOR2xp33_ASAP7_75t_R U29 ( .A(data_in[4]), .B(n19), .Y(n20) );
  NOR2xp33_ASAP7_75t_R U30 ( .A(data_in[5]), .B(n20), .Y(n22) );
  INVxp33_ASAP7_75t_R U31 ( .A(data_in[7]), .Y(n21) );
  OAI21xp33_ASAP7_75t_R U32 ( .A1(data_in[6]), .A2(n22), .B(n21), .Y(
        binary_out[0]) );
endmodule

