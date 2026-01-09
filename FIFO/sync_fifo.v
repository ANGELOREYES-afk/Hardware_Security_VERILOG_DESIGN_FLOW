module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input wire clk_wr,
    input wire rstn,
    input wire rd_en,
    input wire wr_en,
    input wire [DATA_WIDTH-1:0] d_in, 
    output reg [DATA_WIDTH-1:0] d_out,
    output wire full,
    output wire empty
);
    // signal and internal memory declaration
    reg [$clog2(DEPTH)-1:0] wr_ptr;
    reg [$clog2(DEPTH)-1:0] rd_ptr;

    // getting RAM with each having data width of DATA_WDITH and depth of DEPTH
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1]; 

    // a more simple way of implementing FIFO full or empty flag
    reg [$clog2(DEPTH):0] count;

    // writing logic
    always @(posedge clk_wr or negedge rstn) begin
        if(!rstn) begin
            wr_ptr <=0;
        end else if(wr_en && !full) begin
            fifo_mem[wr_ptr] <= d_in;
            wr_ptr <= wr_ptr + 1; 
        count <= count + (wr_en && !full) - (rd_en && !empty);
        end
    end
    
    // reading logic
    always @(posedge clk_wr or negedge rstn) begin
        if(!rstn) begin
            rd_ptr <=0;
        end else if(rd_en && !empty) begin
            d_out <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end
    
    // counting logic 
    always @(posedge clk_wr or negedge rstn) begin
        if(!rstn) begin
            count <= 0;
        end else begin 
            case({wr_en && !full, rd_en && !empty}) 
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end 
    end

    // manipulate output values for end goal
    assign full = (count == DEPTH);
    assign empty = (count == 0);

endmodule