#include <stdio.h>

#include "memory.h"
#include "value.h"

void initValueArray(ValueArray* array){
    array->values = NULL;
    array->capacity = 0;
    array->count = 0;
}

void writeValueArray(ValueArray* array, Value value){
    if (array->capacity < array->count + 1){
        int oldCapacity = array->capacity;
        array->capacity = GROW_CAPACITY(oldCapacity);
        array->values = GROW_ARRAY(Value, array->values, oldCapacity, array->capacity);
    }

    array->values[array->count] = value;
    array->count++;
}

void freeValueArray(ValueArray* array){
    FREE_ARRAY(Value, array->values, array->capacity);
    initValueArray(array);
}

void fprintValue(FILE* stream, Value value){
    switch(value.type){
        case VAL_BOOL: {
            fprintf(stream, AS_BOOL(value) ? "true" : "false");
            break;
        }
        case VAL_NIL: {
            fprintf(stream, "nil");
            break;
        } 
        case VAL_NUMBER: {
            fprintf(stream, "%g", AS_NUMBER(value));
            break;
        }
    }
}

void printValue(Value value){
    fprintValue(stdout, value);
}

