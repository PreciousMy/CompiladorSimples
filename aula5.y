%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>


// nodetype variáveis
// 1 - números (int/float), 2 - string, 3 - vetor
typedef struct vars {
    int nodetype;
    char name[50];     // nome da variavel
    double valor;      // se for numerico
    char valors[50];   // se for string
    double *vet;       // se for um array
    struct vars *prox;
} VARI;

VARI *l1;


VARI *ins(VARI *l, char n[], int type) {
    VARI *new = (VARI *)malloc(sizeof(VARI));
    strcpy(new->name, n);
    new->prox = l;
    new->nodetype = type; 
    
    if (type == 2) { // se for string
        strcpy(new->valors, "");
    } else { // se numerico
        new->valor = 0;
    }
    return new;
}

VARI *ins_a(VARI *l, char n[], int tamanho) {
    VARI *new = (VARI *)malloc(sizeof(VARI));
    strcpy(new->name, n);
    // aloca memoria para o vetor de doubles com o tamanho especificado
    new->vet = (double *)malloc(tamanho * sizeof(double));
    new->prox = l;
    new->nodetype = 3;
    return new;
}


VARI *srch(VARI *l, char n[]) {
    VARI *aux = l;
    while (aux != NULL) {
        if (strcmp(n, aux->name) == 0)
            return aux; // encontrou
        aux = aux->prox;
    }
    return aux; // nao encontrou
}

typedef struct ast {
    int nodetype;     
    struct ast *l;    
    struct ast *r;     
} Ast;

// no para um numero constante
typedef struct numval {
    int nodetype;      // 'K' constante 
    double number;     // o valor do numero
} Numval;

// no para uma referência a uma variável ou vetor
typedef struct varval {
    int nodetype;      // 'N' para variavel normal, 'n' para acesso a elemento de vetor
    char var[50];      // nome da variavel/vetor
    Ast *indice;       // AST para a expressao do indice
    int size; 
} Varval;

// no para um literal de string
typedef struct texto {
    int nodetype;      // 's' para string
    char txt[50];  
} TXT;

// IF, WHILE.
typedef struct flow {
    int nodetype;      // 'I' para IF, 'W' para WHILE
    Ast *cond;         // AST da condiçao
    Ast *tl;           // AST do bloco "then"
    Ast *el;           // AST do bloco "else"
} Flow;

// atribuiçao 
typedef struct symasgn {
    int nodetype;      // '=' para atribuiçao
    char s[50];        // nome da variavel que recebe o valor
    Ast *v;            // AST da expressao a ser atribuida
    Ast *indice;       // AST do indice se for atribuiçao a um vetor
} Symasgn;


// operadores binários como +, -, *, /
Ast *newast(int nodetype, Ast *l, Ast *r) {
    Ast *a = (Ast *)malloc(sizeof(Ast));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

// variavel
Ast *newvari(int nodetype, char nome[50]) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    strcpy(a->var, nome);
    return (Ast *)a;
}

// declaraçao de um array
Ast *newarray(int nodetype, char nome[50], int tam) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    strcpy(a->var, nome);
    a->size = tam;
    a->indice = NULL; 
    return (Ast *)a;
}

// literal de texto
Ast *newtext(int nodetype, char txt[50]) {
    TXT *a = (TXT *)malloc(sizeof(TXT));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    strcpy(a->txt, txt);
    return (Ast *)a;
}

