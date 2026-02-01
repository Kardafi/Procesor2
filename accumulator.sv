//=======================================================
// REQ1: Akumulator musi mieć zapis synchroniczny do narastającego zbocza zegara.
// REQ2: Akumulator musi posiadać asynchroniczny sygnał resetu.
// REQ3: Akumulator musi posiadać sygnał zezwolenia na zapis (ce).
//=======================================================

module accumulator #(
    parameter int WIDTH = 8
)(
    input [WIDTH-1:0] in,
    input ceAcu,
    input clk,
    input rst,

    output logic [WIDTH-1:0] out
);

always @(posedge clk or posedge rst) begin
    if(rst)
        out <='d0;
    else if(ceAcu)begin
        out <= in;
    end

end



endmodule