module graphiz_wrap.dot;
import graphiz_wrap.lang;
import graphiz_wrap.files;

/// Main construction mechanism for Dot files
abstract class Dot : File {
protected:
	string _head;
	string _edge;
	string _edge_plain;

	string _comment = "// %s";
	string _subgraph = "subgraph %s{";
	string _node = "\t%s%s";
	string _tail = "}";

public:
	/// Name of graph
	string name;
	/// Comment on graph
	string comment;

	/// Graph attributes
	string[string] graph_attr;
	/// Per node attributes
	string[string] node_attr;
	/// Per edge attributes
	string[string] edge_attr;

	/// Body lines
	string[] body_;

	/// Is graph strict
	bool strict;

	///
	this(string name = null, string comment = null,
		string filename = null, string directory = null,
		string format = null, string engine = null,
		string[string] graph_attr = null, string[string] node_attr = null,
		string[string] edge_attr = null, string[] body_ = null,
		bool strict = false) {

		this.name = name;
		this.comment = comment;

		super(filename, directory, format, engine);

		this.graph_attr = graph_attr;
		this.node_attr = node_attr;

		this.body_ = body_;
		this.strict = strict;

		_source = &toString;
	}

	auto iter(bool subGraph = false) {
		struct Result {
			Dot dot;
			bool subGraph;

			int opApply(scope int delegate(string) dg) {
				import std.format : format;
				int result = 0;

				if (dot.comment !is null) {
					result = dg(dot._comment.format(dot.comment));
					if (result)
						return result;
				}

				string head = subGraph ? dot._subgraph : dot._head;
				if (dot.strict)
					head = "strict " ~ head;

				if (dot.name !is null)
					result = dg(head.format(quote(dot.name) ~ " "));
				else
					result = dg(head.format(""));
				if (result)
					return result;

				bool styled = false;

				if (dot.graph_attr !is null) {
					styled = true;

					result = dg("\tgraph" ~ attributes(null, dot.graph_attr));
					if (result)
						return result;
				}

				if (dot.node_attr !is null) {
					styled = true;
					
					result = dg("\tnode" ~ attributes(null, dot.node_attr));
					if (result)
						return result;
				}

				if (dot.edge_attr !is null) {
					styled = true;
					
					result = dg("\tedge" ~ attributes(null, dot.edge_attr));
					if (result)
						return result;
				}

				string indent = styled ? "\t" : "";

				foreach(line; dot.body_) {
					result = dg(indent ~ line);
					if (result)
						return result;
				}

				result = dg(dot._tail);
				return result;
			}
		}

		return Result(this, subGraph);
	}

	///
	int opApply(scope int delegate(string) dg) { return iter().opApply(dg); }

	/// The contents of the input
	override string toString() {
		string ret;

		opApply((string line) {ret ~= line ~ "\n"; return 0;});

		if (ret.length > 0)
			ret.length--;
		return ret;
	}

	/// Add a node
	void node(string name, string label = null, string[string] attrs = null) {
		import std.format : format;

		name = quote(name);
		string attrs2 = attributes(label, attrs);
		body_ ~= _node.format(name, attrs2);
	}

	/// Add an edge
	void edge(string tail_name, string head_name, string label = null, string[string] attrs = null) {
		import std.format : format;

		tail_name = quote_edge(tail_name);
		head_name = quote_edge(head_name);
		string attrs2 = attributes(label, attrs);
		string edge = _edge.format(tail_name, head_name, attrs2);
		body_ ~= edge;
	}

	/// Add a set of edges that have the format of plain
	void edges(scope bool delegate(out string t, out string h) tail_head_iter) {
		import std.format : format;
		string t, h;

		while(tail_head_iter(t, h)) {
			body_ ~= _edge_plain.format(quote_edge(t), quote_edge(h));
		}
	}

	/// Set an attributes for either graph, node or edge
	void attr(string kw, string[string] attrs = null) {
		import std.string : toLower;

		kw = kw.toLower;

		if (kw == "graph")
			body_ ~= "\t" ~ kw ~ attributes(null, attrs);
		else if (kw == "node")
			body_ ~= "\t" ~ kw ~ attributes(null, attrs);
		else if (kw == "edge")
			body_ ~= "\t" ~ kw ~ attributes(null, attrs);
		else
			throw new Exception("attr statement must target graph, node or edge: " ~ kw);
	}

	/// Append a graph of same type onto this one
	void subgraph(Dot graph) {
		if (typeid(this) !is typeid(graph)) {
			throw new Exception(typeid(this).name ~ " cannot add subgraphs of different kind: " ~ typeid(graph).name);
		}

		foreach(line; graph.iter(true)) {
			body_ ~= "\t" ~ line;
		}
	}
}

/// An undirected graph
class Graph : Dot {
	///
	this(string name = null, string comment = null,
		string filename = null, string directory = null,
		string format = null, string engine = null,
		string[string] graph_attr = null, string[string] node_attr = null,
		string[string] edge_attr = null, string[] body_ = null,
		bool strict = false) {
		
		super(name, comment, filename, directory, format, engine, graph_attr, node_attr, edge_attr, body_, strict);
		
		_head = "graph %s{";
		_edge = "\t\t%s -- %s%s";
		_edge_plain = "\t\t%s -- %s";
	}
}

/// A directed graph
class Digraph : Dot {
	///
	this(string name = null, string comment = null,
		string filename = null, string directory = null,
		string format = null, string engine = null,
		string[string] graph_attr = null, string[string] node_attr = null,
		string[string] edge_attr = null, string[] body_ = null,
		bool strict = false) {

		super(name, comment, filename, directory, format, engine, graph_attr, node_attr, edge_attr, body_, strict);

		_head = "digraph %s{";
		_edge = "\t\t%s -> %s%s";
		_edge_plain = "\t\t%s -> %s";
	}
}
