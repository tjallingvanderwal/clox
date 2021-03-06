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
    object->isMarked = false;
    object->next = vm.objects;
    vm.objects = object;

#ifdef DEBUG_LOG_GC
    printf("%p allocate %zu for %d\n", (void*)object, size, type);
#endif

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
    function->upvalueCount = 0;
    function->name = NULL;
    initChunk(&function->chunk);
    return function;
}

ObjNative* newNative(NativeFn function){
    ObjNative* native = ALLOCATE_OBJECT(ObjNative, OBJ_NATIVE);
    native->function = function;
    return native;
}

ObjClosure* newClosure(ObjFunction* function){
    ObjUpvalue** upvalues = ALLOCATE(ObjUpvalue*, function->upvalueCount);
    // Prevent the GC seeing uninitialized memory
    for (int i=0; i<function->upvalueCount; i++){
        upvalues[i] = NULL;
    }

    ObjClosure* closure = ALLOCATE_OBJECT(ObjClosure, OBJ_CLOSURE);
    closure->function = function;
    closure->upvalues = upvalues;
    closure->upvalueCount = function->upvalueCount;
    return closure;
}

ObjUpvalue* newUpvalue(Value* slot){
    ObjUpvalue* upvalue = ALLOCATE_OBJECT(ObjUpvalue, OBJ_UPVALUE);
    upvalue->location = slot;
    upvalue->closed = NIL_VAL;
    upvalue->next = NULL;
    return upvalue;
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

static void fprintNativeFunction(FILE* stream){
    fprintf(stream, "<native fn>");
}

static void fprintUpvalue(FILE* stream){
    fprintf(stream, "<upvalue>");
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
        case OBJ_NATIVE: {
            fprintNativeFunction(stream);
            break;
        }
        case OBJ_CLOSURE: {
            fprintFunction(stream, ((ObjClosure*)object)->function);
            break;
        }
        case OBJ_UPVALUE: {
            fprintUpvalue(stream);
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
        case OBJ_NATIVE: {
            fprintNativeFunction(stream);
            break;
        }
        case OBJ_CLOSURE: {
            fprintFunction(stream, AS_CLOSURE(value)->function);
            break;
        }
        case OBJ_UPVALUE: {
            fprintUpvalue(stream);
            break;
        }
    }
}

void printObject(Value value){
    fprintObject(stdout, value);
}
