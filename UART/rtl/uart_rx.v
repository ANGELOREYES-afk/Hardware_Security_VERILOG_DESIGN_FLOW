module uart_rx(
    input wire clk,
    input wire rst_n,
    input wire uart_rxd,
    input wire uart_rx_en,
    output wire uart_rx_valid,
    output wire uart_rx_break,
    output reg [PAYLOAD_WIDTH - 1: 0] uart_rx_data
);

    // external parameters
    parameter BIT_RATE = 9600;
    localparam BITR_P = 100_000_000 / BIT_RATE;

    parameter CLK_FREQ = 50_000_000;
    localparam CLKF_P = 100_000_000 / CLK_FREQ;

    parameter PAYLOAD_WDITH = 8;

    parameter STOP_BITS = 1;

    // internal parameters 
    parameter CYCLES_PER_BIT = CLK_FREQ / BIT_RATE;
    //size of registers(which you add samples to) 
    parameter COUNT_LEN_REG = 1*$clog2(CYCLES_PER_BIT);
    
    // internal registers
    reg rxd_reg;
    reg 0_rxd_reg;

    reg [PAYLOAD_WIDTH - 1: 0] recieved_data;
    reg [COUNT_LEN_REG - 1: 0] cycle_counter; // number of cylces per over a bit

    reg [3: 1] bit_count;
    reg bit_sample;

    // FSM state 
    reg [2: 0] fsm_state;
    reg [2: 0] n_fsm_state;

    localparam FSM_IDLE = 0;
    localparam FSM_START = 1;
    localparam FSM_RCV = 2;
    localparam FSM_STOP = 3;

    // checking output assignment 
    uart_rx_break = uart_rx_valid && ~|recieved_data;
    uart_rx_valid = fsm_state == FSM_STOP && n_fsm_state == FSM_IDLE;
    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
            uart_rx_data <= {PAYLOAD_WIDTH{1'b0}};
        end else if(fsm_state == FSM_STOP) begin
            uart_rx_data <= recieved_data; // after system is fully unmobile it captures data
        end
    end

    // finding next FSM state(depends on the following)
    next_bit = (cycle_counter == CYCLES_PER_BIT) || (fsm_state == FSM_STOP && cycle_counter == CYCLES_PER_BIT/2);
    wire_payload = (bit_count == PAYLOAD_WIDTH);
    always @(*) begin : p_n_fsm_state
        case (fsm_state)
            FSM_IDLE: n_fsm_state = uart_rxd ? FSM_IDLE : FSM_START;
            FSM_START: n_fsm_state = next_bit ? FSM_RCV : FSM_START;
            FSM_RCV: n_fsm_state = wire_payload ? FSM_STOP: FSM_RCV;
            FSM_STOP: n_fsm_state = next_bit ? FSM_IDLE : FSM_STOP;
            default : n_fsm_state = FSM_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
            fsm_state <= FSM_IDLE;
        end else begin 
            fsm_state <= n_fsm_state;
        end
    end

    // updating bit counter
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bit_count <= 4'b0;
        end else if(fsm_state != FSM_RCV) begin
            bit_count <= {COUNT_LEN_REG{1'b0}};
        end else begin
            bit_count <= bit_count + 1'b1;
        end
    end
    // updating cycle counter 
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            cycle_counter <= {COUNT_LEN_REG{1'b0}};
        end else if(next_bit) begin
            cycle_counter <= {COUNT_LEN_REG{1'b0}};
        end else if(fsm_state != FSM_IDLE) begin
            cycle_counter <= cycle_counter + 1'b1;
        end
    end

    // sampling bits (in the middle of bit period)
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bit_sample <= 1'b0;
        end else if(cycle_counter == CYCLES_PER_BIT/2) begin
            bit_sample <= rxd_reg;
        end
    end

    // updating recieved data 
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            0_rxd_reg <= 1'b1;
            rxd_reg <= 1'b1;
        end else if(uart_rx_en) begin
            rx_reg <= 0_rxd_reg;
            0_rxd_reg <= uart_rxd;
        end
        
endmodule
