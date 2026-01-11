// connects uart_rx and uart_tx through clk and reset inputs
// no fpga for now, so cant implement but heres what a normal file would look like
module top_impl (
    input wire clk,
    input wire sw_0,
    input wire sw_1,
    input wire uart_rxd,
    output wire uart_txd,
    output wire [7: 0] led
);
    // Clock frequency in hertz.
    parameter CLK_HZ = 50000000;
    parameter BIT_RATE =   9600;
    parameter PAYLOAD_BITS = 8;

    wire [PAYLOAD_BITS-1:0]  uart_rx_data;
    wire        uart_rx_valid;
    wire        uart_rx_break;

    wire        uart_tx_busy;
    wire [PAYLOAD_BITS-1:0]  uart_tx_data;
    wire        uart_tx_en;

    reg  [PAYLOAD_BITS-1:0]  led_reg;
    assign      led = led_reg;

    