`timescale 1ns/1ps

module register_tb;

    // -------------------------
    // Sygnały TB
    // -------------------------
    logic        clk;
    logic        rst;
    logic        ce_r0;
    logic [7:0]  d;
    logic [7:0]  q;

    // -------------------------
    // DUT
    // -------------------------
    register dut (
        .clk   (clk),
        .rst   (rst),
        .ce (ce_r0),
        .in     (d),
        .out     (q)
    );

    // -------------------------
    // Generator zegara
    // -------------------------
    always #5 clk = ~clk;   // 100 MHz

    // -------------------------
    // FILE DUMP (GTKWave)
    // -------------------------
    initial begin
        $dumpfile("register_tb.vcd");
        $dumpvars(0, register_tb);
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
        
        clk   = 0;
        ce_r0 = 0;
        d     = 8'h00;
        #2

        $display("=== REGISTER TB START ===");

        // ---------------------------------
        // TEST 1: zapis przy CE=1
        // ---------------------------------
        ce_r0 = 1;
        d     = 8'hA5;
        @(posedge clk);
        #2
        ce_r0 = 0;

        #1;
        assert(q == 8'hA5)
            else $error("TEST1 FAIL: expected 0xA5, got %h", q);

        // ---------------------------------
        // TEST 2: brak zapisu przy CE=0
        // ---------------------------------
        d = 8'hFF;
        @(posedge clk);
        #1;

        assert(q == 8'hA5)
            else $error("TEST2 FAIL: register changed with CE=0");

        // ---------------------------------
        // TEST 3: kolejny zapis
        // ---------------------------------
        @(posedge clk);
        ce_r0 = 1;
        d     = 8'h3C;

        @(posedge clk);
        ce_r0 = 0;

        #1;
        assert(q == 8'h3C)
            else $error("TEST3 FAIL: expected 0x3C, got %h", q);

        // ---------------------------------
        // TEST 4: szybkie zmiany danych
        // ---------------------------------
        @(posedge clk);
        ce_r0 = 1;
        d     = 8'h11;

        @(posedge clk);
        d     = 8'h22;   // zmiana przed kolejnym zboczem
        ce_r0 = 0;

        #1;
        assert(q == 8'h11)
            else $error("TEST4 FAIL: wrong captured value");

        // ---------------------------------
        // END
        // ---------------------------------
        #20;
        $display("=== REGISTER TB PASSED ===");
        $finish;
    end

endmodule
