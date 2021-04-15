%{

#include "proj2.h"
#include "y.tab.h"
#define TABLE_MAX_SIZE 256
#define TABLE_1D_MAX_SIZE 1024

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* TODO: declare variables here */
int yyline = 1;
int yycolumn = 1;
void find_newline();


//string table related
typedef struct string_item{
	char* str;
	int idx;
}string_item;


extern string_item* string_table;
extern char* strg_tbl;
extern int table_end, next_idx;

//functions
void print_string_table();					//print all strings/IDs in string table
int find_idx(char* text);					//find index in string table according to input stirng
int add_string(int token_type);			//add string to stirng table
void process_escape_sequence(char* str);	//process escape sequence in SCONST
void move_str(char* str, int start_idx);	//helper function
%}

/* TODO: define regular expressions */
letter      [a-zA-Z]
digit       [0-9]

ID          {letter}({letter}|{digit})*
ICONST  	([1-9]{digit}*)|{digit}
SCONST  	\'([^'\n]|(\\\'))*\'
COMMENT		[\/][*]([^*\/]|([*]+[^*\/]+)|[\/])*[*]+[\/]
SPACE		" "
TAB    	  	\t
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

<<EOF>>                     { yycolumn = 0; yyterminate(); }

{COMMENT} 				    { find_newline(); }
{SPACE}						{ yycolumn++;  }
{NEWLINE}					{ yyline++; yycolumn = 1;}
{TAB}						{ /*do nothing*/}
{ID}                        { yylval.intg = add_string(IDnum); return (IDnum); }
{ICONST}                    { yylval.intg = atoi(yytext); return (ICONSTnum); }
{SCONST}                    { yylval.intg = add_string(SCONSTnum); return (SCONSTnum); }

{EOF_FOUND_IN_COMMENT}		{ find_newline(); }

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


void print_string_table(){
	printf("\nString Table : ");
	for(int i = 0; i < table_end; i++){
		printf("%s ", string_table[i].str);
	}
	printf("\n");
}

int find_idx(char* text){
	for (int i = 0; i < table_end; i++){
		if(!strcmp(string_table[i].str, yytext)){
			return i;
		}
	}
	return -1;
}

int add_string(int token_type){
	if(next_idx >= TABLE_MAX_SIZE){
		printf("REACHED TABLE MAX SIZE\n");
		return -1;
	}
	else{
		int yytext_len = strlen(yytext);
		char *new_str;
		if (token_type == SCONSTnum){ //delete ''
			new_str = (char*)malloc(yytext_len - 1);
			strncpy(new_str, yytext + 1, yytext_len - 2);
			new_str[yytext_len - 2] = '\0';
			process_escape_sequence(new_str);
		}
		else{
			new_str = (char*)malloc(yytext_len + 1);
			strcpy(new_str, yytext);
		}
		int temp_idx = find_idx(new_str);
		if(temp_idx != -1){ //found
			return string_table[temp_idx].idx;
		}
		else{ //not found
			int cur_idx =  next_idx;
			//set table struct
			string_table[table_end].str = new_str;
			string_table[table_end].idx = next_idx;
			table_end++;
			//set table array
			memcpy(strg_tbl + next_idx, new_str, strlen(new_str) * sizeof(char));
			next_idx += strlen(new_str) + 1;
			return cur_idx;
		}
	}
}

void process_escape_sequence(char* str){
	for(int i = 0; i < strlen(str); i++){
		if(( i < strlen(str) - 1 ) && ( str[i] == '\\')){
			switch(str[i + 1]){
				case 'n':{
					str[i] = '\n';
					move_str(str, i + 1);
					break;
				}
				case 't':{
					str[i] = '\t';
					move_str(str, i + 1);
					break;
				}
				case '\'':{
					str[i] = '\'';
					move_str(str, i + 1);
					break;
				}
				case '\\':{
					str[i] = '\\';
					move_str(str, i + 1);
					break;
				}
			}
		}
	}
	return;
}

void move_str(char* str, int start_idx){
	for(int i = start_idx; i <= strlen(str); i++){
		str[i] = str[i + 1];
	}
	return;
}
