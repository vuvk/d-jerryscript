module util;

import std.stdio;
import std.conv;
import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;

import jerryscript_core;
import jerryscript_port;
import handler;

/** 
 * Step 5. Description of JerryScript value descriptors
 */
void print_value (const jerry_value_t value)
{
  if (jerry_value_is_undefined (value) == 1)
  {
    printf ("undefined");
  }
  else if (jerry_value_is_null (value) == 1)
  {
    printf ("null");
  }
  else if (jerry_value_is_boolean (value) == 1)
  {
    if (jerry_get_boolean_value (value) == 1)
    {
      printf ("true");
    }
    else
    {
      printf ("false");
    }
  }
  /* Float value */
  else if (jerry_value_is_number (value) == 1)
  {
    printf ("number");
  }
  /* String value */
  else if (jerry_value_is_string (value) == 1)
  {
    /* Determining required buffer size */
    jerry_size_t req_sz = jerry_get_string_size (value);
    jerry_char_t* str_buf_p = cast(ubyte*)calloc(jerry_char_t.sizeof, req_sz + 1);

    jerry_string_to_char_buffer (value, str_buf_p, req_sz);
    str_buf_p[req_sz] = '\0';

    printf ("%s", str_buf_p);
	
	free(str_buf_p);
  }
  /* Object reference */
  else if (jerry_value_is_object (value) == 1)
  {
    printf ("[JS object]");
  }

  printf ("\n");
}

/**
 *  Get info from throwable object and print it
 */
void print_error(jerry_value_t value)
{
	/*
	jerry_error_t err_type = jerry_get_error_type(value);
	writefln("error type - %d", err_type);
	*/
	jerry_value_t throwable = jerry_get_value_from_error (value, 0);	
	//print_value(throwable);
	
	if (jerry_value_is_object(throwable))
	{
		jerry_value_t name    = jerry_create_string(cast(jerry_char_t*)"name\0".ptr);
		jerry_value_t message = jerry_create_string(cast(jerry_char_t*)"message\0".ptr);
		jerry_value_t stack   = jerry_create_string(cast(jerry_char_t*)"stack\0".ptr);
		
		jerry_value_t exists;

		// print name
		exists = jerry_has_property (throwable, name);
		if ((jerry_value_is_boolean(exists)) && (jerry_get_boolean_value(exists)))
		{
			jerry_value_t txt = jerry_get_property(throwable, name);
			print_value(txt);
			jerry_release_value (txt);
		}		
		
		// print error message
		exists = jerry_has_property (throwable, message);
		if ((jerry_value_is_boolean(exists)) && (jerry_get_boolean_value(exists)))
		{
			jerry_value_t txt = jerry_get_property(throwable, message);
			print_value(txt);
			jerry_release_value (txt);
		}			
		
		// print backtrace
		exists = jerry_has_property (throwable, stack);
		if ((jerry_value_is_boolean(exists)) && (jerry_get_boolean_value(exists)))
		{
            /*
			jerry_value_t txt = jerry_get_property(throwable, stack);
			print_value(txt);
			jerry_release_value (txt);
            */

            if (!jerry_value_is_error (stack) && jerry_value_is_array (stack))
            {
                writeln ("Exception backtrace:\n");

                uint length = jerry_get_array_length (stack);

                /* This length should be enough. */
                if (length > 32)
                {
                    length = 32;
                }

                for (uint i = 0; i < length; ++i)
                {
                    jerry_value_t item_val = jerry_get_property_by_index (stack, i);

                    if (!jerry_value_is_error (item_val) && jerry_value_is_string (item_val))
                    {
                        jerry_size_t str_size = jerry_get_string_size (item_val);
                        string error_txt;
                        error_txt.length = str_size;

                        if (str_size >= 256)
                        {
                            printf ("%3u: [Backtrace string too long]\n", i);
                        }
                        else
                        {
                            jerry_size_t string_end = jerry_string_to_char_buffer (item_val, cast(ubyte*)error_txt.ptr, str_size);
                            //assert (string_end == str_size);
                            //err_str_buf[string_end] = 0;

                            //printf ("%3u: %s\n", i, err_str_buf.ptr);
                            writeln(error_txt);
                        }
                        //print_value(item_val);
                    }

                    jerry_release_value (item_val);
                }
            }
		}			
		
		jerry_release_value (name);
		jerry_release_value (message);
		jerry_release_value (stack);
		jerry_release_value (exists);		
	}
		
	//jerry_release_value (err_type);
	jerry_release_value (throwable);
}




/**
 * Maximum size of source code
 */
immutable uint JERRY_BUFFER_SIZE = (1048576);

/**
 * Maximum size of snapshots buffer
 */
immutable uint JERRY_SNAPSHOT_BUFFER_SIZE = (JERRY_BUFFER_SIZE / uint.sizeof);

/**
 * Standalone Jerry exit codes
 */
immutable JERRY_STANDALONE_EXIT_CODE_OK   = (0);
immutable JERRY_STANDALONE_EXIT_CODE_FAIL = (1);

/**
 * Context size of the SYNTAX_ERROR
 */
immutable SYNTAX_ERROR_CONTEXT_SIZE = 2;

static ubyte[JERRY_BUFFER_SIZE] buffer;

/**
 * Print error value
 */
