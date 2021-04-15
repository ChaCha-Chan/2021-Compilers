%{ /* definition */
#include "proj2.h"
#include <stdio.h>
tree type_global;
#define TABLE_MAX_SIZE 256
#define TABLE_1D_MAX_SIZE 1024
%}

%token <intg> ANDnum ASSGNnum DECLARATIONSnum DOTnum ENDDECLARATIONSnum EQUALnum GTnum IDnum INTnum LBRACnum LPARENnum METHODnum NEnum ORnum PROGRAMnum RBRACnum RPARENnum SEMInum VALnum WHILEnum CLASSnum COMMAnum DIVIDEnum ELSEnum EQnum GEnum ICONSTnum IFnum LBRACEnum LEnum LTnum MINUSnum NOTnum PLUSnum RBRACEnum RETURNnum SCONSTnum TIMESnum VOIDnum EOFnum



%type <tptr> Program ClassDecl ClassBody Decls FieldDecl VariableDeclId VariableInitializer ArrayInitializer ArrayCreationExpression MethodDecl FormalParameterList Block Type StatementList Statement AssignmentStatement MethodCallStatement ReturnStatement IfStatement WhileStatement Expression SimpleExpression Term Factor UnsignedConstant Variable __ClassDecl ___MethodDecl ___FieldDecl Vars Var __VariableInitializer __ArrayCreationExpression _FormalParameterList __FormalParameterList FormalParameter __VID __RID OneType __BRACS __Statement __Expression _IfStatement _Expression _SimpleExpression _Term _Variable ___Expression VOID

%type <intg> ID ICONST SCONST

%% 

/*Program*/
Program : PROGRAMnum ID SEMInum __ClassDecl
        { $$ = MakeTree(ProgramOp, $4, MakeLeaf(IDNode, $2)); printtree($$,0);}
        ;
__ClassDecl : __ClassDecl ClassDecl
        { $$ = MakeTree(ClassOp, $1, $2); }
        | ClassDecl
        { $$ = MakeTree(ClassOp, NullExp(), $1); }
        ;
/*ClassDecl*/
ClassDecl : CLASSnum ID ClassBody
        { $$ = MakeTree(ClassDefOp, $3, MakeLeaf(IDNode, $2)); }
        ;
/*ClassBody*/
ClassBody: LBRACEnum RBRACEnum
        { $$ = NullExp(); }
        | LBRACEnum ___MethodDecl RBRACEnum
        { $$ = $2; }
        | LBRACEnum Decls RBRACEnum
        { $$ = MakeTree(BodyOp, $2, NullExp()); }
        | LBRACEnum Decls ___MethodDecl RBRACEnum
        { $$ = MkLeftC($2, $3); }
        ;
___MethodDecl : ___MethodDecl MethodDecl
        { $$ = MkLeftC($1, MakeTree(BodyOp, NullExp(), $2)); }
        | MethodDecl
        { $$ = MakeTree(BodyOp, NullExp(), $1);}
        ;
/*Decls*/
Decls   : DECLARATIONSnum ENDDECLARATIONSnum
        { $$ = NullExp();}
        | DECLARATIONSnum ___FieldDecl ENDDECLARATIONSnum
        { $$ = $2; }
        ;
___FieldDecl : ___FieldDecl FieldDecl
        { $$ = MakeTree(BodyOp, $1, $2);}
        | FieldDecl
        { $$ = MakeTree(BodyOp, NullExp(), $1); }
        ;
/*FieldDecl*/
FieldDecl : Type Vars SEMInum
        { $$ = $2; }
        ;
Vars    : Vars COMMAnum Var
        { $$ = MakeTree(DeclOp, $1, $3); }
        | Var
        { $$ = MakeTree(DeclOp, NullExp(), $1);}
        ;
Var     : VariableDeclId EQUALnum VariableInitializer
        { $$ = MakeTree(CommaOp, $1, MakeTree(CommaOp, type_global, $3)); }
        | VariableDeclId
        { $$ = MakeTree(CommaOp, $1, MakeTree(CommaOp, type_global, NullExp()));}
        ;
