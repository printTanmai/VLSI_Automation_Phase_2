module magnitude_comparator_tb;

reg [3:0] A, B;
wire A_gt_B, A_lt_B, A_eq_B;

magnitude_comparator uut (
    .A(A),
    .B(B),
    .A_gt_B(A_gt_B),
    .A_lt_B(A_lt_B),
    .A_eq_B(A_eq_B)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, magnitude_comparator_tb);
end

integer i;
always begin
    for (i = 0; i < 16; i = i + 1) begin
        A = i;
        for (B = 0; B < 16; B = B + 1) begin
            #10;

            if ((A > B && !A_gt_B) || (A < B && !A_lt_B) || (A == B && !A_eq_B)) begin
                $display("ERROR: A=%d, B=%d, expected %b/%b/%b but got %b/%b/%b", A, B,
                          (A > B), (A < B), (A == B),
                          A_gt_B, A_lt_B, A_eq_B);
                $fatal(1);
            end
        end
    end

    $display("All tests passed.");
    $finish;
end

endmodule