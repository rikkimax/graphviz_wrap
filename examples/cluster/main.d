import graphviz_wrap;
import std.stdio : writeln;

void main() {
	auto g = new Digraph("G", null, "cluster.gv");

	auto c0 = new Digraph("cluster_0");
	c0.body_ ~= `style=filled`;
	c0.body_ ~= `color=lightgrey`;
	c0.node_attr["style"] = "filled";
	c0.node_attr["color"] = "white";
	c0.edges(tailheadutil(
			"a0", "a1",
			"a1", "a2",
			"a2", "a3"));
	c0.body_ ~= `label = "process #1"`;

	auto c1 = new Digraph("cluster_1");
	c1.node_attr["style"] = "filled";
	c1.edges(tailheadutil(
			"b0", "b1",
			"b1", "b2",
			"b2", "b3"));
	c1.body_ ~= `label = "process #2"`;
	c1.body_ ~= `color=blue`;

	g.subgraph(c0);
	g.subgraph(c1);

	g.edge("start", "a0");
	g.edge("start", "b0");
	g.edge("a1", "b3");
	g.edge("b2", "a3");
	g.edge("a3", "a0");
	g.edge("a3", "end");
	g.edge("b3", "end");

	g.node("start", null, attrsutil(
			"shape", "Mdiamond"));
	g.node("end", null, attrsutil(
			"shape", "Msquare"));

	g.view();
}
