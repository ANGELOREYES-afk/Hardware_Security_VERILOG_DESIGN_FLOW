module uart_tx(
    input wire clk,
    input wire rst_n,
    input wire uart_tx_en,
    input wire [PAYLOAD_WIDTH - 1: 0] uart_tx_data,
    output wire uart_txd,
    output wire uart_busy
);
    // external parameters 
    parameter BIT_RATE = 9600;
    localparam BITR_P = 100_000_000 / BIT_RATE;

    parameter CLK_FREQ = 50_000_000;
    localparam CLKF_P = 100_000_000 / CLK_FREQ;

    parameter PAYLOAD_WIDTH = 8;
    parameter STOP_BITS = 1;

    //internal parameters
    parameter CYCLES_PER_BIT = CLK_FREQ / BIT_RATE;
    // size of registers(which you add samples to) --> bit durations
    parameter COUNT_LEN_REG = 1*$clog2(CYCLES_PER_BIT); 

    //internal registers 
    reg txd_reg;
    reg [PAYLOAD_WIDTH - 1: 0] data_to_send;
    reg [COUNT_LEN_REG - 1: 0] cycle_counter; 
    reg [3: 0] bit_counter;

    // FSM state 
    reg [2: 0] fsm_state;
    reg [2: 0] n_fsm_state;

    localparam FSM_IDLE = 0;
    localparam FSM_START = 1;
    localparam FSM_SEND = 2;
    localparam FSM_STOP = 3;

    assign uart_busy = fsm_state != FSM_IDLE;
    assign uart_txd = txd_reg;

    wire next_bit = (cycle_counter == CYCLES_PER_BIT);
    wire payload_done = (bit_counter == PAYLOAD_WIDTH);
    wire stop_done = (bit_counter == STOP_BITS) && (fsm_state == FSM_STOP);

    always @(*) begin : p_n_fsm_state
        case(fsm_state)
            FSM_IDLE: n_fsm_state = uart_tx_en ? FSM_START: FSM_IDLE;
            FSM_START: n_fsm_state = next_bit ? FSM_SEND : FSM_START;
            FSM_SEND: n_fsm_state = payload_done ? FSM_STOP: FSM_SEND;
            FSM_STOP: n_fsm_state = stop_done ? FSM_IDLE: FSM_STOP;
            default: n_fsm_state = FSM_IDLE;
        endcase
    end

    // setting all the registers 

    // setting data to send register
    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin 
            data_to_send <= {PAYLOAD_WIDTH{1'b0}};
        end else if(fsm_state == FSM_IDLE && uart_tx_end) begin
            data_to_send <= {PAYLOAD_WIDTH{1'b0}};
        end else if(fsm_state == FSM_SEND && next_bit) begin
            for(i = PAYLOAD_WIDTH - 2; i >= 0; i = i - 1) begin
                data_to_send[i] <= data_to_send[i+1];
            end
        end
    end

    // incrementing bit counter 
    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin 
            bit_counter <= 0;
        end else if(fsm_state == FSM_STOP && next_bit) begin
            bit_counter <= bit_counter + 1;
        end else if(fsm_state == FSM_SEND && next_bit) begin
            bit_counter <= bit_counter + 1;
        end else if(fsm_state == FSM_SEND && n_fsm_state == FSM_IDLE) begin 
            bit_counter <= 0;
        end else if(fsm_state != FSM_SEND && fsm_state != FSM_STOP) begin 
            bit_counter <= 0;
        end
    end

    // updating cycle counter 
    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin 
            cycle_counter <= 0;
        end else if(next_bit) begin 
            cycle_counter <= 0;
        end else if(fsm_state != FSM_IDLE) begin 
            cycle_counter <= cycle_counter + 1;
        end
    end 

    // updating fsm_state
    always @(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin 
            fsm_state <= FSM_IDLE;
        end else begin 
            fsm_state <= n_fsm_state;
        end
    end

    // updating internal register txd_reg
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rxd_reg <= 1'b1;
        end else if(fsm_state == FSM_IDLE) begin 
            txd_reg <= 1'b1;
        end else if(fsm_state == FSM_START) begin 
            txd_reg <= 1'b0;
        end else if(fsm_state == FSM_SEND) begin 
            txd_reg <= data_to_send[0];
        end else if(fsm_state == FSM_STOP) begin 
            txd_reg <= 1'b1;
        end
    end


    
endmodule