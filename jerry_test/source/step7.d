module step7;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;

import jerryscript_core;
import handler;

import util;


/**
 * Add param to 'this.x'
 */
extern (C) static jerry_value_t
add_handler (const jerry_value_t func_value, /**< function object */
             const jerry_value_t this_val, /**< this arg */
             const jerry_value_t *args_p, /**< function arguments */
             const jerry_length_t args_cnt) /**< number of function arguments */
{
    /* Get 'this.x' */
    jerry_value_t prop_name = jerry_create_string (cast(const jerry_char_t*)"x");
    jerry_value_t x_val = jerry_get_property (this_val, prop_name);

    if (!jerry_value_is_error (x_val))
    {
        /* Convert Jerry API values to double */
        double x = jerry_get_number_value (x_val);
        double d = jerry_get_number_value (*args_p);

        /* Add the parameter to 'x' */
        jerry_value_t res_val = jerry_create_number (x + d);

        /* Set the new value of 'this.x' */
        jerry_set_property (this_val, prop_name, res_val);
        jerry_release_value (res_val);
    }

    jerry_release_value (x_val);
    jerry_release_value (prop_name);

    return jerry_create_undefined ();
} /* add_handler */


void RunStep7()
{
    /**
     *  Step 7. Extending JS Objects with native functions
     */
    writeln("\nStep 7. Extending JS Objects with native functions");
  
    /* Initialize engine */
    jerry_init (jerry_init_flag_t.JERRY_INIT_EMPTY);

    /* Register 'print' function from the extensions */
    jerryx_handler_register_global (cast(const jerry_char_t*) "print", &jerryx_handler_print);

    /* Create a JS object */
    const string my_js_object = "
	    MyObject =
        {
            x : 12,
            y : 'Value of x is ',
            foo: function ()  {
                return this.y + this.x;
            }
        }
    ";

    jerry_value_t my_js_obj_val;

    /* Evaluate script */
    my_js_obj_val = jerry_eval (cast(ubyte*)my_js_object.ptr, my_js_object.length, false);

    /* Create a JS function object and wrap into a jerry value */
    jerry_value_t add_func_obj = jerry_create_external_function (&add_handler);

    /* Set the native function as a property of previously created MyObject */
    jerry_value_t prop_name = jerry_create_string (cast(const jerry_char_t*) "add2x");
    jerry_set_property (my_js_obj_val, prop_name, add_func_obj);
    jerry_release_value (add_func_obj);
    jerry_release_value (prop_name);

    /* Free JavaScript value, returned by eval (my_js_object) */
    jerry_release_value (my_js_obj_val);

    const string script = "
        var str = MyObject.foo ();
        print (str);
        MyObject.add2x (5);
        print (MyObject.foo ());
	";
    size_t script_size = script.length;

    /* Evaluate script */
    jerry_value_t eval_ret = jerry_eval (cast(ubyte*)script.ptr, script_size, false);

    /* Free JavaScript value, returned by eval */
    jerry_release_value (eval_ret);

    /* Cleanup engine */
    jerry_cleanup ();
}
