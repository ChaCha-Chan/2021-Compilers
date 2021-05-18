#include "proj2.h"
#include "proj3.h"

void traverse(tree root);
void traverseProgram(tree startNode);
void traverseClassDecl(tree startNode);
void traverseClassBody(tree startNode);
void traverseDecls(tree startNode);
void traverseFieldDecl(tree startNode);
void traverseNewVar(tree startNode);
int traverseType(tree startNode);
void traverseVariableInitializer(tree startNode);
void traverseArrayInitializer(tree startNode);
void traverseArrayCreationExpression(tree startNode);
void traverseMethodDecl(tree startNode);
int traverseFormalParameterList(tree startNode);
void traverseBlock(tree startNode);
void traverseStatementList(tree startNode);
void traverseStatement(tree startNode);
void traverseAssignmentStatement(tree startNode);
void traverseMethodCallStatement(tree startNode);
void traverseReturnStatement(tree startNode);
void traverseIfStatement(tree startNode);
void traverseWhileStatement(tree startNode);
void traverseExpression(tree startNode);
void traverseSimpleExpression(tree startNode);
void traverseTerm(tree startNode);
void traverseFactor(tree startNode);
void traverseUnsignedConstant(tree startNode);
int traverseVariable(tree startNode);
int traverseTypeForField(tree startNode);

int mainFlag = 0;

void traverse(tree root)
{
   root->RightC = NullExp();
   traverseProgram(root);
}
void traverseProgram(tree startNode) //ProgramOp
{
   tree curNode = startNode->LeftC;
   if (curNode->NodeKind == DUMMYNode)
   {
      return;
   }
   traverseProgram(curNode);
   traverseClassDecl(curNode->RightC);
}
void traverseClassDecl(tree startNode) //ClassDefOp
{
   int nStrInd, nSymInd;
   nStrInd = startNode->RightC->IntVal; //loc_str(getname(startNode->RightC->IntVal));
   nSymInd = InsertEntry(nStrInd);
   if (nSymInd != 0)
   {
      startNode->RightC->NodeKind = STNode;
      startNode->RightC->IntVal = nSymInd;
      startNode->RightC->NodeOpType = nStrInd;
   }
   SetAttr(nSymInd, KIND_ATTR, CLASS);
   OpenBlock();
   traverseClassBody(startNode->LeftC);
   CloseBlock();
}
void traverseClassBody(tree startNode) //BodyOp
{
   //No Decls
   if (startNode->NodeKind == DUMMYNode)
   {
      return;
   }
   //Find Decls
   if (startNode->RightC->NodeOpType == DeclOp)
   {
      traverseDecls(startNode);
      return;
   }
   //Process MethodDecl Recursively
   traverseClassBody(startNode->LeftC);
   if(startNode->RightC->NodeKind != DUMMYNode){
       traverseMethodDecl(startNode->RightC);
   }
}
void traverseDecls(tree startNode)
{
   if (startNode->NodeKind == DUMMYNode)
   {
      return;
   }
   traverseDecls(startNode->LeftC);
   traverseFieldDecl(startNode->RightC);
}
void traverseFieldDecl(tree startNode)
{
   if (startNode->NodeKind == DUMMYNode)
   {
      return;
   }
   traverseFieldDecl(startNode->LeftC);
   traverseNewVar(startNode->RightC);
}
void traverseNewVar(tree startNode)//CommaOp
{
   //type check: String constants cannot be used to initialize int variables.
   if((traverseTypeForField(startNode->RightC->LeftC) == -1) && (startNode->RightC->RightC->NodeKind == STRINGNode)){
      error_msg(STRING_ASSIGN, 0, startNode->LeftC->IntVal, 0);
   }


   tree VarDeclId = startNode->LeftC;
   int nStrInd, nSymInd;
   nStrInd = VarDeclId->IntVal; //loc_str(getname(startNode->RightC->IntVal));
   nSymInd = InsertEntry(nStrInd);
   if (nSymInd != 0)
   {
      VarDeclId->NodeKind = STNode;
      VarDeclId->IntVal = nSymInd;
      VarDeclId->NodeOpType = nStrInd;
   }
   //array or var
   int dim = traverseType(startNode->RightC->LeftC);
   if (dim > 0)
   {
      SetAttr(nSymInd, KIND_ATTR, ARR);
      SetAttr(nSymInd, DIMEN_ATTR, dim);
   }
   else
   {
      SetAttr(nSymInd, KIND_ATTR, VAR);
   }
   SetAttr(nSymInd, TYPE_ATTR, (uintptr_t)startNode->RightC->LeftC);
   //has VariableInitializera
   if(startNode->RightC->RightC->NodeOpType != DUMMYNode){
      traverseVariableInitializer(startNode->RightC->RightC);
   }
}
int traverseType(tree startNode) //TypeIdOp
{
   int dim = 0;
   while (startNode->NodeKind != DUMMYNode)
   {
      if (startNode->NodeOpType == IndexOp)
      {
         dim++;
         startNode = startNode->RightC;
      }
      else if (startNode->NodeOpType == FieldOp)
      {
         dim = 0;
         startNode = startNode->LeftC;
      }
      else if (startNode->NodeOpType == TypeIdOp)
      {
         if (startNode->LeftC->NodeKind == IDNode)
         {
            int STIndex = LookUp(startNode->LeftC->IntVal);
            if (STIndex)
            {
               startNode->LeftC->NodeKind = STNode;
               startNode->LeftC->NodeOpType = startNode->LeftC->IntVal;
               startNode->LeftC->IntVal = STIndex;
            }
         }
         startNode = startNode->RightC;
      }
   }
   return dim;
}

