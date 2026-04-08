module magnitude_comparator ( A, B, A_gt_B, A_lt_B, A_eq_B );
  input [3:0] A;
  input [3:0] B;
  output reg A_gt_B, A_lt_B, A_eq_B;

  always @* begin
    if (A > B) begin
      A_gt_B = 1'b1;
      A_lt_B = 1'b0;
      A_eq_B = 1'b0;
    end else if (A < B) begin
      A_gt_B = 1'b0;
      A_lt_B = 1'b1;
      A_eq_B = 1'b0;
    end else begin
      A_gt_B = 1'b0;
      A_lt_B = 1'b0;
      A_eq_B = 1'b1;
    end
  end
endmodule