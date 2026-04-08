module tb_magnitude_comparator;
  reg  [3:0] A;
  reg  [3:0] B;
  wire A_gt_B, A_lt_B, A_eq_B;

  magnitude_comparator dut (
    .A(A),
    .B(B),
    .A_gt_B(A_gt_B),
    .A_lt_B(A_lt_B),
    .A_eq_B(A_eq_B)
  );

  integer i, j, errors;

  initial begin
    errors = 0;
    A = 4'd0;
    B = 4'd0;
    $dumpfile("tb_magnitude_comparator.vcd");
    $dumpvars(0, tb_magnitude_comparator);

    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        A = i[3:0];
        B = j[3:0];
        #1;
        if ((A_gt_B !== (A > B)) ||
            (A_lt_B !== (A < B)) ||
            (A_eq_B !== (A == B))) begin
          $display("Mismatch: A=%0d B=%0d | gt=%b lt=%b eq=%b", A, B, A_gt_B, A_lt_B, A_eq_B);
          errors = errors + 1;
        end
        #9;
      end
    end

    if (errors == 0) $display("All tests passed.");
    else $display("Errors: %0d", errors);
    $finish;
  end
endmodule