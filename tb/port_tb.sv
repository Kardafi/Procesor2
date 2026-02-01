`timescale 1ns/1ps

module port_tb;

    localparam int WIDTH = 8;

    // -------------------------
    // Sygnały TB
    // -------------------------
    logic clk;
    logic rst;

    logic                 cePortDir;
    logic                 portDir;

    logic                 cePortOut;
    logic [WIDTH-1:0]     portData;

    logic [WIDTH-1:0]     out;

    // -------------------------
    // DUT
    // -------------------------
    port #(
        .WIDTH(WIDTH)
    ) dut (
        .clk        (clk),
        .rst        (rst),
        .cePortDir  (cePortDir),
        .portDir    (portDir),
        .cePortOut  (cePortOut),
        .portData   (portData),
        .out        (out)
    );

    // -------------------------
    // Zegar
    // -------------------------
    always #5 clk = ~clk;   // 100 MHz

    initial begin
        $dumpfile("port_tb.vcd");     // nazwa pliku
        $dumpvars(0, port_tb);        // dump całej hierarchii
    end


    // -------------------------
    // Test
    // -------------------------
    initial begin
        // INIT
        rst = 1;
        @(posedge clk);
        #2;
        rst = 0;

        clk        = 0;
        cePortDir  = 0;
        cePortOut  = 0;
        portDir    = 0;
        portData   = '0;

        $display("=== PORT TB START ===");

        // -------------------------------------------------
        // TEST 1: zapis kierunku = OUTPUT
        // -------------------------------------------------
        #50
        cePortDir = 1;
        portDir   = 1;
        @(posedge clk);
        #2
        cePortDir = 0;
        // -------------------------------------------------
        // TEST 2: zapis danych wyjściowych
        // -------------------------------------------------

        cePortOut = 1;
        portData  = 8'hA5;
        @(posedge clk);
        #2
        cePortOut = 0;

        #1;
        assert(out == 8'hA5)
            else $error("ERROR: OUT mismatch, expected 0xA5, got %h", out);

        // -------------------------------------------------
        // TEST 3: zmiana danych bez CE
        // -------------------------------------------------
        portData = 8'hFF;
        @(posedge clk);
        #1;

        assert(out == 8'hA5)
            else $error("ERROR: OUT changed without cePortOut");

        // -------------------------------------------------
        // TEST 4: przejście w tryb INPUT
        // -------------------------------------------------
        cePortDir = 1;
        portDir   = 0;
        @(posedge clk);
        #2
        cePortDir = 0;

        // próba zapisu danych w trybie INPUT
        #2
        cePortOut = 1;
        portData  = 8'h3C;
        @(posedge clk);
        #2
        cePortOut = 0;

        #1;
        assert(out === {WIDTH{1'bz}})
            else $error("ERROR: OUT is not Z while portDir=0");

        // -------------------------------------------------
        // TEST 5: powrót do OUTPUT
        // -------------------------------------------------
        #100
        cePortDir = 1;
        portDir   = 1;
        #2
        @(posedge clk);
        #2
        cePortDir = 0;
        #2

        @(posedge clk);
        #2
        cePortOut = 1;
        portData  = 8'h55;
        #2
        @(posedge clk);
        #2
        cePortOut = 0;

        #1;
        assert(out == 8'h55)
            else $error("ERROR: OUT mismatch after re-enabling OUTPUT");

        // -------------------------------------------------
        // KONIEC
        // -------------------------------------------------
        #20;
        $display("=== PORT TB PASSED ===");
        $finish;
    end

endmodule
