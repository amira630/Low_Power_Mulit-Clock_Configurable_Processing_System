vlib work
vlog FSM.v Serializer.v Parity_Calc.v MUX4x1.v UART_TX.v UART_TX_tb.v
vsim -voptargs=+acc work.UART_TX_tb
add wave *
add wave -position insertpoint  \
sim:/UART_TX_tb/DUT/U0/current_state \
sim:/UART_TX_tb/DUT/U0/next_state
run -all