//=======================================================
// REQ1: Rejestry ogólengo przeznaczenia muszą mieć zapis sychroniczny do narastającego zbocza zegara.
// REQ2: Rejestry ogólengo przeznaczenia muszą posiadać asynchroniczny sygnał resetu.
// REQ3: Rejestry ogólengo przeznaczenia muszą posiadać sygnał zezwolenia na zapis (ce).
//=======================================================


module register#(
    parameter int WIDTH = 8
)(
    input logic clk,
    input logic rst,
    input logic ce,
    input logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out 
);

always_ff@(posedge clk or posedge rst)begin
    if(rst)
        out <= 'd0;
    else if(ce)
        out <= in;
end

endmodule