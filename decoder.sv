//=======================================================
// REQ1: Dekoder rozkazów musi poprawnie dekodować instukcje na podstawie pola operacji w pobranym rozkazie.
// REQ2: Dekoder rozkazów musi generować odpowiednie sygnały sterujące dla pozostałych modułów procesora na podstawie aktualnie pobranej instukcji.
// REQ3: Dekoder rozkazów musi uwzględniać flagi stanu (Carry, Zero, Sign, Overflow, Parity) przy dekodowaniu rozkazów skoku warunkowego.
//=======================================================

module decoder 
#(  parameter prog_mem_length = 8,
    parameter prog_mem_width = 13, 
    parameter data_mem_length = 8,
    parameter data_mem_width = 8)(

    input [prog_mem_width-1:0] dataProgMem, //rozkaz do wykonania z pamieci programu

    input flag_c_out,     // Carry
    input flag_z_out,     // Zero
    input flag_s_out,     // Sign
    input flag_v_out,     // Overflow
    input flag_p_out,     // Parity

    output logic rstPC,
    output logic cePC,
    output logic wrJumpAdr,
    output logic [prog_mem_length-1:0] jumpAdr, //adres skoku bezwzlednego

    output logic [data_mem_length-1:0] adrDataMem, //adres pamieci danych
    output logic [2:0] adrReg, //wybor rejestru roboczego
    output logic [1:0] adrPort,
    output logic [7:0] dataImm, //dana natychmiastowa
    output logic [1:0] adrSrc, //wybrór zrodła danych (imm,reg,dataMem,port)

    output logic ceR0,
    output logic ceR1,
    output logic ceR2,
    output logic ceR3,
    output logic ceR4,
    output logic ceR5,
    output logic ceR6,
    output logic ceR7,

    output logic wrDm, //wpis do pamieci danych

    output logic cePortOutA, //wpis do rejestru Out
    output logic cePortDirA, //wpis do rejestru kierunku
    output logic portDirA, //wartość do rejestru kierunku, 1=Out , 0=In

    output logic cePortOutB, //wpis do rejestru Out
    output logic cePortDirB, //wpis do rejestru kierunku
    output logic portDirB, //wartość do rejestru kierunku, 1=Out , 0=In

    output logic cePortOutC, //wpis do rejestru Out
    output logic cePortDirC, //wpis do rejestru kierunku
    output logic portDirC, //wartość do rejestru kierunku, 1=Out , 0=In

    output logic cePortOutD, //wpis do rejestru Out
    output logic cePortDirD, //wpis do rejestru kierunku
    output logic portDirD, //wartość do rejestru kierunku, 1=Out , 0=In

    output logic [3:0] aluOper, //wybór operacji alu

    output logic ceAcu //wpis do akumulatora


);

