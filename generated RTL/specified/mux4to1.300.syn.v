module mux4to1 (in0, sel, y);
  input [3:0] in0;
  input [1:0] sel;
  output reg y;

  assign y = (sel == 2'b00) ? in0[0] :
             (sel == 2'b01) ? in0[1] :
             (sel == 2'b10) ? in0[2] :
                              in0[3];
endmodule