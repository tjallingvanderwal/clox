#include <stdio.h>

#include "chunk.h"
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

static void printConstantInstruction(const char* name, Chunk* chunk, int constant){
    printf("%-16s %6d   # '", name, constant);
    printValue(chunk->constants.values[constant]);
    printf("'\n");
}

static int constantInstruction(const char* name, Chunk* chunk, int offset){
    uint8_t constant = chunk->code[offset+1];
    printConstantInstruction(name, chunk, constant);
    return offset + 2;
}

static int longConstantInstruction(const char* name, Chunk* chunk, int offset){
    int constant = readOperandLong(chunk, offset+1);
    printConstantInstruction(name, chunk, constant);
    return offset + 4;
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
        case OP_CONSTANT_LONG:
            return longConstantInstruction("OP_CONSTANT_LONG", chunk, offset);            
        case OP_RETURN:
            return simpleInstruction("OP_RETURN", offset);
        default:
            printf("Unknown opcode %d\n", instruction);
            return offset + 1;
    }
}