// numero constante
Ast *newnum(double d) {
    Numval *a = (Numval *)malloc(sizeof(Numval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = 'K';
    a->number = d;
    return (Ast *)a;
}

// IF/WHILE
Ast *newflow(int nodetype, Ast *cond, Ast *tl, Ast *el) {
    Flow *a = (Flow *)malloc(sizeof(Flow));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = nodetype;
    a->cond = cond;
    a->tl = tl;
    a->el = el;
    return (Ast *)a;
}

// para comparaçao. (1 para >, 2 para <, etc...)
Ast *newcmp(int cmptype, Ast *l, Ast *r) {
    Ast *a = (Ast *)malloc(sizeof(Ast));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = '0' + cmptype; // converte o tipo numerico em um caractere
    a->l = l;
    a->r = r;
    return a;
}

// atribuiçao para uma variavel simples ou string
Ast *newasgn(char s[50], Ast *v) {
    Symasgn *a = (Symasgn *)malloc(sizeof(Symasgn));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = '=';
    strcpy(a->s, s);
    a->v = v;
    a->indice = NULL; // sem índice, é uma variavel simples
    return (Ast *)a;
}

// atribuiçao para um elemento de vetor
Ast *newasgn_a(char s[50], Ast *v, Ast *indice) {
    Symasgn *a = (Symasgn *)malloc(sizeof(Symasgn));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = '=';
    strcpy(a->s, s);
    a->v = v;
    a->indice = indice; // salva a AST da expressao do indice
    return (Ast *)a;
}

// obter o valor de uma variavel simples
Ast *newValorVal(char s[]) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out of space"); exit(0); }
    a->nodetype = 'N'; // 'N' para referencia a variavel normal
    strcpy(a->var, s);
    a->indice = NULL;
    return (Ast *)a;
}

// obter o valor de um elemento de um vetor
Ast *newValorVal_a(char s[], Ast *indice) {
    Varval *a = (Varval *)malloc(sizeof(Varval));
    if (!a) { printf("out ofspace"); exit(0); }
    a->nodetype = 'n'; // 'n' para acesso a elemento de vetor
    strcpy(a->var, s);
    a->indice = indice; // Salva a AST da expressao do indice
    return (Ast *)a;
}


// INTERPRETADOR

double eval(Ast *a) {
    double v = 0.0;
    VARI *aux;
    int index = 0;

    if (!a) { return 0.0; } // se o no for nulo, não faz nada
    
    switch (a->nodetype) {
        case 'K': v = ((Numval *)a)->number; break; // retorna o valor de uma constante
        
        case 'N': // pega o valor de uma variável simples
            aux = srch(l1, ((Varval *)a)->var);
            if (!aux) printf("Warning: Variavel '%s' nao definida, usando valor 0.\n", ((Varval *)a)->var);
            v = aux ? aux->valor : 0.0;
            break;

        case 'n': // pega o valor de um elemento de vetor
            aux = srch(l1, ((Varval *)a)->var);
            if (!aux) {
                printf("Warning: Vetor '%s' nao definido.\n", ((Varval *)a)->var);
                v = 0.0;
            } else {
                index = (int)eval(((Varval *)a)->indice); // avalia a expressao do índice primeiro
                v = aux->vet[index]; // pega o valor no indice calculado
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

        case '=': // Atribuição
            aux = srch(l1, ((Symasgn *)a)->s);
            if (!aux) { 
                l1 = ins(l1, ((Symasgn *)a)->s, 1); 
                aux = srch(l1, ((Symasgn *)a)->s);
            }
            
            if (((Symasgn *)a)->v->nodetype == 's') { // string literal
                strcpy(aux->valors, ((TXT *)((Symasgn *)a)->v)->txt);
                aux->nodetype = 2; 
                v = 0; 
            } else if (((Symasgn *)a)->indice != NULL) { // elemento de vetor
                v = eval(((Symasgn *)a)->v); 
                if (aux->nodetype == 3) {
                    index = (int)eval(((Symasgn *)a)->indice); // avalia o indice
                    aux->vet[index] = v; // armazena o valor
                } else {
                    printf("Erro: Tentando usar a variavel '%s' como vetor.\n", aux->name);
                }
            } else { // variavel numerica simples
                v = eval(((Symasgn *)a)->v);
                aux->valor = v;
                aux->nodetype = 1; 
            }
            return v;

        case 'I': // IF
            if (eval(((Flow *)a)->cond) != 0) { // avalia a condiçao
                if (((Flow *)a)->tl) v = eval(((Flow *)a)->tl); // se for verdade, executa o bloco then
            } else {
                if (((Flow *)a)->el) v = eval(((Flow *)a)->el); // senao, executa o bloco else
            }
            break;

        case 'W': // WHILE
            while (eval(((Flow *)a)->cond) != 0) { 
                v = eval(((Flow *)a)->tl); 
            }
            break;

        case 'L': eval(a->l); v = eval(a->r); break; // lista de instruçoes

        case 'P': { // instruçao PRINT
            Ast *child = a->l;
            if (child->nodetype == 's') { // imprime um literal de string
                printf("%s\n", ((TXT*)child)->txt);
            } else if (child->nodetype == 'N') { // imprime uma variavel
                VARI *var = srch(l1, ((Varval*)child)->var);
                if (var) {
                    if (var->nodetype == 2) { // se a variavel for string
                        printf("%s\n", var->valors);
                    } else { // se for numerica
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

        case 'S': { // instrução SCAN 
            aux = srch(l1, ((Varval *)a)->var);
            if (aux) {
                if (aux->nodetype == 2) { // Le uma string
                    printf("> ");
                    scanf("%49s", aux->valors);
                } else { // le um numero
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

        case 'a': l1 = ins_a(l1, ((Varval *)a)->var, ((Varval *)a)->size); break; // declaraçao de vetor
        
        case 's': break; // no de texto
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
    char str[50];   
    Ast *a;         
}


%token <flo>  NUM
%token <str>  VARS
%token <str>  STRING_LITERAL
%token        FIM IF ELSE WHILE PRINT SCAN INT FLOAT STRING
%token <fn>   CMP
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
    | VARS '[' exp ']' '=' exp { $$ = newasgn_a($1, $6, $3); } // atribuiçao a vetor: v[i] = expr
    | INT VARS   { l1 = ins(l1, $2, 1); $$ = NULL; }
    | FLOAT VARS { l1 = ins(l1, $2, 1); $$ = NULL; } 
    | STRING VARS { l1 = ins(l1, $2, 2); $$ = NULL; }
    | INT VARS '[' NUM ']'   { $$ = newarray('a', $2, (int)$4); } 
    | FLOAT VARS '[' NUM ']' { $$ = newarray('a', $2, (int)$4); } 
    | PRINT '(' print_arg ')' { $$ = newast('P', $3, NULL); } 
    | SCAN '(' VARS ')' { $$ = newvari('S', $3); } 
    | IF '(' exp ')' '{' list '}' %prec IFX { $$ = newflow('I', $3, $6, NULL); } 
    | IF '(' exp ')' '{' list '}' ELSE '{' list '}' { $$ = newflow('I', $3, $6, $10); }
    | WHILE '(' exp ')' '{' list '}' { $$ = newflow('W', $3, $6, NULL); } 
    | ';' { $$ = NULL; } // ponto e virgula vazio
    ;

// uma expressao ou um literal de string
print_arg: exp              { $$ = $1; }
         | STRING_LITERAL   { $$ = newtext('s', $1); }
         ;


list: { $$ = NULL; } 
    | list stmt { $$ = newast('L', $1, $2); } 
    ;


exp: NUM { $$ = newnum($1); } // uma expressao pode ser um numero
    | VARS { $$ = newValorVal($1); } // ou uma variavel
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