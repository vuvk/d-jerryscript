module step6;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

import util;


extern (C)
{
    struct my_struct
    {
        string msg;
    }

    my_struct myStruct;

    /**
    * Get a string from a native object
    */
    jerry_value_t
    get_msg_handler (const jerry_value_t func_value, /**< function object */
                     const jerry_value_t this_value, /**< this arg */
                     const jerry_value_t* args_p, /**< function arguments */
                     const jerry_length_t args_cnt) /**< number of function arguments */
    {
        return jerry_create_string (cast(const jerry_char_t*)(myStruct.msg));
    } /* get_msg_handler */
}

void RunStep6()
{
    /**
     * Step 6. Creating JS object in global context
     */
    writeln ("\nStep 6. Creating JS object in global context");
    /* Initialize engine */
    jerry_init (jerry_init_flag_t.JERRY_INIT_EMPTY);

    /* Register 'print' function from the extensions */
    jerryx_handler_register_global (cast(const jerry_char_t*)"print", &jerryx_handler_print);

    /* Do something with the native object */
    myStruct.msg = "Hello, World!";

    /* Create an empty JS object */
    jerry_value_t object = jerry_create_object ();

    /* Create a JS function object and wrap into a jerry value */
    jerry_value_t func_obj = jerry_create_external_function (&get_msg_handler);

    /* Set the native function as a property of the empty JS object */
    jerry_value_t prop_name = jerry_create_string (cast(const jerry_char_t*)"myFunc");
    jerry_set_property (object, prop_name, func_obj);
    jerry_release_value (prop_name);
    jerry_release_value (func_obj);

    /* Wrap the JS object (not empty anymore) into a jerry api value */
    jerry_value_t global_object = jerry_get_global_object ();

    /* Add the JS object to the global context */
    prop_name = jerry_create_string (cast(const jerry_char_t*)"MyObject");
    jerry_set_property (global_object, prop_name, object);
    jerry_release_value (prop_name);
    jerry_release_value (object);
    jerry_release_value (global_object);

    /* Now we have a "builtin" object called MyObject with a function called myFunc()
     *
     * Equivalent JS code:
     *                    var MyObject = { myFunc : function () { return "some string value"; } }
     */
    string script = "
        var str = MyObject.myFunc ();
        print (str);
    ";
    uint script_size = script.length;

    /* Evaluate script */
    jerry_value_t eval_ret = jerry_eval (cast(ubyte*)script.ptr, script_size, false);
    if (jerry_value_is_error(eval_ret))
        print_error(eval_ret);

    /* Free JavaScript value, returned by eval */
    jerry_release_value (eval_ret);

    /* Cleanup engine */
    jerry_cleanup ();
}


