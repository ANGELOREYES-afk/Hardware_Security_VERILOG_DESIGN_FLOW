// FILE: tb_mux_demux.v
module tb_mux_demux;
    reg A, B, Sel, In; // Inputs are registers (so we can change them)
    wire Y_mux, Y0_demux, Y1_demux; // Outputs are wires

    // Instantiate Mux (Using Behavioral Version)
    mux2to1_beh u_mux (
        .A(A), .B(B), .Sel(Sel), .Y(Y_mux)
    );

    // Instantiate Demux (Using Behavioral Version)
    demux1to2_beh u_demux (
        .In(In), .Sel(Sel), .Y0(Y0_demux), .Y1(Y1_demux)
    );

    initial begin
        $dumpfile("mux_demux.vcd");
        $dumpvars(0, tb_mux_demux);
        $monitor("Time=%0t | Sel=%b | MUX(A=%b B=%b -> Y=%b) | DEMUX(In=%b -> Y0=%b Y1=%b)", 
                 $time, Sel, A, B, Y_mux, In, Y0_demux, Y1_demux);

        // Test MUX: Toggle Select to swap between A and B
        A = 0; B = 1; In = 1; Sel = 0; #10; // Expect Y_mux = 0 (A)
        Sel = 1; #10;                       // Expect Y_mux = 1 (B)

        // Test DEMUX: Toggle Select to route 'In' to Y0 or Y1
        In = 1; Sel = 0; #10; // Expect Y0=1, Y1=0
        In = 1; Sel = 1; #10; // Expect Y0=0, Y1=1
        
        $finish;
    end
endmodule
