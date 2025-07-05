%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

// nodetype variáveis
// 1 - números (int/float), 2 - string, 3 - vetor
typedef struct vars {
    int nodetype;
    char name[50];
    double valor;
    char valors[50];
    double *vet;
    struct vars *prox;
} VARI;

VARI *l1;

VARI *ins(VARI *l, char n[], int type) {
    VARI *new = (VARI *)malloc(sizeof(VARI));
    strcpy(new->name, n);
    new->prox = l;
    new->nodetype = type; 
    
    if (type == 2) { // Se for string
        strcpy(new->valors, "");
    } else { // Se for numérico
        new->valor = 0;
    }
    return new;
}

VARI *ins_a(VARI *l, char n[], int tamanho) {
    VARI *new = (VARI *)malloc(sizeof(VARI));
    strcpy(new->name, n);
    new->vet = (double *)malloc(tamanho * sizeof(double));
    new->prox = l;
    new->nodetype = 3;
    return new;
}

VARI *srch(VARI *l, char n[]) {
    VARI *aux = l;
    while (aux != NULL) {
        if (strcmp(n, aux->name) == 0)
            return aux;
        aux = aux->prox;
    }
    return aux;
}

typedef struct ast {
    int nodetype;
    struct ast *l;
    struct ast *r;
} Ast;

typedef struct numval {
    int nodetype;
    double number;
} Numval;


typedef struct varval {
    int nodetype;
    char var[50];
    Ast *indice;   // ir no índice 
    int size;   // tamanho do vetor
} Varval;

typedef struct texto {
    int nodetype;
    char txt[50];
} TXT;

typedef struct flow {
    int nodetype;
    Ast *cond;
    Ast *tl;
    Ast *el;
} Flow;

typedef struct symasgn {
    int nodetype;
    char s[50];
    Ast *v;
    Ast *indice; 
} Symasgn;

// Funções construtoras da AST
Ast *newast(int nodetype, Ast *l, Ast *r) {
    Ast *a = (Ast *)malloc(sizeof(Ast));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

Ast *newvari(int nodetype, char nome[50]) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    strcpy(a->var, nome);
    return (Ast *)a;
}

Ast *newarray(int nodetype, char nome[50], int tam) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    strcpy(a->var, nome);
    a->size = tam;
    a->indice = NULL; 
    return (Ast *)a;
}

Ast *newtext(int nodetype, char txt[50]) {
    TXT *a = (TXT *)malloc(sizeof(TXT));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    strcpy(a->txt, txt);
    return (Ast *)a;
}

Ast *newnum(double d) {
    Numval *a = (Numval *)malloc(sizeof(Numval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = 'K';
    a->number = d;
    return (Ast *)a;
}

Ast *newflow(int nodetype, Ast *cond, Ast *tl, Ast *el) {
    Flow *a = (Flow *)malloc(sizeof(Flow));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    a->cond = cond;
    a->tl = tl;
    a->el = el;
    return (Ast *)a;
}

Ast *newcmp(int cmptype, Ast *l, Ast *r) {
    Ast *a = (Ast *)malloc(sizeof(Ast));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = '0' + cmptype;
    a->l = l;
    a->r = r;
    return a;
}

Ast *newasgn(char s[50], Ast *v) {
    Symasgn *a = (Symasgn *)malloc(sizeof(Symasgn));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = '=';
    strcpy(a->s, s);
    a->v = v;
    a->indice = NULL; 
    return (Ast *)a;
}

Ast *newasgn_a(char s[50], Ast *v, Ast *indice) {
    Symasgn *a = (Symasgn *)malloc(sizeof(Symasgn));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = '=';
    strcpy(a->s, s);
    a->v = v;
    a->indice = indice; // Salva a expressão do índice
    return (Ast *)a;
}

Ast *newValorVal(char s[]) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = 'N';
    strcpy(a->var, s);
    a->indice = NULL;
    return (Ast *)a;
}

Ast *newValorVal_a(char s[], Ast *indice) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = 'n';
    strcpy(a->var, s);
    a->indice = indice; // Salva a expressão do índice
    return (Ast *)a;
}

