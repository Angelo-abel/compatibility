# Compatibility

This library provides an advanced `target_compile_features()` and `write_compiler_detection_header()`.
The problem with those is that they are controlled via a CMake internal database, which has to be kept manually up-to-date.
This version uses `check_cxx_source_compiles()` instead and is such automatically up-to-date - a compiler supports a feature,
if the test code compiles.

Based on the test results, a header file is generated that stores the result and often workaround code,
for example a `CONSTEXPR` macro that is `constexpr`, if supported, and `const` otherwise,
to use the features anyway.

It also provides the automatic standard deduction from `target_compile_features()` to activate the right standard.

## Example

If you only want the C++ standard activation, simply `include()` `comp_base.cmake` and replace `target_compile_features()` by `comp_compile_features()`.

This is a `CMakeLists.txt` for a more advanced usage:
```
# suppose we have a target 'tgt'
include(your/dir/to/comp_base.cmake) # only file you need to download, rest is taken as needed

# we want constexpr, noexcept, std::max_align_t and rtti_support
# instead of cpp11_lang/constexpr and cpp11_lang/noexcept, you could also write cxx_constexpr/cxx_noexcept
comp_target_features(tgt PUBLIC cpp11_lang/constexpr cpp11_lang/noexcept cpp11_lib/max_align_t env/rtti_support)
```

Then we define a header, let's name it `config.hpp`:

```cpp
#ifndef CONFIG_HPP
#define CONFIG_HPP

#include <cstddef> // required!

#define COMP_IN_PARENT_HEADER // headers can only be included when this is defined
#include <comp/constexpr.hpp>
#include <comp/noexcept.hpp>
#include <comp/max_align_t.hpp>
#include <comp/rtti_support.hpp>
#undef COMP_IN_PARENT_HEADER // undefine it, to prevent accidentally including them elsewhere

#endif
```

And then we can use it just by including `config.hpp` in our code:

```cpp
#include "config.hpp"

// use a workaround macro
COMP_CONSTEXPR int i = 0;

void func() COMP_NOEXCEPT
{
    // use a workaround typedef
    comp::max_align_t foo;
    
    // or conditional compilation
#if COMP_HAS_RTTI_SUPPORT
    do_sth();
#endif
}
```

If you don't care about the workarounds, but just want C++11 or 14, simply call:
```
comp_target_features(tgt PUBLIC CPP11) # or CPP14
```
This will only activate C++11/14 without doing anything else.

## Usage

The only file needed is `comp_base.cmake`.
You can either manually download it, use CMakes `file(DOWNLOAD` facility,
or use git submodules.
The branch `git-submodule` only contains `comp_base.cmake` and is thus perfect for this purpose.
Run `git submodule add -b "git-submodule" https://github.com/foonathan/compatibility.git` to initialize it and fetch the file.
Then you only need to run `git submodule update --remote` to update it to the newest version.

You only need to download `comp_base.cmake` and `include()` it in your `CMakeLists.txt`.
It generates CMake options - `COMP_CPP11_FLAG` and `COMP_CPP14_FLAG` - storing the calculated compiler flag for a given standard,
useful if you want to override it, if it can't find one for your compiler,
it also provides the following function:

    comp_target_features(<target> <PRIVATE|PUBLIC|INTERFACE> <features...>
                         [NOPREFIX] [PREFIX <prefix] [NAMESPACE <namespace>]
                         [CMAKE_PATH <path>] [INCLUDE_PATH <include_path>]
                         [CPP11] [CPP14])

Ignoring all the other options, it is similar like `target_compile_features()`.
It takes a list of features to activate for a certain target.
A features is a file in this repository without the `.cmake` extension, i.e. `cpp11_lang` for all C++11 language features,
or `cpp14_lang/deprecated` for the C++14 deprecated features.

A feature file with name `dir/xxx.cmake` belonging to a feature `dir/xxx` consists of the following:

* a test testing whether or not the compiler supports this feature

* a CMake option with name `COMP_HAS_XXX` to override its result, useful if you want to act like it doesn't support a feature,
or if the test is poorly written (please contact me in this case!)

* generation of a header named `comp/xxx.hpp`.
It contains at least a macro `<PREFIX>HAS_XXX` with the same value as the CMake option
and often workaround macros or functions that can be used instead of the feature.

