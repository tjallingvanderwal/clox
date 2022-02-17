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

static ObjString* allocateString(char* chars, int length, uint32_t hash, bool owned){
    ObjString* string = ALLOCATE_OBJECT(ObjString, OBJ_STRING);
    string->length = length;
    string->chars = chars;
    string->hash = hash;
    string->owned = owned;
    tableSet(&vm.strings, string, NIL_VAL);
    return string;
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
    return allocateString(chars, length, hash, true);
}

ObjString* copyString(char* chars, int length){
    // char* heapChars = ALLOCATE(char, length+1);
    // memcpy(heapChars, chars, length);
    // heapChars[length] = '\0';
    // return allocateString(heapChars, length);
    uint32_t hash = hashString(chars, length);
    ObjString* interned = tableFindString(&vm.strings, chars, length, hash);
    if (interned != NULL) return interned;
    return allocateString(chars, length, hash, false);
}

void fprintObj(FILE* stream, Obj* object){
    switch(object->type){
        case OBJ_STRING: {
            ObjString* string = ((ObjString*)object);
            if (string->owned){
                fprintf(stream, "<String(O) \"%s\">", string->chars);
            }
            else {
                fprintf(stream, "<String(C) \"%.*s\">", string->length, string->chars);
            }
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
            ObjString* string = ((ObjString*)AS_OBJ(value));
            if (string->owned){
                fprintf(stream, "\"%s\"", string->chars);
            }
            else {
                fprintf(stream, "\"%.*s\"", string->length, string->chars);
            }
            break;
        }
    }
}

void printObject(Value value){
    fprintObject(stdout, value);
}
