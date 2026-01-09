// FILE: demux1to2.v

// Method 1: Behavioral
module demux1to2_beh (
    input In,
    input Sel,
    output Y0,
    output Y1
);
    // If Sel is 0, send In to Y0, else Y0 is 0
    assign Y0 = (Sel == 0) ? In : 0;
    // If Sel is 1, send In to Y1, else Y1 is 0
    assign Y1 = (Sel == 1) ? In : 0;
endmodule

// Method 2: Gate-Level
module demux1to2_gate (
    input In,
    input Sel,
    output Y0,
    output Y1
);
    wire not_sel;

    not (not_sel, Sel);
    and (Y0, In, not_sel); // Pass 'In' to Y0 only if Sel is 0
    and (Y1, In, Sel);     // Pass 'In' to Y1 only if Sel is 1
endmodule
