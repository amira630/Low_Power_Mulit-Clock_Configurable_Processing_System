module Serializer(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] P_DATA,
    input  wire       Ser_En,
    output reg        Ser_Data,
    output reg        Ser_Done
);

reg [7:0] data_reg;
reg       start;
reg [3:0] bit_count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Ser_Data <= 1'b0;
        Ser_Done <= 1'b0;
        start <= 1'b0;
        bit_count <= 3'b0;
        data_reg <= 8'b0;
    end else if (Ser_En) begin
        // Serialization logic
        if (start) begin
            Ser_Data <= data_reg[bit_count];
            if (&bit_count) begin // All bits sent
                Ser_Done <= 1'b1;  
                start <= 1'b0;
            end
            else
                bit_count <= bit_count + 1;
        end else 
            start <= 1'b1; // Indicates the start of bit sending   
    end else begin
        data_reg <= P_DATA;
        start <= 1'b0;
        Ser_Done <= 1'b0;
        bit_count <= 3'b0;
    end
end

endmodule