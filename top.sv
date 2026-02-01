module top #(
        parameter int prog_mem_length = 8,
        parameter int prog_mem_width = 13,

        parameter int data_mem_length = 8,
        parameter int data_mem_width = 8,

        parameter int WIDTH = 8
    )(
        input logic clk,
        input logic rst,
        output logic [WIDTH-1:0] portAwire,
        output logic [WIDTH-1:0] portBwire,
        output logic [WIDTH-1:0] portCwire,
        output logic [WIDTH-1:0] portDwire
    );

    //sygnaly wewnetrzne (jedno bitowych sygnałow nie trzeba definiowac)

    logic [1:0] adrSrc;
    logic [WIDTH-1:0] aluInput; //wyjscie source_mux
    logic [WIDTH-1:0] dataImm;

    logic [prog_mem_length-1:0] jumpAdr; //adres skoku bezwzlednego

    logic [2:0] adrReg;
    logic [WIDTH-1:0] regMuxOut; //wyjscie reg_mux
    logic [WIDTH-1:0] R0out;    //wyjscia rejestrow
    logic [WIDTH-1:0] R1out;
    logic [WIDTH-1:0] R2out;
    logic [WIDTH-1:0] R3out;
    logic [WIDTH-1:0] R4out;
    logic [WIDTH-1:0] R5out;
    logic [WIDTH-1:0] R6out;
    logic [WIDTH-1:0] R7out;

    logic [1:0] adrPort;
    logic [WIDTH-1:0] portMuxOut; //wyjscie port_mux

    logic [prog_mem_length-1:0] adrProgMem;
    logic [prog_mem_width-1:0] dataProgMem;

    logic [data_mem_length-1:0] adrDataMem;
    logic [data_mem_width-1:0] dataMemOut;

    logic [3:0] aluOper;
    logic [WIDTH-1:0] aluOut;

    logic [WIDTH-1:0] accumulatorOut;

    ///-----------------------------------------------------------------

    programCounter #(.prog_mem_length(prog_mem_length)) 
    programCounter0 (
        .clk(clk),
        .rst(rst),
        .rstPC(rstPC),
        .cePC(cePC),
        .wrJumpAdr(wrJumpAdr),
        .jumpAdr(jumpAdr),
        .out(adrProgMem)
    );

    programMemory #(.prog_mem_length(prog_mem_length), .prog_mem_width(prog_mem_width)) 
    programMemory0(
        .addr(adrProgMem),
        .data(dataProgMem)
    );

    dataMemory dataMemory0(
        .addr(adrDataMem),
        .in(accumulatorOut),
        .out(dataMemOut),
        .wrDm(wrDm)
    );

    register #(.WIDTH(WIDTH))
    R0(
        .clk(clk),
        .rst(rst),
        .ce(ceR0),
        .in(accumulatorOut),
        .out(R0out) 
    );
    register #(.WIDTH(WIDTH))
    R1(
        .clk(clk),
        .rst(rst),
        .ce(ceR1),
        .in(accumulatorOut),
        .out(R1out) 
    );
    register #(.WIDTH(WIDTH))
    R2(
        .clk(clk),
        .rst(rst),
        .ce(ceR2),
        .in(accumulatorOut),
        .out(R2out) 
    );
    register #(.WIDTH(WIDTH))
    R3(
        .clk(clk),
        .rst(rst),
        .ce(ceR3),
        .in(accumulatorOut),
        .out(R3out) 
    );
    register #(.WIDTH(WIDTH))
    R4(
        .clk(clk),
        .rst(rst),
        .ce(ceR4),
        .in(accumulatorOut),
        .out(R4out) 
    );
    register #(.WIDTH(WIDTH))
    R5(
        .clk(clk),
        .rst(rst),
        .ce(ceR5),
        .in(accumulatorOut),
        .out(R5out) 
    );
    register #(.WIDTH(WIDTH))
    R6(
        .clk(clk),
        .rst(rst),
        .ce(ceR6),
        .in(accumulatorOut),
        .out(R6out) 
    );
    register #(.WIDTH(WIDTH))
    R7(
        .clk(clk),
        .rst(rst),
        .ce(ceR7),
        .in(accumulatorOut),
        .out(R7out) 
    );

    flags_register flags_register0(
        .clk(clk),
        .rst(rst), //todo czy to jest dobrze?
        .ceFlags(1'd1), //todo
        .flag_c_alu(flag_c_alu),
        .flag_z_alu(flag_z_alu),
        .flag_s_alu(flag_s_alu),
        .flag_v_alu(flag_v_alu),
        .flag_p_alu(flag_p_alu),

        .flag_c_out(flag_c_out),
        .flag_z_out(flag_z_out),
        .flag_s_out(flag_s_out),
        .flag_v_out(flag_v_out),
        .flag_p_out(flag_p_out)
    );

    port #(.WIDTH(WIDTH))
    portA(
        .clk(clk),
        .rst(rst),
        .cePortDir(cePortDirA),
        .portDir(portDirA),
        .cePortOut(cePortOutA),
        .portData(accumulatorOut),
        .out(portAwire) //fizyczne wyjscie
    );
    port #(.WIDTH(WIDTH))
    portB(
        .clk(clk),
        .rst(rst),
        .cePortDir(cePortDirB),
        .portDir(portDirB),
        .cePortOut(cePortOutB),
        .portData(accumulatorOut),
        .out(portBwire) //fizyczne wyjscie
    );
    port #(.WIDTH(WIDTH))
    portC(
        .clk(clk),
        .rst(rst),
        .cePortDir(cePortDirC),
        .portDir(portDirC),
        .cePortOut(cePortOutC),
        .portData(accumulatorOut),
        .out(portCwire) //fizyczne wyjscie
    );
    port #(.WIDTH(WIDTH))
    portD(
        .clk(clk),
        .rst(rst),
        .cePortDir(cePortDirD),
        .portDir(portDirD),
        .cePortOut(cePortOutD),
        .portData(accumulatorOut),
        .out(portDwire) //fizyczne wyjscie
    );

    alu #(.WIDTH(WIDTH))
    alu0(
        .data(aluInput),
        .from_accumulator(accumulatorOut),
        .aluOper(aluOper),
        .carry_in(flag_c_out),
        .flag_c_alu(flag_c_alu),
        .flag_z_alu(flag_z_alu),
        .flag_s_alu(flag_s_alu),
        .flag_v_alu(flag_v_alu),
        .flag_p_alu(flag_p_alu),
        .out(aluOut)
    );

    accumulator #( .WIDTH(WIDTH))
    accumulator0(
        .in(aluOut),
        .ceAcu(ceAcu),
        .clk(clk),
        .rst(rst),
        .out(accumulatorOut)
    );

    decoder #( .prog_mem_length(prog_mem_length), .prog_mem_width(prog_mem_width), .data_mem_width(data_mem_width), .data_mem_length(data_mem_length)) 
    decoder0(
        .dataProgMem(dataProgMem), //rozkaz do wykonania z pamieci programu

        .rstPC(rstPC),
        .cePC(cePC),
        .wrJumpAdr(wrJumpAdr),
        .jumpAdr(jumpAdr),

        .flag_c_out(flag_c_out),     // Carry
        .flag_z_out(flag_z_out),     // Zero
        .flag_s_out(flag_s_out),     // Sign
        .flag_v_out(flag_v_out),     // Overflow
        .flag_p_out(flag_p_out),     // Parity

        .adrDataMem(adrDataMem), //adres pamieci danych

        .adrReg(adrReg), //wybor rejestru roboczego
        .adrPort(adrPort),
        .dataImm(dataImm), //dana natychmiastowa
        .adrSrc(adrSrc), //wybrór zrodła danych (imm,reg,dataMem,port)

        .ceR0(ceR0),
        .ceR1(ceR1),
        .ceR2(ceR2),
        .ceR3(ceR3),
        .ceR4(ceR4),
        .ceR5(ceR5),
        .ceR6(ceR6),
        .ceR7(ceR7),

        .wrDm(wrDm), //wpis do pamieci danych

        .cePortOutA(cePortOutA), //wpis do rejestru Out
        .cePortDirA(cePortDirA), //wpis do rejestru kierunku
        .portDirA(portDirA), //wartość do rejestru kierunku, 1=Out , 0=In
        
        .cePortOutB(cePortOutB), //wpis do rejestru Out
        .cePortDirB(cePortDirB), //wpis do rejestru kierunku
        .portDirB(portDirB), //wartość do rejestru kierunku, 1=Out , 0=In
        
        .cePortOutC(cePortOutC), //wpis do rejestru Out
        .cePortDirC(cePortDirC), //wpis do rejestru kierunku
        .portDirC(portDirC), //wartość do rejestru kierunku, 1=Out , 0=In
        
        .cePortOutD(cePortOutD), //wpis do rejestru Out
        .cePortDirD(cePortDirD), //wpis do rejestru kierunku
        .portDirD(portDirD), //wartość do rejestru kierunku, 1=Out , 0=In

        .aluOper(aluOper), //wybór operacji alu

        .ceAcu(ceAcu) //wpis do akumulatora
    );

    //REGISTER MUX
    always_comb begin : register_mux
        case(adrReg)
            3'b000: regMuxOut = R0out;
            3'b001: regMuxOut = R1out;
            3'b010: regMuxOut = R2out;
            3'b011: regMuxOut = R3out;
            3'b100: regMuxOut = R4out;
            3'b101: regMuxOut = R5out;
            3'b110: regMuxOut = R6out;
            3'b111: regMuxOut = R7out;
            default: regMuxOut = 'd0;
        endcase
    end

    //PORT MUX
    always_comb begin : port_mux
        case(adrPort)
            2'b00: portMuxOut = portAwire;
            2'b01: portMuxOut = portBwire;
            2'b10: portMuxOut = portCwire;
            2'b11: portMuxOut = portDwire;
            default: portMuxOut = 'd0;
        endcase
    end

    //SOURCE MUX
    always_comb begin : source_mux
        case(adrSrc)
            2'b00: aluInput = dataImm;
            2'b01: aluInput = regMuxOut;
            2'b10: aluInput = dataMemOut;
            2'b11: aluInput = portMuxOut;
            default: aluInput = 'd0;
        endcase
    end

   
    


endmodule