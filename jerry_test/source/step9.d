module step9;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import jerryscript_port;
import jerry_snapshot;
import handler;

import util;

void RunStep9()
{
	/**
	 *  Step 9. Save and run snapshot
	 */
	writeln("\nStep 9. Save and run snapshot");
	 
	jerry_init (jerry_init_flag_t.JERRY_INIT_EMPTY);
	jerryx_handler_register_global (cast(ubyte*)"print", &jerryx_handler_print);

	uint[256] global_mode_snapshot_buffer;
	const string code_to_snapshot_p = "
		(function () { 
			function sayHello(name) {
				print('Hello, ' + name + '!');
			}
			
			var name = 'World';
			sayHello(name);
			
			return 'Snapshot is executed!'; 
		}) ();";
	
	jerry_value_t generate_result;
	generate_result = jerry_generate_snapshot (null,
												0,
												cast(ubyte*)code_to_snapshot_p.ptr,
												code_to_snapshot_p.length,
												jerry_generate_snapshot_opts_t.JERRY_SNAPSHOT_SAVE_STRICT,
												global_mode_snapshot_buffer.ptr,
												global_mode_snapshot_buffer.length);
	size_t snapshot_size;
	if (!jerry_value_is_error(generate_result))
		snapshot_size = cast(size_t)jerry_get_number_value (generate_result);
	else
		print_error(generate_result);
	jerry_release_value (generate_result);

	jerry_cleanup ();
	
	writeln("Size of code = " ~ to!string(code_to_snapshot_p.length));
	writeln("Size of snapshot = " ~ to!string(snapshot_size));
	writeln("Snapshot: ");
	for (int i = 0; i < snapshot_size / uint.sizeof; ++i)
		writef("%s  ", cast(char*)&global_mode_snapshot_buffer[i]);
	
	
	writeln("\nNow running snapshot");
	jerry_init (jerry_init_flag_t.JERRY_INIT_EMPTY);
	jerryx_handler_register_global (cast(ubyte*)"print", &jerryx_handler_print);

	jerry_value_t res = jerry_exec_snapshot (cast(const uint*)global_mode_snapshot_buffer.ptr,
											 snapshot_size,
											 0,
											 jerry_exec_snapshot_opts_t.JERRY_SNAPSHOT_EXEC_COPY_DATA);
	if (!jerry_value_is_error(res))
		print_value (res);
	else
		print_error(res);
	jerry_release_value (res);

	jerry_cleanup ();
}