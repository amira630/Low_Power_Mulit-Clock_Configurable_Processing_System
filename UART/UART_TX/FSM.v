module FSM(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       Data_Valid,
    input  wire       Ser_Done,
    input  wire       Par_En,
    output reg [1:0]  MUX_SEL,
    output reg        Ser_En,
    output reg        Busy,
    output reg        Capture
);

    // State Encoding
    localparam [2:0] IDLE      = 3'b000, // 0
                     START_BIT = 3'b001, // 1
                     DATA_BITS = 3'b011, // 3
                     PARITY_BIT= 3'b010, // 2
                     STOP_BIT  = 3'b110; // 6

    reg [2:0] current_state, next_state;

    // State Transition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        Capture = 1'b0;
        case (current_state)
            IDLE: begin
                if (Data_Valid) begin
                    next_state = START_BIT;
                    Capture = 1'b1; // Capture data when transitioning from IDLE
                end
                else
                    next_state = IDLE;
            end
            START_BIT: next_state = DATA_BITS;
            DATA_BITS: begin
                if (Ser_Done) begin
                    if (Par_En)
                        next_state = PARITY_BIT;
                    else
                        next_state = STOP_BIT;
                end
                else
                    next_state = DATA_BITS;
            end
            PARITY_BIT: next_state = STOP_BIT;
            STOP_BIT: begin
                if (Data_Valid) begin
                    next_state = START_BIT;
                    Capture = 1'b1; // Capture data 
                end
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output Logic
    always @(*) begin
        // Default values for outputs
        Ser_En   = 1'b0;
        Busy     = 1'b1; // Assume busy unless in IDLE

        case (current_state)
            START_BIT: begin
                MUX_SEL = 2'b00; // Start bit (0)
                Ser_En = 1'b1; // Enable Serializer
            end
            DATA_BITS: begin
                MUX_SEL = 2'b10; // Data bits from Serializer
                Ser_En = 1'b1; // Keep Serializer enabled
            end
            PARITY_BIT: begin
                MUX_SEL = 2'b11; // Parity bit from Parity Calculator
            end
            STOP_BIT: begin
                MUX_SEL = 2'b01; // Stop bit (1)
            end     
            default: begin
                MUX_SEL = 2'b01; // Default to stop bit (0)
                Busy = 1'b0; // Not busy in IDLE
            end
        endcase
    end
endmodule