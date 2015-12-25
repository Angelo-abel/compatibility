# Copyright (C) 2015 Jonathan Müller <jonathanmueller.dev@gmail.com>
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

if(NOT COMP_API_VERSION)
    message(FATAL_ERROR "needs newer comp_base.cmake version")
endif()
comp_api_version(1)

comp_feature(generic_operator_functors
        "#include <functional>
        int main()
        {
            bool val = std::greater<>{}(4, 5);
        }" COMP_CPP14_FLAG)
comp_workaround(generic_operator_functors
"#include <utility>

namespace ${COMP_NAMESPACE}
{
    #define ${COMP_PREFIX}DETAIL_AUTO_RETURN(x) decltype(x) {return x;}

    // only the generic version

    struct plus
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) + std::forward<U>(u))
    };

    struct minus
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) - std::forward<U>(u))
    };

    struct multiplies
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) * std::forward<U>(u))
    };

    struct divides
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) / std::forward<U>(u))
    };

    struct modulus
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) % std::forward<U>(u))
    };

    struct negate
    {
        typedef void is_transparent;

        template <typename T>
        auto operator()(T&& t) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(-std::forward<T>(t))
    };

    struct equal_to
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) == std::forward<U>(u))
    };

    struct not_equal_to
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) != std::forward<U>(u))
    };

    struct greater
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) > std::forward<U>(u))
    };

    struct greater_equal
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) >= std::forward<U>(u))
    };

    struct less
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) < std::forward<U>(u))
    };

    struct less_equal
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) <= std::forward<U>(u))
    };

    struct logical_and
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) && std::forward<U>(u))
    };

    struct logical_or
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) || std::forward<U>(u))
    };

    struct logical_not
    {
        typedef void is_transparent;

        template <typename T>
        auto operator()(T&& t) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(!std::forward<T>(t))
    };

    struct bit_and
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) & std::forward<U>(u))
    };

    struct bit_or
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) | std::forward<U>(u))
    };

    struct bit_xor
    {
        typedef void is_transparent;

        template <typename T, typename U>
        auto operator()(T&& t, U &&u) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(std::forward<T>(t) ^ std::forward<U>(u))
    };

    struct bit_not
    {
        typedef void is_transparent;

        template <typename T>
        auto operator()(T&& t) const
        -> ${COMP_PREFIX}DETAIL_AUTO_RETURN(~std::forward<T>(t))
    };

    #undef ${COMP_PREFIX}DETAIL_AUTO_RETURN
}")
