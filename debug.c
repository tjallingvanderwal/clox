#include <stdio.h>

#include "debug.h"
#include "value.h"

void disassembleChunk(Chunk* chunk, const char* name){
    int opcodes = 0;
    printf("== %s ==\n", name);
    for (int offset = 0; offset < chunk->count; opcodes++){
        offset = disassembleInstruction(chunk, offset);
    }
    // logical size
    printf("%d opcodes (%d bytes), %d constants\n", 
            opcodes, chunk->count, chunk->constants.count);    
}

static int simpleInstruction(const char* name, int offset){
    printf("%-16s\n", name);
    return offset + 1;
}

static int constantInstruction(const char* name, Chunk* chunk, int offset){
    uint8_t constant = chunk->code[offset+1];
    printf("%-16s %4d   # '", name, constant);
    printValue(chunk->constants.values[constant]);
    printf("'\n");
    return offset + 2;
}

int disassembleInstruction(Chunk* chunk, int offset){
    // offset 
    printf("%04d ", offset);
    // line number
    int line = chunk->lines[offset];
    if (offset > 0 && line == chunk->lines[offset - 1]){
        printf("   | ");
    } else {
        printf("%4d ", line);
    }
    // instruction, with optional arguments and comments
    uint8_t instruction = chunk->code[offset];
    switch(instruction){
        case OP_CONSTANT:
            return constantInstruction("OP_CONSTANT", chunk, offset);
        case OP_RETURN:
            return simpleInstruction("OP_RETURN", offset);
        default:
            printf("Unknown opcode %d\n", instruction);
            return offset + 1;
    }
}


