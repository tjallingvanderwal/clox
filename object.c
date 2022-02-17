#include <stdio.h>
#include <string.h>

#include "memory.h"
#include "object.h"
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

static ObjString* allocateString(char* chars, int length, bool owned){
    ObjString* string = ALLOCATE_OBJECT(ObjString, OBJ_STRING);
    string->length = length;
    string->chars = chars;
    string->owned = owned;
    return string;
}

ObjString* takeString(char* chars, int length){
    return allocateString(chars, length, true);
}

ObjString* copyString(char* chars, int length){
    // char* heapChars = ALLOCATE(char, length+1);
    // memcpy(heapChars, chars, length);
    // heapChars[length] = '\0';
    // return allocateString(heapChars, length);
    return allocateString(chars, length, false);
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
