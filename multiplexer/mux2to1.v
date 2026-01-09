// FILE: mux2to1.v

// Method 1: Behavioral (Recommended for beginners)
// This uses the ternary operator, which acts like an if-else statement.
module mux2to1_beh (
    input A,      // Input 0
    input B,      // Input 1
    input Sel,    // Select Line
    output Y      // Output
);
    assign Y = (Sel) ? B : A; // If Sel is 1, choose B, else choose A
endmodule

// Method 2: Gate-Level (Good for understanding the hardware)
// This explicitly builds the AND-OR logic structure.
module mux2to1_gate (
    input A,
    input B,
    input Sel,
    output Y
);
    wire not_sel, a_path, b_path;

    not (not_sel, Sel);       // Invert Select
    and (a_path, A, not_sel); // Enable A path if Sel is 0
    and (b_path, B, Sel);     // Enable B path if Sel is 1
    or  (Y, a_path, b_path);  // Combine paths
endmodule
