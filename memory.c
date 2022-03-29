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
    if (object->isMarked) return;

#ifdef DEBUG_GC_LOG
    printf("%p mark ", (void*)object);
    printValue(OBJ_VAL(object));
    printf("\n");
#endif

    if (vm.grayCapacity < vm.grayCapacity + 1){
        vm.grayCapacity = GROW_CAPACITY(vm.grayCapacity);
        vm.grayStack = (Obj**)realloc(vm.grayStack, sizeof(Obj*) * vm.grayCapacity);
        // Terminate the VM, because if we can't garbage collect, we can't do anything.
        if (vm.grayStack == NULL){ exit(1); }
    }

    vm.grayStack[vm.grayCount++] = object;
    object->isMarked = true;
}

void markValue(Value value){
    if (IS_OBJ(value)) markObject(AS_OBJ(value));
}

void markArray(ValueArray* array){
    for (int i=0; i < array->count; i++){
        markValue(array->values[i]);
    }
}

static void blackenObject(Obj* object){
#ifdef DEBUG_LOG_GC
    printf("%p blacken ", (void*)object);
    printValue(OBJ_VAL(object));
    printf("\n");
#endif

    switch(object->type){
        case OBJ_CLOSURE: {
            ObjClosure* closure = (ObjClosure*)closure;
            markObject((Obj*)closure->function);
            for (int i=0; i < closure->upvalueCount; i++){
                markObject((Obj*)closure->upvalues[i]);
            }
            break;
        }
        case OBJ_FUNCTION: {
            ObjFunction* function = (ObjFunction*)object;
            markObject((Obj*)function->name);
            markArray(&function->chunk.constants);
            break;
        }
        case OBJ_UPVALUE: {
            markValue(((ObjUpvalue*)object)->closed);
            break;
        }
        case OBJ_NATIVE:
        case OBJ_STRING:
            break;
    }
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

static void traceReferences(){
    while (vm.grayCount > 0){
        Obj* object = vm.grayStack[vm.grayCount--];
        blackenObject(object);
    }
}

static void sweep(){
    Obj* previous = NULL;
    Obj* object = vm.objects;

    while (object != NULL){
        if (object->isMarked){
            object->isMarked = false;
            previous = object;
            object = object->next;
        }
        else {
            Obj* unreached = object;
            if (previous != NULL){
                previous->next = object;
            }
            else {
                vm.objects = object;
            }
            freeObject(unreached);
        }
    }
}

void collectGarbage(){
#ifdef DEBUG_LOG_GC
    printf("--gc begin\n");
#endif

    markRoots();
    traceReferences();
    tableRemoveWhite(&vm.strings); // Sweep the string pool
    sweep();

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
    free(vm.grayStack);
}