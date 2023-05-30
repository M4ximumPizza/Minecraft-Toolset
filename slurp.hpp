/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#ifndef MC-Toolkit_SLURP_HPP
#define MC-Toolkit_SLURP_HPP

#include <string>

namespace MC-Toolkit {

template <typename CharT, typename Traits = std::char_traits<CharT>,
          typename Allocator = std::allocator<CharT>>
std::basic_string<CharT, Traits, Allocator> slurp_string(
    std::basic_istream<CharT, Traits> &in) {
    // create buffer
    std::basic_string<CharT, Traits, Allocator> buffer(
        8192, static_cast<CharT>('\0'));
    std::size_t sz = 0;

    // read into buffer
    in.read(buffer.data() + sz, 8192);
    // count how many values we read
    std::size_t g = in.gcount();
    sz += g;
    while(!in.eof()) {
        // allocate more space
        buffer.resize(buffer.size() + 8192);
        // Keep reading
        in.read(buffer.data() + sz, 8192);
        // count how many values we read
        g = in.gcount();
        sz += g;
    }
    // shrink buffer
    buffer.resize(sz);
    return buffer;
}

};  // namespace MC-Toolkit

#endif