void print_unhandled_exception (jerry_value_t error_value) /**< error value */
{
      //assert (!jerry_value_is_error(error_value));
      if (!jerry_value_is_error(error_value))
            return;

      jerry_char_t[256] err_str_buf;

      if (jerry_value_is_object (error_value))
      {
            jerry_value_t stack_str = jerry_create_string (cast(const jerry_char_t*)"stack\0".ptr);
            jerry_value_t backtrace_val = jerry_get_property (error_value, stack_str);
            jerry_release_value (stack_str);

            if (!jerry_value_is_error (backtrace_val) && jerry_value_is_array (backtrace_val))
            {
                  printf ("Exception backtrace:\n");

                  uint length = jerry_get_array_length (backtrace_val);

                  /* This length should be enough. */
                  if (length > 32)
                  {
                        length = 32;
                  }

                  for (uint i = 0; i < length; i++)
                  {
                        jerry_value_t item_val = jerry_get_property_by_index (backtrace_val, i);

                        if (!jerry_value_is_error (item_val) && jerry_value_is_string (item_val))
                        {
                              jerry_size_t str_size = jerry_get_string_size (item_val);

                              if (str_size >= 256)
                              {
									printf ("%3u: [Backtrace string too long]\n", i);
                              }
                              else
                              {
                                    jerry_size_t string_end = jerry_string_to_char_buffer (item_val, err_str_buf.ptr, str_size);
                                    assert (string_end == str_size);
                                    err_str_buf[string_end] = 0;

                                    printf ("%3u: %s\n", i, err_str_buf.ptr);
                              }
                        }

                        jerry_release_value (item_val);
                  }
            }

            jerry_release_value (backtrace_val);
      }

      jerry_value_t err_str_val = jerry_value_to_string (error_value);
      jerry_size_t err_str_size = jerry_get_string_size (err_str_val);

      if (err_str_size >= 256)
      {
            const char[] msg = "[Error message too long]";
            err_str_size = msg.sizeof / char.sizeof - 1;
            memcpy (err_str_buf.ptr, msg.ptr, err_str_size + 1);
      }
      else
      {
            jerry_size_t string_end = jerry_string_to_char_buffer (err_str_val, err_str_buf.ptr, err_str_size);
            assert (string_end == err_str_size);
            err_str_buf[string_end] = 0;

            if (jerry_is_feature_enabled (jerry_feature_t.JERRY_FEATURE_ERROR_MESSAGES) && jerry_get_error_type (error_value) == jerry_error_t.JERRY_ERROR_SYNTAX)
            {
                  uint err_line = 0;
                  uint err_col = 0;

                  /* 1. parse column and line information */
                  for (jerry_size_t i = 0; i < string_end; ++i)
                  {
                        if (!strncmp (cast(char*) &(err_str_buf[i]), "[line: ", 7))
                        {
                              i += 7;

                              char[8] num_str;
                              uint j = 0;

                              while (i < string_end && err_str_buf[i] != ',')
                              {
                                    num_str[j] = cast(char) err_str_buf[i];
                                    ++j;
                                    ++i;
                              }
                              num_str[j] = '\0';

                              err_line = cast(uint) strtol (num_str.ptr, null, 10);

                              if (strncmp (cast(char*) &(err_str_buf[i]), ", column: ", 10))
                              {
                                    break; /* wrong position info format */
                              }

                              i += 10;
                              j = 0;

                              while (i < string_end && err_str_buf[i] != ']')
                              {
                                    num_str[j] = cast(char) err_str_buf[i];
                                    ++j;
                                    ++i;
                              }
                              num_str[j] = '\0';

                              err_col = cast(uint) strtol (num_str.ptr, null, 10);
                              break;
                        }
                  } /* for */

                  if (err_line != 0 && err_col != 0)
                  {
                        uint curr_line = 1;

                        bool is_printing_context = false;
                        uint pos = 0;

                        /* 2. seek and print */
                        while (buffer[pos] != '\0')
                        {
                              if (buffer[pos] == '\n')
                              {
                                    ++curr_line;
                              }

                              if (err_line < SYNTAX_ERROR_CONTEXT_SIZE
                                  || (err_line >= curr_line
                                      && (err_line - curr_line) <= SYNTAX_ERROR_CONTEXT_SIZE))
                              {
                                    /* context must be printed */
                                    is_printing_context = true;
                              }

                              if (curr_line > err_line)
                              {
                                    break;
                              }

                              if (is_printing_context)
                              {
                                    jerry_port_log (jerry_log_level_t.JERRY_LOG_LEVEL_ERROR, "%c", buffer[pos]);
                              }

                              ++pos;
                        }

                        jerry_port_log (jerry_log_level_t.JERRY_LOG_LEVEL_ERROR, "\n");

                        while (--err_col)
                        {
                            jerry_port_log (jerry_log_level_t.JERRY_LOG_LEVEL_ERROR, "~");
                        }

                        jerry_port_log (jerry_log_level_t.JERRY_LOG_LEVEL_ERROR, "^\n");
                  }
            }
      }

      jerry_port_log (jerry_log_level_t.JERRY_LOG_LEVEL_ERROR, "Script Error: %s\n", err_str_buf.ptr);
      jerry_release_value (err_str_val);
} /* print_unhandled_exception */