If you want a C++11 feature, it also activates C++11 for your target, likewise for C++14.
Note that this activation is `PRIVATE` to allow users of a library to have a different standard than the library itself.

To use the generated header files, it is recommended to create a single header,
which includes `cstddef` (important!), followed by all the other headers.
To prevent accidentally including the generated headers somewhere else,
they can only be included if the macro `COMP_IN_PARENT_HEADER` is defined,
so define it prior the first `#include` and undefine it afterwards.

What `comp_target_features` function actually does is the following:

* For each feature, it downloads the latest version of the test file from Github, if it doesn't exist yet.

* For each feature, it calls `include(feature.cmake)`. This runs the test and generates the header file.

* It calls `target_include_directories` to allow including the generated header files.
The `INTERFACE/PUBLIC/PRIVATE` specifier are only used in this call.

* If any feature requires C++11, it activates C++11 for the target. Likewise for C++14.

This behavior can be customized with the other options:

* `NOPREFIX`/`PREFIX`: The prefix of any generated macros or none if `NOPREFIX` is set. Default is `COMP_`.

* `NAMESPACE`: The namespace name of any generated code, default is `comp`.

* `CMAKE_PATH`/`INCLUDE_PATH`: The download destination for the CMake files/the destination of the generated headers,
default is `${CMAKE_CURRENT_BINARY_DIR}` for both.
`INCLUDE_PATH` is also given to `target_include_directories()`, but note that the generated headers are in a subfolder `comp`.

* `CPP11`/`CPP14`: Override for the standard detection, if you want to have a newer standard than deduced from the features,
or a lower (not recommended). They have priority over the deduction, C++14 over C++11.

## Feature Reference

A feature named `xxx` is tested in `xxx.cmake`, defines an override CMake option `COMP_HAS_XXX` and a macro `{PREFIX}HAS_XXX` in a file named `comp/xxx.hpp`.

For some features, macros are generated that can be used instead (i.e. for `noexcept`), they have the form `{PREFIX}XXX`.
Those macros often use compiler extensions.
If there is none (or a lacking implementation...), an error message will be emmitted.
To prevent this, simply define the macro as no-op or as you want prior to including the file.

Prefix and namespace name can be controlled via parameters, see above.

This library currently tests for the following features.
The code below assumes no prefix and a namespace name of `comp`.

### C++11 language features:

These features are all in the subdirectory `cpp11_lang`.

feature name|alternative name|example|workaround, if any
------------|----------------|-------|------------------
alias_template|cxx_alias_templas|`template <typename T> using my_map = std::map<int, T>;`|no workaround
alignas|cxx_alignas|`alignas(int) char c`|`ALIGNAS(x)`, fallback to compiler extension, if available
alignof|cxx_alignof|`alignof(int)`|`ALIGNOF(x)`, fallback to compiler extension, if available
constexpr|cxx_constexpr|`constexpr int foo()`|`CONSTEXPR`, fallback to `const`; `CONSTEXPR_FNC`, fallback to `inline`
decltype|cxx_decltype|`decltype(a)`|`DECLTYPE(x)`, fallback to `typeof` extension, if available
delete_fnc|cxx_deleted_functions|`void foo() = delete;`|no workaround
explicit_conversion_op|cxx_explicit_conversion|`explicit operator bool()`|no workaround
final|cxx_final|`void bar() final;`|no workaround
literal_op|cxx_user_literals|`operator""`|no workaround
noexcept|cxx_noexcept|`void foo() noexcept;`|`NOEXCEPT`, fallback to nothing; `NOEXCEPT_OP(x)`, fallback to `false`
noreturn|none|`[[noreturn]] void foo();`|`NORETURN`, fallback to compiler extension, if available
nullptr|cxx_nullptr|`void* ptr = nullptr;`|`NULLPTR`, fallback to [null pointer idiom](https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/nullptr); also `comp::nullptr_t`
override|cxx_override|`void bar() override;`|`OVERRIDE`, fallback to nothing
rvalue_ref|cxx_rvalue_references|`int&& a = 4;`|no workaround
static_assert|cxx_static_assert|`static_assert(std::is_integral<T>::value, "");`|`STATIC_ASSERT(Expr, Msg)`, fallback to simple undefined struct technique
thread_local|cxx_thread_local|`thread_local int i;`|`THREAD_LOCAL`, fallback to `__thread` extension or similar, if available - **does not call constructors or destructors!**