/*VariableDeclId*/
VariableDeclId : ID ___BRACS 
        { $$ = MakeLeaf(IDNode, $1);}
        ;
___BRACS : ___BRACS LBRACnum RBRACnum
        | 
        ;
/*VariableInitializer*/
VariableInitializer : Expression
        { $$ = $1; }
        | ArrayInitializer
        { $$ = $1; }
        | ArrayCreationExpression
        { $$ = $1; }
        ;
/*ArrayInitializer*/
ArrayInitializer : LBRACEnum __VariableInitializer RBRACEnum
        { $$ = MakeTree(ArrayTypeOp, $2, type_global);}
        ;
__VariableInitializer : __VariableInitializer COMMAnum VariableInitializer 
        { $$ = MakeTree(CommaOp, $1, $3); }
        | VariableInitializer
        { $$ = MakeTree(CommaOp, NullExp(), $1); }
        ;
/*ArrayCreationExpression*/
ArrayCreationExpression : INTnum __ArrayCreationExpression
        { $$ = MakeTree(ArrayTypeOp, $2, MakeLeaf(INTEGERTNode, 0)); }
        ;
__ArrayCreationExpression : __ArrayCreationExpression LBRACnum Expression RBRACnum
        { $$ = MakeTree(BoundOp, $1, $3); }
        | 
        { $$ = NullExp(); }
        ;
/*MethodDecl*/
MethodDecl : METHODnum Type ID LPARENnum FormalParameterList RPARENnum Block
        { $$ = MakeTree(MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $3), $5), $7); }
        | METHODnum VOID ID LPARENnum FormalParameterList RPARENnum Block
        { $$ = MakeTree(MethodOp, MakeTree(HeadOp, MakeLeaf(IDNode, $3), $5), $7); }
        ;

/*FormalParameterList*/
FormalParameterList : __FormalParameterList
        { $$ = MakeTree(SpecOp, $1, type_global); }
        | 
        { $$ = MakeTree(SpecOp, NullExp(), type_global);}
        ;
__FormalParameterList : __FormalParameterList SEMInum FormalParameter
        { $$ = MkRightC($3, $1); }
        | FormalParameter
        { $$ = $1; }
        ;
FormalParameter : VALnum INTnum __VID
        { $$ = $3; }
        | INTnum __RID
        { $$ = $2; }
        ;
__VID   : ID COMMAnum __VID
        { $$ = MakeTree(VArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), NullExp()); MkRightC($3,$$);}
        | ID
        { $$ = MakeTree(VArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), NullExp()); }
        ;
__RID   : ID COMMAnum __RID
        { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), NullExp()); MkRightC($3,$$);}
        | ID
        { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), NullExp()); }
        ;
/*Block*/
Block   : Decls StatementList
        { $$ = MakeTree(BodyOp, $1, $2); }
        | StatementList
        { $$ = MakeTree(BodyOp, NullExp(), $1); }
        ;
/*Type*/
Type    : OneType
        { $$ = $1; type_global= $$;}
        | Type DOTnum OneType
        { $$ = MkRightC(MakeTree(FieldOp, $3, NullExp()), $1); }
        ;
OneType : ID __BRACS
        { $$ = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2); }
        | INTnum __BRACS
        { $$ = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, 0), $2);}
        ;
__BRACS : __BRACS LBRACnum RBRACnum
        { $$ = MakeTree(IndexOp, NullExp(), $1);}
        | 
        { $$ = NullExp();}
        ;
/*StatementList*/
StatementList : LBRACEnum __Statement RBRACEnum
        { $$ = $2; }
        | LBRACEnum RBRACEnum
        { $$ = MakeTree(StmtOp, NullExp(), NullExp()); }
        ;
__Statement : __Statement Statement SEMInum
        { $$ = MakeTree(StmtOp, $1, $2); }
        | Statement SEMInum
        { $$ = MakeTree(StmtOp, NullExp(), $1); }
        ;
