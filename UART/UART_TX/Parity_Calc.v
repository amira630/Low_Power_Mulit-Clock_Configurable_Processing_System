module Parity_Calc(
    input  wire [7:0] P_DATA,
    input  wire       Data_Valid,
    input  wire       Par_Type, // 0: Even, 1: Odd
    output reg        parity_out
);
    // Parity Calculator
    always @(*) begin
        if (Data_Valid) begin
            if (Par_Type) begin
                parity_out = ~^P_DATA; // Odd Parity
            end else begin
                parity_out = ^P_DATA; // Even Parity
            end
        end else begin
            parity_out = 1'b0; // Default value when data is not valid
        end
    end
endmodule