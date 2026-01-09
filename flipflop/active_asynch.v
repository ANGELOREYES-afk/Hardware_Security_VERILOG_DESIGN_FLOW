// D Flip-Flop with Asynchronous Active-Low Reset
// rstn : active-low reset
// d   : data input --> for abrupt changes
// clk : clock input
// q   : data output --> depends on clk and rstn


module dff 	( input d,
              input rstn,
              input clk,
              output reg q);

	always @ (posedge clk or negedge rstn)
       if (!rstn)
          q <= 1'b0; // captures 0 right away when rest is presed(when rstm is low)
       else
          q <= d; // captures d at rising edge of clk
endmodule