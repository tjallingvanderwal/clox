#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "common.h"
#include "compiler.h"
#include "debug.h"
#include "object.h"
#include "memory.h"
#include "value.h"
#include "vm.h"

VM vm;

static void resetStack(){
    vm.stackTop = vm.stack;
}

static bool stackEmpty(){
    return vm.stackTop == vm.stack;
}

static void runtimeError(const char* format, ...){
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fputs("\n", stderr);
 
    size_t instruction = vm.ip - vm.chunk->code - 1;
    int line = vm.chunk->lines[instruction];
    fprintf(stderr, "[line %d] in script\n", line);
    resetStack();
}

void initVM(){
    resetStack();
    vm.objects = NULL;
    initTable(&vm.globals);
    initTable(&vm.strings);
}

void freeVM(){
    freeTable(&vm.globals);
    freeTable(&vm.strings);
    freeObjects();
}

void push(Value value){
    *vm.stackTop = value;
    vm.stackTop++;
}

Value pop(){
    vm.stackTop--;
    return *vm.stackTop;
}

static Value peek(int distance){
    return vm.stackTop[-1 - distance];
}

static bool isFalsey(Value value){
    return IS_NIL(value) || (IS_BOOL(value) && !AS_BOOL(value));
}

static void concatenate(){
    Value val_b = pop();
    Value val_a = pop();
    ObjString* b = AS_STRING(val_b);
    ObjString* a = AS_STRING(val_a);

    if (b->length == 0){ push(val_a); return; }
    if (a->length == 0){ push(val_b); return; }

    int length = a->length + b->length;
    char* chars = ALLOCATE(char, length+ 1 );
    memcpy(chars            , a->chars, a->length);
    memcpy(chars + a->length, b->chars, b->length);
    chars[length] = '\0';
    ObjString* result = takeString(chars, length);
    push(OBJ_VAL(result));
}

static InterpretResult run(){
#define READ_BYTE() (*vm.ip++)
#define READ_CONSTANT() (vm.chunk->constants.values[READ_BYTE()])
#define READ_LONG_CONSTANT() (vm.chunk->constants.values[READ_BYTE() | (READ_BYTE()<<8) | (READ_BYTE()<<16)])
#define READ_STRING() AS_STRING(READ_CONSTANT())
#define BINARY_OP(valueType, op) \
    do { \
        if (!IS_NUMBER(peek(0)) || !IS_NUMBER(peek(1))){ \
            runtimeError("Operands must be numbers."); \
            return INTERPRET_RUNTIME_ERROR; \
        } \
        double b = AS_NUMBER(pop()); \
        double a = AS_NUMBER(pop()); \
        push(valueType(a op b)); \
    } while (false)

    bool trace = cloxRun.traceExecution;
    bool traceMemory = cloxRun.traceMemory;

    if (trace){
        printf("\n== execution ==\n");
    }

    for (;;){
        if (trace){
            if (stackEmpty()){
                printf("          stack: <empty>\n");
            }   
            else {
                printf("          stack: ");
                for (Value* slot = vm.stack; slot < vm.stackTop; slot++){
                    printf("[ ");
                    printValue(*slot);
                    printf(" ]");
                }   
                printf("\n");     
            }
            if (traceMemory){
                if (vm.objects == NULL){
                    printf("          heap : <empty>\n");
                } 
                else {
                    printf("          heap : ");
                    Obj* object = vm.objects;
                    while (object != NULL){
                        printf("[ ");
                        printObj(object);
                        printf(" ]");
                        object = object->next;
                    }  
                    printf("\n");  
                }
            }
            disassembleInstruction(vm.chunk, (int)(vm.ip - vm.chunk->code));    
        }
        uint8_t instruction;
        switch (instruction = READ_BYTE()){
            case OP_CONSTANT: {
                Value constant = READ_CONSTANT();
                push(constant);
                break;
            }
            case OP_CONSTANT_LONG: {
                Value constant = READ_LONG_CONSTANT();
                push(constant);
                break;
            }
            case OP_NIL: {
                push(NIL_VAL);
                break;
            }
            case OP_TRUE: {
                push(BOOL_VAL(true));
                break;
            }
            case OP_FALSE: {
                push(BOOL_VAL(false));
                break;
            }
            case OP_POP: {
                pop();
                break;
            }
            case OP_DEFINE_GLOBAL: {
                ObjString* name = READ_STRING();
                tableSet(&vm.globals, name, peek(0));
                pop();
                break;
            }
            case OP_EQUAL: {
                Value b = pop();
                Value a = pop();
                push(BOOL_VAL(valuesEqual(a, b)));
                break;
            }
            case OP_GREATER: {
                BINARY_OP(BOOL_VAL, >);
                break;
            }
            case OP_LESS: {
                BINARY_OP(BOOL_VAL, <);
                break;
            }
            case OP_NEGATE: {
                Value* top = (vm.stackTop - 1);
                if (!IS_NUMBER(*top)){
                    runtimeError("Operand must be a number.");
                    return INTERPRET_RUNTIME_ERROR;
                }     
                top->as.number = -(top->as.number);
                break;
            }
            case OP_ADD: {
                if (IS_STRING(peek(0)) && IS_STRING(peek(1))){
                    concatenate();
                } 
                else if (IS_NUMBER(peek(0)) && IS_NUMBER(peek(1))){
                    double b = AS_NUMBER(pop());
                    double a = AS_NUMBER(pop());
                    push(NUMBER_VAL(a + b));
                }
                else {
                    runtimeError("Operands must be two numbers or two strings.");
                    return INTERPRET_RUNTIME_ERROR;
                }
                break;
            }
            case OP_SUBTRACT: BINARY_OP(NUMBER_VAL, -); break;
            case OP_MULTIPLY: BINARY_OP(NUMBER_VAL, *); break;
            case OP_DIVIDE:   BINARY_OP(NUMBER_VAL, /); break;
            case OP_NOT: {
                Value* top = (vm.stackTop - 1);
                *top = BOOL_VAL(isFalsey(*top));
                break;
            }
            case OP_PRINT: {
                if (cloxRun.printResultVerbose){
                    printf("\n== output ==\n");
                    printValue(pop());
                    printf("\n");
                }
                else {                   
                    printValue(pop());
                    printf("\n");
                }  
                break;
            }
            case OP_RETURN: {
                return INTERPRET_OK;
            }
        }
    }

#undef READ_BYTE
#undef READ_STRING
#undef READ_CONSTANT
#undef READ_LONG_CONSTANT
#undef BINARY_OP
}

InterpretResult interpret(const char* source){
    InterpretResult result;
    Chunk chunk;
    initChunk(&chunk);

    if (compile(source, &chunk)){
        if (cloxRun.noExecution){
            result = INTERPRET_OK;
        }
        else {
            vm.chunk = &chunk;
            vm.ip = vm.chunk->code;
            result = run();
        }    
    }
    else {
        result = INTERPRET_COMPILE_ERROR;
    }

    freeChunk(&chunk);
    return result;
}
