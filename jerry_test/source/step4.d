module step4;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

import util;



void RunStep4()
{
    /**
     * Step 4. Interaction with JavaScript environment
     */
    writeln("\nStep 4. Interaction with JavaScript environment");

    string str = "Hello, World!";
    string script = "print(message);";

    /* Initializing JavaScript environment */
    jerry_init (jerry_init_flag_t.JERRY_INIT_EMPTY);

    /* Register 'print' function from the extensions */
    jerryx_handler_register_global (cast(const jerry_char_t*)"print", &jerryx_handler_print);

    /* Getting pointer to the Global object */
    jerry_value_t global_object = jerry_get_global_object ();

    /* Constructing strings */
    jerry_value_t prop_name = jerry_create_string (cast(const jerry_char_t*)"message".ptr);
    jerry_value_t prop_value = jerry_create_string (cast(ubyte*)str.ptr);

    /* Setting the string value as a property of the Global object */
    jerry_set_property (global_object, prop_name, prop_value);

    /* Releasing string values, as it is no longer necessary outside of engine */
    jerry_release_value (prop_name);
    jerry_release_value (prop_value);

    /* Releasing the Global object */
    jerry_release_value (global_object);

    /* Now starting script that would output value of just initialized field */
    jerry_value_t ret_value = jerry_eval(cast(ubyte*)script.ptr, script.length, 0);
    if (jerry_value_is_error(ret_value))
        print_error(ret_value);

    /* Free JavaScript value, returned by eval */
    jerry_release_value (ret_value);

    /* Freeing engine */
    jerry_cleanup ();
}


