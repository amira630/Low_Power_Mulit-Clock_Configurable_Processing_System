module UART_TX(
    input wire        clk,
    input wire        rst_n,
    input wire [7:0]  P_DATA,
    input wire        Data_Valid,
    input wire        Par_En,
    input wire        Par_Typ, // 0: Even, 1: Odd
    output wire       TX_OUT,
    output wire       Busy
);

    wire [1:0] mux_sel;
    wire       ser_en, ser_done, capture, s_data, parity;

    FSM U0 (
        .clk(clk),
        .rst_n(rst_n),
        .Data_Valid(Data_Valid),
        .Ser_Done(ser_done),
        .Par_En(Par_En),
        .MUX_SEL(mux_sel),
        .Ser_En(ser_en),
        .Busy(Busy),
        .Capture(capture)
    );

    Serializer U1 (
        .clk(clk),
        .rst_n(rst_n),
        .P_DATA(P_DATA),
        .Ser_En(ser_en),
        .Ser_Data(s_data),
        .Ser_Done(ser_done)
    );

    Parity_Calc U2 (
        .clk(clk),
        .rst_n(rst_n),
        .P_DATA(P_DATA),
        .Capture(capture),
        .Par_Type(Par_Typ),
        .parity_out(parity)
    );

    MUX4x1 U3 (
        .Ser_Data(s_data),
        .Par_Bit(parity),
        .SEL(mux_sel),
        .OUT(TX_OUT)
    );

endmodule