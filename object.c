#include <stdio.h>
#include <string.h>

#include "memory.h"
#include "object.h"
#include "table.h"
#include "value.h"
#include "vm.h"

#define ALLOCATE_OBJECT(type, objectType) \
    (type*)allocateObject(sizeof(type), objectType)

static Obj* allocateObject(size_t size, ObjType type){
    Obj* object = (Obj*)reallocate(NULL, 0, size);
    object->type = type;
    object->next = vm.objects;
    vm.objects = object;
    return object;
}

static ObjString* allocateString(char* chars, int length, uint32_t hash){
    ObjString* string = ALLOCATE_OBJECT(ObjString, OBJ_STRING);
    string->length = length;
    string->chars = chars;
    string->hash = hash;
    tableSet(&vm.strings, string, NIL_VAL);
    return string;
}

ObjFunction* newFunction(){
    ObjFunction* function = ALLOCATE_OBJECT(ObjFunction, OBJ_FUNCTION);
    function->arity = 0;
    function->name = NULL;
    initChunk(&function->chunk);
    return function;
}

static uint32_t hashString(const char* key, int length){
    uint32_t hash = 2166136261u;
    for (int i = 0; i < length; i++){
        hash ^= (uint32_t)key[i];
        hash *= 16777619;
    }
    return hash;
}

ObjString* takeString(char* chars, int length){
    uint32_t hash = hashString(chars, length);
    ObjString* interned = tableFindString(&vm.strings, chars, length, hash);
    if (interned != NULL) {
        FREE_ARRAY(char, chars, length+1);
        return interned;
    }
    return allocateString(chars, length, hash);
}

ObjString* copyString(const char* chars, int length){
    uint32_t hash = hashString(chars, length);
    ObjString* interned = tableFindString(&vm.strings, chars, length, hash);
    if (interned != NULL) return interned;

    char* heapChars = ALLOCATE(char, length+1);
    memcpy(heapChars, chars, length);
    heapChars[length] = '\0';
    return allocateString(heapChars, length, hash);
}

static void fprintFunction(FILE* stream, ObjFunction* function){
    if (function->name != NULL){
        fprintf(stream, "<fn %s(%d)>", function->name->chars, function->arity);
    }
    else {
        fprintf(stream, "<script>");
    }
}

void fprintObj(FILE* stream, Obj* object){
    switch(object->type){
        case OBJ_STRING: {
            fprintf(stream, "<String \"%s\">", ((ObjString*)object)->chars);
            break;
        }
        case OBJ_FUNCTION: {
            fprintFunction(stream, (ObjFunction*)object);
            break;
        }
    }
}

void printObj(Obj* object){
    fprintObj(stdout, object);
}

void fprintObject(FILE* stream, Value value){
    switch(OBJ_TYPE(value)){
        case OBJ_STRING: {
            fprintf(stream, "\"%s\"", AS_CSTRING(value));
            break;
        }
        case OBJ_FUNCTION: {
            fprintFunction(stream, AS_FUNCTION(value));
            break;
        }
    }
}

void printObject(Value value){
    fprintObject(stdout, value);
}
