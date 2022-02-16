#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "debug.h"
#include "common.h"
#include "compiler.h"
#include "vm.h"

static void repl(){
    char line[1024];
    for (;;){
        printf("> ");

        if (!fgets(line, sizeof(line), stdin)){
            printf("\n");
            break;
        }

        if (memcmp(line, "quit", 4)==0){
            exit(0);
        }
        else{
            interpret(line);
        }
    }
}

static char* readFile(const char* path){
    FILE* file = fopen(path, "rb");
    if (file == NULL){
        fprintf(stderr, "Could not open file \"%s\".\n", path);
        exit(74);
    }

    fseek(file, 0L, SEEK_END);
    size_t fileSize = ftell(file);
    rewind(file);

    char* buffer = (char*)malloc(fileSize+1);
    if (buffer == NULL){
        fprintf(stderr, "Not enough memory to read \"%s\"\n", path);
        exit(74);
    }
    size_t bytesRead = fread(buffer, sizeof(char), fileSize, file);
    if (bytesRead < fileSize){
        fprintf(stderr, "Could not read \"%s\".\n", path);
        exit(74);
    }
    buffer[bytesRead] = '\0';

    fclose(file);
    return buffer;
}

static void runFile(const char* path){
    char* source = readFile(path);
    InterpretResult result = interpret(source);
    free(source);

    if (result == INTERPRET_COMPILE_ERROR) exit(65);
    if (result == INTERPRET_RUNTIME_ERROR) exit(70);
}

static void eval(const char* expression){
    InterpretResult result = interpret(expression);
    if (result == INTERPRET_COMPILE_ERROR) exit(65);
    if (result == INTERPRET_RUNTIME_ERROR) exit(70);
}

static void printBytecode(const char* source){
    Chunk chunk;
    initChunk(&chunk);

    if (!compile(source, &chunk)){
        exit(65);
    } 
    else {
        // already printed because of DEBUG_PRINT_CODE
        // disassembleChunk(&chunk, "code");
    }
    freeChunk(&chunk);
}

int main(int argc, const char* argv[]){
    initVM();

    if (argc == 1){
        repl();
    } else if (argc == 2){
        runFile(argv[1]);
    } else if (argc == 3 && memcmp(argv[1], "--eval", 6) == 0){
        eval(argv[2]);
    } else if (argc == 3 && memcmp(argv[1], "--bytecode", 10) == 0){
        printBytecode(argv[2]);
    } else {
        fprintf(stderr, "Usage: clox [path]\n");
        fprintf(stderr, "Usage: clox --bytecode \"expression\"\n");
        fprintf(stderr, "Usage: clox --eval \"expression\"\n");
        exit(64);
    }

    freeVM();
    return 0;
}