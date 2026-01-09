module tb_dff;
	reg clk;
	reg d;
	reg rstn;
	reg [2:0] delay; // 2-bit delay for random intervals
    wire q;

    dff  dff0 ( .d(d),
                .rstn (rstn),
                .clk (clk),
                .q (q));

    // Generate clock
    // always #10 clk = ~clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end // 
    // Testcase
    initial begin
        $dumpfile("tb_dff.vcd");
        $dumpvars(0, tb_dff);

    	clk <= 0;
    	d <= 0;
    	rstn <= 0;

    	#15 d <= 1; // set d before releasing reset
    	#10 rstn <= 1; // release reset
    	for (int i = 0; i < 5; i=i+1) begin
    		delay = $random;
    		#(delay) d <= i; // change d at random intervals
    	end
        $finish;
    end
endmodule