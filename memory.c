#include <stdlib.h>

#include "compiler.h"
#include "memory.h"
#include "object.h"
#include "vm.h"

#ifdef DEBUG_LOG_GC
#include <stdio.h>
#include "debug.h"
#endif

void* reallocate(void* pointer, size_t oldSize, size_t newSize){
    if (newSize > oldSize){
#ifdef DEBUG_STRESS_GC
        collectGarbage();
#endif
    }

    if (newSize == 0){
        free(pointer);
        return NULL;
    }

    void* result = realloc(pointer, newSize);
    if (result == NULL) exit(1);
    return result;
}

void freeObject(Obj* object){
#ifdef DEBUG_LOG_GC
    printf("%p free type %d\n", (void*)object, object->type);
#endif

    switch(object->type){
        case OBJ_STRING: {
            ObjString* string = (ObjString*)object;
            FREE_ARRAY(char, string->chars, string->length + 1);
            FREE(ObjString, object);
            break;
        }
        case OBJ_FUNCTION: {
            ObjFunction* function = (ObjFunction*)object;
            freeChunk(&function->chunk);
            FREE(ObjFunction, object);
            break;
        }
        case OBJ_NATIVE: {
            FREE(ObjNative, object);
            break;
        }
        case OBJ_CLOSURE: {
            ObjClosure* closure = (ObjClosure*)object;
            FREE_ARRAY(ObjUpvalue*, closure->upvalues, closure->upvalueCount);
            FREE(ObjClosure, object);
            break;
        }
        case OBJ_UPVALUE: {
            FREE(ObjUpvalue, object);
            break;
        }
    }
}

void markObject(Obj* object){
    if (object == NULL) return;
#ifdef DEBUG_GC_LOG
    printf("%p mark ", (void*)object);
    printValue(OBJ_VAL(object));
    printf("\n");
#endif
    object->isMarked = true;
}

void markValue(Value value){
    if (IS_OBJ(value)) markObject(AS_OBJ(value));
}

static void markRoots(){
    // Everything on the Stack
    for (Value* slot = vm.stack; slot < vm.stackTop; slot++){
        markValue(*slot);
    }
    // All globals
    markTable(&vm.globals);
    // All Closures on the CallStack
    for (int i=0; i < vm.frameCount; i++){
        markObject((Obj*)vm.frames[i].closure);
    }
    // Open Upvalues
    for (ObjUpvalue* upvalue = vm.openUpvalues; upvalue != NULL; upvalue = upvalue->next){
        markObject((Obj*)upvalue);
    }
    // Things the compiler has a reference to
    markCompilerRoots();
}

void collectGarbage(){
#ifdef DEBUG_LOG_GC
    printf("--gc begin\n");
#endif

    markRoots();

#ifdef DEBUG_LOG_GC
    printf("--gc end\n");
#endif
}

void freeObjects(){
    Obj* object = vm.objects;
    while (object != NULL){
        Obj* next = object->next;
        freeObject(object);
        object = next;
    }
}