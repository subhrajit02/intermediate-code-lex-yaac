# intermediate-code-lex-yaac

lex int6.l
yacc -d int6.y
gcc lex.yy.c y.tab.c -ll -lm
./a.out > a.cpp
program of cpp file can be run in g++ compiler to check right output

i:0;
j:0;
a:0;
b:0;
for(i=0;i<3;i++)
{
b++;
for(j=0;j<3;j++)
{
b++;
print b;
}
}
quit


i:0;
j:0;
a:0;
b:0;
c:;
for(i=0;i<8;i++)
{
if(a<7)
{
a++;
print a;
}
else
{
print a;
b++;
}

a=a+2+b;
}
quit

i:0;
j:0;
a:0;
b:0;
c:;
if(a<7)
{
a++;
print a;
}
else
{
print a;
b++;
}

a=a+2+b;
quit
