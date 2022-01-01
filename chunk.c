#include <stdlib.h>
#include <stdio.h>

#include "chunk.h"
#include "memory.h"
#include "value.h"

void initChunk(Chunk* chunk){
    chunk->count = 0;
    chunk->capacity = 0;
    chunk->code = NULL;
    chunk->lines = NULL;
    initValueArray(&chunk->constants);
}

void freeChunk(Chunk* chunk){
    FREE_ARRAY(uint8_t, chunk->code, chunk->capacity);
    FREE_ARRAY(int, chunk->lines, chunk->capacity);
    freeValueArray(&chunk->constants);
    initChunk(chunk);
}

void writeChunk(Chunk* chunk, uint8_t byte, int line){
    if (chunk->capacity < chunk->count + 1){
        int oldCapacity = chunk->capacity;
        chunk->capacity = GROW_CAPACITY(oldCapacity);
        chunk->code = GROW_ARRAY(uint8_t, chunk->code, oldCapacity, chunk->capacity);
        chunk->lines = GROW_ARRAY(int, chunk->lines, oldCapacity, chunk->capacity);
    }

    chunk->code[chunk->count] = byte;
    chunk->lines[chunk->count] = line;
    chunk->count++;
}

int addConstant(Chunk* chunk, Value value){
    writeValueArray(&chunk->constants, value);
    return chunk->constants.count - 1;
}

void writeConstant(Chunk* chunk, Value value, int line){
    int constant = addConstant(chunk, value);
    if (constant < 4){
        writeChunk(chunk, OP_CONSTANT, line);
        writeChunk(chunk, constant, line);
    }  
    else if (constant < 1024){
        writeChunk(chunk, OP_CONSTANT_LONG, line);
        writeOperandLong(chunk, constant, line);
    }
    else {
        fprintf(stderr, "INTERNAL: Exceeded max. constants in chunk. ");
        fprintf(stderr, "Last constant: '");
        fprintValue(stderr, value);
        fprintf(stderr, "'\n");
        exit(74);
    }
}

// Writes the last 3 bytes of an int to a Chunk.
void writeOperandLong(Chunk* chunk, int operand, int line){
    if ((operand & 0xFF000000) != 0){
        fprintf(stderr, "INTERNAL: Long operand too long: %d at line %d\n", operand, line);
        exit(174);
    }
    writeChunk(chunk,  operand      & 0x000000FF, line);
    writeChunk(chunk, (operand>> 8) & 0x000000FF, line);
    writeChunk(chunk, (operand>>16) & 0x000000FF, line);
}

// Reads 3 bytes starting at the specified offset, 
// and recombines them into an int.
int readOperandLong(Chunk* chunk, int offset){
    int a = chunk->code[offset];
    int b = chunk->code[offset+1];
    int c = chunk->code[offset+2];
    return (a | b<<8 | c<<16);
}