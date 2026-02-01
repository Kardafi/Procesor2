`timescale 1ns/1ps

module accumulator_tb;

    // ===== SYGNAŁY TB =====
    logic [7:0] in;
    logic       ceAcu;
    logic       clk;
    logic       rst;
    logic [7:0] out;

    // ===== INSTANCJA DUT =====
    accumulator dut (
        .in    (in),
        .ceAcu (ceAcu),
        .clk   (clk),
        .rst   (rst),
        .out   (out)
    );

    // ===== GENERATOR ZEGARA =====
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // okres = 10ns
    end

    // ===== TESTY =====
    initial begin
        // --- dump ---
        $dumpfile("accumulator_tb.vcd");
        $dumpvars(0, accumulator_tb);

        // --- inicjalizacja ---
        rst = 1;
        @(posedge clk);
        #2;
        rst = 0;
        in    = 8'h00;
        ceAcu = 0;

        // =========================
        // TEST 1: brak CE -> brak zmiany
        // =========================
        $display("TEST 1: ceAcu = 0, brak zapisu");

        in = 8'hAA;
        @(posedge clk);
        #1;
        assert(out !== 8'hAA)
            else $fatal(1, "ERROR: out zmienilo sie bez ceAcu!");

        // =========================
        // TEST 2: zapis przy CE = 1
        // =========================
        $display("TEST 2: ceAcu = 1, zapis");

        ceAcu = 1;
        in    = 8'h55;
        @(posedge clk);
        #1;
        assert(out == 8'h55)
            else $fatal(1, "ERROR: out = %h, expected 55", out);

        // =========================
        // TEST 3: zmiana in bez CE
        // =========================
        $display("TEST 3: zmiana in bez ceAcu");

        ceAcu = 0;
        in    = 8'hFF;
        @(posedge clk);
        #1;
        assert(out == 8'h55)
            else $fatal(1, "ERROR: out zmienilo sie bez ceAcu!");

        // =========================
        // TEST 4: kilka zapisów
        // =========================
        $display("TEST 4: kolejne zapisy");

        // ceAcu = 1;
        // in    = 8'h01; @(posedge clk);
        // assert(out == 8'h01)
        //     else $fatal(1, "ERROR: out = %h, expected 01", out);

        // in    = 8'h02; @(posedge clk);
        // assert(out == 8'h02)
        //     else $fatal(1, "ERROR: out = %h, expected 02", out);

        // in    = 8'h03; @(posedge clk);
        // assert(out == 8'h03)
        //     else $fatal(1, "ERROR: out = %h, expected 03", out);

        ceAcu = 1;
        
        in = 8'h01;
        @(posedge clk);
        #1;
        assert(out == 8'h01);

        in = 8'h02;
        @(posedge clk);
        #1;
        assert(out == 8'h02);

        in = 8'h03;
        @(posedge clk);
        #1;
        assert(out == 8'h03);


        // =========================
        // KONIEC
        // =========================
        $display("\n=== ACCUMULATOR TEST PASSED ===");
        $finish;
    end

endmodule
