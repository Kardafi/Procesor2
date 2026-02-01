//=======================================================
// REQ1: Licznik rozkazów zwiększa wartośc o 1 przy każdym cyklu zegara, gdy sygnał cePC jest aktywny.
// REQ2: Licznik rozkazów musi posiadać asynchroniczny sygnał resetu.
// REQ3: Licznik rozkazów musi posiadać sygnał zezwalający na zapis adresu skoku bezwzględnego (wrJumpAdr).
//=======================================================

module programCounter 
#(  parameter int prog_mem_length = 8 //16 -> 64k
)(
    input clk,
    input rst, //reset globalny (symulacja)
    input rstPC, //reset licznika z decodera
    input cePC,
    input wrJumpAdr,
    input [prog_mem_length-1:0] jumpAdr, //adres skoku bezwzlednego

    output reg [prog_mem_length-1:0] out //adres do pamieci
);
    // do symulacji
    initial begin
        out = 'd0;
    end

 always @(posedge clk) begin
    if(rstPC || rst)
        out<= 0;
    else
        if(cePC)
            out <= out + 1;
        else if(wrJumpAdr) //skok bezwzlędny
            out <= jumpAdr;
end

    
endmodule