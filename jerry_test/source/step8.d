module step8;

import std.stdio;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import jerryscript_port;
import handler;

import util;

void RunStep8()
{
    /**
     *  Step 8. Changing the seed of pseudorandom generated numbers
     */
    writeln("\nStep 8. Changing the seed of pseudorandom generated numbers");

    /* Initialize srand value */
    /* IT'S NOT WORK!!! */
    stdlib : srand (cast(uint) jerry_port_get_current_time ());

    /* Generate a random number, and print it */
    const string script = "var a = Math.random (); print(a)";
    size_t script_size = script.length;

    /* Initialize the engine */
    jerry_init (jerry_init_flag_t.JERRY_INIT_EMPTY);

    /* Register the print function */
    jerryx_handler_register_global (cast(ubyte*)"print", &jerryx_handler_print);

    /* Evaluate the script */
    jerry_value_t eval_ret = jerry_eval (cast(ubyte*)script.ptr, script_size, false);

    /* Free the JavaScript value returned by eval */
    jerry_release_value (eval_ret);

    /* Cleanup the engine */
    jerry_cleanup ();
}

