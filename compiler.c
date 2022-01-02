#include <stdio.h>

#include "common.h"
#include "compiler.h"
#include "scanner.h"

bool compile(const char* source, Chunk* chunk){
    initScanner(source);
    int line = -1;
    for (;;){
        Token token = scanToken();
        if (token.line != line){
            printf("%4d ", token.line);
            line = token.line;
        } else {
            printf("   | ");
        }


        if (token.type == TOKEN_ERROR){
            printf("%2d <%.*s>\n", token.type, token.length, token.start);
        }
        else if (token.type == TOKEN_EOF){
            printf("%2d <EOF>\n", token.type);
            break;
        }
        else {
            printf("%2d '%.*s'\n", token.type, token.length, token.start);
        }
    }

    return true;
}