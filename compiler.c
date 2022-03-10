#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "debug.h"
#include "common.h"
#include "compiler.h"
#include "scanner.h"
#include "object.h"

typedef struct {
    Token current;
    Token previous;
    bool hadError;
    bool panicMode;
} Parser;

typedef enum {
    PREC_NONE,
    PREC_ASSIGNMENT,
    PREC_OR,
    PREC_AND,
    PREC_EQUALITY,
    PREC_COMPARISON,
    PREC_TERM,
    PREC_FACTOR,
    PREC_UNARY,
    PREC_CALL,
    PREC_PRIMARY
} Precedence;

typedef void (*ParseFn)(bool canAssign);

typedef struct {
    ParseFn prefix;
    ParseFn infix;
    Precedence precedence;
} ParseRule;

typedef struct {
    Token name;
    int depth;
    int offset;
    bool constant;
    bool anonymous;
} Local;

typedef struct {
    uint8_t index;
    uint8_t offset;
    bool isLocal;
} Upvalue;

typedef enum {
    TYPE_FUNCTION,
    TYPE_SCRIPT
} FunctionType;

typedef struct Loop {
    struct Loop* enclosing;
    int breakTarget;
    int breakLocalCount;
    int continueTarget;
    int continueLocalCount;
} Loop;

typedef struct Compiler {
    struct Compiler* enclosing;
    ObjFunction* function;
    FunctionType type;
    Local locals[UINT8_COUNT];
    Upvalue upvalues[UINT8_COUNT];
    Loop* currentLoop;
    int localCount;
    int scopeDepth;
} Compiler;

Parser parser;
Compiler* current = NULL;

static int addAnonymousLocal();
static Upvalue* resolveUpvalue(Compiler* compiler, Token* name);

static Chunk* currentChunk(){
    return &current->function->chunk;
}

static void errorAt(Token* token, const char* message){
    if (parser.panicMode) return;
    parser.panicMode = true;

    fprintf(stderr, "[line %d] Error", token->line);

    if (token->type == TOKEN_EOF){
        fprintf(stderr, " at end");
    }
    else if (token->type == TOKEN_ERROR){
        // Nothing
    }
    else {
        fprintf(stderr, " at '%.*s'", token->length, token->start);
    }

    fprintf(stderr, ": %s\n", message);
    parser.hadError = true;
}

static void error(const char* message){
    errorAt(&parser.previous, message);
}

static void errorAtCurrent(const char* message){
    errorAt(&parser.current, message);
}

static void advance(){
    parser.previous = parser.current;

    for(;;){
        parser.current = scanToken();
        // Token token = parser.current;
        // printf("%2d <%.*s>\n", token.type, token.length, token.start);
        if (parser.current.type != TOKEN_ERROR) break;

        errorAtCurrent(parser.current.start);
    }
}

static void consume(TokenType type, const char* message){
    if (parser.current.type == type){
        advance();
        return;
    }

    errorAtCurrent(message);
}

static bool check(TokenType type){
    return parser.current.type == type;
}

static bool match(TokenType type){
    if (!check(type)) return false;
    advance();
    return true;
}

static void emitByte(uint8_t byte){
    writeChunk(currentChunk(), byte, parser.previous.line);
}

static void emitBytes(uint8_t byte1, uint8_t byte2){
    emitByte(byte1);
    emitByte(byte2);
}

static void emitPop(int count){
    if (count == 0){
        // nothing to do
    }
    else if (count == 1){
        emitByte(OP_POP);
    }
    else {
        emitBytes(OP_POPN, (uint8_t)count);
    }
}

static int emitJump(uint8_t instruction){
    emitByte(instruction);
    emitByte(0xFF);
    emitByte(0xFF);
    return currentChunk()->count - 2;
}

static void emitLoop(int loopStart){
    emitByte(OP_LOOP);

    int offset = currentChunk()->count - loopStart + 2;
    if (offset > UINT16_MAX) error("Loop body too large.");

    emitByte((offset >> 8) & 0xFF);
    emitByte(offset & 0xFF);
}

