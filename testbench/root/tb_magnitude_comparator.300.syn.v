module tb_magnitude_comparator;

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
    $dumpvars(0, tb_magnitude_comparator);
end

initial begin
    A = 4'b0000;
    B = 4'b0000;
    #10;

    A = 4'b0001;
    B = 4'b0000;
    #10;

    A = 4'b0000;
    B = 4'b0001;
    #10;

    A = 4'b0010;
    B = 4'b0001;
    #10;

    A = 4'b0001;
    B = 4'b0010;
    #10;

    A = 4'b0010;
    B = 4'b0010;
    #10;

    $finish;
end

endmodule