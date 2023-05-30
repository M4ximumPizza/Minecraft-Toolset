/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */
#ifndef MC-Toolkit_PERENC_HPP
#define MC-Toolkit_PERENC_HPP

#include <algorithm>
#include <cassert>
#include <string>
#include <string_view>

namespace MC-Toolkit {

std::string percent_encode(std::string_view str);
bool percent_decode(std::string *str);

inline std::string percent_encode(std::string_view str) {
    auto is_notgraph = [](unsigned char c) {
        return std::isgraph(c) == 0 || c == '%' || c == '@';
    };

    // optimize for situation in which no encoding is needed
    auto it = std::find_if(str.begin(), str.end(), is_notgraph);
    if(it == str.end()) {
        return std::string{str};
    }
    char buffer[8];
    // setup return value
    std::string ret;
    ret.reserve(str.size());
    auto bit = str.begin();
    do {
        // Append sequences and encoded character
        unsigned char c = *it;
        std::snprintf(buffer, 8, "%%%02hhX", c);
        ret.append(bit, it);
        ret.append(buffer);
        // Find next character to encode
        bit = ++it;
        it = std::find_if(it, str.end(), is_notgraph);
    } while(it != str.end());
    // Append tail
    ret.append(bit, str.end());

    return ret;
}

inline int hex_decode(char x) {
    if('0' <= x && x <= '9') {
        return x - '0';
    }
    if('A' <= x && x <= 'F') {
        return x - 'A' + 10;
    }
    if('a' <= x && x <= 'f') {
        return x - 'a' + 10;
    }
    return -1;
}

inline bool percent_decode_core(std::string *str, size_t start) {
    assert(str != nullptr);
    assert(start < str->size());
    assert((*str)[start] == '%');
    auto p = str->begin() + start;
    auto q = p;
    do {
        assert(*p == '%');
        if(++p == str->end()) {
            return false;
        }
        int a = hex_decode(*p);
        if(++p == str->end()) {
            return false;
        }
        int b = hex_decode(*p);
        if(a == -1 || b == -1) {
            return false;
        }
        *q++ = a * 16 + b;
        for(++p; p != str->end(); ++p) {
            if(*p == '%') {
                break;
            }
            *q++ = *p;
        }
    } while(p != str->end());
    str->erase(q, str->end());
    return true;
}

inline bool percent_decode(std::string *str) {
    assert(str != nullptr);
    auto pos = str->find('%');
    if(pos != std::string::npos) {
        return percent_decode_core(str, pos);
    }
    return true;
}

}  // namespace MC-Toolkit

#endif  // MC-Toolkit_PERCENC_HPP
