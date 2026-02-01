`timescale 1ns/1ps

module top_tb;

    localparam int WIDTH = 8;

    logic clk;
    logic rst;

    logic [WIDTH-1:0] portAwire;
    logic [WIDTH-1:0] portBwire;
    logic [WIDTH-1:0] portCwire;
    logic [WIDTH-1:0] portDwire;

    // =========================
    // DUT
    // =========================
    top dut (
        .clk(clk),
        .rst(rst),
        .portAwire(portAwire),
        .portBwire(portBwire),
        .portCwire(portCwire),
        .portDwire(portDwire)
    );

    // =========================
    // CLOCK
    // =========================
    initial clk = 0;
    always #5 clk = ~clk;   // 100 MHz

    // =========================
    // WAVEFORM DUMP
    // =========================
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

    // =========================
    // SIMULATION CONTROL
    // =========================
    initial begin
        $display("=== START SIMULATION ===");

        rst = 1;
        @(posedge clk);
        #2;
        rst=0;

        // symulacja ~200 cykli
        #2000;

        //assert(portCwire == 8'b11101101)else $error("Zla wartosc portu C!!!!!");

        $display("=== END SIMULATION ===");


        $finish;
    end

    // =========================
    // MONITOR (opcjonalne)
    // =========================
    always @(posedge clk) begin
        $display("t=%0t | PA=%h PB=%h PC=%h PD=%h | ACC=%h PC=%0d",
                 $time,
                 portAwire,
                 portBwire,
                 portCwire,
                 portDwire,
                 dut.accumulatorOut,
                 dut.adrProgMem);
    end

endmodule
