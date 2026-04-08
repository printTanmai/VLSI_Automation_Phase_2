/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : V-2023.12-SP5-1
// Date      : Mon Apr  6 05:32:43 2026
/////////////////////////////////////////////////////////////


module full_adder_4bit ( a, b, cin, sum, cout );
  input [3:0] a;
  input [3:0] b;
  output [3:0] sum;
  input cin;
  output cout;
  wire   n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33,
         n34, n35, n36, n37, n38, n39, n40, n41, n42, n43;

  OAI21xp33_ASAP7_75t_R U24 ( .A1(a[0]), .A2(b[0]), .B(cin), .Y(n42) );
  NAND2xp33_ASAP7_75t_R U25 ( .A(a[0]), .B(b[0]), .Y(n43) );
  NAND2xp33_ASAP7_75t_R U26 ( .A(n42), .B(n43), .Y(n20) );
  OAI21xp33_ASAP7_75t_R U27 ( .A1(b[1]), .A2(a[1]), .B(n20), .Y(n30) );
  NAND2xp33_ASAP7_75t_R U28 ( .A(b[1]), .B(a[1]), .Y(n31) );
  NAND2xp33_ASAP7_75t_R U29 ( .A(n30), .B(n31), .Y(n21) );
  OAI21xp33_ASAP7_75t_R U30 ( .A1(a[2]), .A2(b[2]), .B(n21), .Y(n36) );
  NAND2xp33_ASAP7_75t_R U31 ( .A(a[2]), .B(b[2]), .Y(n37) );
  NAND2xp33_ASAP7_75t_R U32 ( .A(n36), .B(n37), .Y(n22) );
  OAI21xp33_ASAP7_75t_R U33 ( .A1(a[3]), .A2(b[3]), .B(n22), .Y(n24) );
  NAND2xp33_ASAP7_75t_R U34 ( .A(a[3]), .B(b[3]), .Y(n23) );
  NAND2xp33_ASAP7_75t_R U35 ( .A(n24), .B(n23), .Y(cout) );
  INVxp33_ASAP7_75t_R U36 ( .A(cin), .Y(n25) );
  FAx1_ASAP7_75t_R U37 ( .A(a[0]), .B(b[0]), .CI(n25), .SN(sum[0]) );
  INVxp33_ASAP7_75t_R U38 ( .A(b[2]), .Y(n27) );
  INVxp33_ASAP7_75t_R U39 ( .A(a[2]), .Y(n26) );
  AOI22xp33_ASAP7_75t_R U40 ( .A1(a[2]), .A2(b[2]), .B1(n27), .B2(n26), .Y(n29) );
  NAND3xp33_ASAP7_75t_R U41 ( .A(n30), .B(n31), .C(n29), .Y(n28) );
  A2O1A1Ixp33_ASAP7_75t_R U42 ( .A1(n31), .A2(n30), .B(n29), .C(n28), .Y(
        sum[2]) );
  INVxp33_ASAP7_75t_R U43 ( .A(b[3]), .Y(n33) );
  INVxp33_ASAP7_75t_R U44 ( .A(a[3]), .Y(n32) );
  AOI22xp33_ASAP7_75t_R U45 ( .A1(a[3]), .A2(b[3]), .B1(n33), .B2(n32), .Y(n35) );
  NAND3xp33_ASAP7_75t_R U46 ( .A(n36), .B(n37), .C(n35), .Y(n34) );
  A2O1A1Ixp33_ASAP7_75t_R U47 ( .A1(n37), .A2(n36), .B(n35), .C(n34), .Y(
        sum[3]) );
  INVxp33_ASAP7_75t_R U48 ( .A(a[1]), .Y(n39) );
  INVxp33_ASAP7_75t_R U49 ( .A(b[1]), .Y(n38) );
  AOI22xp33_ASAP7_75t_R U50 ( .A1(b[1]), .A2(a[1]), .B1(n39), .B2(n38), .Y(n41) );
  NAND3xp33_ASAP7_75t_R U51 ( .A(n42), .B(n43), .C(n41), .Y(n40) );
  A2O1A1Ixp33_ASAP7_75t_R U52 ( .A1(n43), .A2(n42), .B(n41), .C(n40), .Y(
        sum[1]) );
endmodule

