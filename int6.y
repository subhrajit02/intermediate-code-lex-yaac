%{
#include <stdio.h>
#include <stdarg.h> 
#include <stdlib.h> 
#include <math.h>
#include <unistd.h>
#include <string.h>

int yylex();
int yyerror(char *s);
typedef struct Variable_node
{
	char var_name[100];
	struct Variable_node *next;
	int float_used;
	float value ; 
}Variable;

typedef struct Nodetag_node
{
	char start_char;
	Variable *var_list;
}Nodetag;


Nodetag *root[39];


typedef struct Node_node
{
	char name[100];
	struct Node_node *next;
}Node;

typedef struct Stack_node
{
	Node *top;
}Stack;

Stack *stack;
Node * loop[100];
Node * increment[100];
Stack *loop_stack[100];
Node *stmt[100];
int tmp_value;
int for_count;
int if_count;
Stack *stack2;




%}






%union
{
	char name[100];
    float f;
}



%token FOR IF ELSE SEMICOLON PRINT QUIT
%token <name> VARIABLE
%token <f> NUMBER
%type <name> exp data data1 data2



%right '='
%left '*' '/'
%left '+' '-'








%{

void push_stmt(char *str)
{
	Node *n=malloc(sizeof(Node));
	n->next=NULL;
	strcpy(n->name,str);
	Node * tmp=stmt[for_count];
	if(tmp==NULL)
	{
		stmt[for_count]=n;
	}
	else
	{
		while(tmp->next!=NULL)
		{
			tmp=tmp->next;
		}
		tmp->next=n;
	}
}



void push_loop(char *str)
{

	
	Node *n=malloc(sizeof(Node));
	strcpy(n->name,str);
	n->next=loop_stack[for_count]->top;
	loop_stack[for_count]->top=n;
}


void push_node(char *str)
{
	Node *n=malloc(sizeof(Node));
	n->next=NULL;
	strcpy(n->name,str);
	Node * tmp=loop[for_count];
	if(tmp==NULL)
	{
		loop[for_count]=n;
	}
	else
	{
		while(tmp->next!=NULL)
		{
			tmp=tmp->next;
		}
		tmp->next=n;
	}
}


void push_increment(char *str)
{
	Node *n=malloc(sizeof(Node));
	n->next=NULL;
	strcpy(n->name,str);
	Node * tmp=increment[for_count];
	if(tmp==NULL)
	{
		increment[for_count]=n;
	}
	else
	{
		while(tmp->next!=NULL)
		{
			tmp=tmp->next;
		}
		tmp->next=n;
	}
}



char* pop_loop(char *str1)
{
	
	char str[100];
	strcpy(str,loop_stack[for_count]->top->name);
	Node *ptr=loop_stack[for_count]->top;
	loop_stack[for_count]->top=loop_stack[for_count]->top->next;
	free(ptr);
	strcpy(str1,str);
}




void push(char *str)
{

	
	Node *n=malloc(sizeof(Node));
	strcpy(n->name,str);
	n->next=stack->top;
	stack->top=n;
}



char* pop(char *str1)
{
	
	char str[100];
	strcpy(str,stack->top->name);
	Node *ptr=stack->top;
	stack->top=stack->top->next;
	free(ptr);
	strcpy(str1,str);
}


void push_stack2(char *str)
{

	
	Node *n=malloc(sizeof(Node));
	strcpy(n->name,str);
	n->next=stack2->top;
	stack2->top=n;
}



char* pop_stack2(char *str1)
{
	
	char str[100];
	strcpy(str,stack2->top->name);
	Node *ptr=stack2->top;
	stack2->top=stack2->top->next;
	free(ptr);
	strcpy(str1,str);
}




char* temp_var(char *str)
{

	
	char a[100];
	a[0]='_';
	int i = tmp_value;
	int count=0;
	
	while(i>0)
	{
		i=i/10;
		count++;
	}
	i=tmp_value;
	if(count==0)
	{
		a[1]='0';
		a[2]='\0';
	}
	else
	{
		int t=count;
		while(i>0)
		{
			a[count]= (i%10) + '0'; 
			i=i/10; 
			count--;
		}
		a[t+1]='\0';
	}
	tmp_value++;
	strcpy(str,a);
}



void print_label()
{
	
	printf("\nL%d:\n",for_count);
}
void print_label2()
{
	
	printf("\nN%d:\n",for_count);
}	


void print_trace()
{
	Node * n= loop[for_count];
	while(n!=NULL)
	{
		printf("%s ",n->name);
		Node *ptr=n;
		n=n->next;
		free(ptr);
	}
	loop[for_count] =NULL;
}

void print_increment()
{
	Node * n= increment[for_count];
	while(n!=NULL)
	{
		printf("%s\n",n->name);
		Node *ptr=n;
		n=n->next;
		free(ptr);
	}
	increment[for_count]=NULL;
}

void print_stmt()
{
	Node * n= stmt[for_count];
	stmt[for_count]=NULL;
	while(n!=NULL)
	{
		printf("%s\n",n->name);
		Node *ptr=n;
		n=n->next;
		free(ptr);
	}
	stmt[for_count] =NULL;
}

%}