int traverseTypeForField(tree startNode) //TypeIdOp
{
   int fieldId;
   while (startNode->NodeKind != DUMMYNode)
   {
      if (startNode->NodeOpType == IndexOp)
      {
         startNode = startNode->RightC;
      }
      else if (startNode->NodeOpType == FieldOp)
      {
         startNode = startNode->LeftC;
      }
      else if (startNode->NodeOpType == TypeIdOp)
      {
         if(startNode->LeftC->NodeKind != INTEGERTNode){
            fieldId = startNode->LeftC->IntVal;
         } 
         else{
            fieldId = -1;
         }
         startNode = startNode->RightC;
      }
   }
   return fieldId;
}

void traverseVariableInitializer(tree startNode)
{
   return;
   if (startNode->NodeOpType == ArrayTypeOp)
   {
      if (startNode->LeftC->NodeOpType == CommaOp)
      {
         traverseArrayInitializer(startNode);
      }
      else
      {
         traverseArrayCreationExpression(startNode);
      }
   }
   else
   {
      traverseExpression(startNode);
   }
}
void traverseArrayInitializer(tree startNode)
{
   tree curNode = startNode->LeftC;
   if (curNode->NodeKind == DUMMYNode)
   {
      return;
   }
   traverseArrayInitializer(curNode->LeftC);
   traverseVariableInitializer(curNode->RightC);
}
void traverseArrayCreationExpression(tree startNode)
{
   tree curNode = startNode->LeftC;
   if (curNode->NodeKind == DUMMYNode)
   {
      return;
   }
   traverseArrayCreationExpression(curNode->LeftC);
   traverseExpression(curNode->RightC);
}
void traverseMethodDecl(tree startNode)
{
   int nStrInd, nSymInd;
   nStrInd = startNode->LeftC->LeftC->IntVal; 
   if(!strcmp(getname(nStrInd),"main")){
      mainFlag++;
      if(mainFlag>1){
         error_msg(MULTI_MAIN, 0, 0, 0);
         return;
      }
   }
   nSymInd = InsertEntry(nStrInd);
   if (nSymInd != 0)
   {
      startNode->LeftC->LeftC->NodeKind = STNode;
      startNode->LeftC->LeftC->IntVal = nSymInd;
      startNode->LeftC->LeftC->NodeOpType = nStrInd;
   }
   //void
   if (startNode->LeftC->RightC->RightC->NodeKind == DUMMYNode)
   {
      SetAttr(nSymInd, KIND_ATTR, PROCE);
   }
   else
   {
      SetAttr(nSymInd, KIND_ATTR, FUNC);
      SetAttr(nSymInd, TYPE_ATTR, (uintptr_t)startNode->LeftC->RightC->RightC);
   }
   OpenBlock();
   int argNum = traverseFormalParameterList(startNode->LeftC->RightC);
   SetAttr(nSymInd, ARGNUM_ATTR, argNum);
   SetAttr(nSymInd, TREE_ATTR, (uintptr_t)startNode);
   traverseBlock(startNode->RightC);
   CloseBlock();
}

