module step2;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

import util;

void RunStep2()
{
	/**
	 * Step 2. Split engine initialization and script execution
	 */
    writeln("\nStep 2. Split engine initialization and script execution");
    string script = "printir('Hello, World!');";
    uint script_size = script.length;

    /* Initialize engine */
    jerry_init(jerry_init_flag_t.JERRY_INIT_EMPTY);

    /* Register 'print' function from the extensions */
    jerryx_handler_register_global (cast(ubyte*)("print".ptr), &jerryx_handler_print);

    /* Setup Global scope code */
    jerry_value_t parsed_code = jerry_parse (null, 0, cast(ubyte*)script.ptr, script_size, jerry_parse_opts_t.JERRY_PARSE_STRICT_MODE);
    //writeln(script);
	
    jerry_value_t ret_value;

	if (!jerry_value_is_error(parsed_code))
	{
		/* Execute the parsed source code in the Global scope */
		ret_value = jerry_run (parsed_code);
		writeln("retval = " ~ to!string(ret_value));

		/* Returned value must be freed */
		jerry_release_value (ret_value);
	}
	else
	{
		print_unhandled_exception(parsed_code);
		jerry_release_value (ret_value);
	}

	/* Parsed source code must be freed */
	jerry_release_value (parsed_code);

	/* Cleanup engine */
	jerry_cleanup ();
}
