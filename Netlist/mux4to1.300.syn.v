/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : V-2023.12-SP5-1
// Date      : Mon Apr  6 04:56:00 2026
/////////////////////////////////////////////////////////////


module mux4to1 ( in0, sel, y );
  input [3:0] in0;
  input [1:0] sel;
  output y;
  wire   n10, n11, n12, n13, n14, n15, n16;

  NAND2xp33_ASAP7_75t_R U11 ( .A(sel[0]), .B(in0[1]), .Y(n16) );
  INVxp33_ASAP7_75t_R U12 ( .A(sel[0]), .Y(n10) );
  NAND2xp33_ASAP7_75t_R U13 ( .A(in0[0]), .B(n10), .Y(n15) );
  NAND2xp33_ASAP7_75t_R U14 ( .A(sel[0]), .B(in0[3]), .Y(n12) );
  NAND2xp33_ASAP7_75t_R U15 ( .A(in0[2]), .B(n10), .Y(n11) );
  NAND2xp33_ASAP7_75t_R U16 ( .A(n12), .B(n11), .Y(n13) );
  NAND2xp33_ASAP7_75t_R U17 ( .A(sel[1]), .B(n13), .Y(n14) );
  A2O1A1Ixp33_ASAP7_75t_R U18 ( .A1(n16), .A2(n15), .B(sel[1]), .C(n14), .Y(y)
         );
endmodule

