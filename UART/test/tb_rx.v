// 
// Module: tb
// 
// Notes:
// - Top level simulation testbench.
// drives uart_rx with a modeled serial waveform and checks parallel output.

`timescale 1ns/1ns

module tb;
reg        clk          ; // Top level system clock input.
reg        resetn       ;
reg        uart_rxd     ; // UART Recieve pin.

reg        uart_rx_en   ; // Recieve enable
wire       uart_rx_break; // Did we get a BREAK message?
wire       uart_rx_valid; // Valid data recieved and available.
wire [7:0] uart_rx_data ; // The recieved data.

//
// Bit rate of the UART line we are testing.
localparam BIT_RATE = 115200;
localparam BIT_P    = (1000000000/BIT_RATE);

//
// Period and frequency of the system clock.
localparam CLK_HZ   = 50000000;
localparam CLK_P    = 1000000000/ CLK_HZ;

//setting clk
always begin #(CLK_P/2) clk = ~clk; end 

task send_byte;
    input [7:0] to_send;
    integer i;
    begin 
        // start bits with stalling BIT_P
        #BIT_P, uart_rxd = 1'b0; 
        for(i = 0; i < 8; i = 1 + 1) begin
            #BIT_P; uart_rxd = to_send[i];
        end 
        #BIT_P; uart_rxd = 1'b1; // stop bit 
        #1000;
    end
endtask


integer passes = 0;
integer fails = 0;

task check_byte;
    input [7:0] expected;
    begin 
        if(uart_rx_data !== expected) begin
            $display("ERROR: Expected %02x, got %02x", expected, uart_rx_data);
            fails = fails + 1;
        end else begin
            $display("PASS: Got expected %02x", expected);
            passes = passes + 1;
        end
    end
endtask

reg [7:0] to_send;
initial begin;
    // Initialize signals
    clk = 1'b0;
    resetn = 1'b0;
    uart_rxd = 1'b1; // idle state
    #50, resetn = 1'b1;

    $dumpfile(`WAVES_FILE);
    $dumpvars(0,tb);

    uart_rx_en = 1'b1;

    #1000;
    // Send a series of bytes
    repeat(10) begin
    to_send = $random;
    send_byte(to_send); check_byte(to_send);
    end

    $display("BIT RATE      : %db/s", BIT_RATE );
    $display("CLK PERIOD    : %dns" , CLK_P    );
    $display("CYCLES/BIT    : %d"   , i_uart_rx.CYCLES_PER_BIT);
    $display("SAMPLE PERIOD : %d", CLK_P *i_uart_rx.CYCLES_PER_BIT);
    $display("BIT PERIOD    : %dns" , BIT_P    );

    $display("Test Results:");
    $display("    PASSES: %d", passes);
    $display("    FAILS : %d", fails);

    $display("Finish simulation at time %d", $time);
    $finish();

end 

//
// Instance of the DUT
uart_rx #(
.BIT_RATE(BIT_RATE),
.CLK_HZ  (CLK_HZ  )
) i_uart_rx(
.clk          (clk          ), // Top level system clock input.
.resetn       (resetn       ), // Asynchronous active low reset.
.uart_rxd     (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   (uart_rx_en   ), // Recieve enable
.uart_rx_break(uart_rx_break), // Did we get a BREAK message?
.uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
.uart_rx_data (uart_rx_data )  // The recieved data.
);
endmodule