static void emitReturn(){
    emitByte(OP_NIL);
    emitByte(OP_RETURN);
}

static void emitConstant(Value value){
    writeOPConstant(currentChunk(), value, parser.previous.line);
}

static void patchJump(int offset){
    // -2 to adjust for the bytecode for the jump offset itself
    int jump = currentChunk()->count - offset - 2;

    if (jump > UINT16_MAX){
        error("Too much code to jump over.");
    }

    currentChunk()->code[offset] = (jump >> 8) & 0xFF;
    currentChunk()->code[offset + 1] = jump & 0xFF;
}

static void initCompiler(Compiler* compiler, FunctionType type){
    compiler->enclosing = current;
    compiler->type = type;
    compiler->function = NULL;  // GC-related paranoia
    compiler->localCount = 0;
    compiler->scopeDepth = 0;
    compiler->currentLoop = NULL;
    compiler->function = newFunction();
    current = compiler;
    if (type != TYPE_SCRIPT){
        current->function->name = copyString(parser.previous.start, parser.previous.length);
    }

    // reserve a local slot to store the function
    int functionLocal = addAnonymousLocal();
}

static uint8_t makeConstant(Value value) {
  int constant = addConstant(currentChunk(), value);
  if (constant > UINT8_MAX) {
    error("Too many constants in one chunk.");
    return 0;
  }

  return (uint8_t)constant;
}

static ObjFunction* endCompiler(){
    emitReturn();
    ObjFunction* function = current->function;

    if (cloxRun.showBytecode){
        char* label = function->name != NULL ? function->name->chars : "<script>";
        disassembleChunk(&function->chunk, label);
    }

    current = current->enclosing;
    return function;
}

static void beginScope(){
    current->scopeDepth++;
}

static void endScope(){
    current->scopeDepth--;

    // Count how many locals there are in this scope.
    int scopeCount = 0;
    while (current->localCount > 0 && current->locals[current->localCount - 1].depth > current->scopeDepth){
        scopeCount++;
        current->localCount--;
    }

    // Pop those locals off the stack to remove all variables of the current scope.
    emitPop(scopeCount);
}

static void expression();
static void statement();
static void declaration();
static ParseRule* getRule(TokenType type);
static void parsePrecedence(Precedence precedence);
static uint8_t identifierConstant(Token* name);
static Local* resolveLocal(Compiler* compiler, Token* name);

static void binary(bool canAssign){
    TokenType operatorType = parser.previous.type;
    ParseRule* rule = getRule(operatorType);
    parsePrecedence((Precedence)(rule->precedence + 1));
    switch(operatorType){
        case TOKEN_BANG_EQUAL:      emitBytes(OP_EQUAL, OP_NOT); break;
        case TOKEN_EQUAL_EQUAL:     emitByte(OP_EQUAL); break;
        case TOKEN_GREATER:         emitByte(OP_GREATER); break;
        case TOKEN_GREATER_EQUAL:   emitBytes(OP_LESS, OP_NOT); break;
        case TOKEN_LESS:            emitByte(OP_LESS); break;
        case TOKEN_LESS_EQUAL:      emitBytes(OP_GREATER, OP_NOT); break;
        case TOKEN_PLUS:            emitByte(OP_ADD); break;
        case TOKEN_MINUS:           emitByte(OP_SUBTRACT); break;
        case TOKEN_STAR:            emitByte(OP_MULTIPLY); break;
        case TOKEN_SLASH:           emitByte(OP_DIVIDE); break;
        default:
            return; // unreachable
    }
}

static uint8_t argumentList(){
    uint8_t argCount = 0;
    if (!check(TOKEN_RIGHT_PAREN)){
        do {
            expression();
            if (argCount == 255){
                error("Can't have more than 255 arguments.");
            }
            argCount++;
        } while (match(TOKEN_COMMA));
    }
    consume(TOKEN_RIGHT_PAREN, "Expect ';' after arguments.");
    return argCount;
}

