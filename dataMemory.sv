//=======================================================
// REQ1: Pamięć danych musi posiadać sygnał zezwolenia na zapis (wrDm).
// REQ2: Pamięć danych musi być zorganizowana jako tablica o rozmiarze 2^data_mem_length słów, gdzie każde słowo ma szerokość data_mem_width bitów.
// REQ3: Pamięc danych musi posiadać asynchroniczny odczyt danych na podstawie podanego adresu.
//=======================================================

module dataMemory #(
    parameter int data_mem_length = 8,
    parameter int data_mem_width = 8
)(
    input logic wrDm, //wpis do pamieci
    input  logic [data_mem_length-1:0]  addr,
    input logic [data_mem_width-1:0] in,
    output logic [data_mem_width-1:0] out
);
    logic [data_mem_width-1:0] mem [0:(2**data_mem_length)-1];

    always_comb begin
        if(wrDm)
            mem[addr] = in;
    end

    assign out = mem[addr];
endmodule