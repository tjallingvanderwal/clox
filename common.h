#ifndef clox_common_h
#define clox_common_h

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct {
    bool eval;
    bool file;
    bool help;
    bool noExecution;
    bool printResult;
    bool printResultVerbose;
    bool repl;
    bool showBytecode;
    bool traceExecution;
    bool traceMemory;
    int evalExpressionIndex;
    int filePathIndex;
} CloxRun;
extern CloxRun cloxRun;

#define UINT8_COUNT (UINT8_MAX+1)

#endif