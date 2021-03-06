import graphviz_wrap;
import std.stdio : writeln;
import std.process : environment;
import std.path : pathSeparator, buildPath, getcwd;

void main() {
	environment["PATH"] = environment["PATH"] ~ pathSeparator ~ buildPath(getcwd(), "graphiz", "bin");
	string[string] nodeAttrs;
	nodeAttrs["shape"] = "plaintext";
	
	auto g = new Digraph("structs", null, null, null, null, null, 
null, nodeAttrs);
	
	g.node("struct1", `
<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR>
    <TD>left</TD>
    <TD PORT="f1">middle</TD>
    <TD PORT="f2">right</TD>
  </TR>	
</TABLE>>`);
	g.node("struct2", `
<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR>
    <TD PORT="f0">one</TD>
    <TD>two</TD>
  </TR>
</TABLE>>`);
	g.node("struct3", `
<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4">
  <TR>
    <TD ROWSPAN="3">hello<BR/>world</TD>
    <TD COLSPAN="3">b</TD>
    <TD ROWSPAN="3">g</TD>
    <TD ROWSPAN="3">h</TD>
  </TR>
  <TR>
    <TD>c</TD>
    <TD PORT="here">d</TD>
    <TD>e</TD>
  </TR>
  <TR>
    <TD COLSPAN="3">f</TD>
  </TR>
</TABLE>>`);
	g.edges(tailheadutil("struct1:f1", "struct2:f0", "struct1:f2", 
"struct3:here"));
	
	g.view();
}
