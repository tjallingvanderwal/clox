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

static Value allocateString(char* chars, int length, uint32_t hash){
    ObjString* string = ALLOCATE_OBJECT(ObjString, OBJ_STRING);
    string->length = length;
    string->chars = chars;
    string->hash = hash;
    tableSet(&vm.strings, OBJ_VAL(string), NIL_VAL);
    return OBJ_VAL(string);
}

static uint32_t hashString(const char* key, int length){
    uint32_t hash = 2166136261u;
    for (int i = 0; i < length; i++){
        hash ^= (uint32_t)key[i];
        hash *= 16777619;
    }
    return hash;
}

Value takeString(char* chars, int length){
    uint32_t hash = hashString(chars, length);
    Value* interned = tableFindString(&vm.strings, chars, length, hash);
    if (interned != NULL) {
        FREE_ARRAY(char, chars, length+1);
        return *interned;
    }
    return allocateString(chars, length, hash);
}

Value copyString(const char* chars, int length){
    uint32_t hash = hashString(chars, length);
    Value* interned = tableFindString(&vm.strings, chars, length, hash);
    if (interned != NULL) return *interned;

    char* heapChars = ALLOCATE(char, length+1);
    memcpy(heapChars, chars, length);
    heapChars[length] = '\0';
    return allocateString(heapChars, length, hash);
}

void fprintObj(FILE* stream, Obj* object){
    switch(object->type){
        case OBJ_STRING: {
            fprintf(stream, "<String \"%s\">", ((ObjString*)object)->chars);
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
    }
}

void printObject(Value value){
    fprintObject(stdout, value);
}
