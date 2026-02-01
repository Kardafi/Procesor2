`ifndef ALU_DEFS_SV
`define ALU_DEFS_SV

typedef enum  { 
    moveCode, //przepisz
    incrementCode, //incrementacja wartoci z aku
    addCode,
    subCode,
    andCode,
    orCode,
    xorCode,
    notCode,
    addcCode,
    subcCode,
    decrementCode
} aluOperCode;

`endif