module graphiz_wrap.backend;

// All valid drawing engines provided by Graphiz
static immutable string[] ENGINES = [
	"dot", "neato", "twopi", "circo", "fdp", "sfdp", "patchwork", "osage"
];

// All valid image formats provided by Graphiz
static immutable string[] FORMATS = [
	"bmp",
	"canon", "dot", "gv", "xdot", "xdot1.2", "xdot1.4",
	"cgimage",
	"cmap",
	"eps",
	"exr",
	"fig",
	"gd", "gd2",
	"gif",
	"gtk",
	"ico",
	"imap", "cmapx",
	"imap_np", "cmapx_np",
	"ismap",
	"jp2",
	"jpg", "jpeg", "jpe",
	"pct", "pict",
	"pdf",
	"pic",
	"plain", "plain-ext",
	"png",
	"pov",
	"ps",
	"ps2",
	"psd",
	"sgi",
	"svg", "svgz",
	"tga",
	"tif", "tiff",
	"tk",
	"vml", "vmlz",
	"vrml",
	"wbmp",
	"webp",
	"xlib",
	"x11"
];

/// See_Also: command
struct CommandArgs {
	///
	string[4] values;
	/// Number of values used $(D values[0 .. usedValues])
	size_t usedValues;
}

/**
 * Creates a command to turn dot format into an image.
 * 
 * Params:
 * 		engine		=	The engine to generate via
 * 		format		=	The format to generate
 * 		filepath	=	The location of file, default is null
 * 
 * See_Also:
 * 		ENGINES
 * 		FORMATS
 * 
 * Returns:
 * 		The command to turn the input into format via specified engine.
 */
CommandArgs command(string engine, string format, string filepath = null) {
	import std.typecons : tuple;
	import std.algorithm : canFind;

	if (!ENGINES.canFind(engine))
		throw new Exception("Unknown engine " ~ engine);
	if (!FORMATS.canFind(format))
		throw new Exception("Unknown format" ~ format);

	CommandArgs ret;
	ret.values[0] = engine;
	ret.values[1] = "-T" ~ format;
	ret.usedValues += 2;

	string rendered;
	if (filepath !is null) {
		ret.values[2] = "-O";
		ret.values[3] = filepath;
		ret.usedValues += 2;

		// can't help this allocation :(
		rendered = filepath ~ "." ~ format;
	}

	return tuple(ret, rendered);
}

/**
 * Renders input out into a file.
 * 
 * Params:
 * 		engine		=	The rendering engine
 * 		format		=	The format to render as
 * 		filepath	=	The location in file system it should save to
 * 
 * See_Also:
 * 		ENGINES
 * 		FORMATS
 * 
 * Returns:
 * 		The final location of the rendered file
 */
string render(string engine, string format, string filepath) {
	import std.process : execute, environment;
	import std.string : join;

	auto cret = command(engine, format, filepath);
	string[] args = cret[0].values[0 .. cret[0].usedValues];
	string rendered = cret[1];

	auto eret = execute(args, environment.toAA);

	if (eret.status != 0)
		throw new Exception("Failed to execute " ~ args.join(" ") ~ ", make sure the Graphviz executables are on the systems' path\n" ~ eret.output);

	return rendered;
}

/**
 * Renders input and returns it.
 * 
 * Params:
 * 		engine	=	The rendering engine
 * 		format	=	The format to render as
 * 		data	=	The input to send to the renderer
 * 
 * Returns:
 * 		Renders out some input via stdin and returns via stdout.
 */
string pipe(string engine, string format, string data) {
	import std.process : pipeProcess, wait, environment, Redirect;
	import std.array : appender;

	auto cret = command(engine, format);
	string[] args = cret[0].values[0 .. cret[0].usedValues];

	auto output = appender!string;
	// reserve 20mb of space, plenty for even the largest of images
	// unless you do something insane
	output.reserve(1024*1024*20);

	auto pipes = pipeProcess(args, Redirect.all, environment.toAA);
	pipes.stdin.write(data);

	foreach(line; pipes.stdin.byLine)
		output.put(line);

	// don't forget to dup as appender will auto deallocate its memory!
	return output.data.dup;
}
