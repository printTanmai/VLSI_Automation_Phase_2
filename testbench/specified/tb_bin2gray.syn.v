module tb_bin2gray;

reg [3:0] bin;
wire [3:0] gray;

// Instantiate the DUT
bin2gray uut (
    .bin(bin),
    .gray(gray)
);

initial begin
    // Initialize signals
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_bin2gray);
    
    // Test vectors
    for (int i = 0; i < 16; i++) begin
        bin = i;
        #10;

        // Expected gray code calculation
        wire [3:0] expected_gray;
        assign expected_gray[3] = bin[3];
        assign expected_gray[2] = bin[2] ^ bin[1];
        assign expected_gray[1] = bin[2] ^ bin[1];
        assign expected_gray[0] = bin[1] ^ bin[0];

        if (gray != expected_gray) begin
            $display("ERROR: At input %h, output is %h but expected was %h", bin, gray, expected_gray);
            $fatal(1);
        end
    end
    
    // Finish simulation
    $finish;
end

endmodule