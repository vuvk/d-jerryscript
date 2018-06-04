module step0;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

void RunStep0()
{
	/**
	 * Step 0. Check Features
	 */
	writeln("Enabled features:");
	immutable string[] featuresNames = [
		"JERRY_FEATURE_CPOINTER_32_BIT", 	/**< 32 bit compressed pointers */
		"JERRY_FEATURE_ERROR_MESSAGES ", 	/**< error messages */
		"JERRY_FEATURE_JS_PARSER      ", 	/**< js-parser */
		"JERRY_FEATURE_MEM_STATS      ", 	/**< memory statistics */
		"JERRY_FEATURE_PARSER_DUMP    ", 	/**< parser byte-code dumps */
		"JERRY_FEATURE_REGEXP_DUMP    ", 	/**< regexp byte-code dumps */
		"JERRY_FEATURE_SNAPSHOT_SAVE  ", 	/**< saving snapshot files */
		"JERRY_FEATURE_SNAPSHOT_EXEC  ", 	/**< executing snapshot files */
		"JERRY_FEATURE_DEBUGGER       ", 	/**< debugging */
		"JERRY_FEATURE_VM_EXEC_STOP   ", 	/**< stopping ECMAScript execution */
		"JERRY_FEATURE_JSON           ", 	/**< JSON support */
		"JERRY_FEATURE_PROMISE        ", 	/**< promise support */
		"JERRY_FEATURE_TYPEDARRAY     ", 	/**< Typedarray support */
		"JERRY_FEATURE_DATE           ", 	/**< Date support */
		"JERRY_FEATURE_REGEXP         ", 	/**< Regexp support */
		"JERRY_FEATURE_LINE_INFO      " 	/**< line info available */
	];
	for (int i = 0; i < featuresNames.length; ++i)
	{
        write(featuresNames[i] ~ '\t');
        (jerry_is_feature_enabled(cast(jerry_feature_t)i))  ?
            writeln ("enabled")                             :
            writeln ("not enabled");
	}
}
