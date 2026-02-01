//=======================================================
// REQ1: Porty muszą posiadać rejestr kierunku określający, kierunek (wejscie/wyjście) portu.
// REQ2: Gdy w rejestrze kierunku ustawiono 1, port działa jako wyjście.
// REQ3: Porty muszą posiadać rejestr wyjściowy do przechowywania danych do wysłania na zewnątrz.
// REQ4: Gdy port jest skonfigurowany jako wejście, jego wyjście powinno być w stanie wysokiej impedancji (high-Z).
//=======================================================

module port #(
    parameter int WIDTH = 8
)(
    input  logic clk,
    input logic rst,

    // Rejestr kierunku
    input  logic                 cePortDir,
    input  logic                 portDir,     // 1 = wyjście, 0 = wejście

    // Rejestr wyjściowy
    input  logic                 cePortOut,
    input  logic [WIDTH-1:0]     portData,

    // Port fizyczny
    output  logic  [WIDTH-1:0]   out
);

    // -------------------------
    // Rejestry wewnętrzne
    // -------------------------
    logic dir_reg;
    logic [WIDTH-1:0] out_reg;

    // -------------------------
    // Rejestr kierunku
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            dir_reg <= 'd0;
        else if (cePortDir)
            dir_reg <= portDir;
    end

    // -------------------------
    // Rejestr wyjściowy
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out_reg <= 'd0;
        if (cePortOut)
            out_reg <= portData;
    end

    //Wyjscie portu
    assign out = dir_reg ? out_reg : 1'bz;


endmodule
