# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(shared_lock "#include <shared_mutex>
                int main()
                {
                    std::shared_timed_mutex m;
                    std::shared_lock<std::shared_timed_mutex> lock(m);
                }" COMP_CPP14_FLAG)
