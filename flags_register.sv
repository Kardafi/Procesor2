//=======================================================
// REQ1: Rejestr flag musi mieć zapis synchroniczny do narastającego zbocza zegara.
// REQ2: Rejestr flag musi posiadać asynchroniczny sygnał resetu.
// REQ3: Rejestr flag musi posiadać sygnał zezwolenia na zapis (ceFlags).
//=======================================================

module flags_register (
    input  logic        clk,
    input  logic        rst,        // reset synchroniczny
    input  logic        ceFlags,   // enable zapisu flag

    // flagi z ALU (kombinacyjne)
    input  logic        flag_c_alu,     // Carry
    input  logic        flag_z_alu,     // Zero
    input  logic        flag_s_alu,     // Sign
    input  logic        flag_v_alu,     // Overflow
    input  logic        flag_p_alu,     // Parity

    output logic        flag_c_out,     // Carry
    output logic        flag_z_out,     // Zero
    output logic        flag_s_out,     // Sign
    output logic        flag_v_out,     // Overflow
    output logic        flag_p_out     // Parity
);

    always_ff @(posedge clk) begin
        if (rst) begin
            flag_c_out <= 0;
            flag_z_out <= 0;
            flag_s_out <= 0;
            flag_v_out <= 0;
            flag_p_out <= 0;
        end
        else if (ceFlags) begin
            flag_c_out <= flag_c_alu;
            flag_z_out <= flag_z_alu;
            flag_s_out <= flag_s_alu;
            flag_v_out <= flag_v_alu;
            flag_p_out <= flag_p_alu;
        end
    end

endmodule