typedef enum  { 
    LDaddr,
    LDRx,
    LDn,
    STaddr,
    STRx,
    INp,
    OUTp,
    INC,
    ADDRx,
    SUBRx,
    ANDRx,
    ORRx,
    XORRx,
    NOT,
    RST,
    NOP,
    SET_OUTp,
    SET_INp,
    //nowe
    ADDCRx, //dodaj z przeniesieniem
    SUBCRx, //odejmij z przeniesieniem
    DEC, //dekrementacja
    JZ, //skok jesli zero
    JC, //skok jesli carry
    JS, //skok jesli sign (wynik ujemny flag_s=1)
    JV, //skok jesli overflow
    JP, //skok jesli parity (parzysta liczba jedynek)
    JMP //skok bezwarunkowy


} kodRozkazu;


    
always @(*) begin
    // ===== DOMYŚLNE ZEROWANIE =====
    rstPC = 0;
    cePC  = 1;

    adrDataMem = '0;
    adrReg     = '0;
    adrPort    = '0;
    dataImm    = '0;
    adrSrc     = '0;

    ceR0=0; ceR1=0; ceR2=0; ceR3=0;
    ceR4=0; ceR5=0; ceR6=0; ceR7=0;

    wrDm = 0;

    cePortOutA=0; cePortDirA=0; portDirA=0;
    cePortOutB=0; cePortDirB=0; portDirB=0;
    cePortOutC=0; cePortDirC=0; portDirC=0;
    cePortOutD=0; cePortDirD=0; portDirD=0;

    aluOper = 'd0;
    ceAcu   = 0;
 
    // ===== DEKODOWANIE =====
    case (dataProgMem[prog_mem_width-1:prog_mem_width-5]) //5 najstarszych bitów
        LDaddr: begin // zawartosc spod adresu pamieci danych do aku
            adrDataMem=dataProgMem[7:0];
            adrSrc= 2'b10;
            aluOper=4'b0000;
            ceAcu=1;
        end 
        LDRx: begin
            adrReg= dataProgMem[2:0];
            adrSrc= 2'b01;
            aluOper= 4'b0000;
            ceAcu=1;
        end
        LDn: begin
            dataImm= dataProgMem[7:0];
            adrSrc= 2'b00;
            aluOper= 4'b0000;
            ceAcu=1;
        end
        STaddr: begin
            adrDataMem= dataProgMem[7:0];
            wrDm=1;
        end
        STRx: begin
            case (dataProgMem[2:0])
                3'b000: ceR0=1;
                3'b001: ceR1=1;
                3'b010: ceR2=1;
                3'b011: ceR3=1;
                3'b100: ceR4=1;
                3'b101: ceR5=1;
                3'b110: ceR6=1;
                3'b111: ceR7=1;

                default: begin
                    ceR0=0;
                    ceR1=0;
                    ceR2=0;
                    ceR3=0;
                    ceR4=0;
                    ceR5=0;
                    ceR6=0;
                    ceR7=0; 
                end
            endcase
        end
        INp: begin
            adrPort= dataProgMem[1:0];
            adrSrc=2'b11;
            aluOper=4'b0000;
            ceAcu=1;
        end
        OUTp: begin
            case (dataProgMem[1:0])
                2'b00:cePortOutA=1;
                2'b01:cePortOutB=1;
                2'b10:cePortOutC=1;
                2'b11:cePortOutD=1; 
                default:
                begin 
                    cePortOutA=0;
                    cePortOutB=0;
                    cePortOutC=0;
                    cePortOutD=0; 
                end
            endcase
        end
        INC: begin
            aluOper=4'b0001;
            ceAcu=1;
        end
        ADDRx: begin
            adrReg= dataProgMem[2:0];
            adrSrc=2'b01;
            aluOper= 4'b0010;
            ceAcu=1;
        end
        SUBRx: begin
            adrReg= dataProgMem[2:0];
            adrSrc=2'b01;
            aluOper= 4'b0011;
            ceAcu=1;
        end
        ANDRx: begin
            adrReg= dataProgMem[2:0];
            adrSrc=2'b01;
            aluOper=4'b0100;
            ceAcu=1;
        end
        ORRx: begin
            adrReg = dataProgMem[2:0];
            adrSrc=2'b01;
            aluOper=4'b0101;
            ceAcu=1;
        end
        XORRx: begin
            adrReg= dataProgMem[2:0];
            adrSrc=2'b01;
            aluOper=4'b0110;
            ceAcu=1;
        end
        NOT: begin
            aluOper=4'b0111;
            ceAcu=1;
        end
        RST: begin
            rstPC=1;
        end
        NOP:begin
            //nic nie rób
        end
        SET_OUTp: begin
            case (dataProgMem[1:0])
                2'b00:begin cePortDirA=1; portDirA=1; end
                2'b01:begin cePortDirB=1; portDirB=1; end
                2'b10:begin cePortDirC=1; portDirC=1; end
                2'b11:begin cePortDirD=1; portDirD=1; end 
                default: 
                begin
                    cePortDirA=0; cePortDirB=0; cePortDirC=0; cePortDirD=0;
                    portDirA=0; portDirB=0; portDirC=0; portDirD=0; 
                end
            endcase
        end
        SET_INp:begin
            case (dataProgMem[1:0])
                2'b00:begin cePortDirA=1; portDirA=0; end
                2'b01:begin cePortDirB=1; portDirB=0; end
                2'b10:begin cePortDirC=1; portDirC=0; end
                2'b11:begin cePortDirD=1; portDirD=0; end 
                default: 
                begin
                    cePortDirA=0; cePortDirB=0; cePortDirC=0; cePortDirD=0;
                    portDirA=0; portDirB=0; portDirC=0; portDirD=0; 
                end
            endcase
        end
        //nowe
        ADDCRx: begin
            adrReg= dataProgMem[2:0];
            adrSrc=2'b01;
            aluOper=4'b1000; //ADDC
            ceAcu=1;
        end
        SUBCRx: begin
            adrReg= dataProgMem[2:0];
            adrSrc=2'b01;
            aluOper=4'b1001; //SUBC
            ceAcu=1;
        end
        DEC: begin
            aluOper=4'b1010; //DECREMENT
            ceAcu=1;
        end
         JZ: begin //skok jesli zero
            if (flag_z_out==1) begin
                cePC=0;
                jumpAdr=dataProgMem[prog_mem_width-6:0];
                wrJumpAdr=1;
            end
        end
        JC: begin //skok jesli carry
            if (flag_c_out==1) begin
                cePC=0;
                jumpAdr=dataProgMem[prog_mem_width-6:0];
                wrJumpAdr=1;
            end
        end
        JS: begin //skok jesli sign (wynik ujemny flag_s=1)
            if (flag_s_out==1) begin
                cePC=0;
                jumpAdr=dataProgMem[prog_mem_width-6:0];
                wrJumpAdr=1;
            end
        end
        JV: begin //skok jesli overflow
            if (flag_v_out==1) begin
                cePC=0;
                jumpAdr=dataProgMem[prog_mem_width-6:0];
                wrJumpAdr=1;
            end
        end
        JP: begin //skok jesli parity (parzysta liczba jedynek)
            if (flag_p_out==1) begin
                cePC=0;
                jumpAdr=dataProgMem[prog_mem_width-6:0];
                wrJumpAdr=1;
            end
        end
        JMP: begin //skok bezwarunkowy
            cePC=0;
            jumpAdr=dataProgMem[prog_mem_width-6:0];
            wrJumpAdr=1;
        end
        default: begin
            rstPC=0;

            ceR0=0;
            ceR1=0;
            ceR2=0;
            ceR3=0;
            ceR4=0;
            ceR5=0;
            ceR6=0;
            ceR7=0;

            wrDm=0;
        
            cePortOutA=0;
            cePortDirA=0;

            cePortOutB=0;
            cePortDirB=0;

            cePortOutC=0;
            cePortDirC=0;

            cePortOutD=0;
            cePortDirD=0;
            ceAcu=0;
        end
    endcase
end  

endmodule