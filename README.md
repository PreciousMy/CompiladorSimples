# Compilador Simples usando Flex e Bison
Um compilador simples para uma linguagem simples para um tempo simples.

## 👇 Este Compilador Contem

- Suporte a tipos: `int`, `float` e `string`.
- Declaração e manipulação de vetores numéricos.
- Aritmética (`+`, `-`, `*`, `/`) e comparações (`>`, `<`, `==`,`<=`,`>=`).
- Condicionais `IF`/`ELSE` e laços `WHILE`.
- Funções de entrada/saída `LER()` e `PRINT()`.
- Suporte a comentários de linha com `//`.

## ✍ Sintaxe

**Declaração** 
```txt
int idade;
float notas[10];
string nome;
```
**Atribuição**
```txt
idade = 25;
notas[0] = 9.5;
nome = "nome";
```
**Laço While**
```txt
WHILE (i < 10) { ... }
```
**Condicional If** 
```txt
IF (media >= 7.0) { ... } ELSE { ... }
```
**Leitura e Escrita** 
```txt
LER(idade);
PRINT("O resultado e:");
PRINT(media);
```

## 💾 Exemplo de Uso
```txt

// Declaração 
float notas[3];
float media;
string situacao;
int i;

// Atribuição de vetores
notas[0] = 10.0;
notas[1] = 8.5;
notas[2] = 5.0;

// Laço WHILE 
i = 0;
media = 0;
WHILE (i < 3) {
    media = media + notas[i];
    i = i + 1;
}

// IF/ELSE.
media = media / 3.0;
IF (media >= 7.0) {
    situacao = "Aprovado";
} ELSE {
    situacao = "Reprovado";
}

// Impressão 
PRINT("Media final:");
PRINT(media);
PRINT("Situacao:");
PRINT(situacao);

FIM
```

## 👇 Este Compilador não contem no momento

- Concatenação de string
- Atribuição de string para um vetor
- Operações condicionais && (and) e || (or)
