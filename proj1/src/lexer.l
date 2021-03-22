%{
#include "token.h"
#include <stdio.h>
#include <string.h>
/* TODO: declare variables here */
int yyline = 1;
int yycolumn = 1;

void find_newline();

%}

/* TODO: define regular expressions */
letter      [a-zA-Z]
digit       [0-9]

ID          {letter}({letter}|{digit})*
ICONST  	([1-9]{digit}*)|{digit}
SCONST  	\'([^'\n]|(\\\'))*\'
COMMENT		[\/][*]([^*\/]|([*]+[^*\/]+)|[\/])*[*]+[\/]
SPACE		" "
NEWLINE		\n	

ID_ERROR    				{digit}({letter}|{digit})+
UNMATCHED_STRING_CONSTANT   \'[^'\n]*
EOF_FOUND_IN_COMMENT		[/][*]([^*]|[*]+[^*/])*[*]*
UNDEFINED  	.

/* TODO: define translation rules: pattern and action */
%%

"int"                       { return (INTnum); }
"&&"                        { return (ANDnum); }
":="                        { return (ASSGNnum); }
"declarations"              { return (DECLARATIONSnum); }
"."                         { return (DOTnum); }
"enddeclarations"           { return (ENDDECLARATIONSnum); }
"="                         { return (EQUALnum); }
">"                         { return (GTnum); }
"["                         { return (LBRACnum); }
"("                         { return (LPARENnum); }
"method"                    { return (METHODnum); }
"!="                        { return (NEnum); }
"||"                        { return (ORnum); }
"program"                   { return (PROGRAMnum); }
"]"                         { return (RBRACnum); }
")"                         { return (RPARENnum); }
";"                         { return (SEMInum); }
"val"                       { return (VALnum); }
"while"                     { return (WHILEnum); }
"class"                     { return (CLASSnum); }
","                         { return (COMMAnum); }
"/"                         { return (DIVIDEnum); }
"else"                      { return (ELSEnum); }
"=="                        { return (EQnum); }
">="                        { return (GEnum); }
"if"                        { return (IFnum); }
"{"                         { return (LBRACEnum); }
"<="                        { return (LEnum); }
"<"                         { return (LTnum); }
"-"                         { return (MINUSnum); }
"!"                         { return (NOTnum); }
"+"                         { return (PLUSnum); }
"}"                         { return (RBRACEnum); }
"return"                    { return (RETURNnum); }
"*"                         { return (TIMESnum); }
"void"                      { return (VOIDnum); }

<<EOF>>                     { yycolumn = 0; return (EOFnum); }

{COMMENT} 				    { find_newline(); }
{SPACE}						{ yycolumn++;  }
{NEWLINE}					{ yyline++; yycolumn = 1;}

{ID}                        { return (IDnum); }
{ICONST}                    { return (ICONSTnum); }
{SCONST}                    { return (SCONSTnum); }

{ID_ERROR} 					{ return (ID_ERRORnum); }
{UNMATCHED_STRING_CONSTANT}	{ return (UNMATCHED_STRING_CONSTANTnum); }
{UNDEFINED}					{ return (UNDEFINEDnum);}
{EOF_FOUND_IN_COMMENT}		{ find_newline(); return (EOF_FOUND_IN_COMMENTnum);}
%%

/* TODO: define the auxiliary functions you may use */

int yywrap() {
    return 1;
}
void find_newline(){
	for(int i = 0; i < strlen(yytext); i++){
		if(yytext[i] == '\n'){
			yyline++;
			yycolumn = 1;
		}
		else{
			yycolumn ++;
		}
	}
}