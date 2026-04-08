module tb_bin2gray;

reg [3:0] bin;
wire [3:0] gray;

bin2gray uut (
    .bin(bin),
    .gray(gray)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_bin2gray);
end

task check_output;
    input [3:0] expected_gray;
    if (expected_gray != gray) begin
        $display("ERROR: bin=%h, expected_gray=%h, actual_gray=%h", bin, expected_gray, gray);
        $fatal(1);
    end
endtask

initial begin
    for (int i = 0; i < 16; i++) begin
        bin = i;
        #10;
        check_output(i ^ (i >> 1));
    end
    $display("All tests passed.");
    $finish;
end

endmodule