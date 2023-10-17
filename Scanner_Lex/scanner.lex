%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define MAX_LINE_LENG 256
#define MAX_FUNCTION_NAME 30
typedef struct Symbol_Table{
	char symbol[MAX_FUNCTION_NAME];
	struct Symbol_Table* next;
}Table_Node;
typedef Table_Node* TablePtr;
TablePtr symbol_table = NULL;
int search(char* s); //search the symbol table
void add(char* s); //add the new symbol to the symbol table
int isEmpty(TablePtr symbol_table);
char buf[MAX_LINE_LENG]; //the newest token be scan in
void getToken(char* yytext); //compute the number of tokens
int token_index; //the token unit being scaned in
void output(char* token,char* type); //print the output
int lineNum = 1; //the number of lines
char quote[20]; //count for the quotes
int Q_index = -1; //the intitial quote that needs to be scaned in
void check_quote(); //check the quote is double set(),[]
%}

%%
[(][*]([A-Za-z0-9 \t!"#$%&'()+,-./:;<=>?@\[\]^_`{|}~\r\n]|[*][^/])*[*][)] {
	getToken(yytext);
	output(yytext,"comment");
	int count = 0;
	while(yytext[count] != '\0'){
		if(yytext[count] == '\n'){
			lineNum++;
		}
		count++;
	}
}
[ \t]* {getToken(yytext);}
[(\[] {
	getToken(yytext);
	output(yytext,"symbol");
	Q_index++;
	quote[Q_index] = yytext[0];
}
[\])] {
	getToken(yytext);
	//count the double quote
	switch(yytext[0]){
		case ']':
			if(quote[Q_index] == '['){
				output(yytext,"symbol");
				Q_index--;
			}
			else
				output(yytext,"error");
			break;
		case ')':
			if(quote[Q_index] == '('){
				output(yytext,"symbol");
				Q_index--;
			}
			else
				output(yytext,"error");
			break;
	}
}
[,:;] {getToken(yytext);output(yytext,"symbol");}
[Aa][Bb][Ss][Oo][Ll][Uu][Tt][Ee]|[Aa][Nn][Dd]|[Bb][Ee][Gg][Ii][Nn]|[Bb][Rr][Ee][Aa][Kk]|[Cc][Aa][Ss][Ee]|[Cc][Oo][Nn][Ss][Tt]|[Cc][Oo][Nn][Tt][Ii][Nn][Uu][Ee]|[Dd][Oo]|[Ee][Ll][Ss][Ee]|[Ee][Nn][Dd]|[Ff][Oo][Rr]|[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]|[Ii][Ff]|[Mm][Oo][Dd]|[Nn][Ii][Ll]|[Nn][Oo][Tt]|[Oo][Bb][Jj][Ee][Cc][Tt]|[Oo][Ff]|[Oo][Rr]|[Pp][Rr][Oo][Gg][Rr][Aa][Mm]|[Tt][Hh][Ee][Nn]|[Tt][Oo]|[Vv][Aa][Rr]|[Ww][Hh][Ii][Ll][Ee]|[Aa][Rr][Rr][Aa][Yy]|[Ii][Nn][Tt][Ee][Gg][Ee][Rr]|[Dd][Oo][Uu][Bb][Ll][Ee]|[Ww][Rr][Ii][Tt][Ee]|[Ww][Rr][Ii][Tt][Ee][Ll][Nn]|[Ss][Tt][Rr][Ii][Nn][Gg]|[Ff][Ll][Oo][Aa][Tt]|[Rr][Ee][Aa][Dd] {getToken(yytext);output(yytext,"reserved word");} //reserved word ignore lower and upper capital

[0-9]+[-+][0-9]+ {
	getToken(yytext);
	char i[strlen(yytext)], s[strlen(yytext)], ii[strlen(yytext)];
	i[0] = yytext[0]; i[1] = '\0';
	s[0] = yytext[1]; s[1] = '\0';
	ii[0] = yytext[2]; ii[1] = '\0';
	output(i,"integer");
	token_index++;
	output(s,"symbol");
	token_index++;
	output(ii,"integer");
}
[-+][0-9]+[-+][0-9]+ {
	getToken(yytext);
	char i[strlen(yytext)], s[strlen(yytext)], ii[strlen(yytext)];
	i[0] = yytext[0]; i[1] = yytext[1]; i[2] = '\0';
	s[0] = yytext[2]; s[1] = '\0';
	ii[0] = yytext[3]; ii[1] = '\0';
	output(i,"integer");
	token_index++;
	output(s,"symbol");
	token_index++;
	output(ii,"integer");
}


[+]{1,2}|[-]{1,2}|[&][&]|[|][|]|[><=!][=]?|[!*/%] {getToken(yytext);output(yytext,"symbol");}
['][A-Za-z0-9 !"#$%&'()*+,-./:;<=>?@\[\]^_`{|}~]*['][;] {
	getToken(yytext);
	char s[strlen(yytext)];
	int index = 1, ddouble = 0;
	s[0] = yytext[0]; //display '
	//ddouble means that the double ' trigger the index, if it is triggered(has double '), then s[index] will jump to next alphabet
	while(yytext[index+ddouble] != ';')
	{
		if(yytext[index+ddouble] == '\'' && yytext[index+1+ddouble] == '\'')
		{
			s[index] = yytext[index+ddouble];
			index++;
			ddouble++; //to dicard the double ' into one '
		}
		//when it is triggered
		if(ddouble > 0)
		{
			s[index] = yytext[index+ddouble];
			index++;
			
		}
		//not being triggered
		else
		{
			s[index] = yytext[index+ddouble];
			index++;
		}
	}
	s[index] = '\0';
	if(strlen(yytext) > 30) //the string that is over 15
		output(yytext,"invalid string");
	else if(strlen(yytext) == 3 && s[0] == '\'' && s[1] == '\'')
		output(s,"empty quoted string");
	else if(strlen(yytext) == 4 && s[0] == '\'' && s[1] == ' ' && s[2] == '\'')
		output(s,"blank quoted string");
	else
		output(s,"quoted string");
	char end[strlen(yytext)]; //to record ; as a symbol
	end[0] = yytext[index+ddouble]; end[1] = '\0';
	token_index += strlen(s);
	output(end,"symbol");
}

['][A-Za-z0-9!"#$%&()*+,-./:;<=>?@\[\]^_`{|}~]*[;] {
	getToken(yytext);
	char s[strlen(yytext)]; //declare a string to store the entire yytext
	int index = 0;
	//scan to the end
	while(yytext[index] != ';')
	{
		s[index] = yytext[index];
		index++;
	}
	s[index] = '\0';
	output(s,"invalid quoted strings");
	char end[strlen(yytext)]; //to record ; as a symbol
	end[0] = yytext[index]; end[1] = '\0';
	token_index += strlen(s);
	output(end,"symbol");
}
[A-Za-z0-9!"#$%&()*+,-./:;<=>?@\[\]^_`{|}~]*['][;] {
	getToken(yytext);
	char s[strlen(yytext)]; //declare a string to store the entire yytext
	int index = 0;
	//scan to the end
	while(yytext[index] != ';')
	{
		s[index] = yytext[index];
		index++;
	}
	s[index] = '\0';
	output(s,"invalid quoted strings");
	char end[strlen(yytext)]; //to record ; as a symbol
	end[0] = yytext[index]; end[1] = '\0';
	token_index += strlen(s);
	output(end,"symbol");
}
[A-Za-z_0-9#^]* {
	getToken(yytext);
	//begin with numbers means invaild ID
	if(yytext[0] == '0' || yytext[0] == '1' || yytext[0] == '2'|| yytext[0] == '3'|| yytext[0] == '4'|| yytext[0] == '5'|| yytext[0] == '6'|| yytext[0] == '7'|| yytext[0] == '8'|| yytext[0] == '9'|| yytext[0] == '#'|| yytext[0] == '^')
		output(yytext,"invalid ID");
	else if(strlen(yytext) > 15) //the ID that is over 15
		output(yytext,"invalid ID");
	else
		output(yytext,"ID");
}
[-+]?[0-9]+ {
	getToken(yytext);
	output(yytext,"integer");
}
[.][0-9]+([Ee][-+]?[0-9]+)?|[-]?[0-9]+|[-] {getToken(yytext);output(yytext,"invalid real");}

[-]?[0-9]+[.][1-9]*[0]+ {getToken(yytext);output(yytext,"invalid real");}
[-]?[0-9]+[.][0-9]+([Ee][-+]?[0-9]+)?|[-]?[0-9]+|[-] {getToken(yytext);output(yytext,"real");}

[+]{1,2}|[-]{1,2}|[:><=][=]?|[*/] {
	getToken(yytext);
	output(yytext,"symbol");
}
[.] {getToken(yytext);output(yytext,"symbol");}

[\r]?[\n] {
	getToken(yytext);
	buf[0] = '\0';
	lineNum++;
}
%%

/*main function*/
int main(){
	yylex();
	check_quote();
	return 0;
}

/*check whether the symbol table is empty or not*/
int isEmpty(TablePtr symbol_table){
	if(symbol_table == NULL)
		return 0;
	return -1;
}

/*search the symbol table*/
int search(char* s){
	if(isEmpty(symbol_table) == 0)
		return -1;
	TablePtr now = symbol_table;
	//whether the newest symbol matches or already exit in the symbol table
	while(now != NULL){
		if(strcmp(now->symbol,s) == 0)
			return 0;
		now = now->next;
	}
	return -1;
}

/*add newest symbol into the symbol table*/
void add(char* s){
	TablePtr new_node = (TablePtr)malloc(sizeof(Table_Node));
	strcpy(new_node->symbol,s);
	new_node->next = symbol_table;
	symbol_table = new_node;
}

/*print the output*/
void output(char* token,char* type){
	printf("Line: %d, 1st char: %d,\"%s\" is a \"%s\".\n",lineNum,token_index,token,type);
}

/*compute the number of tokens*/
void getToken(char* yytext){
	token_index = (int)strlen(buf) + 1;
	strcat(buf, yytext); //add the newest token into yytext
}

/*check the quote is double set(),[]*/
void check_quote(){
	//means there at least one quote
	if(Q_index != -1){
		for(int i = 0;i <= Q_index;i++){
			switch(quote[i]){
				case '[':
					printf("error: Missing ']'\n");
					break;
				case '(':
					printf("error: Missing ')'\n");
					break;
				case '\'' :
					printf("error: Missing '\''\n");
					break;
			}
		}
	}
}

/*until all the file has been scaned, it will return 1*/
int yywrap(){
	return 1;
}
