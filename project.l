%{
    #include <stdio.h>
	#include "y.tab.h"

    int lineno = 1;
    char *token;
%}
%%
"echo "                 {
                            // printf("Token: ECHO, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return ECHO;
                        }
"if" 					{
                            // printf("Token: IF, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return IF;
                        }
"elif"					{
                            // printf("Token: ELIF, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return ELSEIF;
                        }       
"then"[ \t\n]*                 {
                            // printf("Token: THEN, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return THEN;
                        }
"else"[ \t\n]*				    {
                            // printf("Token: ELSE, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return ELSE;
                        }
"fi"[ \t\n]* 					{
                            // printf("Token: FI, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return FI;
                        }
"while"				    {
                            // printf("Token: WHILE, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return WHILE;
                        }
"do"[ \t\n]*  		    {
                            // printf("Token: DO, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return DO;
                        }
"done"[ \t\n]*          {
                            // printf("Token: DONE, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return DONE;
                        }
"$"					    {
                            // printf("Token: DOLLAR, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return DOLLAR;
                        }
"(" 					{
                            // printf("Token: LEFT_PARENTHESIS, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return LEFT_PARENTHESIS;
                        }
")" 					{
                            // printf("Token: RIGHT_PARENTHESIS, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return RIGHT_PARENTHESIS;
                        }
" [ " 					{
                            // printf("Token: LEFT_SQ_BRACKET, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return LEFT_SQ_BRACKET;
                        }
" ]" 					{
                            // printf("Token: RIGHT_SQ_BRACKET, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return RIGHT_SQ_BRACKET;
                        }
"+"	 				    {
                            // printf("Token: PLUS, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return PLUS;
                        }
"-"	 				    {
                            // printf("Token: MINUS, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return MINUS;
                        }
"*" 					{
                            // printf("Token: MULTIPLY, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return MULTIPLY;
                        }
"/" 					{
                            // printf("Token: DIVIDE, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return DIVIDE;
                        }
"="				        {
                            // printf("Token: ASSIGN, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return ASSIGN;
                        }
" -lt "				        {
                            // printf("Token: LT, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return LT;
                        }
" -le "				    {
                            // printf("Token: LE, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return LE;
                        }
" -gt "				        {
                            // printf("Token: GT, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return GT;
                        }
" -ge "				    {
                            // printf("Token: GE, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return GE;
                        }
" -eq "				    {
                            // printf("Token: EQ, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return EQ;
                        }
["]([^"\\\n]|\\(.|\n))*["]                {
                            // printf("Token: STRING, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            ++lineno;
                            return STRING;
                        }
[']([^"\\\n]|\\(.|\n))*[']                 {
                            // printf("Token: STRING, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            ++lineno;
                            return STRING;
                        }
[0-9]+					{
                            // printf("Token: NUM, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return NUM;
                        }
[a-zA-Z_][a-zA-Z0-9_]*	{
                            // printf("Token: VARNAME, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            return VARNAME;
                        }
"#"[ ]*"!/bin/sh"	    {
                            // printf("Token: DEFLINE, Lexeme: %s\n", yytext);
                            // printf("Defline at line: %d\n", yylineno);
                            yylval.value = strdup(yytext);
                            return DEFLINE;
                        }
"#"[^\n]*               {
                            // printf("Token: COMMENT, Lexeme: %s\n", yytext);
                            yylval.value = strdup(yytext);
                            // ++lineno;
                            return COMMENT;
                        }
[ \t\n]					{
                            // if (yytext[0] == '\n') printf("%s", yytext);
                            if (yytext[0] == '\n') ++lineno;
                        }
.						{token = strdup(yytext);}
%%

int getLineNumber() {
    return lineno;
}

char *getUnexpectedToken() {
    return token;
}

// int main() {
//     yylex();
//     return 0;
// }
