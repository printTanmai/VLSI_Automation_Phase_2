module full_adder_4bit (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output reg [3:0] sum,
    output reg cout
);

always @(*) begin
    // Full adder logic for each bit
    sum[0] = a[0] ^ b[0] ^ cin;
    sum[1] = (a[0] & b[0]) | ((a[0] ^ b[0]) & cin) | (b[1] & a[1]);
    sum[2] = (a[1] & b[1]) | ((a[1] ^ b[1]) & cin) | (a[2] & b[2]);
    sum[3] = (a[2] & b[2]) | ((a[2] ^ b[2]) & cin) | (a[3] & b[3]);

    // Carry out calculation
    cout = (a[0] & b[0]) | ((a[0] ^ b[0]) & cin) | (b[1] & a[1])
        | (a[2] & b[2]) | ((a[2] ^ b[2]) & cin) | (a[3] & b[3]);
end

endmodule