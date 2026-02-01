`timescale 1ns/1ps

module programMemory_tb;

    // -------------------------
    // Sygnały TB
    // -------------------------
    logic [7:0]  addr;
    logic [12:0] data;

    // -------------------------
    // DUT
    // -------------------------
    programMemory dut (
        .addr(addr),
        .data(data)
    );

    // -------------------------
    // FILE DUMP (GTKWave)
    // -------------------------
    initial begin
        $dumpfile("programMemory_tb.vcd");
        $dumpvars(0, programMemory_tb);
    end

    // -------------------------
    // Test
    // -------------------------
    initial begin
        $display("=== PROGRAM MEMORY TB START ===");

        // -------------------------
        // Test 0: adres 0
        // -------------------------
        addr = 8'h00;
        #1;
        assert(data == 13'b000_000000001)
            else $error("ADDR 0x00: expected 000_000000001, got %b", data);

        // -------------------------
        // Test 1: adres 1
        // -------------------------
        addr = 8'h01;
        #1;
        assert(data == 13'b001_000000010)
            else $error("ADDR 0x01: expected 001_000000010, got %b", data);

        // -------------------------
        // Test 2: adres 2
        // -------------------------
        addr = 8'h02;
        #1;
        assert(data == 13'b010_000000100)
            else $error("ADDR 0x02: expected 010_000000100, got %b", data);

        // -------------------------
        // Test 3: adres 3
        // -------------------------
        addr = 8'h03;
        #1;
        assert(data == 13'b111_000000000)
            else $error("ADDR 0x03: expected 111_000000000, got %b", data);

        // -------------------------
        // Test 4: niezainicjalizowany adres
        // -------------------------
        addr = 8'h10;
        #1;
        assert(data == 13'b0)
            else $error("ADDR 0x10: expected 0, got %b", data);

        // -------------------------
        // Szybka zmiana adresu (async!)
        // -------------------------
        addr = 8'h00; #1;
        addr = 8'h01; #1;
        addr = 8'h02; #1;
        addr = 8'h03; #1;

        $display("=== PROGRAM MEMORY TB PASSED ===");
        #10;
        $finish;
    end

endmodule