/*Statement*/
Statement : AssignmentStatement
        { $$ = $1; }
        | MethodCallStatement
        { $$ = $1; }
        | ReturnStatement
        { $$ = $1; }
        | IfStatement
        { $$ = $1; }
        | WhileStatement
        { $$ = $1; }
        |
        { $$ = NullExp();}
        ;
/*AssignmentStatement*/
AssignmentStatement : Variable ASSGNnum Expression
        { $$ = MakeTree(AssignOp, MakeTree(AssignOp, NullExp(), $1), $3);}
        ;
MethodCallStatement : Variable LPARENnum __Expression RPARENnum
        { $$ = MakeTree(RoutineCallOp, $1, $3); }
        | Variable LPARENnum RPARENnum
        { $$ = MakeTree(RoutineCallOp, $1, NullExp()); }
        ;
__Expression : Expression COMMAnum __Expression
        { $$ = MakeTree(CommaOp, $1, $3); }
        | Expression
        { $$ = MakeTree(CommaOp, $1, NullExp());}
        ;
/*ReturnStatement*/
ReturnStatement : RETURNnum Expression
        { $$ = MakeTree(ReturnOp, $2, NullExp()); }
        | RETURNnum
        { $$ = MakeTree(ReturnOp, NullExp(), NullExp());}
        ; 
/*IfStatement FIXME: not sure*/
IfStatement : IFnum Expression StatementList  /*if*/
        { $$ = MakeTree(IfElseOp, NullExp(), MakeTree(CommaOp, $2, $3)); }
        | IFnum Expression StatementList ELSEnum StatementList  /*if else*/
        { $$ = MakeTree(IfElseOp, MakeTree(IfElseOp, NullExp(), MakeTree(CommaOp, $2, $3)), $5); }
        | IFnum Expression StatementList _IfStatement   /*if (else if)+ */
        { $$ = MkLeftC(MakeTree(IfElseOp, NullExp(), MakeTree(CommaOp, $2, $3)), $4);}  
        | IFnum Expression StatementList _IfStatement ELSEnum StatementList /*if (else if)+ else*/
        { $$ = MkLeftC(MakeTree(IfElseOp, NullExp(), MakeTree(CommaOp, $2, $3)), $4); $$ = MkLeftC($$, MakeTree(IfElseOp, NullExp(), $6));}
        ;
_IfStatement : _IfStatement ELSEnum IFnum Expression StatementList
        { $$ = MkLeftC(MakeTree(IfElseOp, NullExp(), MakeTree(CommaOp, $4, $5)), $1); }
        | ELSEnum IFnum Expression StatementList
        { $$ = MakeTree(IfElseOp, NullExp(), MakeTree(CommaOp, $3, $4));}
        ;
/*WhileStatement*/
WhileStatement : WHILEnum Expression StatementList
        { $$ = MakeTree(LoopOp, $2, $3); }
        ;
/*Expression*//*FIXME: not sure, no defination*/
Expression : SimpleExpression _Expression SimpleExpression
        { $$ = $2; MkLeftC($1, $$); MkRightC($3, $$); }
        | SimpleExpression
        { $$ = $1; } 
        ;
_Expression : LTnum
        { $$ = MakeTree(LTOp, NullExp(), NullExp()); }
        | LEnum
        { $$ = MakeTree(LEOp, NullExp(), NullExp()); }
        | EQnum
        { $$ = MakeTree(EQOp, NullExp(), NullExp()); }
        | NEnum
        { $$ = MakeTree(NEOp, NullExp(), NullExp()); }
        | GEnum
        { $$ = MakeTree(GEOp, NullExp(), NullExp()); }
        | GTnum
        { $$ = MakeTree(GTOp, NullExp(), NullExp()); }
        ;