static void call(bool canAssign){
    uint8_t argCount = argumentList();
    emitBytes(OP_CALL, argCount);
}

static void literal(bool canAssign){
    TokenType literalType = parser.previous.type;
    switch(literalType){
        case TOKEN_FALSE: emitByte(OP_FALSE); break;
        case TOKEN_NIL: emitByte(OP_NIL); break;
        case TOKEN_TRUE: emitByte(OP_TRUE); break;
        default: return; // unreachable
    }
}

static void grouping(bool canAssign){
    expression();
    consume(TOKEN_RIGHT_PAREN, "Expect ')' after expression.");
}

static void number(bool canAssign){
    double value = strtod(parser.previous.start, NULL);
    emitConstant(NUMBER_VAL(value));
}

static void string(bool canAssign){
    emitConstant(OBJ_VAL(copyString(parser.previous.start+1,
                                    parser.previous.length - 2)));
}

static void namedVariable(Token name, bool canAssign){
    uint8_t getOp, setOp;

    // Try if we can find a local with this name.
    Local* local;
    Upvalue* upvalue;
    int operand;
    if ((local = resolveLocal(current, &name)) != NULL){
        // found -> local
        getOp = OP_GET_LOCAL;
        setOp = OP_SET_LOCAL;
        operand = local->offset;
    }
    // Look in enclosing scopes for a local with this name
    else if ((upvalue = resolveUpvalue(current, &name)) != NULL){
        // found -> upvalue
        getOp = OP_GET_UPVALUE;
        setOp = OP_SET_UPVALUE;
        operand = upvalue->offset;
    }
    else {
        // not found -> assume global
        getOp = OP_GET_GLOBAL;
        setOp = OP_SET_GLOBAL;
        operand = identifierConstant(&name);
    }

    if (canAssign && match(TOKEN_EQUAL)){
        if (local != NULL && local->constant){
            error("Constant cannot be assigned to.");
        }
        expression();
        emitBytes(setOp, (uint8_t)operand);
    }
    else {
        emitBytes(getOp, (uint8_t)operand);
    }
}

static void variable(bool canAssign){
    namedVariable(parser.previous, canAssign);
}

static void unary(bool canAssign){
    TokenType operatorType = parser.previous.type;

    // Compile the operand
    parsePrecedence(PREC_UNARY);

    // Emit the operator instruction
    switch(operatorType){
        case TOKEN_MINUS: emitByte(OP_NEGATE); break;
        case TOKEN_BANG: emitByte(OP_NOT); break;
        default: return; // unreachable
    }
}

static void and_(bool canAssign){
    // Duplicate LHS operand, so that it can become the result when it is falsey.
    emitByte(OP_DUP);
    int endJump = emitJump(OP_JUMP_IF_FALSE);
    // LHS operand is truthy; right-hand operand will be result.
    emitByte(OP_POP);
    parsePrecedence(PREC_AND);
    patchJump(endJump);
}

static void or_(bool canAssign){
    // Duplicate LHS operand, so that it can become the result when it is truthey.
    emitByte(OP_DUP);
    int elseJump = emitJump(OP_JUMP_IF_FALSE);
    int endJump = emitJump(OP_JUMP);
    patchJump(elseJump);
    // LHS operand is falsey; right-hand operand is result
    emitByte(OP_POP);
    parsePrecedence(PREC_OR);
    patchJump(endJump);
}

