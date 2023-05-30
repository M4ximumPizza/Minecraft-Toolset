/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#ifndef MC-Toolkit_NBT_HPP
#define MC-Toolkit_NBT_HPP

#include <variant>
#include <string_view>

namespace MC-Toolkit {

enum struct nbt_type: int {
    END = 0,
    BYTE = 1,
    SHORT = 2,
    INT = 3,
    LONG = 4,
    FLOAT = 5,
    DOUBLE = 6,
    BYTE_ARRAY = 7,
    STRING = 8,
    LIST = 9,
    COMPOUND = 10,
    INT_ARRAY = 11,
    LONG_ARRAY = 12
};

struct nbt_byte_array_t {
    int32_t size;
    int8_t *data;
};

struct nbt_int_array_t {
    int32_t size;
    int32_t *data;
};

struct nbt_long_array_t {
    int32_t size;
    int64_t *data;
};

struct nbt_string_t {
    int16_t size;
    char *data;
};

struct nbt_compound_t {

};

struct nbt_end_t {

};

struct nbt_list_t {
    int32_t size;
    nbt_type type;
};

struct nbt_list_end_t {

};


struct nbt_t {
    using payload_t = std::variant<std::monostate,
        int8_t,int16_t,int32_t,int64_t,
        float,double,
        nbt_byte_array_t, nbt_int_array_t, nbt_long_array_t,
        nbt_string_t,
        nbt_compound_t,
        nbt_end_t,
        nbt_list_t,
        nbt_list_end_t
        >;

    template<typename Arg>
    nbt_t(std::string_view n, Arg&& arg) : name{n}, payload{std::forward<Arg>(arg)} {}

    std::string_view name;
    payload_t payload;
};

}

#endif