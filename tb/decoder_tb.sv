`timescale 1ns/1ps

module decoder_tb;

    // Parametry jak w DUT
    localparam prog_mem_data_width = 13;
    localparam adr_mem_width       = 8;

    // Sygnały wejściowe
    logic [prog_mem_data_width-1:0] dataProgMem;

    // Sygnały wyjściowe
    logic rstPC, cePC;
    logic [adr_mem_width-1:0] adrDataMem;
    logic [2:0] adrReg;
    logic [1:0] adrPort;
    logic [7:0] dataImm;
    logic [1:0] adrSrc;

    logic ceR0, ceR1, ceR2, ceR3, ceR4, ceR5, ceR6, ceR7;
    logic wrDm;

    logic cePortOutA, cePortDirA, portDirA;
    logic cePortOutB, cePortDirB, portDirB;
    logic cePortOutC, cePortDirC, portDirC;
    logic cePortOutD, cePortDirD, portDirD;

    logic [2:0] aluOper;
    logic ceAcu;

    // =========================
    // Instancja DUT
    // =========================
    decoder #(
        .prog_mem_data_width(prog_mem_data_width),
        .adr_mem_width(adr_mem_width)
    ) dut (
        .dataProgMem(dataProgMem),
        .rstPC(rstPC),
        .cePC(cePC),
        .adrDataMem(adrDataMem),
        .adrReg(adrReg),
        .adrPort(adrPort),
        .dataImm(dataImm),
        .adrSrc(adrSrc),
        .ceR0(ceR0), .ceR1(ceR1), .ceR2(ceR2), .ceR3(ceR3),
        .ceR4(ceR4), .ceR5(ceR5), .ceR6(ceR6), .ceR7(ceR7),
        .wrDm(wrDm),
        .cePortOutA(cePortOutA), .cePortDirA(cePortDirA), .portDirA(portDirA),
        .cePortOutB(cePortOutB), .cePortDirB(cePortDirB), .portDirB(portDirB),
        .cePortOutC(cePortOutC), .cePortDirC(cePortDirC), .portDirC(portDirC),
        .cePortOutD(cePortOutD), .cePortDirD(cePortDirD), .portDirD(portDirD),
        .aluOper(aluOper),
        .ceAcu(ceAcu)
    );

    // =========================
    // Test
    // =========================
initial begin
	$dumpfile("decoder_tb.vcd");
	$dumpvars (1, decoder_tb);    // Dumps all variables within module 'tb', not in any sub-modules

    test_LDaddr(8'h00);
    test_LDaddr(8'h3A);
    test_LDaddr(8'hFF);

	test_LDRx(3'd0);
	test_LDRx(3'd1);
	test_LDRx(3'd7);

    test_LDn(8'd0);
    test_LDn(8'd55);
    test_LDn(8'd255);

    test_STaddr(8'd0);
    test_STaddr(8'd222);
    test_STaddr(8'd255);  

    test_STRx(3'd0);
    test_STRx(3'd1);
    test_STRx(3'd7);

    test_INp(2'd0);
    test_INp(2'd3);

    test_OUTp(2'd0);
    test_OUTp(2'd3);

    test_INC();
    test_INC();
    test_INC();

    test_ALU_Rx("ADD", 3'd0);
    test_ALU_Rx("ADD", 3'd7);
    test_ALU_Rx("SUB", 3'd1);
    test_ALU_Rx("AND", 3'd2);
    test_ALU_Rx("OR",  3'd3);
    test_ALU_Rx("XOR", 3'd4);

    test_NOT();
    test_NOT();
    
    test_RST();
    test_RST();

    test_NOP();
    test_NOP();

    test_SET_OUTp(2'b00); // Port A
    test_SET_OUTp(2'b01); // Port B
    test_SET_OUTp(2'b10); // Port C
    test_SET_OUTp(2'b11); // Port D

    test_SET_INp(2'b00); // Port A
    test_SET_INp(2'b01); // Port B
    test_SET_INp(2'b10); // Port C
    test_SET_INp(2'b11); // Port D

    $display("ALL TESTS ENDED");
    $finish;
end
	// TASKI TESTOWE=======================================================
    //UWAGA!! nie testujemy czy wartość została załadowana do AKU, testujemy tylko sygnały dekodera!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
task automatic test_LDaddr(input [7:0] addr); //automatic -> każde wywołanie ma własne „egzemplarze” zmiennych
    begin
        $display("TEST LDaddr, adr = 0x%0h", addr);

        dataProgMem = {5'd0, addr};

        #1; // czas na propagację kombinacyjną

        // ===== ASSERCJE =====
        assert(adrDataMem == addr)
            else $error("LDaddr: adrDataMem = %h, expected %h",
                        adrDataMem, addr);

        assert(adrSrc == 2'b10)
            else $error("LDaddr: adrSrc = %b (expected dataMem)",
                        adrSrc);

        assert(aluOper == 3'b000)
            else $error("LDaddr: aluOper = %b (expected PASS/ADD)",
                        aluOper);

        assert(ceAcu == 1'b1)
            else $error("LDaddr: ceAcu not asserted");

        // ===== SYGNALY, KTÓRE MUSZĄ BYĆ 0 =====
        assert(wrDm == 0) else $error("LDaddr: wrDm should be 0");

        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("LDaddr: register enables should be 0");

        //$display("LDaddr END\n");
    end
endtask

task automatic test_LDRx(input [2:0] reg_addr);
    begin
        $display("TEST LDRx reg = R%0d", reg_addr);

        dataProgMem = {5'd1, 5'd0, reg_addr};

        #1; // czas na propagację kombinacyjną

        // ===== ASSERCJE =====
        assert(adrSrc == 2'b01)
            else $error("LDRx: adrSrc = %b (expected 01",
                        adrSrc);

        assert(aluOper == 3'b000)
            else $error("LDaddr: aluOper = %b (expected PASS/ADD)",
                        aluOper);

        assert(ceAcu == 1'b1)
            else $error("LDaddr: ceAcu not asserted");

        // ===== SYGNALY, KTÓRE MUSZĄ BYĆ 0 =====
        assert(wrDm == 0) else $error("LDaddr: wrDm should be 0");

        // ===== CE REJESTRÓW — WSZYSTKIE MUSZĄ BYĆ 0 =====
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("LDRx: register CE must all be 0");

        //$display("LDRx END\n");
    end
endtask

task automatic test_LDn(input [7:0] imm);
    begin
        $display("TEST LDn imm = 0x%0h", imm);

        // opcode LDn = 5'd2
        // dataProgMem[7:0] = dana natychmiastowa
        dataProgMem = {5'd2, imm};

        #1; // czas na propagację kombinacyjną

        // ===== ASSERCJE FUNKCJONALNE =====
        assert(dataImm == imm)
            else $error("LDn: dataImm = %h, expected %h",
                        dataImm, imm);

        assert(adrSrc == 2'b00)
            else $error("LDn: adrSrc = %b (expected 00 for imm)",
                        adrSrc);

        assert(aluOper == 3'b000)
            else $error("LDn: aluOper = %b (expected 000)",
                        aluOper);

        assert(ceAcu == 1'b1)
            else $error("LDn: ceAcu not asserted");

        // ===== SYGNAŁY, KTÓRYCH NIE MOŻE BYĆ =====
        assert(wrDm == 0)
            else $error("LDn: wrDm must be 0");

        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("LDn: register CE must all be 0");

        //$display("LDn OK\n");
    end
endtask

task automatic test_STaddr(input [7:0] addr);
    begin
        $display("TEST STaddr addr = 0x%0h", addr);

        // opcode STaddr = 5'd3
        // dataProgMem[7:0] = adres pamieci danych
        dataProgMem = {5'd3, addr};

        #1; // czas na propagację kombinacyjną

        // ===== ASSERCJE FUNKCJONALNE =====
        assert(adrDataMem == addr)
            else $error("STaddr: adrDataMem = %h, expected %h",
                        adrDataMem, addr);

        assert(wrDm == 1'b1)
            else $error("STaddr: wrDm not asserted");

        // ===== SYGNAŁY, KTÓRYCH NIE MOŻE BYĆ =====

        // brak zapisu do akumulatora
        assert(ceAcu == 0)
            else $error("STaddr: ceAcu must be 0");

        // brak zapisu do rejestrów
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("STaddr: register CE must all be 0");

        //$display("STaddr OK\n");
    end
endtask

task automatic test_STRx(input [2:0] reg_idx);
    begin
        $display("TEST STRx reg = R%0d", reg_idx);

        // opcode STRx = 5'd4
        // dataProgMem[2:0] = numer rejestru
        dataProgMem = {5'd4, 5'b00000, reg_idx};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: zapis do pamięci wyłączony =====
        assert(wrDm == 0)
            else $error("STRx: wrDm should be 0");

        // ===== ASSERT: ACU nie zapisywany =====
        assert(ceAcu == 0)
            else $error("STRx: ceAcu should be 0");

        // ===== ASSERT: dokładnie jeden rejestr CE = 1 =====
        assert(
            (ceR0 + ceR1 + ceR2 + ceR3 +
             ceR4 + ceR5 + ceR6 + ceR7) == 1
        )
        else $error("STRx: exactly one CE must be asserted");

        // ===== ASSERT: właściwy rejestr =====
        case (reg_idx)
            3'd0: assert(ceR0) else $error("STRx: ceR0 not asserted");
            3'd1: assert(ceR1) else $error("STRx: ceR1 not asserted");
            3'd2: assert(ceR2) else $error("STRx: ceR2 not asserted");
            3'd3: assert(ceR3) else $error("STRx: ceR3 not asserted");
            3'd4: assert(ceR4) else $error("STRx: ceR4 not asserted");
            3'd5: assert(ceR5) else $error("STRx: ceR5 not asserted");
            3'd6: assert(ceR6) else $error("STRx: ceR6 not asserted");
            3'd7: assert(ceR7) else $error("STRx: ceR7 not asserted");
        endcase


        //$display("STRx OK (R%0d)\n", reg_idx);
    end
endtask

task automatic test_INp(input [1:0] port_idx);
    begin
        $display("TEST INp port = %0d", port_idx);

        // opcode INp = 5'd5
        // dataProgMem[1:0] = numer portu
        dataProgMem = {5'd5, 6'b0, port_idx};

        #1; // propagacja kombinacyjna

        // ===== ASSERCJE FUNKCJONALNE =====
        assert(adrPort == port_idx)
            else $error("INp: adrPort = %b, expected %b",
                        adrPort, port_idx);

        assert(adrSrc == 2'b11)
            else $error("INp: adrSrc = %b, expected 11",
                        adrSrc);

        assert(aluOper == 3'b000)
            else $error("INp: aluOper = %b, expected 000",
                        aluOper);

        assert(ceAcu == 1'b1)
            else $error("INp: ceAcu not asserted");

        // ===== SYGNAŁY, KTÓRE MUSZĄ POZOSTAĆ 0 =====

        assert(wrDm == 0)
            else $error("INp: wrDm should be 0");

        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("INp: register CE must all be 0");

        assert(cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("INp: no port CE should be asserted");

        //$display("INp OK (port %0d)\n", port_idx);
    end
endtask

task automatic test_OUTp(input [1:0] port_idx);
    begin
        $display("TEST OUTp port = %0d", port_idx);

        // opcode OUTp = 5'd6
        // dataProgMem[1:0] = numer portu
        dataProgMem = {5'd6, 6'b0, port_idx};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: brak zapisu do ACU =====
        assert(ceAcu == 0)
            else $error("OUTp: ceAcu must be 0");

        // ===== ASSERT: brak zapisu do rejestrów =====
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("OUTp: register CE must all be 0");

        // ===== ASSERT: brak zapisu do pamieci =====
        assert(wrDm == 0)
            else $error("OUTp: wrDm must be 0");

        // ===== ASSERT: dokładnie jeden port OUT =====
        assert(
            (cePortOutA + cePortOutB +
             cePortOutC + cePortOutD) == 1
        )
        else $error("OUTp: exactly one cePortOut must be asserted");

        // ===== ASSERT: właściwy port =====
        case (port_idx)
            2'd0: assert(cePortOutA) else $error("OUTp: cePortOutA not asserted");
            2'd1: assert(cePortOutB) else $error("OUTp: cePortOutB not asserted");
            2'd2: assert(cePortOutC) else $error("OUTp: cePortOutC not asserted");
            2'd3: assert(cePortOutD) else $error("OUTp: cePortOutD not asserted");
        endcase

        // ===== ASSERT: brak pozostałych sterowań portu =====
        assert(cePortDirA==0 && cePortDirB==0 && cePortDirC==0 && cePortDirD==0)
            else $error("OUTp: no port IN/DIR CE should be asserted");

        //$display("OUTp OK (port %0d)\n", port_idx);
    end
endtask

task automatic test_INC;
    begin
        $display("TEST INC");

        // opcode INC = 5'd7
        dataProgMem = {5'd7, 8'b0};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: ALU =====
        assert(aluOper == 3'b001)
            else $error("INC: aluOper = %b (expected 001)", aluOper);

        // ===== ASSERT: zapis do ACU =====
        assert(ceAcu == 1)
            else $error("INC: ceAcu must be asserted");

        // ===== ASSERT: brak zapisu do RAM =====
        assert(wrDm == 0)
            else $error("INC: wrDm must be 0");

        // ===== ASSERT: brak CE rejestrów =====
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("INC: register CE must all be 0");

        // ===== ASSERT: brak portów =====
        assert(cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("INC: no port signals should be asserted");

        //$display("INC OK\n");
    end
endtask

//test ADD, SUB, AND, OR, XOR
task automatic test_ALU_Rx(
    input string op_name,
    input logic [2:0] reg_idx
);
    logic [4:0] opcode;
    logic [2:0] alu_expected;

    begin
        // ===== MAPOWANIE NA OPCODE + ALU =====
        if (op_name == "ADD") begin
            opcode       = 5'd8;
            alu_expected = 3'b010;
        end
        else if (op_name == "SUB") begin
            opcode       = 5'd9;
            alu_expected = 3'b011;
        end
        else if (op_name == "AND") begin
            opcode       = 5'd10;
            alu_expected = 3'b100;
        end
        else if (op_name == "OR") begin
            opcode       = 5'd11;
            alu_expected = 3'b101;
        end
        else if (op_name == "XOR") begin
            opcode       = 5'd12;
            alu_expected = 3'b110;
        end
        else begin
            $fatal(1,"Unknown ALU operation: %s", op_name);
        end

        $display("TEST %s Rx=%0d", op_name, reg_idx);

        // format: [opcode][xxxxx][reg_idx]
        dataProgMem = {opcode, 5'b0, reg_idx};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: źródło =====
        assert(adrSrc == 2'b01)
            else $error("%s: adrSrc = %b (expected 01)", op_name, adrSrc);

        // ===== ASSERT: rejestr =====
        assert(adrReg == reg_idx)
            else $error("%s: adrReg = %0d (expected %0d)",
                        op_name, adrReg, reg_idx);

        // ===== ASSERT: ALU =====
        assert(aluOper == alu_expected)
            else $error("%s: aluOper = %b (expected %b)",
                        op_name, aluOper, alu_expected);

        // ===== ASSERT: zapis do ACU =====
        assert(ceAcu == 1)
            else $error("%s: ceAcu must be asserted", op_name);

        // ===== ASSERT: brak zapisu do RAM =====
        assert(wrDm == 0)
            else $error("%s: wrDm must be 0", op_name);

        // ===== ASSERT: brak CE rejestrów =====
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("%s: register CE must all be 0", op_name);

        // ===== ASSERT: brak portów =====
        assert(cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("%s: no port signals should be asserted", op_name);

        //$display("%s OK (R%0d)\n", op_name, reg_idx);
    end
endtask

task automatic test_NOT;
    begin
        $display("TEST NOT");

        // opcode NOT = 5'd13
        dataProgMem = {5'd13, 8'b0};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: ALU =====
        assert(aluOper == 3'b111)
            else $error("NOT: aluOper = %b (expected 111)", aluOper);

        // ===== ASSERT: zapis do ACU =====
        assert(ceAcu == 1)
            else $error("NOT: ceAcu must be asserted");

        // ===== ASSERT: brak zapisu do RAM =====
        assert(wrDm == 0)
            else $error("NOT: wrDm must be 0");

        // ===== ASSERT: brak CE rejestrów =====
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("NOT: register CE must all be 0");

        // ===== ASSERT: brak portów =====
        assert(cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("NOT: no port signals should be asserted");

        //$display("NOT OK\n");
    end
endtask

task automatic test_RST;
    begin
        $display("TEST RST");

        // opcode RST = 5'd14
        dataProgMem = {5'd14, 8'b0};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: reset PC =====
        assert(rstPC == 1)
            else $error("RST: rstPC must be asserted");

        // ===== ASSERT: brak zapisu do ACU =====
        assert(ceAcu == 0)
            else $error("RST: ceAcu must be 0");

        // ===== ASSERT: brak zapisu do RAM =====
        assert(wrDm == 0)
            else $error("RST: wrDm must be 0");

        // ===== ASSERT: brak CE rejestrów =====
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("RST: register CE must all be 0");

        // ===== ASSERT: brak portów =====
        assert(cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("RST: no port signals should be asserted");

        //$display("RST OK\n");
    end
endtask

task automatic test_NOP;
    begin
        $display("TEST NOP");

        // opcode NOP = 5'd15
        dataProgMem = {5'd15, 8'b0};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: brak resetu PC =====
        assert(rstPC == 0)
            else $error("NOP: rstPC must be 0");

        // ===== ASSERT: brak zapisu do ACU =====
        assert(ceAcu == 0)
            else $error("NOP: ceAcu must be 0");

        // ===== ASSERT: brak zapisu do RAM =====
        assert(wrDm == 0)
            else $error("NOP: wrDm must be 0");

        // ===== ASSERT: brak CE rejestrów =====
        assert(ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0)
            else $error("NOP: register CE must all be 0");

        // ===== ASSERT: brak portów =====
        assert(cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("NOP: no port signals should be asserted");

        // ===== ASSERT: brak innych efektów =====
        assert(adrSrc==0 && adrReg==0 && adrDataMem==0 && dataImm==0 &&
               aluOper==3'b000)
            else $error("NOP: all other signals must remain 0");

        //$display("NOP OK\n");
    end
endtask

task automatic test_SET_OUTp(input logic [1:0] port_idx);
    begin
        $display("TEST SET_OUTp port=%0d", port_idx);

        // format: [opcode][xxxxx][port_idx]
        dataProgMem = {5'd16, 6'b0, port_idx};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: ustawienie odpowiedniego portDir =====
        assert((port_idx == 2'b00 ? portDirA :
               port_idx == 2'b01 ? portDirB :
               port_idx == 2'b10 ? portDirC :
               port_idx == 2'b11 ? portDirD : 0) == 1)
            else $error("SET_OUTp: portDir%0c not set correctly", "A"+port_idx);

        // ===== ASSERT: pozostałe porty =====
        assert((port_idx != 2'b00 ? portDirA : 0) == 0 &&
               (port_idx != 2'b01 ? portDirB : 0) == 0 &&
               (port_idx != 2'b10 ? portDirC : 0) == 0 &&
               (port_idx != 2'b11 ? portDirD : 0) == 0)
            else $error("SET_OUTp: other portDir should be 0");

        // ===== ASSERT: brak innych efektów =====
        assert(rstPC==0 && ceAcu==0 && wrDm==0 &&
               ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0 &&
               cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("SET_OUTp: unexpected signal asserted");

        //$display("SET_OUTp port %0d OK\n", port_idx);
    end
endtask

task automatic test_SET_INp(input logic [1:0] port_idx);
    begin
        $display("TEST SET_INp port=%0d", port_idx);

        // format: [opcode][xxxxx][port_idx]
        dataProgMem = {5'd17, 6'b0, port_idx};

        #1; // propagacja kombinacyjna

        // ===== ASSERT: ustawienie odpowiedniego portDir =====
        assert((port_idx == 2'b00 ? portDirA :
               port_idx == 2'b01 ? portDirB :
               port_idx == 2'b10 ? portDirC :
               port_idx == 2'b11 ? portDirD : 1) == 0)
            else $error("SET_INp: portDir%0c not set correctly", "A"+port_idx);

        // ===== ASSERT: brak innych efektów =====
        assert(rstPC==0 && ceAcu==0 && wrDm==0 &&
               ceR0==0 && ceR1==0 && ceR2==0 && ceR3==0 &&
               ceR4==0 && ceR5==0 && ceR6==0 && ceR7==0 &&
               cePortOutA==0 && cePortDirA==0 &&
               cePortOutB==0 && cePortDirB==0 &&
               cePortOutC==0 && cePortDirC==0 &&
               cePortOutD==0 && cePortDirD==0)
            else $error("SET_INp: unexpected signal asserted");

        //$display("SET_INp port %0d OK\n", port_idx);
    end
endtask



endmodule

