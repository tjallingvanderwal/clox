#ifndef clox_object_h
#define clox_object_h

#include <stdio.h>

#include "common.h"
#include "value.h"

#define OBJ_TYPE(value) (AS_OBJ(value)->type)

#define IS_STRING(value) isObjType(value, OBJ_STRING)

#define AS_STRING(value) ((ObjString*)AS_OBJ(value))
#define AS_CSTRING(value) (((ObjString*)AS_OBJ(value))->chars)

typedef enum {
    OBJ_STRING
} ObjType;

struct Obj {
    ObjType type;
    struct Obj* next;
};

struct ObjString {
    Obj obj;
    int length;
    bool owned;
    char* chars;
    uint32_t hash;
};

ObjString* copyString(char* chars, int length);
ObjString* takeString(char* chars, int length);

void fprintObject(FILE* stream, Value value);
void printObject(Value value);

void fprintObj(FILE* stream, Obj* object);
void printObj(Obj* object);

static inline bool isObjType(Value value, ObjType type){
    return IS_OBJ(value) && AS_OBJ(value)->type == type;
}

#endif