ParseRule rules[] = {
    [TOKEN_LEFT_PAREN]    = { grouping, call,   PREC_CALL     },
    [TOKEN_RIGHT_PAREN]   = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_LEFT_BRACE]    = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_RIGHT_BRACE]   = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_CONST]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_COMMA]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_DOT]           = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_MINUS]         = { unary,    binary, PREC_TERM     },
    [TOKEN_PLUS]          = { NULL,     binary, PREC_TERM     },
    [TOKEN_SEMICOLON]     = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_SLASH]         = { NULL,     binary, PREC_FACTOR   },
    [TOKEN_STAR]          = { NULL,     binary, PREC_FACTOR   },
    [TOKEN_BANG]          = { unary,    NULL,   PREC_NONE     },
    [TOKEN_BANG_EQUAL]    = { NULL,     binary, PREC_EQUALITY },
    [TOKEN_EQUAL]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_EQUAL_EQUAL]   = { NULL,     binary, PREC_EQUALITY },
    [TOKEN_GREATER]       = { NULL,     binary, PREC_EQUALITY },
    [TOKEN_GREATER_EQUAL] = { NULL,     binary, PREC_EQUALITY },
    [TOKEN_LESS]          = { NULL,     binary, PREC_EQUALITY },
    [TOKEN_LESS_EQUAL]    = { NULL,     binary, PREC_EQUALITY },
    [TOKEN_IDENTIFIER]    = { variable, NULL,   PREC_NONE     },
    [TOKEN_STRING]        = { string,   NULL,   PREC_NONE     },
    [TOKEN_NUMBER]        = { number,   NULL,   PREC_NONE     },
    [TOKEN_AND]           = { NULL,     and_,   PREC_AND      },
    [TOKEN_CLASS]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_ELSE]          = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_FALSE]         = { literal,  NULL,   PREC_NONE     },
    [TOKEN_FOR]           = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_FUN]           = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_IF]            = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_NIL]           = { literal,  NULL,   PREC_NONE     },
    [TOKEN_OR]            = { NULL,     or_,    PREC_OR       },
    [TOKEN_PRINT]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_RETURN]        = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_SUPER]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_THIS]          = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_TRUE]          = { literal,  NULL,   PREC_NONE     },
    [TOKEN_VAR]           = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_WHILE]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_ERROR]         = { NULL,     NULL,   PREC_NONE     },
    [TOKEN_EOF]           = { NULL,     NULL,   PREC_NONE     }
};

static void parsePrecedence(Precedence precedence){
    advance();
    ParseFn prefixRule = getRule(parser.previous.type)->prefix;
    if (prefixRule == NULL){
        error("Expect expression");
        return;
    }

    bool canAssign = (precedence <= PREC_ASSIGNMENT);
    prefixRule(canAssign);

    while (precedence <= getRule(parser.current.type)->precedence){
        advance();
        ParseFn infixRule = getRule(parser.previous.type)->infix;
        infixRule(canAssign);
    }

    if (canAssign && match(TOKEN_EQUAL)){
        error("Invalid assignment target.");
    }
}

static uint8_t identifierConstant(Token* name){
    return makeConstant(OBJ_VAL(copyString(name->start, name->length)));
}

static bool identifiersEqual(Token* a, Token* b){
    if (a->length != b->length) return false;
    return memcmp(a->start,  b->start,  a->length) == 0;
}

static Local* resolveLocal(Compiler* compiler, Token* name){
    for (int i = compiler->localCount - 1; i >= 0; i--){
        Local* local = &compiler->locals[i];
        if (!local->anonymous && identifiersEqual(name, &local->name)){
            if (local->depth == -1){
                error("Can't read local variable or constant in its own initializer.");
            }
            return local;
        }
    }
    return NULL;
}

static void addLocal(Token name, bool constant){
    if (current->localCount == UINT8_COUNT){
        error("Too many local variables or constants in function.");
        return;
    }

    Local* local = &current->locals[current->localCount];
    local->offset = current->localCount;
    local->name = name;
    local->depth = -1;
    local->constant = constant;
    local->anonymous = false;
    current->localCount++;
}

// Creates a local without a name, to be used by the compiler for its own purposes.
static int addAnonymousLocal(){
    if (current->localCount == UINT8_COUNT){
        error("Too many local variables or constants in function.");
        return 0;
    }

    Local* local = &current->locals[current->localCount];
    local->offset = current->localCount;
    local->name.start = "";
    local->name.length = 0;
    local->depth = current->scopeDepth;
    local->constant = false;
    local->anonymous = true;
    current->localCount++;
    return local->offset;
}