%%
S: | S1 S{} 
	| QUIT { printf("return 0;\n}");exit(0);}
;
S1 : FOR'('C1 { print_label(); }SEMICOLON  C2 { printf("if("); print_trace();printf(")\n{\n} \nelse"); printf("\n{\ngoto N%d;\n}\n",for_count); } SEMICOLON C3 ')' SEMICOLON  '{' SEMICOLON   { for_count++; printf("\n");  }  stmts { print_stmt(); }   '}'  { for_count--; print_increment(); printf("goto L%d;\n",for_count); print_label2(); }  


 | IF { print_stmt(); } '('  {  printf("if(");  } C2  {  print_trace(); printf(")\n{\ngoto I%d;\n}\n",if_count);  printf("else \n {\n goto J%d; \n } \n",if_count);  } ')' SEMICOLON '{' SEMICOLON  { printf("I%d: \n",if_count); if_count++;} stmts{ print_stmt(); }'}' SEMICOLON { if_count--; printf("\ngoto K%d;\n",if_count); printf("\nJ%d: \n",if_count); }  el {  printf("\nK%d:\n",if_count);  }

| VARIABLE ':' NUMBER SEMICOLON{printf("float %s;\n",$1);printf("%s=%f;\n",$1,$3);} 

| VARIABLE ':' SEMICOLON{printf("float %s;\n",$1);} 
;


el : {}

| 	ELSE  SEMICOLON '{' SEMICOLON  stmts { print_stmt(); } '}'  

;

stmt:VARIABLE '=' data2 {
							char ch[100];
							strcpy(ch,$1);
							strcat (ch,"=");
							char a[100];
							pop_stack2(a);
							strcat(ch,a);
							strcat(ch,";");
							push_stmt(ch);
						}
	|VARIABLE '+''+'  	{  
							char ch[100];
							char b[100];
							strcpy(ch,$1);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"+1;");
							push_stmt(ch);
						}
	|VARIABLE '-''-' {  
							char ch[100];
							char b[100];
							strcpy(ch,$1);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"-1;");
							push_stmt(ch);
						}
	|'-''-'VARIABLE	 	{  
							char ch[100];
							char b[100];
							strcat(ch,$3);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"-1;");
							push_stmt(ch);
						}
	|'+''+'VARIABLE 	{  
							char ch[100];
							char b[100];
							strcpy(ch,$3);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"+1;");
							push_stmt(ch);
						}
						
	| PRINT VARIABLE {printf("printf(\"%%f\\n\",%s);\n",$2);}
						
	| S{}
;

stmts:stmt SEMICOLON  stmts{}

| {}
;


data2 : NUMBER { 	
					
					float f =$1;
					char c[100];
					sprintf(c,"%g",f);
					push_stack2(c);
				 }
		| VARIABLE {	
						
						
						push_stack2($1);	
									 
					} 
					
		|data2 '+' data2 	{
								char ch[100];
								temp_var(ch);
								char x[100];
								strcpy(x,"float ");
								strcat(x,ch);
								strcat(x,";");
								char a[100];
								char b[100];
								pop_stack2(a);
								pop_stack2(b);
								push_stack2(ch);
								strcat(ch,"=");
								strcat(ch,b);
								strcat(ch,"+");
								strcat(ch,a);
								strcat(ch,";");
								push_stmt(x);
								push_stmt(ch);
							}
		|data2 '-' data2 	{
								char ch[100];
								temp_var(ch);
								char x[100];
								strcpy(x,"float ");
								strcat(x,ch);
								strcat(x,";");
								char a[100];
								char b[100];
								pop_stack2(a);
								pop_stack2(b);
								push_stack2(ch);
								strcat(ch,"=");
								strcat(ch,b);
								strcat(ch,"-");
								strcat(ch,a);
								strcat(ch,";");
								push_stmt(x);
								push_stmt(ch);
								
							}
		|data2 '*' data2 	{
								char ch[100];
								temp_var(ch);
								char x[100];
								strcpy(x,"float ");
								strcat(x,ch);
								strcat(x,";");
								char a[100];
								char b[100];
								pop_stack2(a);
								pop_stack2(b);
								push_stack2(ch);
								strcat(ch,"=");
								strcat(ch,b);
								strcat(ch,"*");
								strcat(ch,a);
								strcat(ch,";");
								push_stmt(x);
								push_stmt(ch);
							}
		|data2 '/' data2 	{
								char ch[100];
								temp_var(ch);
								char x[100];
								strcpy(x,"float ");
								strcat(x,ch);
								strcat(x,";");
								char a[100];
								char b[100];
								pop_stack2(a);
								pop_stack2(b);
								push_stack2(ch);
								strcat(ch,"=");
								strcat(ch,b);
								strcat(ch,"/");
								strcat(ch,a);
								strcat(ch,";");
								push_stmt(x);
								push_stmt(ch);
							}
		| '(' data2 ')'  { }
		
