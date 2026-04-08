/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : V-2023.12-SP5-1
// Date      : Mon Apr  6 02:39:15 2026
/////////////////////////////////////////////////////////////


module magnitude_comparator ( A, B, A_gt_B, A_lt_B, A_eq_B );
  input [3:0] A;
  input [3:0] B;
  output A_gt_B, A_lt_B, A_eq_B;
  wire   n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
         n35, n36, n37, n38, n39, n40, n41;

  INVxp33_ASAP7_75t_R U25 ( .A(A[1]), .Y(n21) );
  NOR2xp33_ASAP7_75t_R U26 ( .A(B[1]), .B(n21), .Y(n35) );
  NOR2xp33_ASAP7_75t_R U27 ( .A(n35), .B(A[0]), .Y(n22) );
  INVxp33_ASAP7_75t_R U28 ( .A(B[2]), .Y(n29) );
  NOR2xp33_ASAP7_75t_R U29 ( .A(A[2]), .B(n29), .Y(n37) );
  NOR2xp33_ASAP7_75t_R U30 ( .A(n22), .B(n37), .Y(n24) );
  INVxp33_ASAP7_75t_R U31 ( .A(B[1]), .Y(n23) );
  NOR2xp33_ASAP7_75t_R U32 ( .A(A[1]), .B(n23), .Y(n33) );
  INVxp33_ASAP7_75t_R U33 ( .A(n33), .Y(n25) );
  NAND2xp5_ASAP7_75t_R U34 ( .A(n24), .B(n25), .Y(n28) );
  NOR2xp33_ASAP7_75t_R U35 ( .A(B[0]), .B(n37), .Y(n26) );
  NAND2xp5_ASAP7_75t_R U36 ( .A(n26), .B(n25), .Y(n27) );
  NAND2xp5_ASAP7_75t_R U37 ( .A(n28), .B(n27), .Y(n32) );
  INVxp33_ASAP7_75t_R U38 ( .A(A[3]), .Y(n40) );
  NAND2xp5_ASAP7_75t_R U39 ( .A(A[2]), .B(n29), .Y(n30) );
  OAI21xp5_ASAP7_75t_R U40 ( .A1(B[3]), .A2(n40), .B(n30), .Y(n38) );
  NAND2xp5_ASAP7_75t_R U41 ( .A(B[3]), .B(n40), .Y(n31) );
  OAI21xp5_ASAP7_75t_R U42 ( .A1(n32), .A2(n38), .B(n31), .Y(A_lt_B) );
  NOR2xp33_ASAP7_75t_R U43 ( .A(B[0]), .B(n33), .Y(n34) );
  OAI22xp5_ASAP7_75t_R U44 ( .A1(A[0]), .A2(n35), .B1(n34), .B2(n35), .Y(n36)
         );
  NOR2xp33_ASAP7_75t_R U45 ( .A(n37), .B(n36), .Y(n39) );
  NOR2xp33_ASAP7_75t_R U46 ( .A(n39), .B(n38), .Y(n41) );
  OAI22xp5_ASAP7_75t_R U47 ( .A1(B[3]), .A2(n41), .B1(n40), .B2(n41), .Y(
        A_gt_B) );
  NOR2xp33_ASAP7_75t_R U48 ( .A(A_gt_B), .B(A_lt_B), .Y(A_eq_B) );
endmodule

