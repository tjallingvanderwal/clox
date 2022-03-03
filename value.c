#include <stdio.h>
#include <string.h>

#include "object.h"
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
        case VAL_OBJ: { 
            fprintObject(stream, value);
            break;
        }
    }
}

void printValue(Value value){
    fprintValue(stdout, value);
}

bool valuesEqual(Value a, Value b){
    if (a.type != b.type) return false;
    switch(a.type){
        case VAL_BOOL:   return AS_BOOL(a)==AS_BOOL(b);
        case VAL_NIL:    return true;
        case VAL_NUMBER: return AS_NUMBER(a)==AS_NUMBER(b);
        case VAL_OBJ:    return AS_OBJ(a)==AS_OBJ(b);
        default: return false; //unreachable
    }
}

static uint32_t hashBytes(const char* key, int length){
    uint32_t hash = 2166136261u;
    for (int i = 0; i < length; i++){
        hash ^= (uint32_t)key[i];
        hash *= 16777619;
    }
    return hash;
}

uint32_t hashValue(Value value){
    switch(value.type){
        case VAL_BOOL:   return (AS_BOOL(value) ?  1 : 2);
        case VAL_NIL:    return 3;
        case VAL_NUMBER: return hashBytes((char*)&AS_NUMBER(value), sizeof(AS_NUMBER(value)));
        case VAL_OBJ:    
            switch(OBJ_TYPE(value)){
                case OBJ_STRING: return AS_STRING(value)->hash;
                default: return (uint32_t)AS_OBJ(value);
            }
        
        default: return 0; //unreachable
    }
}