// Função de avaliação da AST
double eval(Ast *a) {
    double v = 0.0;
    VARI *aux;
    int index = 0; // Variável para guardar o índice calculado

    if (!a) { return 0.0; }
    
    switch (a->nodetype) {
        case 'K': v = ((Numval *)a)->number; break;
        case 'N':
            aux = srch(l1, ((Varval *)a)->var);
            if (!aux) printf("Warning: Variavel '%s' nao definida, usando valor 0.\n", ((Varval *)a)->var);
            v = aux ? aux->valor : 0.0;
            break;
        
        case 'n':
            aux = srch(l1, ((Varval *)a)->var);
            if (!aux) {
                printf("Warning: Vetor '%s' nao definido.\n", ((Varval *)a)->var);
                v = 0.0;
            } else {
                index = (int)eval(((Varval *)a)->indice);
                v = aux->vet[index];
            }
            break;
            
        case '+': v = eval(a->l) + eval(a->r); break;
        case '-': v = eval(a->l) - eval(a->r); break;
        case '*': v = eval(a->l) * eval(a->r); break;
        case '/': v = eval(a->l) / eval(a->r); break;
        case 'M': v = -eval(a->l); break;
        case '1': v = (eval(a->l) > eval(a->r)) ? 1 : 0; break;
        case '2': v = (eval(a->l) < eval(a->r)) ? 1 : 0; break;
        case '3': v = (eval(a->l) != eval(a->r)) ? 1 : 0; break;
        case '4': v = (eval(a->l) == eval(a->r)) ? 1 : 0; break;
        case '5': v = (eval(a->l) >= eval(a->r)) ? 1 : 0; break;
        case '6': v = (eval(a->l) <= eval(a->r)) ? 1 : 0; break;
        case '7': v = (eval(a->l) || eval(a->r))? 1 : 0; break;
        case '8': v = (eval(a->l) && eval(a->r))? 1 : 0; break;

        case '=':
            aux = srch(l1, ((Symasgn *)a)->s);
            if (!aux) {
                l1 = ins(l1, ((Symasgn *)a)->s, 1); 
                aux = srch(l1, ((Symasgn *)a)->s);
            }
            
            if (((Symasgn *)a)->v->nodetype == 's') { // Atribuição de string
                strcpy(aux->valors, ((TXT *)((Symasgn *)a)->v)->txt);
                aux->nodetype = 2;
                v = 0;
            } else if (((Symasgn *)a)->indice != NULL) { // Atribuição a vetor 
                v = eval(((Symasgn *)a)->v);
                if (aux->nodetype == 3) {
                    index = (int)eval(((Symasgn *)a)->indice); // Avalia o índice
                    aux->vet[index] = v;
                } else {
                    printf("Erro: Tentando usar a variavel '%s' como vetor.\n", aux->name);
                }
            } else { // Atribuição a variável simples
                v = eval(((Symasgn *)a)->v);
                aux->valor = v;
                aux->nodetype = 1;
            }
            return v;

        case 'I':
            if (eval(((Flow *)a)->cond) != 0) {
                if (((Flow *)a)->tl) v = eval(((Flow *)a)->tl);
            } else {
                if (((Flow *)a)->el) v = eval(((Flow *)a)->el);
            }
            break;
        case 'W':
            while (eval(((Flow *)a)->cond) != 0) {
                v = eval(((Flow *)a)->tl);
            }
            break;
        case 'L': eval(a->l); v = eval(a->r); break;
        case 'P': {
            Ast *child = a->l;
            if (child->nodetype == 's') {
                printf("%s\n", ((TXT*)child)->txt);
            } else if (child->nodetype == 'N') {
                VARI *var = srch(l1, ((Varval*)child)->var);
                if (var) {
                    if (var->nodetype == 2) {
                        printf("%s\n", var->valors);
                    } else {
                        printf("%.2f\n", eval(child));
                    }
                } else {
                    printf("%.2f\n", eval(child));
                }
            } else {
                printf("%.2f\n", eval(child));
            }
            v = 0.0;
            break;
        }
        case 'S': {
            aux = srch(l1, ((Varval *)a)->var);
            if (aux) {
                if (aux->nodetype == 2) {
                    printf("> ");
                    scanf("%49s", aux->valors);
                } else {
                    printf("> ");
                    scanf("%lf", &v);
                    aux->valor = v;
                    aux->nodetype = 1;
                }
            } else {
                printf("Warning: Variavel '%s' nao declarada. Nao foi possivel ler o valor.\n", ((Varval *)a)->var);
            }
            break;
        }
        case 'a': l1 = ins_a(l1, ((Varval *)a)->var, ((Varval *)a)->size); break;
        case 's': break;
        default: printf("internal error: bad node %c\n", a->nodetype);
    }
    return v;
}