;
C3 : {}
	| C3 ',' inc {}
	| inc {}
;



inc : VARIABLE '=' data1{
							char ch[100];
							strcpy(ch,$1);
							strcat (ch,"=");
							strcat(ch,$3);
							strcat(ch,";");
							push_increment(ch);
						}
	| VARIABLE '+''+'  	{  
							char ch[100];
							char b[100];
							strcpy(ch,$1);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"+1;");
							push_increment(ch);
						}
	|VARIABLE '-''-'	{  
							char ch[100];
							char b[100];
							strcpy(ch,$1);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"-1;");
							push_increment(ch);
						}
	|'-''-'VARIABLE		{  
							char ch[100];
							char b[100];
							strcat(ch,$3);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"-1;");
							push_increment(ch);
						}
	|'+''+'VARIABLE		{  
							char ch[100];
							char b[100];
							strcpy(ch,$3);
							strcpy(b,ch);
							strcat(ch,"=");
							strcat(ch,b);
							strcat(ch,"+1;");
							push_increment(ch);
						}
;


data1:	NUMBER { 	
					
					float f =$1;
					char c[100];
					sprintf(c,"%g",f);
					strcpy($$,c);
					
					
				 }
		| VARIABLE {	
						
						char a[100];
						strcpy(a,$1);
						strcpy($$,a);	
									 
					} 
		| data1 '+' data1 {  	
								
								char a[100];
								temp_var(a);
								char x[100];
								strcpy(x,"float ");
								strcat(x,a);
								strcat(x,";");
								strcpy($$,a);
								char ch[100];
								strcpy(ch,$$);
								strcat(ch,"=");
								strcat(ch,$1);
								strcat(ch,"+");
								strcat(ch,$3);
								strcat(ch,";");
								
								push_increment(x);
								push_increment(ch);
							}
		| data1 '-' data1 {  	
								char a[100];
								temp_var(a);
								char x[100];
								strcpy(x,"float ");
								strcat(x,a);
								strcat(x,";");
								strcpy($$,a);
								char ch[100];
								strcpy(ch,$$);
								strcat(ch,"=");
								strcat(ch,$1);
								strcat(ch,"-");
								strcat(ch,$3);
								strcat(ch,";");
								
								push_increment(x);
								push_increment(ch);
							}
		| data1 '*' data1 {  	
								char a[100];
								temp_var(a);
								char x[100];
								strcpy(x,"float ");
								strcat(x,a);
								strcat(x,";");
								strcpy($$,a);
								char ch[100];
								strcpy(ch,$$);
								strcat(ch,"=");
								strcat(ch,$1);
								strcat(ch,"*");
								strcat(ch,$3);
								strcat(ch,";");
								
								push_increment(x);
								push_increment(ch);
							}
		| data1 '/' data1 {  	
								char a[100];
								temp_var(a);
								char x[100];
								strcpy(x,"float ");
								strcat(x,a);
								strcat(x,";");
								strcpy($$,a);
								char ch[100];
								strcpy(ch,$$);
								strcat(ch,"=");
								strcat(ch,$1);
								strcat(ch,"/");
								strcat(ch,$3);
								strcat(ch,";");
								
								push_increment(x);
								push_increment(ch);
							}
		|'(' data1 ')'  { strcpy($$,$2);}

;


C2 : {}
	| cond{}
	| C2 '&''&' {char a[]="&&";push_node(a);}  cond
	| C2 '|''|' {char a[]="||";push_node(a);}  cond
;