//return arg num
int traverseFormalParameterList(tree startNode)
{
   tree curNode = startNode->LeftC;
   int argNum = 0;
   int nStrInd, nSymInd;
   while (curNode->NodeKind != DUMMYNode)
   {
      if (curNode->NodeOpType == RArgTypeOp)
      {
         nStrInd = curNode->LeftC->LeftC->IntVal; //loc_str(getname(startNode->RightC->IntVal));
         nSymInd = InsertEntry(nStrInd);
         if (nSymInd != 0)
         {
            curNode->LeftC->LeftC->NodeKind = STNode;
            curNode->LeftC->LeftC->IntVal = nSymInd;
            curNode->LeftC->LeftC->NodeOpType = nStrInd;
         }
         SetAttr(nSymInd, KIND_ATTR, REF_ARG);
         SetAttr(nSymInd, TYPE_ATTR, (uintptr_t)curNode->LeftC->RightC);
      }
      else if (curNode->NodeOpType == VArgTypeOp)
      {
         nStrInd = curNode->LeftC->LeftC->IntVal; //loc_str(getname(startNode->RightC->IntVal));
         nSymInd = InsertEntry(nStrInd);
         if (nSymInd != 0)
         {
            curNode->LeftC->LeftC->NodeKind = STNode;
            curNode->LeftC->LeftC->IntVal = nSymInd;
            curNode->LeftC->LeftC->NodeOpType = nStrInd;
         }
         SetAttr(nSymInd, KIND_ATTR, VALUE_ARG);
         SetAttr(nSymInd, TYPE_ATTR, (uintptr_t)curNode->LeftC->RightC);
      }
      argNum++;
      curNode = curNode->RightC;
   }
   return argNum;
}
void traverseBlock(tree startNode)
{
   if (startNode->LeftC->NodeKind != DUMMYNode)
   {
      traverseDecls(startNode->LeftC);
   }
   traverseStatementList(startNode->RightC);
}
void traverseStatementList(tree startNode)
{
   if (startNode->NodeKind == DUMMYNode)
   {
      return;
   }
   traverseStatementList(startNode->LeftC);
   traverseStatement(startNode->RightC);
}
void traverseStatement(tree startNode)
{
   switch (startNode->NodeOpType)
   {
   case AssignOp:
      traverseAssignmentStatement(startNode);
      break;
   case RoutineCallOp:
      traverseMethodCallStatement(startNode);
      break;
   case ReturnOp:
      traverseReturnStatement(startNode);
      break;
   case IfElseOp:
      traverseIfStatement(startNode);
      break;
   case LoopOp:
      traverseWhileStatement(startNode);
      break;
   default:
      return;
   }
}
void traverseAssignmentStatement(tree startNode){
   traverseVariable(startNode->LeftC->RightC);
   traverseExpression(startNode->RightC);
}
void traverseMethodCallStatement(tree startNode){
   int STArgNum = traverseVariable(startNode->LeftC);
   tree curNode = startNode->RightC;
   int argNum = 0;
   while(curNode->NodeKind != DUMMYNode){
      traverseExpression(curNode);
      curNode = curNode->RightC;
      argNum++;
   }
   //check argNum, STArgNum==-1: field miss.
   if(STArgNum != -1 && argNum != STArgNum){
      error_msg(ARGUMENTS_NUM2, 0, startNode->LeftC->LeftC->NodeOpType, 0);
   }
}
void traverseReturnStatement(tree startNode){
   traverseExpression(startNode->LeftC);
}
void traverseIfStatement(tree startNode){
   if(startNode->NodeKind == DUMMYNode){
      return;
   }
   traverseIfStatement(startNode->LeftC);
   //if,else if
   if(startNode->RightC->NodeOpType == CommaOp){
      traverseExpression(startNode->RightC->LeftC);
      traverseStatementList(startNode->RightC->RightC);
   }
   //else
   else{
      traverseStatementList(startNode->RightC);
   }
}
void traverseWhileStatement(tree startNode){
   traverseExpression(startNode->LeftC);
   traverseStatementList(startNode->RightC);
}
void traverseExpression(tree startNode){
   traverseSimpleExpression(startNode);
}
void traverseSimpleExpression(tree startNode){
   if(startNode->NodeKind == DUMMYNode || startNode->NodeKind == STRINGNode || startNode->NodeKind == NUMNode){
      return;
   }
   if(startNode->NodeOpType == VarOp){
      traverseVariable(startNode);
      return;
   }
   else if(startNode->NodeOpType == RoutineCallOp){
      traverseMethodCallStatement(startNode);
      return;
   }
   else{
      traverseSimpleExpression(startNode->LeftC);
      traverseSimpleExpression(startNode->RightC);
   }
}

