module step1;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

void RunStep1()
{
	/**
	 * Step 1. Execute JavaScript from your application
	 */
	writeln("\nStep 1. Execute JavaScript from your application");
	string script = "var str = 'Hello, World!';";
	uint script_size = script.length;
	jerry_value_t ret_value = jerry_run_simple (cast(ubyte*)script.ptr, script_size, jerry_init_flag_t.JERRY_INIT_SHOW_OPCODES);
	writeln("retval = " ~ to!string(ret_value));
}