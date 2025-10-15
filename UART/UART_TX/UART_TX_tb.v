`timescale 1ns/1ps
module UART_TX_tb();

    /////////////////////////////////////////////////////////
    ///////////////////// Parameters ////////////////////////
    /////////////////////////////////////////////////////////

    parameter CLOCK_PERIOD = 5; // Clock period in ns
    reg [3:0] count;
    integer correct, error;

    /////////////////////////////////////////////////////////
    /////////// Testbench Signal Declaration ////////////////
    /////////////////////////////////////////////////////////

    reg        clk_tb, rst_n_tb;
    reg [7:0]  P_DATA_tb;
    reg        Data_Valid_tb, Par_En_tb, Par_Typ_tb;
    wire       TX_OUT_tb, Busy_tb;

    reg        TX_OUT_expec, Busy_expec, Busy_expec_temp, done;
    reg [7:0]  P_DATA_reg;

    ////////////////////////////////////////////////////////
    /////////////////// DUT Instantation ///////////////////
    ////////////////////////////////////////////////////////

    UART_TX DUT (
        .clk(clk_tb),
        .rst_n(rst_n_tb),
        .P_DATA(P_DATA_tb),
        .Data_Valid(Data_Valid_tb),
        .Par_En(Par_En_tb),
        .Par_Typ(Par_Typ_tb), 
        .TX_OUT(TX_OUT_tb),
        .Busy(Busy_tb)
    );
    ////////////////////////////////////////////////////////
    ////////////////// Clock Generator  ////////////////////
    ////////////////////////////////////////////////////////

    always #(CLOCK_PERIOD/2) clk_tb = ~clk_tb;

    ////////////////////////////////////////////////////////
    /////////// Applying Stimulus on Inputs //////////////// 
    ////////////////////////////////////////////////////////

    initial begin
        // System Functions
        $dumpfile("UART_TX.vcd");
        $dumpvars;

        // initialization
        initialize();
        check_out();

        $display("Start of Odd Parity Testing at %0t", $time);
        
        repeat(50) begin
            @(negedge clk_tb);
            Data_Valid_tb = $random;
            P_DATA_tb = $random;
            Par_En_tb = 1'b1; // Parity enabled
            Par_Typ_tb = 1'b1; // Odd Parity
            if (Data_Valid_tb) 
                $display("Data Valid at time %0t with P_DATA = %b", $time, P_DATA_tb);
            // @(negedge clk_tb);
            check_out(); 
        end

        $display("Start of Even Parity Testing at %0t", $time);
                
        repeat(50) begin
            @(negedge clk_tb);
            Data_Valid_tb = $random;
            P_DATA_tb = $random;
            Par_En_tb = 1'b1; // Parity enabled
            Par_Typ_tb = 1'b0; // Even Parity
            // @(negedge clk_tb);
            if (Data_Valid_tb) 
                $display("Data Valid at time %0t with P_DATA = %b", $time, P_DATA_tb);
            check_out(); 
        end

        $display("Start of no Parity Testing at %0t", $time);
        
        repeat(25) begin
            @(negedge clk_tb);
            Data_Valid_tb = $random;
            P_DATA_tb = $random;
            Par_En_tb = 1'b0; // Parity Disabled
            Par_Typ_tb = 1'b1; // Odd Parity
            // @(negedge clk_tb);
            if (Data_Valid_tb) 
                $display("Data Valid at time %0t with P_DATA = %b", $time, P_DATA_tb);
            check_out(); 
        end

        repeat(25) begin
            @(negedge clk_tb);
            Data_Valid_tb = $random;
            P_DATA_tb = $random;
            Par_En_tb = 1'b0; // Parity Disabled
            Par_Typ_tb = 1'b0; // Even Parity
            // @(negedge clk_tb);
            if (Data_Valid_tb) 
                $display("Data Valid at time %0t with P_DATA = %b", $time, P_DATA_tb);
            check_out(); 
        end
         Data_Valid_tb = 1'b0;
        #(20*CLOCK_PERIOD)
        $display("Simulation Ended with %0d correct and %0d errors", correct, error);
        $stop;
    end

    ////////////////////////////////////////////////////////
    /////////////////////// TASKS //////////////////////////
    ////////////////////////////////////////////////////////

    /////////////// Signals Initialization //////////////////

    task initialize;
        begin
            count = 0;
            correct = 0;
            error = 0;
            done = 1'b0;
            clk_tb  	  = 1'b0;
            Data_Valid_tb = 1'b0;
            P_DATA_tb     = 8'hFF;
            Par_En_tb     = 1'b0; // Parity Disabled
            Par_Typ_tb    = 1'b0; // Even Parity
            TX_OUT_expec = 1'b1; // Assuming TX_OUT is high during reset
            Busy_expec = 1'b0; // Not busy during reset
            Busy_expec_temp = 1'b0;
            reset();
        end	
    endtask

    ///////////////////////// RESET /////////////////////////

    task reset;
        begin
            rst_n_tb = 1'b1;
            @(negedge clk_tb)
            rst_n_tb = 1'b0;
            @(negedge clk_tb)
            rst_n_tb = 1'b1;
        end
    endtask

    ////////////////// Check Out Response  ////////////////////

    task check_out;
        begin
            if(!rst_n_tb) begin
                // During Reset
                TX_OUT_expec = 1'b1; // Assuming TX_OUT is high during reset
                Busy_expec = 1'b0; // Not busy during reset
                Busy_expec_temp = 1'b0;
                P_DATA_reg = 8'b0; // Clear stored data
                count = 0; // Reset count for next transmission
                done = 1'b0; // Reset done for next transmission
            end
            else if (Data_Valid_tb && !Busy_expec) begin
                // When Data is Valid, TX_OUT should start transmitting
                P_DATA_reg = P_DATA_tb; // Store the data for calculation
                Busy_expec_temp = 1'b1; // Indicate start of transmission
            end
            else if (Busy_expec_temp) begin
                TX_OUT_expec = 1'b0; // Start bit
                if (count == 9) begin// After sending all data bits
                    if (Par_En_tb && !done) begin
                        if (Par_Typ_tb) // Odd Parity
                            TX_OUT_expec = ~^P_DATA_reg; // Calculate odd parity
                        else          // Even Parity
                            TX_OUT_expec = ^P_DATA_reg; // Calculate even parity
                        done = 1'b1; // Indicate transmission done
                    end else if (!Par_En_tb || done)  begin
                        TX_OUT_expec = 1'b1; // Stop bit
                        Busy_expec_temp = 1'b0;
                        done = 1'b0; // Reset done for next transmission
                        count = 0; // Reset count for next transmission
                        if (Data_Valid_tb) begin
                            P_DATA_reg = P_DATA_tb; // Store the data for calculation
                            Busy_expec_temp = 1'b1;
                        end
                    end
                end else if (count != 0) begin
                    TX_OUT_expec = P_DATA_reg[count-1]; // Serial state
                    count = count + 1; // Increment count for next bit
                end
                else begin
                    count = count + 1; // Increment count for next bit
                end
            end else begin
                // Idle State
                TX_OUT_expec = 1'b1; // Idle state
                Busy_expec_temp = 1'b0; // Not busy
                count = 0; // Reset count for next transmission
            end
            // Check if the outputs match the expected values
            if(TX_OUT_tb === TX_OUT_expec && Busy_tb === Busy_expec) begin
                $display("Test Case has succeeded");
                correct = correct + 1;
            end else begin
                $display("Test Case has failed at %0t", $time);
                error = error + 1;
            end
            Busy_expec = Busy_expec_temp; // Update Busy_expec for next cycle
        end
    endtask

endmodule