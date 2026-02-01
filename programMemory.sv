//=======================================================
// REQ1: Pamięć programu musi być zorganizowana jako tablica o rozmiarze 2^prog_mem_length słów, gdzie każde słowo ma szerokość prog_mem_width bitów.
// REQ2: Pamięć programu musi posiadać asynchroniczny odczyt danych na podstawie podanego adresu.
//=======================================================

module programMemory #(
    parameter int prog_mem_length = 8,
    parameter int prog_mem_width = 13
)(
    input  logic [prog_mem_length-1:0]  addr,   // 256 adresów
    output logic [prog_mem_width-1:0] data     // instrukcja
);
    logic [12:0] mem [0:255];

    // ----------------------------------------
    // Inicjalizacja (symulacja)
    // ----------------------------------------
    initial begin
        //inicjalizacja pamieci
        $readmemb("../memfiles/mem1.mem",mem);
    end 

    assign data = mem[addr];

endmodule
