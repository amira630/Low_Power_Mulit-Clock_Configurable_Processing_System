module Parity_Calc(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] P_DATA,
    input  wire       Capture,
    input  wire       Par_Type, // 0: Even, 1: Odd
    output reg        parity_out
);

    reg [7:0] data_reg;

    // Parity Calculator
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parity_out <= 1'b0;
            data_reg <= 8'b0;
        end
        else if (Capture) begin
            data_reg <= P_DATA;
        end
        else begin
            if (Par_Type) // Odd Parity
                parity_out <= ~^data_reg;
            else          // Even Parity
                parity_out <= ^data_reg;
        end
    end
endmodule