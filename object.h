#ifndef clox_object_h
#define clox_object_h

#include <stdio.h>

#include "chunk.h"
#include "common.h"
#include "value.h"

#define OBJ_TYPE(value) (AS_OBJ(value)->type)

#define IS_STRING(value) isObjType(value, OBJ_STRING)
#define IS_FUNCTION(value) isObjType(value, OBJ_FUNCTION);
#define IS_NATIVE(value) isObjType(value, OBJ_NATIVE);
#define IS_CLOSURE(value) isObjType(value, OBJ_CLOSURE);

#define AS_STRING(value) ((ObjString*)AS_OBJ(value))
#define AS_CSTRING(value) (((ObjString*)AS_OBJ(value))->chars)
#define AS_FUNCTION(value) ((ObjFunction*)AS_OBJ(value))
#define AS_NATIVE(value) (((ObjNative*)AS_OBJ(value))->function)
#define AS_CLOSURE(value) ((ObjClosure*)AS_OBJ(value))

typedef enum {
    OBJ_STRING,
    OBJ_FUNCTION,
    OBJ_NATIVE,
    OBJ_CLOSURE
} ObjType;

struct Obj {
    ObjType type;
    struct Obj* next;
};

struct ObjString {
    Obj obj;
    int length;
    char* chars;
    uint32_t hash;
};

typedef struct {
    Obj obj;
    int arity;
    Chunk chunk;
    ObjString* name;
} ObjFunction;

typedef struct {
    Obj obj;
    ObjFunction* function;
} ObjClosure;

typedef Value (*NativeFn)(int argCount, Value* args);

typedef struct {
    Obj obj;
    NativeFn function;
} ObjNative;

ObjString* copyString(const char* chars, int length);
ObjString* takeString(char* chars, int length);

ObjFunction* newFunction();
ObjNative* newNative();
ObjClosure* newClosure(ObjFunction* function);

void fprintObject(FILE* stream, Value value);
void printObject(Value value);

void fprintObj(FILE* stream, Obj* object);
void printObj(Obj* object);

static inline bool isObjType(Value value, ObjType type){
    return IS_OBJ(value) && AS_OBJ(value)->type == type;
}

#endif