static Upvalue* addUpvalue(Compiler* compiler, uint8_t index, bool isLocal){
    int upvalueCount = compiler->function->upvalueCount;

    // Look for an existing Upvalue
    for (int i=0; i<upvalueCount; i++){
        Upvalue* upvalue = &compiler->upvalues[i];
        if (upvalue->index == index && upvalue->isLocal == isLocal){
            return upvalue;
        }
    }

    if (upvalueCount == UINT8_COUNT){
        error("Too many closure variables in function.");
        return NULL;
    }

    Upvalue* upvalue = &compiler->upvalues[upvalueCount];
    upvalue->isLocal = isLocal;
    upvalue->index = index;

    upvalue->offset = upvalueCount;
    compiler->function->upvalueCount++;

    return upvalue;
}

static Upvalue* resolveUpvalue(Compiler* compiler, Token* name){
    if (compiler->enclosing == NULL) return NULL;

    Local* local = resolveLocal(compiler->enclosing, name);
    if (local != NULL){
        return addUpvalue(compiler, (uint8_t)local->offset, true);
    }

    Upvalue* upvalue = resolveUpvalue(compiler->enclosing, name);
    if (upvalue != NULL){
        return addUpvalue(compiler, (uint8_t)upvalue->offset, false);
    }

    return NULL;
}

static void declareVariable(bool constant){
    if (current->scopeDepth == 0) return;

    Token* name = &parser.previous;

    for (int i = current->localCount - 1; i >= 0; i--){
        Local* local = &current->locals[i];
        if (local->depth != -1 && local->depth < current->scopeDepth){
            break;
        }
        if (identifiersEqual(name, &local->name)){
            error("Already a variable or constant with this name in this scope.");
        }
    }

    addLocal(*name, constant);
}

static uint8_t parseVariable(const char* errorMessage, bool constant){
    consume(TOKEN_IDENTIFIER, errorMessage);

    declareVariable(constant);
    if (current->scopeDepth > 0) return 0;

    return identifierConstant(&parser.previous);
}

static void markInitialized(){
    if (current->scopeDepth == 0) return;
    current->locals[current->localCount - 1].depth = current->scopeDepth;
}

static void defineVariable(uint8_t global, bool constant){
    // Local
    if (current->scopeDepth > 0) {
        markInitialized();
        return;
    }
    // Global
    else {
        if (constant){
            error("Constants not allowed at global level.");
            // Semantic error, let's continue to generate bytecode
            // as close a possible to what we would generate otherwise.
            // return;
        }
        emitBytes(OP_DEFINE_GLOBAL, global);
    }
}

static ParseRule* getRule(TokenType type){
    return &rules[type];
}

static void expression(){
    parsePrecedence(PREC_ASSIGNMENT);
}

static void block(){
    while (!check(TOKEN_RIGHT_BRACE) && !check(TOKEN_EOF)){
        declaration();
    }
    consume(TOKEN_RIGHT_BRACE, "Expect '}' after block.");
}

static void function(FunctionType type){
    Compiler compiler;
    initCompiler(&compiler, type);
    beginScope();

    consume(TOKEN_LEFT_PAREN, "Expect '(' after function name.");
    if (!check(TOKEN_RIGHT_PAREN)){
        do {
            current->function->arity++;
            if (current->function->arity > 255){
                errorAtCurrent("Can't have more than 255 parameters.");
            }
            bool isConst = match(TOKEN_CONST);
            uint8_t constant = parseVariable("Expect parameter name.", isConst);
            defineVariable(constant, isConst);
        } while (match(TOKEN_COMMA));
    }
    consume(TOKEN_RIGHT_PAREN, "Expect ')' after parameters.");
    consume(TOKEN_LEFT_BRACE, "Expect '{' before function body.");
    block();

    ObjFunction* function = endCompiler();
    emitBytes(OP_CLOSURE, makeConstant(OBJ_VAL(function)));
    for (int i=0; i<function->upvalueCount; i++){
        emitByte(compiler.upvalues[i].isLocal ? 1 : 0);
        emitByte(compiler.upvalues[i].index);
    }
}

