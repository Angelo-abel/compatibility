# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(noexcept "void foo() noexcept {} int main(){}" COMP_CPP11_FLAG)
comp_workaround(noexcept
"#ifndef ${COMP_PREFIX}NOEXCEPT
    #if ${COMP_PREFIX}HAS_NOEXCEPT
        #define ${COMP_PREFIX}NOEXCEPT noexcept
    #else
        #define ${COMP_PREFIX}NOEXCEPT
    #endif
#endif

#ifndef ${COMP_PREFIX}NOEXCEPT_OP
    #if ${COMP_PREFIX}HAS_NOEXCEPT
        #define ${COMP_PREFIX}NOEXCEPT_OP(x) noexcept(x)
    #else
        #define ${COMP_PREFIX}NOEXCEPT_OP(x) false
    #endif
#endif" COMP_CPP98_FLAG)
