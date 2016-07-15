import graphviz_wrap;
import std.stdio : writeln;
import std.process : environment;
import std.path : pathSeparator, buildPath, getcwd;

void main() {
	environment["PATH"] = environment["PATH"] ~ pathSeparator ~ buildPath(getcwd(), "graphiz", "bin");
	auto g = new Graph("er", null, "er.gv", null, null, "neato");

	g.attr("node", attrsutil(
			"shape", "box"));
	g.node("course");
	g.node("institute");
	g.node("student");

	g.attr("node", attrsutil(
			"shape", "ellipse"));
	g.node("name0", "name");
	g.node("name1", "name");
	g.node("name2", "name");
	g.node("code");
	g.node("grade");
	g.node("number");

	g.attr("node", attrsutil(
			"shape", "diamond",
			"style", "filled",
			"color", "lightgrey"));
	g.node("C-I");
	g.node("S-C");
	g.node("S-I");

	g.edge("name0", "course");
	g.edge("code", "course");
	g.edge("course", "C-I", "n", attrsutil(
			"len", "1.00"));
	g.edge("C-I", "institute", "1", attrsutil(
			"len", "1.00"));
	g.edge("institute", "name1");
	g.edge("institute", "S-I", "1", attrsutil(
			"len", "1.00"));
	g.edge("S-I", "student", "n", attrsutil(
			"len", "1.00"));
	g.edge("student", "grade");
	g.edge("student", "name2");
	g.edge("student", "number");
	g.edge("student", "S-C", "m", attrsutil(
			"len", "1.00"));
	g.edge("S-C", "course", "n", attrsutil(
			"len", "1.00"));

	g.body_ ~= `label = "\n\nEntity Relation Diagram\ndrawn by 
NEATO"`;
	g.body_ ~= `fontsize=20`;

	g.view();
}
