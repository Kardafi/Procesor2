`timescale 1ns/1ps


module alu_tb;

    // ===== SYGNAŁY =====
    logic [7:0] data;
    logic [7:0] from_accumulator;
    logic [2:0] aluOpe;
    logic [7:0] out;

    // ===== DUT =====
    alu dut (
        .data(data),
        .from_accumulator(from_accumulator),
        .aluOpe(aluOpe),
        .out(out)
    );

    // ===== TASK DO SPRAWDZANIA =====
    task automatic check(
        input string name,
        input [7:0] expected
    );
        #1;
        assert(out === expected)
            else $fatal(1,
                "%s FAILED: out=%0h expected=%0h (data=%0h acu=%0h)",
                name, out, expected, data, from_accumulator
            );
        $display("%s OK", name);
    endtask

    // ===== TESTY =====
    initial begin
        $display("=== ALU TEST START ===");

        // MOVE
        data = 8'hAA;
        from_accumulator = 8'h55;
        aluOpe = moveCode;
        check("MOVE", data);

        // INC
        data = 8'h00;
        from_accumulator = 8'h0F;
        aluOpe = incrementCode;
        check("INC", 8'h10);

        // ADD
        data = 8'h05;
        from_accumulator = 8'h03;
        aluOpe = addCode;
        check("ADD", 8'h08);

        // SUB
        data = 8'h02;
        from_accumulator = 8'h08;
        aluOpe = subCode;
        check("SUB", 8'h06);

        // AND
        data = 8'b11001100;
        from_accumulator = 8'b10101010;
        aluOpe = andCode;
        check("AND", 8'b10001000);

        // OR
        aluOpe = orCode;
        check("OR", 8'b11101110);

        // XOR
        aluOpe = xorCode;
        check("XOR", 8'b01100110);

        // NOT
        data = 8'h00; // nieużywane
        from_accumulator = 8'b00001111;
        aluOpe = notCode;
        check("NOT", 8'b11110000);

        $display("=== ALU TEST PASSED ===");
        $finish;
    end

endmodule
