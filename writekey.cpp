/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#include <cassert>
#include <cstdio>
#include <iostream>
#include <memory>
#include <sstream>

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

#include "db.hpp"
#include "mcbekey.hpp"
#include "slurp.hpp"

int writekey_main(int argc, char* argv[]) {
    if(argc < 4 || strcmp("help", argv[1]) == 0) {
        printf("Usage: %s writekey <minecraft_world_dir> <key> < input.bin\n",
               argv[0]);
        return EXIT_FAILURE;
    }

#ifdef _WIN32
    _setmode(_fileno(stdin), O_BINARY);
#endif

    // slurp from stdin into value before we open db
    auto value = MC-Toolkit::slurp_string(std::cin);

    // construct path for Minecraft BE database
    std::string path = std::string(argv[2]) + "/db";

    // open the database
    MC-Toolkit::DB db{path.c_str()};

    if(!db) {
        fprintf(stderr, "ERROR: Opening '%s' failed.\n", path.c_str());
        return EXIT_FAILURE;
    }

    std::string key;
    if(!MC-Toolkit::decode_key(argv[3], &key)) {
        fprintf(stderr, "ERROR: key '%s' is malformed\n", argv[3]);
        return EXIT_FAILURE;
    }

    leveldb::Status status = db().Put({}, key, value);

    if(!status.ok()) {
        // LCOV_EXCL_START
        fprintf(stderr, "ERROR: Reading key '%s' failed: %s\n", argv[3],
                status.ToString().c_str());
        return EXIT_FAILURE;
        // LCOV_EXCL_STOP
    }

    return EXIT_SUCCESS;
}
