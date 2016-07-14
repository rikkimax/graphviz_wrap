module graphviz_wrap;
public import graphviz_wrap.backend;
public import graphviz_wrap.dot;
public import graphviz_wrap.files;
public import graphviz_wrap.lang;

bool delegate(out string t, out string h) tailheadutil(string[] args...) {
	return (out string t, out string h) {
		if (args.length <= 1)
			return false;
		
		t = args[0];
		h = args[1];
		
		args = args[2 .. $];
		return true;
	};
}

string[string] attrsutil(string[] args...) {
	string[string] ret;

	while(args.length > 1) {
		ret[args[0]] = args[1];
		args = args[2 .. $];
	}

	return ret;
}
