`timescale 1ns/1ps


module tb_sync_fifo;
    reg clk_wr;
    reg rstn;
    reg rd_en;
    reg wr_en;
    reg [7:0] d_in;
    wire [7:0] d_out;
    wire full;
    wire empty;
    localparam DEPTH      = 8;
    localparam DATA_WIDTH = 16;

    // DUT interface
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk_wr(clk_wr),
        .rstn(rstn),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .d_in(d_in),
        .d_out(d_out),
        .full(full),
        .empty(empty)
    );
    // generating clock
    initial begin
        clk_wr = 0;
        forever #5 clk_wr = ~clk_wr; // 10 time units clock period
    end

    //indexing
    integer i;

    initial begin 
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        //initial values 
        rd_en = 0;
        wr_en = 0;
        rstn = 0;
        d_in = 0;

        #20;
        rstn = 1; // release reset
        #10;

        // filling fifo now
        $display("FILLING FIFO");
        for(i = 0; i < DEPTH; i = i + 1) begin
            @(negedge clk_wr);
            wr_en = 1; 
            rd_en = 0;
            d_in = 16`h10;
            @(negedge clk_wr);
            $display("Written data: %0d with full: %b, empty: %b", d_in, full, empty);
        end
        @(negedge clk_wr);
        wr_en = 0;
        // stop writing for sec

        //try writing when full(given we for looped with 16 iterations)
        @(negedge clk_wr);
        wr_en = 1;
        d_in=16`h20;
        @(negedge clk_wr);
        wr_en = 0;
        $display("Tried writing when full: Written data: %0d with full: %b, empty: %b", d_in, full, empty);

        // empty fifo now
        for(i=0; i < DEPTH; i = i + 1) begin
            @(negedge clk_wr);
            rd_en = 1;
            wr_en = 0; 
            @(negedge clk_wr);
            $display("Read data: %0d with full: %b, empty: %b", d_out, full, empty);
        end

        @(negedge clk_wr);
        rd_en = 1;
        @(negedge clk_wr);
        rd_en = 0;
        $display("Tried reading when empty: Read data: %0d with full: %b, empty: %b", d_out, full, empty);
        #20;
        $finish;
    end
endmodule