Get them all by specifying `cpp11_lang`..

### C++11 library features:

These features are all in the subdirectory `cpp11_lib`.

feature name|example|workaround, if any
------------|-------|------------------
get_new_handler|`std::get_new_handler()`|`comp::get_new_handler()`, fallback to old `std::set_new_handler(nullptr)` technique - **not thread safe**
get_terminate|`std::get_terminate()`|`comp::get_terminate()`, same as above
max_align_t|`std::max_align_t`|`comp::max_align_t`, fallback to `::max_align_t` or a struct with a `long double` and `long long`
to_string|`std::to_string(54)`|`comp::to_string()`, fallback to `std::sprintf()`

Get them all by specifying `cpp11_lib`.

### C++14 language features:

These features are all in the subdirectory `cpp14_lang`.

feature name|alternative name|example|workaround, if any
------------|----------------|-------|------------------
deprecated|cxx_attribute_deprecated|`[[deprecated]] int foo();`|`DEPRECATED` and `DEPRECATED(Msg)`, fallback to compiler attribute, if available
general_constexpr|cxx_relaxed_constexpr|generalized constexpr|no workaround
variable_template|cxx_variable_templates|`template <typename T> T pi;`|no workaround

Get them all by specifying `cpp14_lang`.

### C++14 library features:

These features are all in the subdirectory `cpp14_lib`.

feature name|example|workaround, if any
------------|-------|------------------
make_unique|`std::make_unique()`|`comp::make_unique`, own implementation

Get them all by specifying `cpp14_lib`.

### Environment

Features regarding the general environment. These features are all in the subdirectory `env`.
Note: These checks here aren't that great, it is recommended to set option explicitly.

feature name|description|workaround, if any
------------|-------|------------------
exception_support|support for exception handling|`THROW(Ex)`, `RETHROW_EX`, fallback to `std::abort()`; `TRY`, fallback to `if (true)`, CATCH_ALL, fallback to `if (false)`
hosted_implementation|freestanding vs hosted|no workaround, but alias macro `HOSTED_IMPLEMENTATION`, since `HAS_HOSTED_IMPLEMENTATION` doesn't sound nice
rtti_support|support for RTTI|`comp::polymorhpic_cast`, fallback to `static_cast`
threading_support|support for threading|no workaround

Get them all by specifying `env`.

### Common extensions

These features are all in the subdirectory `ext`.

feature name|example|workaround, if any
------------|-------|------------------
counter|`__COUNTER__`|no workaround
pretty_function|`__PRETTY_FUNCTION__`|`PRETTY_FUNCTION`, fallback to `__FUNCSIG__` on MSVC

Get them all by specifying `ext.cmake`.

## Pull-Requests.

As you probably noted, there are *many* features missing.
I wrote this library in a few hours and concentrated on the most important features for me.
If you want to extend it or improve a workaround, please don't hesitate to fork and PR
(or just write an issue and let me take care of it, when I have time, if you're lazy).

To write a new feature check, just create a new file in the appropriate subdirectory.
You only need to call two CMake function defined in `comp_base.cmake`:

1. `comp_check_feature` - It takes three parameters. The first is a minimal test code that uses this feature.
It is recommended to avoid using multiple features (i.e. avoid `auto`, `nullptr` and the like).
The second parameter is the name of the feature, this should follow my naming convention.
The third is a list of required compiler flags, use the variables `${cpp11_flag}` or `${cpp14_flag}` for that or simply `""`.
Based on the flags the language standard for a feature is also determined.

2. `comp_gen_header` - It takes two parameters. The first is the name of the feature, must be the same as above.
The second is code that will be appended to the file. It is used for workarounds.
If you define macros, wrap them in an `#ifndef ... #endif` and use `${COMP_PREFIX}` as prefix.
If you define anything else, do it inside namespace `${COMP_NAMESPACE}` or a sub namespace.

Note: Do **not** include `comp_base.cmake!`.
Look at a few other files for example implementations.