/*SimpleExpression FIXME: no defination*/
SimpleExpression : Term
        { $$ = $1; }
        | PLUSnum Term
        { $$ = MakeTree(AddOp, NullExp(), $2); }
        | MINUSnum Term
        { $$ = MakeTree(SubOp, NullExp(), $2); }
        | Term _SimpleExpression
        { $$ = MkLeftC($1,$2); }
        | PLUSnum Term _SimpleExpression
        { $$ = MkLeftC(MakeTree(AddOp, NullExp(), $2), $3); }
        | MINUSnum Term _SimpleExpression
        { $$ = MkLeftC(MakeTree(SubOp, NullExp(), $2), $3); }
        ;
_SimpleExpression : _SimpleExpression PLUSnum Term
        { $$ = MakeTree(AddOp, $1, $3); }
        | _SimpleExpression MINUSnum Term
        { $$ = MakeTree(SubOp, $1, $3); }
        | _SimpleExpression ORnum Term
        { $$ = MakeTree(OrOp, $1, $3); }
        | PLUSnum Term
        { $$ = MakeTree(AddOp, NullExp(), $2); }
        | MINUSnum Term
        { $$ = MakeTree(SubOp, NullExp(), $2); }
        | ORnum Term
        { $$ = MakeTree(OrOp, NullExp(), $2); }
        ;
/*Term*/
Term    : Factor
        { $$ = $1; }
        | Factor _Term
        { $$ = MkLeftC($1, $2); }
        ;
_Term   : _Term TIMESnum Factor
        { $$ = MakeTree(MultOp, $1, $3); }
        | _Term DIVIDEnum Factor
        { $$ = MakeTree(DivOp, $1, $3); }
        | _Term ANDnum Factor
        { $$ = MakeTree(AndOp, $1, $3); }
        | TIMESnum Factor
        { $$ = MakeTree(MultOp, NullExp(), $2); }
        | DIVIDEnum Factor
        { $$ = MakeTree(DivOp, NullExp(), $2); }
        | ANDnum Factor
        { $$ = MakeTree(AndOp, NullExp(), $2); }
        ;
/*Factor*/
Factor  : UnsignedConstant
        { $$ = $1; }
        | Variable
        { $$ = $1; }
        | MethodCallStatement
        { $$ = $1; }
        | LPARENnum Expression RPARENnum
        { $$ = $2; }
        | NOTnum Factor
        { $$ = MakeTree(UnaryNegOp, $2, NullExp()); }
        ;
/*UnsignedConstant*/
UnsignedConstant : ICONST
        { $$ = MakeLeaf(NUMNode, $1); }
        | SCONST
        { $$ = MakeLeaf(STRINGNode, $1); }
        ;
/*Variable*/
Variable : ID _Variable
        {  $$ = MakeTree(VarOp, MakeLeaf(IDNode, $1), $2);}
        ;
_Variable : LBRACnum ___Expression RBRACnum _Variable
        { $$ = MakeTree(SelectOp, $2, $4);}
        | DOTnum ID _Variable
        { $$ = MakeTree(SelectOp,MakeTree(FieldOp, MakeLeaf(IDNode, $2), NullExp()), $3); }
        | 
        { $$ = NullExp();}
        ;
___Expression : ___Expression COMMAnum Expression
        { $$ = MakeTree(IndexOp, $3, $1); }
        | Expression
        { $$ = MakeTree(IndexOp, $1, NullExp());}
        ;

ID  : IDnum 
    { $$ = yylval.intg; }
    ;

ICONST : ICONSTnum 
    { $$ = yylval.intg; }
    ;
SCONST : SCONSTnum 
    { $$ = yylval.intg; }
    ;

VOID : VOIDnum{
    type_global = NullExp();
}
%%
typedef struct string_item{
    char* str;
    int idx;
}string_item;

int yycolumn, yyline;
FILE *treelst;

string_item* string_table;
char* strg_tbl;
int table_end = 0, next_idx = 0;

main() {

    string_table = (string_item*)malloc(TABLE_MAX_SIZE);
    strg_tbl = (char*)malloc(TABLE_1D_MAX_SIZE);
    memset(strg_tbl, '\0', TABLE_1D_MAX_SIZE * sizeof(char));

    treelst = stdout;
    yyparse();
}

yyerror(char *str) { printf("yyerror: %s at line %d\n", "", yyline); }
