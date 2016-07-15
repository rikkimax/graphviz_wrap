module graphiz_wrap.files;
import backend = graphiz_wrap.backend;

/// Base class for everything else in this library
abstract class Base {
protected:
	string _format = "pdf";
	string _engine = "dot";

public:
	@property {
		/// The format to export as
		string format() { return _format; }
		/// The engine to render via
		string engine() { return _engine; }

		/**
		 * Sets the format validating it against FORMATS
		 * 
		 * Params:
		 * 		format	=	The format to assign
		 * 
		 * See_Also:
		 * 		backend.FORMATS
		 */
		void format(string format) {
			import std.string : toLower;
			import std.algorithm : canFind;

			format = format.toLower;

			if (!backend.FORMATS.canFind(format))
				throw new Exception("Unknown format: " ~ format);

			_format = format;
		}

		/**
		 * Sets the engine validating it against ENGINES
		 * 
		 * Params:
		 * 		engine	=	The engine to assign
		 * 
		 * See_Also:
		 * 		backend.ENGINES
		 */
		void engine(string engine) {
			import std.string : toLower;
			import std.algorithm : canFind;

			engine = engine.toLower;

			if (!backend.ENGINES.canFind(engine))
				throw new Exception("Unknown engine: " ~ engine);

			_engine = engine;
		}
	}
}

// Abstracts out the exportation and rendering capability
abstract class File : Base {
protected:
	string _directory;
	string _default_extension = "gv";
	string _filename;

	string _repr_svg() {
		return pipe("svg");	
	}

	string delegate() _source;

public:
	/**
	 * Constructs the representation with basic output information.
	 * 
	 * Params:
	 * 		filename	=	The filename to export as, default null
	 * 		directory	=	The directory to export to, default null
	 * 		format		=	The format to render as, default null
	 * 		engine		=	The engine that will render via, default null
	 */
	this(this T)(string filename = null, string directory = null, string format = null, string engine = null) {
		if (filename is null) {
			string name;
			static if (__traits(hasMember, T, "name"))
				name = (cast(T)this).name;

			if (name is null)
				name = __traits(identifier, T);

			_filename = name ~ "." ~ _default_extension;
		} else
			_filename = filename;

		if (directory !is null)
			_directory = directory;
		if (format !is null)
			_format = format;
		if (engine !is null)
			_engine = engine;
	}

	@property {
		/// The directory to render to
		string directory() { return _directory; }
		/// Assigns the directory to render to
		void directory(string v) { _directory = v; }

		/// The full location to render to
		string filepath() {
			import std.path : buildPath;
			return buildPath(_directory, _filename);
		}
	}

	/**
	 * Renders and returns the result for the renderer.
	 * 
	 * Params:
	 * 		format	=	The format to render as, default null
	 * 
	 * Returns:
	 * 		The renderers stdout
	 */
	string pipe(string format = null) {
		if (format is null)
			format = _format;

		return backend.pipe(_engine, format, _source());
	}

	/**
	 * Saves the input as a file
	 * 
	 * Params:
	 * 		filename	=	The filename to save to, default null
	 * 		directory	=	The directory to save to, default null
	 * 
	 * Returns:
	 * 		The full path of the saved file
	 */
	string save(string filename = null, string directory = null) {
		import std.file : mkdirRecurse, write;

		if (filename !is null)
			_filename = filename;
		if (directory !is null)
			_directory = directory;

		string filepath = this.filepath;
		if (_directory !is null)
			mkdirRecurse(_directory);

		write(filepath, _source());
		return filepath;
	}

	/**
	 * Renders the input into a file
	 * 
	 * Params:
	 * 		filename	=	The name of the file to render into, default null
	 * 		directory	=	The directory to render as, default null
	 * 		view		=	Should the file be viewed after rendering, default false
	 * 		cleanup		=	Should a previous file be removed, default false
	 * 
	 * Returns:
	 * 		The full filename of the output
	 */
	string render(string filename = null, string directory = null, bool view = false, bool cleanup = false) {
		import std.file : remove, exists;
		string filepath = save(filename, directory);
		string rendered = backend.render(_engine, _format, filepath);

		if (filepath.exists && cleanup)
			remove(filepath);

		if (view)
			_view(rendered, _format);

		return rendered;
	}

	/**
	 * Renders and views the output in appropriete external program.
	 * 
	 * Returns:
	 * 		The full filename of the output
	 */
	string view() {
		import std.process : browse;

		string rendered = render();
		browse(filepath);
		return rendered;
	}
}

/// Loads a complete input file up and allows for rendering but no modification
class Source : File {
protected:
	string _source2;

public:
	/**
	 * Constructs using the given known inputs for rendering
	 * 
	 * Params:
	 * 		source		=	The source input
	 * 		filename	=	File to render to
	 * 		directory	=	Directory so save the generated file to
	 * 		format		=	Format of the generated file
	 * 		engine		=	The engine to generate via
	 */
	this(string source, string filename = null, string directory = null, string format = null, string engine = null) {
		super(filename, directory, format, engine);
		_source2 = source;
		_source = &this.source;
	}

	@property {
		/// Gets the input source
		string source() { return _source2; }
		/// Sets the input source
		void source(string v) { _source2 = v; }
	}
}
