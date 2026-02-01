//=======================================================
// REQ1: ALU musi realizować operacje zgodnie z tabelą funkcji ALU (dokumentacja).
// REQ2: ALU musi generować flage przeniesienia (flag_c_alu) dla operacji dodawania, odejmowania, incrementacji oraz dekrementacji równą 1, gdy wystąpi przeniesienie poza zakres reprezentacji liczby.
// REQ3: ALU musi generować flage zerową (flag_z_alu) równą 1, gdy wynik operacji jest równy zero.
// REQ4: ALU musi generować flage znaku (flag_s_alu) równą 1, gdy wynik operacji jest liczbą ujemną w reprezentacji znak-moduł.
// REQ5: ALU musi generować flage przepełnienia (flag_v_alu) równą 1, gdy wystąpi przepełnienie arytmetyczne dla operacji dodawania i odejmowania liczb ze znakiem.
// REQ6: ALU musi obsługiwać sygnał przeniesienia (carry_in) dla operacji dodawania i odejmowania z przeniesieniem.
// REQ7: ALU musi być modułem kombinacyjnym bez elementów pamiętających stan.
//=======================================================


`include "../alu_defs.sv"

module alu #(
    parameter int WIDTH = 8
)(
    input [WIDTH-1:0] data,
    input [WIDTH-1:0] from_accumulator,
    input [3:0] aluOper,
    input logic carry_in,  // for addc and subc operations

    output logic [WIDTH-1:0] out, 

    // flagi
    output logic             flag_c_alu,   // Carry
    output logic             flag_z_alu,   // Zero
    output logic             flag_s_alu,   // Sign
    output logic             flag_v_alu,   // Overflow
    output logic             flag_p_alu    // Parity
);

always @(*) begin
    out = 'd0;
    flag_c_alu = 1'b0;

    case(aluOper)
        moveCode:
            out = data;
        incrementCode:
            {flag_c_alu, out} = from_accumulator + 1;
        addCode:
            {flag_c_alu, out} = data + from_accumulator;
        subCode:
            {flag_c_alu, out} = from_accumulator - data;
        andCode:
            out = data & from_accumulator;
        orCode:
            out = data | from_accumulator;
        xorCode:
            out = data ^ from_accumulator;
        notCode:
            out = ~from_accumulator;
        addcCode:
            {flag_c_alu, out} = data + from_accumulator + carry_in;
        subcCode:
            {flag_c_alu, out} = from_accumulator - data - carry_in;
        decrementCode:
            {flag_c_alu, out} = from_accumulator - 1;
    endcase

    flag_z_alu = (out == 'd0);
    flag_s_alu = out[WIDTH-1];
    flag_v_alu = (data[WIDTH-1] & from_accumulator[WIDTH-1] & ~out[WIDTH-1]) | (~data[WIDTH-1] & ~from_accumulator[WIDTH-1] & out[WIDTH-1]);
    flag_p_alu = ~^out;   // parzysta liczba jedynek to flag_p = 1

end

endmodule