static void funDeclaration(){
    uint8_t global = parseVariable("Expect function name.", false);
    markInitialized();
    function(TYPE_FUNCTION);
    defineVariable(global, false);
}

static void varDeclaration(){
    uint8_t global = parseVariable("Expect variable name.", false);

    if (match(TOKEN_EQUAL)){
        expression();
    }
    else {
        emitByte(OP_NIL);
    }

    consume(TOKEN_SEMICOLON, "Expect ';' after variable declaration.");

    defineVariable(global, false);
}

static void constDeclaration(){
    uint8_t global = parseVariable("Expect constant name.", true);

    consume(TOKEN_EQUAL, "Expect expresion to initialize constant.");
    expression();
    consume(TOKEN_SEMICOLON, "Expect ';' after constant declaration.");

    defineVariable(global, true);
}


static void expressionStatement(){
    expression();
    consume(TOKEN_SEMICOLON, "Expect ';' after expression.");
    emitByte(OP_POP);
}

static void ifStatement(){
    consume(TOKEN_LEFT_PAREN, "Expect '(' after if.");
    expression();
    consume(TOKEN_RIGHT_PAREN, "Expect ')' after condition.");

    int thenJump = emitJump(OP_JUMP_IF_FALSE);
    statement();

    if (check(TOKEN_ELSE)){
        int elseJump = emitJump(OP_JUMP);
        patchJump(thenJump);
        consume(TOKEN_ELSE, "Already seen else.");
        statement();
        patchJump(elseJump);
    }
    else {
        patchJump(thenJump);
    }
}

static void returnStatement(){
    if (current->type == TYPE_SCRIPT){
        error("Can't return from top-level code.");
    }

    if (match(TOKEN_SEMICOLON)){
        emitReturn();
    }
    else {
        expression();
        consume(TOKEN_SEMICOLON, "Expect ';' after return value.");
        emitByte(OP_RETURN);
    }
}

// Loops are nested and we compile them recursively.
// This allows us to store them as a linked list
// threaded through the C stack.
static void startLoop(Loop* loop){
    loop->enclosing = current->currentLoop;
    current->currentLoop = loop;
}

static void endLoop(){
    current->currentLoop = current->currentLoop->enclosing;
}

static void whileStatement(){
    // Bookkeeping for 'break' and 'continue' statements.
    Loop whileLoop;
    startLoop(&whileLoop);

    // Insert a jump that unconditionally jumps out of the loop.
    emitByte(OP_SKIP);
    whileLoop.breakTarget = currentChunk()->count;
    whileLoop.breakLocalCount = current->localCount;
    int breakJump = emitJump(OP_JUMP);

    // This is were we jump to at the end of the loop
    // (or when continue statement is used).
    int loopStart = currentChunk()->count;

    // Configure where 'continue' should jump to.
    whileLoop.continueTarget = loopStart;
    whileLoop.continueLocalCount = current->localCount;

    consume(TOKEN_LEFT_PAREN, "Expect '(' after 'while'.");
    expression();
    consume(TOKEN_RIGHT_PAREN, "Expect ')' after condition.");

    int exitJump = emitJump(OP_JUMP_IF_FALSE);
    statement();
    emitLoop(loopStart);

    patchJump(exitJump);   // condition has become false
    patchJump(breakJump);  // break statement used
}