int yylex();
void yyerror(char *s) { fprintf(stderr, "Erro sintatico: %s\n", s); }

%}

%union {
    float flo;
    int fn;
    int inter;
    char str[50];
    Ast *a;
}

%token <flo>   NUM
%token <str>   VARS
%token <str>   STRING_LITERAL
%token         FIM IF ELSE WHILE PRINT SCAN INT FLOAT STRING
%token <fn>    CMP
%token AND OR

%right '='
%left  OR
%left  AND
%left  CMP
%left  '+' '-'
%left  '*' '/'
%right NEG

%type <a> exp list stmt print_arg

%nonassoc IFX
%nonassoc ELSE

%%

program: 
    | program FIM
    | program stmt { if ($2) eval($2); }
    ;

stmt: VARS '=' exp { $$ = newasgn($1, $3); }
    | VARS '=' STRING_LITERAL { $$ = newasgn($1, newtext('s', $3)); }
    | VARS '[' exp ']' '=' exp { $$ = newasgn_a($1, $6, $3); }
    | INT VARS     { l1 = ins(l1, $2, 1); $$ = NULL; }
    | FLOAT VARS   { l1 = ins(l1, $2, 1); $$ = NULL; }
    | STRING VARS { l1 = ins(l1, $2, 2); $$ = NULL; }
    | INT VARS '[' NUM ']'   { $$ = newarray('a', $2, (int)$4); }
    | FLOAT VARS '[' NUM ']' { $$ = newarray('a', $2, (int)$4); }
    | PRINT '(' print_arg ')' { $$ = newast('P', $3, NULL); }
    | SCAN '(' VARS ')' { $$ = newvari('S', $3); }
    | IF '(' exp ')' '{' list '}' %prec IFX { $$ = newflow('I', $3, $6, NULL); }
    | IF '(' exp ')' '{' list '}' ELSE '{' list '}' { $$ = newflow('I', $3, $6, $10); }
    | WHILE '(' exp ')' '{' list '}' { $$ = newflow('W', $3, $6, NULL); }
    | ';' { $$ = NULL; }
    ;

print_arg: exp             { $$ = $1; }
         | STRING_LITERAL  { $$ = newtext('s', $1); }
         ;

list: { $$ = NULL; }
    | list stmt { $$ = newast('L', $1, $2); }
    ;

exp: NUM { $$ = newnum($1); }
    | VARS { $$ = newValorVal($1); }
    | VARS '[' exp ']' { $$ = newValorVal_a($1, $3); }
    | exp '+' exp { $$ = newast('+', $1, $3); }
    | exp '-' exp { $$ = newast('-', $1, $3); }
    | exp '*' exp { $$ = newast('*', $1, $3); }
    | exp '/' exp { $$ = newast('/', $1, $3); }
    | exp CMP exp { $$ = newcmp($2, $1, $3); }
    | exp AND exp { $$ = newcmp(8, $1, $3); }
    | exp OR exp  { $$ = newcmp(7, $1, $3); }
    | '(' exp ')' { $$ = $2; }
    | '-' exp %prec NEG { $$ = newast('M', $2, NULL); }
    ;

%%

#include "lex.yy.c"

int main() {
    yyin = fopen("entrada.txt", "r");
    yyparse();
    fclose(yyin);
    return 0;
}