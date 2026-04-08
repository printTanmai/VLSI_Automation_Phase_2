module magnitude_comparator (
    input [3:0] A,
    input [3:0] B,
    output reg  A_gt_B,
    output reg  A_lt_B,
    output reg  A_eq_B
);

always @(*) begin
    if (A[3] > B[3]) begin
        A_gt_B = 1'b1;
        A_lt_B = 1'b0;
        A_eq_B = 1'b0;
    end else if (A[3] < B[3]) begin
        A_gt_B = 1'b0;
        A_lt_B = 1'b1;
        A_eq_B = 1'b0;
    end else begin
        if (A[2] > B[2]) begin
            A_gt_B = 1'b1;
            A_lt_B = 1'b0;
            A_eq_B = 1'b0;
        end else if (A[2] < B[2]) begin
            A_gt_B = 1'b0;
            A_lt_B = 1'b1;
            A_eq_B = 1'b0;
        end else begin
            if (A[1] > B[1]) begin
                A_gt_B = 1'b1;
                A_lt_B = 1'b0;
                A_eq_B = 1'b0;
            end else if (A[1] < B[1]) begin
                A_gt_B = 1'b0;
                A_lt_B = 1'b1;
                A_eq_B = 1'b0;
            end else begin
                if (A[0] > B[0]) begin
                    A_gt_B = 1'b1;
                    A_lt_B = 1'b0;
                    A_eq_B = 1'b0;
                end else if (A[0] < B[0]) begin
                    A_gt_B = 1'b0;
                    A_lt_B = 1'b1;
                    A_eq_B = 1'b0;
                end else begin
                    A_gt_B = 1'b0;
                    A_lt_B = 1'b0;
                    A_eq_B = 1'b1;
                end
            end
        end
    end
end

endmodule