static void forStatement(){
    consume(TOKEN_LEFT_PAREN, "Expect '(' after 'for'.");

    // Bookkeeping for 'break' and 'continue' statements.
    Loop forLoop;
    startLoop(&forLoop);

    // Insert a jump that unconditionally jumps out of the loop.
    emitByte(OP_SKIP);
    forLoop.breakLocalCount = current->localCount;
    forLoop.breakTarget = currentChunk()->count;
    int breakJump = emitJump(OP_JUMP);

    // A variable declared in the initializer has its own scope.
    beginScope();

    if (match(TOKEN_SEMICOLON)){
        // Empty initializer
    }
    else if (match(TOKEN_VAR)){
        varDeclaration();
    }
    else if (match(TOKEN_CONST)){
        error("Cannot declare a constant in the initializer of a for loop.");
        // Semantic error. Consume the declaration to keep parser in sync.
        constDeclaration();
    }
    else {
        expressionStatement();
    }

    int loopStart = currentChunk()->count;
    int exitJump = -1;
    if (!match(TOKEN_SEMICOLON)){
        expression();
        consume(TOKEN_SEMICOLON, "Expect ';' after loop condition.");

        // Jump out of the loop if the condition is false.
        exitJump = emitJump(OP_JUMP_IF_FALSE);
    }

    if (!match(TOKEN_RIGHT_PAREN)){
        int bodyJump = emitJump(OP_JUMP);
        int incrementStart = currentChunk()->count;
        expression();
        emitByte(OP_POP);
        consume(TOKEN_RIGHT_PAREN, "Expect ')' after for clauses.");

        emitLoop(loopStart);
        loopStart = incrementStart;
        patchJump(bodyJump);;
    }

    // Configure where 'continue' should jump to.
    forLoop.continueTarget = loopStart;
    forLoop.continueLocalCount = current->localCount;

    // Compile the body of the loop, and afterward jump back to the start.
    statement();
    emitLoop(loopStart);

    // Jump taken when condition becomes false.
    // We need to pop the local created in the initializer from the stack.
    if (exitJump != -1){ patchJump(exitJump); }
    endScope();

    // Jump taken when 'break' is used.
    // The local created in the initializer and all other locals
    // have already been popped by the 'break' statement.
    patchJump(breakJump);

    endLoop();
}

static void switchStatement(){
    beginScope();

    consume(TOKEN_LEFT_PAREN, "Expect '(' after 'switch'.");
    int conditionLocal = addAnonymousLocal();
    expression();
    consume(TOKEN_RIGHT_PAREN, "Expect ')' after condition.");
    consume(TOKEN_LEFT_BRACE, "Expect '{' to start list of cases.");

    int caseCount = 0;

    // Jump to the evaluation of the first case.
    int nextCaseJump = emitJump(OP_JUMP);

    // Instead of keeping a list of all OP_JUMPs that need patching,
    // we jump back from the end of each CASE to a jump that takes us
    // to the end of the switch.
    int exitSwitch = currentChunk()->count;
    int exitSwitchJump = emitJump(OP_JUMP);

    // Process 'case' keywords one by one.
    while (match(TOKEN_CASE)){
        caseCount++;
        // This point in the instruction stream is where
        // the previous case should jump to if that case
        // was false.
        patchJump(nextCaseJump);
        // Load the value of the condition
        emitBytes(OP_GET_LOCAL, (uint8_t)conditionLocal);
        // Evaluate condition for this case.
        expression();
        consume(TOKEN_COLON, "Expect ':' after 'case' expression.");
        // Compare condition with case.
        emitByte(OP_EQUAL);
        // Jump to the next case when this
        // case does not match the condition.
        nextCaseJump = emitJump(OP_JUMP_IF_FALSE);
        // Body of the case to be executed
        // when case matches condition.
        statement();
        // Jump back to the OP_JUMP
        // that exits the whole switch.
        emitLoop(exitSwitch);
    }

    // Process optional 'default' case.
    if (match(TOKEN_DEFAULT)){
        caseCount++;
        consume(TOKEN_COLON, "Expect ':' after 'default'");
        // This point in the instruction stream is where
        // the previous case should jump to if that case
        // was false.
        patchJump(nextCaseJump);
        // Body of the case to be executed.
        statement();
        // Default case is the last, so it can fall through
        // to the end of the switch without extra jumps.
    }
    else {
        // The last 'case' needs to jump somewhere
        // when there is no 'default' and none of the
        // cases match.
        patchJump(nextCaseJump);
    }

    // We've compiled the entire switch. Now we know where the
    // end of the switch is, and we can patch the jump that we
    // inserted at the top.
    patchJump(exitSwitchJump);

    // End the scope. This discards the anonymous local
    // that stores the result of the condition.
    endScope();

    consume(TOKEN_RIGHT_BRACE, "Expect '}' to end list of cases.");

    if (caseCount == 0){
        error("No 'case'es nor 'default' in 'switch'.");
    }
}

