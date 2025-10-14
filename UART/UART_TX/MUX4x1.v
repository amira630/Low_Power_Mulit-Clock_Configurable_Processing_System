module MUX4x1 (
    input  wire       Ser_Data, // Serial Data Input
    input  wire       Par_Bit,  // Parity Bit Input         
    input  wire [1:0] SEL,      // 2-bit select input
    output reg        OUT       // Output
);
    always @(*) begin
        case (SEL)
            2'b00: OUT = 1'b0;
            2'b01: OUT = 1'b1;
            2'b10: OUT = Ser_Data;
            2'b11: OUT = Par_Bit;
            default: OUT = 1'b1; // Default case (should not occur)
        endcase
    end
endmodule