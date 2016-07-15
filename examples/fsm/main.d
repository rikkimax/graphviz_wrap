import graphviz_wrap;
import std.stdio : writeln;
import std.process : environment;
import std.path : pathSeparator, buildPath, getcwd;

void main() {
	environment["PATH"] = environment["PATH"] ~ pathSeparator ~ buildPath(getcwd(), "graphiz", "bin");
	auto g = new Digraph("finite_state_machine", null, "fsm.gv");
	g.body_ ~= [`rankdir=LR`, `size="8,5"`];

	string[string] nodeAttrs;
	nodeAttrs["shape"] = "doublecircle";
	g.attr("node", nodeAttrs);

	g.node("LR_0");
	g.node("LR_3");
	g.node("LR_4");
	g.node("LR_8");

	nodeAttrs["shape"] = "circle";
	g.attr("node", nodeAttrs);

	g.edge("LR_0", "LR_2", "SS(B)");
	g.edge("LR_0", "LR_1", "SS(S)");
	g.edge("LR_1", "LR_3", "S($end)");
	g.edge("LR_2", "LR_6", "SS(b)");
	g.edge("LR_2", "LR_5", "SS(a)");
	g.edge("LR_2", "LR_4", "S(A)");
	g.edge("LR_5", "LR_7", "S(b)");
	g.edge("LR_5", "LR_5", "S(a)");
	g.edge("LR_6", "LR_6", "S(b)");
	g.edge("LR_6", "LR_5", "S(a)");
	g.edge("LR_7", "LR_8", "S(b)");
	g.edge("LR_7", "LR_5", "S(a)");
	g.edge("LR_8", "LR_6", "S(b)");
	g.edge("LR_8", "LR_5", "S(a)");

	g.view();
}