static void breakStatement(){
    Compiler* compiler = current;
    Loop* loop = compiler->currentLoop;

    if (loop == NULL){
        error("No loop to 'break' out of.");
    }
    else {
        emitPop(compiler->localCount - loop->breakLocalCount);
        emitLoop(loop->breakTarget);
    }
    consume(TOKEN_SEMICOLON, "Expect ';' after 'break'.");
}

static void continueStatement(){
    Compiler* compiler = current;
    Loop* loop = compiler->currentLoop;

    if (loop == NULL){
        error("No loop to 'continue' with.");
    }
    else {
        emitPop(compiler->localCount - loop->continueLocalCount);
        emitLoop(loop->continueTarget);
    }
    consume(TOKEN_SEMICOLON, "Expect ';' after 'continue'.");
}

static void printStatement(){
    expression();
    consume(TOKEN_SEMICOLON, "Expect ';' after value.");
    emitByte(OP_PRINT);
}

static void synchronize(){
    parser.panicMode = false;

    while (parser.current.type != TOKEN_EOF){
        if (parser.previous.type == TOKEN_SEMICOLON) return;
        switch (parser.current.type){
            case TOKEN_BREAK:
            case TOKEN_CASE:
            case TOKEN_CLASS:
            case TOKEN_CONST:
            case TOKEN_CONTINUE:
            case TOKEN_DEFAULT:
            case TOKEN_FUN:
            case TOKEN_VAR:
            case TOKEN_FOR:
            case TOKEN_IF:
            case TOKEN_WHILE:
            case TOKEN_PRINT:
            case TOKEN_RETURN:
            case TOKEN_SWITCH:
                return;

            default:
                ; // Do nothing
        }

        advance();
    }
}

static void declaration(){
    if (match(TOKEN_FUN)){
        funDeclaration();
    }
    else if (match(TOKEN_VAR)){
        varDeclaration();
    }
    else if (match(TOKEN_CONST)){
        constDeclaration();
    } else {
        statement();
    }
    if (parser.panicMode) synchronize();
}

static void statement(){
    if (match(TOKEN_PRINT)){
        printStatement();
    }
    else if (match(TOKEN_IF)){
        ifStatement();
    }
    else if (match(TOKEN_RETURN)){
        returnStatement();
    }
    else if (match(TOKEN_FOR)){
        forStatement();
    }
    else if (match(TOKEN_WHILE)){
        whileStatement();
    }
    else if (match(TOKEN_SWITCH)){
        switchStatement();
    }
    else if (match(TOKEN_BREAK)){
        breakStatement();
    }
    else if (match(TOKEN_CONTINUE)){
        continueStatement();
    }
    else if (match(TOKEN_LEFT_BRACE)){
        beginScope();
        block();
        endScope();
    }
    else {
        expressionStatement();
    }
}

ObjFunction* compile(const char* source){
    initScanner(source);
    Compiler compiler;
    initCompiler(&compiler, TYPE_SCRIPT);

    parser.hadError = false;
    parser.panicMode = false;

    advance();

    while (!match(TOKEN_EOF)){
        declaration();
    }

    ObjFunction* function = endCompiler();
    return parser.hadError ? NULL : function;
}