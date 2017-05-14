#!/usr/bin/env vala
/**
 * ValaC2 
 *  
 * breaks valac into 2 steps with plugin pre/post processing
 * this front end just collects all of the command line arguments 
 * 
 * 1 copy out of tree
 * 2 preprocess vala
 * 3 run valac, retain c code
 * 4 preprocess c
 * 5 run cc/emcc
 * 
 * 
 * Adds 2 new optiona:
 * --plugin=DIRECTORY
 * 		plugin location
 * --builddir=DIRECTORY
 * 		required location for out of tree build
 * 		no in tree builds allowed
 * 
 * use case: emscripten
 * 
 * 
 * using the command line interface described in valacompiler.vala
 * @see https://github.com/GNOME/vala/blob/master/compiler/valacompiler.vala 
 */

using GLib;

class Valac2 {

	static StringBuilder sb_valac;
	static StringBuilder sb_cc;

	static string plugin;
	static string builddir;
	static string basedir;
	static string directory;
	static bool version;
	static bool api_version;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] sources;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] vapi_directories;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] gir_directories;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] metadata_directories;
	static string vapi_filename;
	static string library;
	static string shared_library;
	static string gir;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] packages;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] fast_vapis;
	static string target_glib;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] gresources;

	static bool ccode_only;
	static string header_filename;
	static bool use_header;
	static string internal_header_filename;
	static string internal_vapi_filename;
	static string fast_vapi_filename;
	static bool vapi_comments;
	static string symbocmd_filename;
	static string includedir;
	static bool compile_only;
	static string output;
	static bool debug;
	static bool thread;
	static bool mem_profiler;
	static bool disable_assert;
	static bool enable_checking;
	static bool deprecated;
	static bool hide_internal;
	static bool experimental;
	static bool experimental_non_null;
	static bool gobject_tracing;
	static bool disable_since_check;
	static bool disable_warnings;
	static string cc_command;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] cc_options;
	static string pkg_config_command;
	static string dump_tree;
	static bool save_temps;
	[CCode (array_length = false, array_null_terminated = true)]
	static string[] defines;
	static bool quiet_mode;
	static bool verbose_mode;
	static string profile;
	static bool nostdpkg;
	static bool enable_version_header;
	static bool disable_version_header;
	static bool fatal_warnings;
	static bool disable_colored_output;
	static string dependencies;

	static string entry_point;

	static bool run_output;

	const OptionEntry[] options = {
		{ "plugin", 0, 0, OptionArg.FILENAME, ref plugin, "Plugin build process location", "DIRECTORY" },
		{ "builddir", 0, 0, OptionArg.FILENAME, ref builddir, "Out of tree location for build", "DIRECTORY" },
		
		{ "vapidir", 0, 0, OptionArg.FILENAME_ARRAY, ref vapi_directories, "Look for package bindings in DIRECTORY", "DIRECTORY..." },
		{ "girdir", 0, 0, OptionArg.FILENAME_ARRAY, ref gir_directories, "Look for .gir files in DIRECTORY", "DIRECTORY..." },
		{ "metadatadir", 0, 0, OptionArg.FILENAME_ARRAY, ref metadata_directories, "Look for GIR .metadata files in DIRECTORY", "DIRECTORY..." },
		{ "pkg", 0, 0, OptionArg.STRING_ARRAY, ref packages, "Include binding for PACKAGE", "PACKAGE..." },
		{ "vapi", 0, 0, OptionArg.FILENAME, ref vapi_filename, "Output VAPI file name", "FILE" },
		{ "library", 0, 0, OptionArg.STRING, ref library, "Library name", "NAME" },
		{ "shared-library", 0, 0, OptionArg.STRING, ref shared_library, "Shared library name used in generated gir", "NAME" },
		{ "gir", 0, 0, OptionArg.STRING, ref gir, "GObject-Introspection repository file name", "NAME-VERSION.gir" },
		{ "basedir", 'b', 0, OptionArg.FILENAME, ref basedir, "Base source directory", "DIRECTORY" },
		{ "directory", 'd', 0, OptionArg.FILENAME, ref directory, "Change output directory from current working directory", "DIRECTORY" },
		{ "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
		{ "api-version", 0, 0, OptionArg.NONE, ref api_version, "Display API version number", null },
		{ "ccode", 'C', 0, OptionArg.NONE, ref ccode_only, "Output C code", null },
		{ "header", 'H', 0, OptionArg.FILENAME, ref header_filename, "Output C header file", "FILE" },
		{ "use-header", 0, 0, OptionArg.NONE, ref use_header, "Use C header file", null },
		{ "includedir", 0, 0, OptionArg.FILENAME, ref includedir, "Directory used to include the C header file", "DIRECTORY" },
		{ "internal-header", 'h', 0, OptionArg.FILENAME, ref internal_header_filename, "Output internal C header file", "FILE" },
		{ "internal-vapi", 0, 0, OptionArg.FILENAME, ref internal_vapi_filename, "Output vapi with internal api", "FILE" },
		{ "fast-vapi", 0, 0, OptionArg.STRING, ref fast_vapi_filename, "Output vapi without performing symbol resolution", null },
		{ "use-fast-vapi", 0, 0, OptionArg.STRING_ARRAY, ref fast_vapis, "Use --fast-vapi output during this compile", null },
		{ "vapi-comments", 0, 0, OptionArg.NONE, ref vapi_comments, "Include comments in generated vapi", null },
		{ "deps", 0, 0, OptionArg.STRING, ref dependencies, "Write make-style dependency information to this file", null },
		{ "symbols", 0, 0, OptionArg.FILENAME, ref symbocmd_filename, "Output symbols file", "FILE" },
		{ "compile", 'c', 0, OptionArg.NONE, ref compile_only, "Compile but do not link", null },
		{ "output", 'o', 0, OptionArg.FILENAME, ref output, "Place output in file FILE", "FILE" },
		{ "debug", 'g', 0, OptionArg.NONE, ref debug, "Produce debug information", null },
		{ "thread", 0, 0, OptionArg.NONE, ref thread, "Enable multithreading support (DEPRECATED AND IGNORED)", null },
		{ "enable-mem-profiler", 0, 0, OptionArg.NONE, ref mem_profiler, "Enable GLib memory profiler", null },
		{ "define", 'D', 0, OptionArg.STRING_ARRAY, ref defines, "Define SYMBOL", "SYMBOL..." },
		{ "main", 0, 0, OptionArg.STRING, ref entry_point, "Use SYMBOL as entry point", "SYMBOL..." },
		{ "nostdpkg", 0, 0, OptionArg.NONE, ref nostdpkg, "Do not include standard packages", null },
		{ "disable-assert", 0, 0, OptionArg.NONE, ref disable_assert, "Disable assertions", null },
		{ "enable-checking", 0, 0, OptionArg.NONE, ref enable_checking, "Enable additional run-time checks", null },
		{ "enable-deprecated", 0, 0, OptionArg.NONE, ref deprecated, "Enable deprecated features", null },
		{ "hide-internal", 0, 0, OptionArg.NONE, ref hide_internal, "Hide symbols marked as internal", null },
		{ "enable-experimental", 0, 0, OptionArg.NONE, ref experimental, "Enable experimental features", null },
		{ "disable-warnings", 0, 0, OptionArg.NONE, ref disable_warnings, "Disable warnings", null },
		{ "fatal-warnings", 0, 0, OptionArg.NONE, ref fatal_warnings, "Treat warnings as fatal", null },
		{ "disable-since-check", 0, 0, OptionArg.NONE, ref disable_since_check, "Do not check whether used symbols exist in local packages", null },
		{ "enable-experimental-non-null", 0, 0, OptionArg.NONE, ref experimental_non_null, "Enable experimental enhancements for non-null types", null },
		{ "enable-gobject-tracing", 0, 0, OptionArg.NONE, ref gobject_tracing, "Enable GObject creation tracing", null },
		{ "cc", 0, 0, OptionArg.STRING, ref cc_command, "Use COMMAND as C compiler command", "COMMAND" },
		{ "Xcc", 'X', 0, OptionArg.STRING_ARRAY, ref cc_options, "Pass OPTION to the C compiler", "OPTION..." },
		{ "pkg-config", 0, 0, OptionArg.STRING, ref pkg_config_command, "Use COMMAND as pkg-config command", "COMMAND" },
		{ "dump-tree", 0, 0, OptionArg.FILENAME, ref dump_tree, "Write code tree to FILE", "FILE" },
		{ "save-temps", 0, 0, OptionArg.NONE, ref save_temps, "Keep temporary files", null },
		{ "profile", 0, 0, OptionArg.STRING, ref profile, "Use the given profile instead of the default", "PROFILE" },
		{ "quiet", 'q', 0, OptionArg.NONE, ref quiet_mode, "Do not print messages to the console", null },
		{ "verbose", 'v', 0, OptionArg.NONE, ref verbose_mode, "Print additional messages to the console", null },
		{ "no-color", 0, 0, OptionArg.NONE, ref disable_colored_output, "Disable colored output, alias for --color=never", null },
		{ "target-glib", 0, 0, OptionArg.STRING, ref target_glib, "Target version of glib for code generation", "MAJOR.MINOR" },
		{ "gresources", 0, 0, OptionArg.STRING_ARRAY, ref gresources, "XML of gresources", "FILE..." },
		{ "enable-version-header", 0, 0, OptionArg.NONE, ref enable_version_header, "Write vala build version in generated files", null },
		{ "disable-version-header", 0, 0, OptionArg.NONE, ref disable_version_header, "Do not write vala build version in generated files", null },
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref sources, null, "FILE..." },
		{ null }
	};


	static int main (string[] args) {
		try {
			var opt_context = new OptionContext ("- ValaC2");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		} catch (OptionError e) {
			stdout.printf ("error: %s\n", e.message);
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 0;
		}

		if (version) {
			stdout.printf ("ValaC2 Beta 0.0.2\n");
			return 0;
		}

		if (builddir == null) {
			stderr.printf ("In tree build not allowed.\n");
			return 1;
		}

		if (plugin == null) {
			stderr.printf ("Build plugin required.\n");
			return 1;
		}

		if (sources == null && fast_vapis == null) {
			stderr.printf ("No source file specified.\n");
			return 1;
		} 
		if (cc_command == null) {
			stderr.printf("no compiler specified");
			return 1;
		}
		build();
		/** Ok, call the back end  */
		var s1 = spawn(@"cp -rf src $(builddir)");
		var s2 = spawn(@"$(plugin)/pre");
		var s3 = spawn(@"$(plugin)/proc \"$(uriEncode(sb_valac.str))\"");
		var s4 = spawn(@"$(plugin)/post");
		var s5 = spawn(@"$(plugin)/proc \"$(uriEncode(sb_cc.str))\"");
		stdout.printf("Ok!");
		return 0;
	}

	/** mangle the flags so they pass thru unchanged  */
	static void build() {
		sb_valac = new StringBuilder("/usr/bin/valac ");
		sb_cc = new StringBuilder(@"$(cc_command) ");

		sb_valac.append("-C ");
		//sb_valac.append("--save-temps ");

		if (quiet_mode) sb_valac.append("--quiet ");
		if (verbose_mode) sb_valac.append("--verbose ");
		if (vapi_comments) sb_valac.append("--vapi-comments ");
		if (compile_only) sb_valac.append("--compile-only ");
		if (api_version) sb_valac.append("--api-version ");
		if (use_header) sb_valac.append("--use-header ");
		if (debug) sb_valac.append("--debug ");
		if (thread) sb_valac.append("--thread ");
		if (mem_profiler) sb_valac.append("--enable-mem-profiler ");
		if (disable_assert) sb_valac.append("--disable-assert ");
		if (enable_checking) sb_valac.append("--enable-checking ");
		if (deprecated) sb_valac.append("--enable-deprecated ");
		if (hide_internal) sb_valac.append("--hide-internal ");
		if (experimental) sb_valac.append("--enable-experimental ");
		if (experimental_non_null) sb_valac.append("--enable-experimental-non-null ");
		if (gobject_tracing) sb_valac.append("--enable-gobject-tracing ");
		if (disable_since_check) sb_valac.append("--disable-since-check ");
		//  if (disable_warnings) sb_valac.append("--disable-warnings ");
		if (nostdpkg) sb_valac.append("--nostdpkg ");
		if (enable_version_header) sb_valac.append("--enable-version-header ");
		if (disable_version_header) sb_valac.append("--disable-version-header ");
		if (fatal_warnings) sb_valac.append("--fatal-warnings ");
		if (disable_colored_output) sb_valac.append("--no-color ");

		if (basedir != null) {
			sb_valac.append("--basedir ");
			sb_valac.append(basedir);
			sb_valac.append(" ");
		}

		if (directory != null) {
			sb_valac.append("--directory ");
			sb_valac.append(directory);
			sb_valac.append(" ");
		}

		if (vapi_directories != null) {
			foreach (var v in vapi_directories) {
				sb_valac.append("--vapidir ");
				sb_valac.append(v);
				sb_valac.append(" ");
			}
		} 
		if (gir_directories != null) {
			foreach (var g in gir_directories) {
				sb_valac.append("--girdir ");
				sb_valac.append(g);
				sb_valac.append(" ");
			}
		}
		if (metadata_directories != null) {
			foreach (var m in metadata_directories) {
				sb_valac.append("--metadatadir ");
				sb_valac.append(m);
				sb_valac.append(" ");
			}
		}
		if (vapi_filename != null) {
			sb_valac.append("--vapi ");
			sb_valac.append(vapi_filename);
			sb_valac.append(" ");
		}

		if (library != null) {
			sb_valac.append("--library ");
			sb_valac.append(library);
			sb_valac.append(" ");
		}
		if (shared_library != null) {
			sb_valac.append("--shared-library ");
			sb_valac.append(shared_library);
			sb_valac.append(" ");
		}
		if (gir != null) {
			sb_valac.append("--gir ");
			sb_valac.append(gir);
			sb_valac.append(" ");
		}
		if (fast_vapis != null) {
			foreach (var f in fast_vapis) {
				sb_valac.append("--fast-vapi ");
				sb_valac.append(f);
				sb_valac.append(" ");
			}
		}
		if (target_glib != null) {
			sb_valac.append("--target-glib ");
			sb_valac.append(target_glib);
			sb_valac.append(" ");
		}
		if (gresources != null) {
			foreach (var g in gresources) {
				sb_valac.append("--gresources ");
				sb_valac.append(g);
				sb_valac.append(" ");
			}
		}
		if (header_filename != null) {
			sb_valac.append("--header-filename ");
			sb_valac.append(header_filename);
			sb_valac.append(" ");
		}
		if (internal_header_filename != null) {
			sb_valac.append("--internal-header ");
			sb_valac.append(internal_header_filename);
			sb_valac.append(" ");
		}
		if (internal_vapi_filename != null) {
			sb_valac.append("--internal-vapi ");
			sb_valac.append(internal_vapi_filename);
			sb_valac.append(" ");
		}
		if (fast_vapi_filename != null) {
			sb_valac.append("--fast-vapi ");
			sb_valac.append(fast_vapi_filename);
			sb_valac.append(" ");
		}
		if (symbocmd_filename != null) {
			sb_valac.append("--symbols ");
			sb_valac.append(symbocmd_filename);
			sb_valac.append(" ");
		}
		if (includedir != null) {
			sb_valac.append("--includedir ");
			sb_valac.append(includedir);
			sb_valac.append(" ");
		}
		if (pkg_config_command != null) {
			sb_valac.append("--pkg-config ");
			sb_valac.append(pkg_config_command);
			sb_valac.append(" ");
		}
		if (dump_tree != null) {
			sb_valac.append("--dump-tree ");
			sb_valac.append(dump_tree);
			sb_valac.append(" ");
		}
		if (defines != null) {
			foreach (var d in defines) {
				sb_valac.append("--define ");
				sb_valac.append(d);
				sb_valac.append(" ");
			}
		}
		if (profile != null) {
			sb_valac.append("--profile ");
			sb_valac.append(profile);
			sb_valac.append(" ");
		}

		if (packages != null) {
			foreach (var p in packages) {
				sb_valac.append("--pkg ");
				sb_valac.append(p);
				sb_valac.append(" ");
				switch (p) {
					case "sdl2":
						sb_cc.append("-s USE_SDL=2 " );
						break;
					case "SDL2_image":
						sb_cc.append("-s USE_SDL_IMAGE=2 ");
						sb_cc.append("-s SDL2_IMAGE_FORMATS='[\"png\"]' ");
						break;
					case "SDL2_ttf":
						sb_cc.append("-s USE_SDL_TTF=2 ");
						break;

                    case "emscripten":
                        sb_cc.append("-s WASM=1 ");
                        sb_cc.append("-s ASSERTIONS=1 ");
                        sb_cc.append("-s EXPORTED_FUNCTIONS='[\"_game\"]' ");
                        sb_cc.append("--preload-file assets ");
						break;
				}
			}
		}
		if (output != null) {
			sb_cc.append("-o ");
			sb_cc.append(output);
			sb_cc.append(" ");
		}
		if (cc_options != null) {
			foreach (var o in cc_options) {
				sb_cc.append(o);
				sb_cc.append(" ");
			}
		}
		foreach (var s in sources) {
			sb_valac.append(s);
			sb_valac.append(" ");

			s = s.replace(".vala", ".c");
			s = s.replace(".gs", ".c");

			sb_cc.append(s);
			sb_cc.append(" ");
		}

	}

	static bool spawn(string cmd) {
		
		bool result = false;

		try {
			string[] spawn_args = cmd.split(" "); 
			string[] spawn_env = Environ.get();
			string cmd_stdout;
			string cmd_stderr;
			int cmd_status;

			Process.spawn_sync(null, 
								spawn_args,
								spawn_env,
								SpawnFlags.SEARCH_PATH,
								null,
								out cmd_stdout,
								out cmd_stderr,
								out cmd_status);

			stdout.puts(cmd_stdout);
			stdout.puts(cmd_stderr);
			result = cmd_status == 0;

		} catch (SpawnError e) {
			stdout.printf("Error: %s\n", e.message);
		}
		return result;
		
	}


	static string uriEncode(string str) {
		//  SPACE  %20
		//  SLASH  %2F
		//  HYPHEN %2D
		//  DQUOTE %22
		//	SQUOTE %27
		string s1 = str;

		while (s1.index_of(" ") >= 0) s1 = s1.replace(" ", "%20");
		while (s1.index_of("\"") >= 0) s1 = s1.replace("\"", "%22");
		while (s1.index_of("-") >= 0) s1 = s1.replace("-", "%2D");
		while (s1.index_of("'") >= 0) s1 = s1.replace("'", "%27");
		while (s1.index_of("/") >= 0) s1 = s1.replace("/", "%2F");
		
		return s1;
	}
}