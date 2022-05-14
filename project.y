%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OUTFILE_PTR stdout
// #include <stack>
int yylex(void);
void yyerror(char *);
int getLineNumber();
char *getUnexpectedToken();

int tabs, ifs, elseifs, thens, elses, whiles, dos, parentheses, brackets;
char *previousToken;

void indent() {
  int i;
  for(i = 1; i <= tabs; ++i) fprintf(OUTFILE_PTR, "\t");
}
%}
%token <value> COMMENT DEFLINE ECHO
%token <value> VARNAME STRING NUM DOLLAR HASH
%token <value> IF THEN ELSEIF ELSE FI WHILE DO DONE
%token <value> LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_SQ_BRACKET RIGHT_SQ_BRACKET SINGLE_QUOTE DOUBLE_QUOTE
%token <value> GT GE LT LE EQ

%left PLUS MINUS  
%left MULTIPLY DIVIDE 
%right ASSIGN

%union {
  char* value;
}

%start start

%%

start: DEFLINE start | programs | ;

programs: programs {indent();} program {fprintf(OUTFILE_PTR ,"\n");}
        | {indent();} program {fprintf(OUTFILE_PTR ,"\n");}
        ;

program: instruction
       | if
       | loop
       | COMMENT {fprintf(OUTFILE_PTR, "%s", yylval.value);}
       ;

if: IF {fprintf(OUTFILE_PTR, "if"); ++ifs;} 
    LEFT_SQ_BRACKET {fprintf(OUTFILE_PTR, " ("); ++brackets;} 
    condition 
    RIGHT_SQ_BRACKET {--brackets; fprintf(OUTFILE_PTR, ")\n");} 
    THEN {indent(); fprintf(OUTFILE_PTR, "{\n"); ++tabs; ++thens;} 
    programs 
    elsifs 
    elses 
    FI {--tabs; --ifs; indent(); fprintf(OUTFILE_PTR, "}");};

elsifs: ELSEIF {--thens; fprintf(OUTFILE_PTR, "}\n"); --tabs; fprintf(OUTFILE_PTR, "elsif");} 
        LEFT_SQ_BRACKET {fprintf(OUTFILE_PTR, "("); ++brackets;} 
        condition 
        RIGHT_SQ_BRACKET {--brackets; fprintf(OUTFILE_PTR, ")\n");} 
        THEN {indent(); fprintf(OUTFILE_PTR, "{\n"); ++tabs; ++thens;} 
        programs 
        elsifs
      | ;

elses: ELSE {indent(); fprintf(OUTFILE_PTR, "}\n"); --tabs; indent(); fprintf(OUTFILE_PTR, "else\n{\n"); ++tabs;} 
       programs
     | ;

loop: WHILE {fprintf(OUTFILE_PTR, "while"); ++whiles;} 
      LEFT_SQ_BRACKET {fprintf(OUTFILE_PTR, "("); ++brackets;} 
      condition 
      RIGHT_SQ_BRACKET {--brackets; fprintf(OUTFILE_PTR, ")\n");} 
      DO {indent(); fprintf(OUTFILE_PTR, "{\n"); ++tabs; ++dos;} 
      programs 
      DONE {--tabs; --whiles; --dos; indent(); fprintf(OUTFILE_PTR, "}");};

condition: name conditional_operator name;

conditional_operator: LT {fprintf(OUTFILE_PTR, "<");} 
                    | LE {fprintf(OUTFILE_PTR, "<=");} 
                    | GT {fprintf(OUTFILE_PTR, ">");} 
                    | GE {fprintf(OUTFILE_PTR, ">=");} 
                    | EQ {fprintf(OUTFILE_PTR, "==");};

instruction: variable ASSIGN {fprintf(OUTFILE_PTR, "=");} name {fprintf(OUTFILE_PTR, ";");}
           | echo;

name: NUM {fprintf(OUTFILE_PTR, "%s", yylval.value);}
    | STRING {fprintf(OUTFILE_PTR, "%s", yylval.value);}
    | DOLLAR variable 
    | DOLLAR LEFT_PARENTHESIS {++parentheses;} LEFT_PARENTHESIS {++parentheses;} expression RIGHT_PARENTHESIS {--parentheses;} RIGHT_PARENTHESIS {--parentheses;};

expression: expression PLUS {fprintf(OUTFILE_PTR, "+");} expression_one
          | expression MINUS {fprintf(OUTFILE_PTR, "-");} expression_one
          | expression_one
          ;

expression_one: expression_one MULTIPLY {fprintf(OUTFILE_PTR, "*");} expression_two
              | expression_one DIVIDE {fprintf(OUTFILE_PTR, "/");} expression_two
              | expression_two
              ;

expression_two: name
              | LEFT_PARENTHESIS {fprintf(OUTFILE_PTR, "("); ++parentheses;} expression RIGHT_PARENTHESIS {--parentheses; fprintf(OUTFILE_PTR, ")");}
              ;

echo: ECHO {fprintf(OUTFILE_PTR, "print ");} name {fprintf(OUTFILE_PTR, " . \"\\n\";");};

variable: VARNAME {fprintf(OUTFILE_PTR, "$%s", yylval.value);};
%%
void yyerror(char *s) {
    // printf("Error: %d\n", yychar);
    // printf("Returned: %s\nPrevious token: %s\nCurrent token: %s\n", s, yylval.value, previousToken);
    // printf("%d %d %d %d %d %d %d %d\n", ifs, elseifs, elses, thens, whiles, dos, parentheses, brackets);
    // printf("Unexpected token: %s\n", getUnexpectedToken());

    char* token = getUnexpectedToken();
    int linenumber = getLineNumber();
    if (ifs == thens && ifs == 0 && parentheses > 0 && token == NULL) printf("\nMissing ) on line %d\n", linenumber);
    else if (ifs == thens && ifs == 0 && parentheses == 0 && token == NULL) printf("\nMissing ( on line %d\n", linenumber);
    else if (ifs - thens == 1 && token == NULL) printf("\nMissing then in line %d\n", linenumber);
    else if (ifs - thens == 1 && !strcmp(token, "[")) printf("\nline %d: missing space around the [ symbol\n", linenumber);
    else if (ifs - thens == 1 && !strcmp(token, "]") && brackets >= 1) printf("\nline %d: missing space before ] symbol\n", linenumber);
    else if (ifs == thens && ifs > 0 && token == NULL) printf("\nMissing fi in line %d\n", linenumber);
}

int yywrap(void) {
   return 1;
}

int main(int argc, char *argv[]) {
  tabs = ifs = elseifs = elses = thens = whiles = dos = parentheses = brackets = 0;
  if (argc == 2) {
    extern FILE *yyin;
    yyin = fopen(argv[1], "r");
    yyparse();
  } else if (argc == 1) {
    yyparse();
  } else {
    printf("Wrong parameters!\n");
  }
	return 0;
}
