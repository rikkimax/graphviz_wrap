module graphiz_wrap.lang;
import std.regex : ctRegex, matchFirst;

/// Describes an identifier used by Dot
static auto ID = ctRegex!(`^[a-zA-Z_][\s]*$`);

/// Describes what all keywords are used by Dot
static auto KEYWORD = ctRegex!(`((node)|(edge)|(graph)|(digraph)|(subgraph)|(strict))$`, "i");

/// Describes how to embed html in Dot labels
static auto HTML_STRING = ctRegex!(`<.*>$`, "s");

/// Describes compass directions used in Dot
static auto COMPASS = ctRegex!`((n)|(ne)|(e)|(se)|(s)|(sw)|(w)|(nw)|(c)|(_))$`;

/**
 * Ensures that the identifier is well formed.
 * If it is not, escape it via double quotes.
 * 
 * Params:
 * 		identifier	=	The identifier to be escaped
 * 
 * Returns:
 * 		A valid identifier.
 */
string quote(string identifier) {
	import std.string : tr;

	if (identifier.matchFirst(HTML_STRING).empty &&
		identifier.matchFirst(ID).empty &&
		identifier.matchFirst(KEYWORD).empty) {

		// sadly this doesn't optimize tr any better
		string idAltered = identifier.tr("\"", "\\\"");

		char[] ret;
		ret.length = idAltered.length + 2;

		ret[0] = '"';
		ret[$-1] = '"';

		ret[1 .. $-1] = idAltered;

		return cast(immutable)ret;
	}

	return identifier;
}

/**
 * Ensures that the identifier is well formed.
 * If it is not, escape it via double quotes.
 * 
 * It can contain a port and compass.
 * 
 * Params:
 * 		identifier	=	The identifier to be escaped
 * 
 * Returns:
 * 		A valid identifier.
 */
string quote_edge(string identifier) {
	import std.string : join;

	static auto partition(string from, string sep) {
		import std.string : indexOf;
		import std.typecons : tuple;

		ptrdiff_t i = from.indexOf(sep);
		if (i == -1)
			return tuple(from, cast(string)null, cast(string)null);
		else if (i >= from.length - sep.length)
			return tuple(from[0 .. i], sep, cast(string)null);
		else
			return tuple(from[0 .. i], sep, from[i + sep.length .. $]);
	}

	auto p1 = partition(identifier, ":");
	string node = p1[0];
	string rest = p1[2];

	// one less dynamic allocation + extension = good
	string[3] parts = [quote(node), null, null];
	size_t usedParts = 1;

	if (rest !is null) {
		auto p2 = partition(rest, ":");
		string port = p2[0];
		string compass = p2[2];

		parts[usedParts] = quote(port);
		usedParts++;

		if (compass !is null) {
			parts[usedParts] = compass;
			usedParts++;
		}
	}

	return parts[0 .. usedParts].join(":");
}

/**
 * For an element, apply a label, attributes and raw values all escaped.
 * 
 * Params:
 * 		label		=	A label
 * 		attributes	=	An AA of attributes (k, v)
 * 		raw			=	An array of non quoted text to add
 * 
 * Returns:
 * 		A valid attributes string
 */
string attributes(string label = null, string[string] attributes = null, string[] raw = null) {
	import std.string : join;

	string[] result;
	// maximum it can be
	result.length = 1 + attributes.length + raw.length;
	size_t usedResult;

	if (label !is null) {
		result[usedResult] = "label=" ~ quote(label);
		usedResult++;
	}

	if (attributes !is null) {
		foreach(k, v; attributes) {
			if (v !is null) {
				result[usedResult] = quote(k) ~ "=" ~ quote(v);
				usedResult++;
			}
		}
	}

	if (raw !is null) {
		result[usedResult .. usedResult + raw.length] = raw;
		usedResult += raw.length;
	}

	string temp = result[0 .. usedResult].join(" ");
	char[] ret;
	ret.length = temp.length + 3;

	ret[0 .. 2] = " [";
	ret[$-1] = ']';
	ret[2 .. $-1] = temp;

	return cast(immutable)ret;
}
