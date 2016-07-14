import graphviz_wrap;
import std.stdio : writeln;

void main() {
	auto dot = new Digraph(null, "The Round Table");
	writeln(dot);
}