cond :  data '<' data 	{
							char a[100];pop_loop(a);
							char b[100];pop_loop(b);
							char c[100];temp_var(c);
							push_loop(c);
							strcpy(c,"");
							strcat(c,b);
							strcat(c,"<");
							strcat(c,a);
							
							push_node(c);
						}

		|data '>' data 	{
							char a[100];pop_loop(a);
							char b[100];pop_loop(b);
							char c[100];temp_var(c);
							push_loop(c);
							strcpy(c,"");
							strcat(c,b);
							strcat(c,"<");
							strcat(c,a);
							
							push_node(c);
						}
						
						
						
		|data '>''=' data 	{
							char a[100];pop_loop(a);
							char b[100];pop_loop(b);
							char c[100];temp_var(c);
							push_loop(c);
							strcpy(c,"");
							strcat(c,b);
							strcat(c,">=");
							strcat(c,a);
							
							push_node(c);
						}
						
						
						
		|data '<''=' data 	{
							char a[100];pop_loop(a);
							char b[100];pop_loop(b);
							char c[100];temp_var(c);
							push_loop(c);
							strcpy(c,"");
							strcat(c,b);
							strcat(c,"<=");
							strcat(c,a);
							
							push_node(c);
						}
						
		|data '=''=' data 	{
							char a[100];pop_loop(a);
							char b[100];pop_loop(b);
							char c[100];temp_var(c);
							push_loop(c);
							strcpy(c,"");
							strcat(c,b);
							strcat(c,"==");
							strcat(c,a);
							
							push_node(c);
						}


;



data :  NUMBER { 	
					
					float f =$1;
					char c[100];
					sprintf(c,"%g",f);
					push_loop(c);
					
				 }
		| VARIABLE {	
						
						char a[100];
						strcpy(a,$1);
						strcpy($$,a);	
						push_loop(a);			 
					}


;
C1 : C1 ',' VARIABLE '=' exp {	
								char a[100];
								strcpy(a,$3);
								
								char b[100];
								pop(b);
								printf("%s = %s;\n",$3,b);				
							}
	|  VARIABLE '=' exp {	
								char a[100];
								strcpy(a,$1);
								
								char b[100];
								pop(b);
								printf("%s = %s;\n",$1,b);				
							}
	| {}
;


exp :  NUMBER { 	
					
					float f =$1;
					char c[100];
					sprintf(c,"%g",f);
					push(c);
					
				 }
		| VARIABLE {	
						
						char a[100];
						strcpy(a,$1);
						strcpy($$,a);	
						push(a);			 
					}
					
		| '(' exp ')'  { }
		
		| exp '+' exp { 	
							char a[100];pop(a);
							char b[100];pop(b);
							char c[100];temp_var(c);
							printf("float %s;",c);
							push(c);
							printf("%s = %s + %s; \n",c,b,a);
							
						}
		| exp '-' exp { 
							char a[100];pop(a);
							char b[100];pop(b);
							char c[100];temp_var(c);
							printf("float %s;",c);
							push(c);
							printf("%s = %s - %s; \n",c,b,a);
						}
		| exp '*' exp { 
							char a[100];pop(a);
							char b[100];pop(b);
							char c[100];temp_var(c);
							printf("float %s;",c);
							push(c);
							printf("%s = %s * %s; \n",c,b,a);
							}
		| exp '/' exp { 
		
		
							char a[100];pop(a);
							char b[100];pop(b);
							char c[100];temp_var(c);
							printf("float %s;",c);
							push(c);
							printf("%s = %s / %s; \n",c,b,a);
							}				
;				
							
						
%%



int yyerror(char *s)
{
	printf("error in line %s",s);
	return 0;
}

int main()
{
	
	stack = malloc(sizeof(Stack));
	stack->top=NULL;
	
	stack2 = malloc(sizeof(Stack));
	stack2->top=NULL;
	
	for(int i=0;i<100;i++)
	{
		loop[i] = NULL;
		increment[i] = NULL;
		stmt[i] = NULL;
	}
	for(int i=0;i<100;i++)
	{
		loop_stack[i]=malloc(sizeof(Stack));
		loop_stack[i]->top=NULL;
	}

	
	
	for(int i=0;i<26;i++)
	{
		root[i]=malloc(sizeof(Nodetag));
		root[i]->var_list=NULL;
		root[i]->start_char = (char)('a' +i);
	}
	root[26]=malloc(sizeof(Nodetag));
	root[26]->var_list=NULL;
	root[26]->start_char = '+';
	root[27]=malloc(sizeof(Nodetag));
	root[27]->var_list=NULL;
	root[27]->start_char = '-';
	root[28]=malloc(sizeof(Nodetag));
	root[28]->var_list=NULL;
	root[28]->start_char = '_';
	for(int i=29;i<39;i++)
	{
		root[i]=malloc(sizeof(Nodetag));
		root[i]->var_list=NULL;
		root[i]->start_char = (char)('0' +i);
	}
	for_count=0;
	if_count=0;
	tmp_value=0;
	printf("#include<stdio.h>\n");
	printf("int main(){\n");
    yyparse();
    return 0;
}
























