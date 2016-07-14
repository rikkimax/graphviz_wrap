module graphviz_wrap.files;
import backend = graphviz_wrap.backend;

class Base {
protected:
	string _format = "pdf";
	string _engine = "dot";

public:
	@property {
		string format() { return _format; }
		string engine() { return _engine; }

		void format(string format) {
			import std.string : toLower;
			import std.algorithm : canFind;

			format = format.toLower;

			if (!backend.FORMATS.canFind(format))
				throw new Exception("Unknown format: " ~ format);

			_format = format;
		}

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
		string directory() { return _directory; }
		void directory(string v) { _directory = v; }

		string filepath() {
			import std.path : buildPath;
			return buildPath(_directory, _filename);
		}
	}

	string pipe(string format = null) {
		if (format is null)
			format = _format;

		return backend.pipe(_engine, format, _source());
	}

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

	string view() {
		string rendered = render();
		_view(rendered, _format);
		return rendered;
	}

	void _view(this T)(string filepath, string format) {
		import std.process : browse;
		browse(filepath);
	}
}

class Source : File {
protected:
	string _source2;

public:
	this(string source, string filename = null, string directory = null, string format = null, string engine = null) {
		super(filename, directory, format, engine);
		_source2 = source;
		_source = &this.source;
	}

	@property {
		string source() { return _source2; }
		void source(string v) { _source2 = v; }
	}
}
