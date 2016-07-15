module graphviz_wrap;
public import graphviz_wrap.backend;
public import graphviz_wrap.dot;
public import graphviz_wrap.files;
public import graphviz_wrap.lang;

/**
 * Turns an array of strings into a delegate that returns them in pairs.
 * 
 * Params:
 * 		args	=	An array of strings
 * 
 * Returns:
 * 		A delegate that returns pairs of values from the arguments.
 */
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

/**
 * Turns an array of strings into an AA.
 * 
 * Pairs up the values, if its an odd number ignore it.
 * k, v, k, v.
 * 
 * Params:
 * 		args	=	An array of strings
 * 
 * Returns:
 * 		An AA representation of pairs of arguments.
 */
string[string] attrsutil(string[] args...) {
	string[string] ret;

	while(args.length > 1) {
		ret[args[0]] = args[1];
		args = args[2 .. $];
	}

	return ret;
}
