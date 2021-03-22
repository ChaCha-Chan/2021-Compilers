#include "token.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_MAX_SIZE 512 

/* TODO: handle the tokens, and output the result */

//yy related
extern int yylex();  // yylex() is in lex.yy.c
extern int yyline;
extern int yycolumn;
extern int yyleng;
extern char* yytext;

//string table related
typedef struct string_item{
	char* str;
	int idx;
}string_item;

string_item* string_table;
int table_end, next_idx;

//functions
void print_string_table();					//print all strings/IDs in string table
int find_idx(char* text);					//find index in string table according to input stirng
void add_string(int token_type);			//add string to stirng table
void process_escape_sequence(char* str);	//process escape sequence in SCONST
void move_str(char* str, int start_idx);	//helper function

int main (int argc, char* argv[]) {

    //init string table
    string_table = (string_item*)malloc(TABLE_MAX_SIZE);
    table_end = 0;
    next_idx = 0;

    printf("Line    Column  Token               Index in String table\n");
	/* recognize each token type */
    int lexRtn = -1;			// return value of yylex	
	while (1) {
		lexRtn = yylex();
		yycolumn += yyleng;
		if (lexRtn >= 0){		//else ERROR
			printf("%-8d", yyline);
			printf("%-8d", yycolumn);
		}
		switch (lexRtn)
		{
			case ID_ERRORnum:
			{
				printf("Error: Malformed identifier '%s', at line %d column %d", yytext, yyline, yycolumn - yyleng);
				break;
			}
			case UNMATCHED_STRING_CONSTANTnum:
			{
				printf("Error: Unmatched string constant, at line %d column %d", yyline, yycolumn - yyleng);
				break;
			}
			case EOF_FOUND_IN_COMMENTnum:
			{
				printf("Error: EOF found in comment, at line %d column %d", yyline, yycolumn - yyleng);
				break;
			}
			case UNDEFINEDnum:
			{
				printf("Error: Undefined symbol '%s', at line %d column %d", yytext, yyline, yycolumn - yyleng);
				break;
			}
			case SCONSTnum:
			{
				printf("%-20s","SCONSTnum");
				add_string(SCONSTnum);
				break;
			}
			case IDnum:
			{
				printf("%-20s","IDnum");
				add_string(IDnum);
				break; 
			}
			case ANDnum:
			{
				printf("%-20s\n","ANDnum");
				break;
			}
			case ASSGNnum:
			{
				printf("%-20s","ASSGNnum");
				break; 
			}
			case DECLARATIONSnum:
			{
				printf("%-20s","DECLARATIONSnum");
				break; 
			}
			case DOTnum:
			{
				printf("%-20s","DOTnum");
				break; 
			}
			case ENDDECLARATIONSnum:
			{
				printf("%-20s","ENDDECLARATIONSnum");
				break; 
			}
			case EQUALnum:
			{
				printf("%-20s","EQUALnum");
				break; 
			}
			case GTnum:
			{
				printf("%-20s","GTnum");
				break; 
			}
			case INTnum:
			{
				printf("%-20s","INTnum");
				break; 
			}
			case LBRACnum:
			{
				printf("%-20s","LBRACnum");
				break; 
			}
			case LPARENnum:
			{
				printf("%-20s","LPARENnum");
				break; 
			}
			case METHODnum:
			{
				printf("%-20s","METHODnum");
				break; 
			}
			case NEnum:
			{
				printf("%-20s","NEnum");
				break; 
			}
			case ORnum:
			{
				printf("%-20s","ORnum");
				break; 
			}
			case PROGRAMnum:
			{
				printf("%-20s","PROGRAMnum");
				break; 
			}
			case RBRACnum:
			{
				printf("%-20s","RBRACnum");
				break; 
			}
			case RPARENnum:
			{
				printf("%-20s","RPARENnum");
				break; 
			}
			case SEMInum:
			{
				printf("%-20s","SEMinum");
				break; 
			}
			case VALnum:
			{
				printf("%-20s","VALnum");
				break; 
			}
			case WHILEnum:
			{
				printf("%-20s","WHILEnum");
				break; 
			}
			case CLASSnum:
			{
				printf("%-20s","CLASSnum");
				break; 
			}
			case COMMAnum:
			{
				printf("%-20s","COMMAnum");
				break; 
			}
			case DIVIDEnum:
			{
				printf("%-20s","DIVIDEnum");
				break; 
			}
			case ELSEnum:
			{
				printf("%-20s","ELSEnum");
				break; 
			}
			case EQnum:
			{
				printf("%-20s","EQnum");
				break; 
			}
			case GEnum:
			{
				printf("%-20s","GEnum");
				break; 
			}
			case ICONSTnum:
			{
				printf("%-20s","ICONSTnum");
				break; 
			}
			case IFnum:
			{
				printf("%-20s","IFnum");
				break; 
			}
			case LBRACEnum:
			{
				printf("%-20s","LBRACEnum");
				break; 
			}
			case LEnum:
			{
				printf("%-20s","LEnum");
				break; 
			}
			case LTnum:
			{
				printf("%-20s","LTnum");
				break; 
			}
			case MINUSnum:
			{
				printf("%-20s","MINUSnum");
				break; 
			}
			case NOTnum:
			{
				printf("%-20s","NOTnum");
				break; 
			}
			case PLUSnum:
			{
				printf("%-20s","PLUSnum");
				break; 
			}
			case RBRACEnum:
			{
				printf("%-20s","RBRACEnum");
				break; 
			}
			case RETURNnum:
			{
				printf("%-20s","RETURNnum");
				break; 
			}
			case TIMESnum:
			{
				printf("%-20s","TIMESnum");
				break; 
			}
			case VOIDnum:
			{
				printf("%-20s","VOIDnum");
				break; 
			}
			case EOFnum:
			{
				printf("%-20s","EOFnum");
				break; 
			}
			default:
				break;
		}
		printf("\n");
		if (lexRtn == EOFnum) break;
	}
	print_string_table();
	return 0;
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

void add_string(int token_type){
	if(next_idx >= TABLE_MAX_SIZE){
		printf("REACHED TABLE MAX SIZE\n");
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
			printf("%d", string_table[temp_idx].idx);
		}
		else{ //not found
			printf("%d", next_idx);
			string_table[table_end].str = new_str;
			string_table[table_end].idx = next_idx;
			table_end++;
			next_idx += strlen(new_str) + 1;
		}
	}
	return;
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
