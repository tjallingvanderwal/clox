#include <stdio.h>

#include "common.h"
#include "chunk.h"
#include "debug.h"
#include "vm.h"

int main(int argc, const char* argv[]){
    initVM();

    Chunk chunk;
    initChunk(&chunk);

    writeConstant(&chunk, 1.2, 10);
    writeConstant(&chunk, 3.4, 11);
    writeChunk(&chunk, OP_ADD, 11);
    writeConstant(&chunk, 5.6, 12);
    writeChunk(&chunk, OP_DIVIDE, 12);
    writeChunk(&chunk, OP_NEGATE, 10);
    writeChunk(&chunk, OP_RETURN, 10);

    disassembleChunk(&chunk, "test chunk");
    printf("\n");
    interpret(&chunk);

    freeVM();
    freeChunk(&chunk);
    return 0;
}