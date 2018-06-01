module step3;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

import util;

void RunStep3()
{
    /**
     * Step 3. Execution in 'eval'-mode
     */
    writeln("\nStep 3. Execution in 'eval'-mode");
    const string script_1 = "var s = 'Hello, World!';";
    const string script_2 = "tryser {print(s);} catch(e) {print(e.name + ' ' + e.message);}";

    /* Initialize engine */
    jerry_init (jerry_init_flag_t.JERRY_INIT_EMPTY);

    /* Register 'print' function from the extensions */
    jerryx_handler_register_global (cast(const jerry_char_t*)"print", &jerryx_handler_print);
    jerryx_handler_register_global (cast(const jerry_char_t*)"alert", &jerryx_handler_print);

    /* Evaluate script1 */
    jerry_value_t ret_value = jerry_eval (cast(ubyte*)script_1.ptr, script_1.length, 0);
    if (jerry_value_is_error(ret_value))
        print_error(ret_value);

    /* Free JavaScript value, returned by eval */
    jerry_release_value (ret_value);

    /* Evaluate script2 */
    ret_value = jerry_eval (cast(ubyte*)script_2.ptr, script_2.length, 0);
    if (jerry_value_is_error(ret_value))
        print_error(ret_value);

    /* Free JavaScript value, returned by eval */
    jerry_release_value (ret_value);

    /* Cleanup engine */
    jerry_cleanup ();
}
