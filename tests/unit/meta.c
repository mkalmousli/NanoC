#include "test.h"
void test_meta(void) {
    test_program("@m twice($x){(($x)*2)}\n"
        "@f add(int a,b)->int => a+b;\n"
        "@f main()->int { int x=@twice(add(2,3)); if(x!=10){=>1;} =>0; }\n", "", false);
    test_program("@m enums($prefix:ident,$items...) => {"
        "for(i:=0;i<len(items);i++){n:=ident(str(prefix)+str(i));v:=items[i];emit(quote{enum{$n=$v};});}}\n"
        "@enums(value,2,3,5)\n@m id($x)=>quote{$x};\n"
        "@f main()->int => @id(value2)!=5;\n", "", false);
    test_program("@ct { f square(x)=>x*x; total:=0;"
        "for(i:=0;i<10;i++){if(i==1){continue;}if(i==5){break;}total+=square(i);}"
        "assert(total==29);xs:=split(\"a,b,c\",\",\");xs=push(xs,\"d\");"
        "assert(join(slice(xs,1,3),\"-\")==\"b-c\");"
        "assert(slice(\"abcd\",1,3)==\"bc\");assert(find(\"abcd\",\"bc\")==1);"
        "words:=lex(\"int /*comment*/ x = 3;\");assert(str(words[1])==\"x\");"
        "assert(replace(\"aaaa\",\"aa\",\"b\")==\"bb\");"
        "eval(\"f triple(x)=>x*3;\");assert(triple(14)==42);"
        "emit(quote{enum{total=$total};});}\n@f main()->int=>total!=29;\n", "", false);
    test_program("@m id($x){$x}\n@ct {"
        "key:=\"PLACE\"+\"HOLDER\";if(contains(source(),key)){rewrite(replace(source(),key,\"41\"));}}\n"
        "@f main()->int=>@id(PLACEHOLDER)!=41;\n", "", false);
    test_program("@ct {n:=get(\"n\",0);put(\"n\",n+1);if(n<2){again();}"
        "emit(quote{enum{n=$n};});}\n@f main()->int=>n!=2;\n", "", false);
    test_program("@ct {rewrite(rename(source(),\"old\",\"renamed\"));}\n"
        "int old=42; const char *message=\"old\"; // old stays in comments\n"
        "@f main()->int=>renamed!=42 || message[0]!='o';\n", "", false);
    test_program("#include <vector>\n@f count(const std::vector<int>& xs)->int=>(int)xs.size();\n"
        "@f main()->int {std::vector<int> xs{1,2,3};=>count(xs)!=3;}\n", "", true);
    test_program("@f main()->int {"
        "@ct {f square(x)=>x*x; n:=square(7);emit(quote{int n=$n;});}"
        "@m finish($x){=>$x;} @finish(n!=49)}\n", "", false);
    test_reject("@ct {again();}", "pass limit", 0, 0, 0);
    test_reject("@ct {break;}", "loop control", 0, 0, 0);
    test_reject("@ct {slice(\"x\",-1);}", "slice bounds", 0, 0, 0);
    test_reject("@ct {replace(\"x\",\"\",\"y\");}", "must not be empty", 0, 0, 0);
    test_reject("@ct {run([\"true\"]);}", "require @bt", 0, 0, 0);
    puts("[OK] native syntax, executable macros, token editing, programs and rewrite passes");
}
