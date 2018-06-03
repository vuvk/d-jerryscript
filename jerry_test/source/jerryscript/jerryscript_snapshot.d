/* Copyright JS Foundation and other contributors, http://js.foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
module jerry_snapshot;

import jerryscript_core;
import jerryscript_port;

extern (C):

/* __cplusplus */

/** \addtogroup jerry-snapshot Jerry engine interface - Snapshot feature
 * @{
 */

/**
 * Flags for jerry_generate_snapshot and jerry_generate_function_snapshot.
 */
enum jerry_generate_snapshot_opts_t
{
    JERRY_SNAPSHOT_SAVE_STATIC = 1u << 0, /**< static snapshot */
    JERRY_SNAPSHOT_SAVE_STRICT = 1u << 1 /**< strict mode code */
}

/**
 * Flags for jerry_exec_snapshot_at and jerry_load_function_snapshot_at.
 */
enum jerry_exec_snapshot_opts_t
{
    JERRY_SNAPSHOT_EXEC_COPY_DATA = 1u << 0, /**< copy snashot data */
    JERRY_SNAPSHOT_EXEC_ALLOW_STATIC = 1u << 1 /**< static snapshots allowed */
}

/**
 * Snapshot functions.
 */
jerry_value_t jerry_generate_snapshot (
    const(jerry_char_t)* resource_name_p,
    size_t resource_name_length,
    const(jerry_char_t)* source_p,
    size_t source_size,
    uint generate_snapshot_opts,
    uint* buffer_p,
    size_t buffer_size);
jerry_value_t jerry_generate_function_snapshot (
    const(jerry_char_t)* resource_name_p,
    size_t resource_name_length,
    const(jerry_char_t)* source_p,
    size_t source_size,
    const(jerry_char_t)* args_p,
    size_t args_size,
    uint generate_snapshot_opts,
    uint* buffer_p,
    size_t buffer_size);

jerry_value_t jerry_exec_snapshot (
    const(uint)* snapshot_p,
    size_t snapshot_size,
    size_t func_index,
    uint exec_snapshot_opts);
jerry_value_t jerry_load_function_snapshot (
    const(uint)* function_snapshot_p,
    const size_t function_snapshot_size,
    size_t func_index,
    uint exec_snapshot_opts);

size_t jerry_merge_snapshots (
    const(uint*)* inp_buffers_p,
    size_t* inp_buffer_sizes_p,
    size_t number_of_snapshots,
    uint* out_buffer_p,
    size_t out_buffer_size,
    const(char*)* error_p);
size_t jerry_parse_and_save_literals (
    const(jerry_char_t)* source_p,
    size_t source_size,
    bool is_strict,
    uint* buffer_p,
    size_t buffer_size,
    bool is_c_format);
/**
 * @}
 */

/* __cplusplus */
/* !JERRYSCRIPT_SNAPSHOT_H */