//return argnum if exist
int traverseVariable(tree startNode)//VarOp
{
   int STIndex = LookUp(startNode->LeftC->IntVal);
   if (STIndex)
   {
      startNode->LeftC->NodeKind = STNode;
      startNode->LeftC->NodeOpType = startNode->LeftC->IntVal;
      startNode->LeftC->IntVal = STIndex;
   }
   else{
      return -2;
   }
   //SelectOp
   tree curNode = startNode->RightC;
   int varAttr = GetAttr(STIndex, KIND_ATTR);
   int typeIndex = STIndex;
   while (curNode->NodeKind != DUMMYNode)
   {
      if(curNode->LeftC->NodeOpType == IndexOp){
         tree idxNode = curNode->LeftC;
         while(idxNode->NodeKind != DUMMYNode){
            traverseExpression(idxNode->LeftC);
            idxNode = idxNode->RightC;
         }
      }
      else if(curNode->LeftC->NodeOpType == FieldOp){
         if(varAttr == CLASS){
            typeIndex = LookUpField(typeIndex, curNode->LeftC->LeftC->IntVal);
            if (typeIndex)
            {
               curNode->LeftC->LeftC->NodeKind = STNode;
               curNode->LeftC->LeftC->NodeOpType = curNode->LeftC->LeftC->IntVal;
               curNode->LeftC->LeftC->IntVal = typeIndex;
            }
            else
            {  
               error_msg(FIELD_MIS, CONTINUE, curNode->LeftC->LeftC->IntVal, 0);
               break;
            }
            varAttr = GetAttr(typeIndex, KIND_ATTR);
         }
         else if(varAttr == VAR){
            tree typeTree = (tree)GetAttr(typeIndex, TYPE_ATTR);
            typeIndex = LookUpField(traverseTypeForField(typeTree), curNode->LeftC->LeftC->IntVal);
            if (typeIndex)
            {
               curNode->LeftC->LeftC->NodeKind = STNode;
               curNode->LeftC->LeftC->NodeOpType = curNode->LeftC->LeftC->IntVal;
               curNode->LeftC->LeftC->IntVal = typeIndex;
            }
            else
            {  
               error_msg(FIELD_MIS, CONTINUE, curNode->LeftC->LeftC->IntVal, 0);
               break;
            }
            varAttr = GetAttr(typeIndex, KIND_ATTR);
         }
      }
      curNode = curNode->RightC;
   }
   if(IsAttr(typeIndex, ARGNUM_ATTR)){
      return GetAttr(typeIndex, ARGNUM_ATTR);
   }
   else{
      return -1;
   }
}




void do_semantic(tree parseTree)
{
   STInit();            // Initialize the symbol table
   traverse(parseTree); // Traverse tree
   STPrint();           // Print the symbol table
}
