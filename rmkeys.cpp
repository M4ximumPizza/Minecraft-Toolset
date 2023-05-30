/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#include <cassert>
#include <cstdio>
#include <iostream>
#include <memory>

#include "db.hpp"
#include "mcbekey.hpp"

int rmkeys_main(int argc, char *argv[]) {
    if(argc < 3 || strcmp("help", argv[1]) == 0) {
        printf("Usage: %s rmkeys <minecraft_world_dir> < keys.txt\n", argv[0]);
        printf("       %s rmkeys <minecraft_world_dir> <key> <key> ...\n",
               argv[0]);
        return EXIT_FAILURE;
    }

    // construct path for Minecraft BE database
    std::string path = std::string(argv[2]) + "/db";

    // open the database
    MC-Toolkit::DB db{path.c_str()};

    if(!db) {
        fprintf(stderr, "ERROR: Opening '%s' failed.\n", path.c_str());
        return EXIT_FAILURE;
    }

    leveldb::Status status;

    // Create a function that deletes the key.
    auto delete_key = [&](const std::string &line) -> bool {
        std::string key;
        if(!MC-Toolkit::decode_key(line, &key)) {
            printf("Skipping malformed key '%s'...\n", line.c_str());
            return true;
        }
        printf("Deleting key '%s'...\n", line.c_str());
        status = db().Delete({}, key);
        if(!status.ok()) {
            // LCOV_EXCL_START
            fprintf(stderr, "ERROR: Writing '%s' failed: %s\n", path.c_str(),
                    status.ToString().c_str());
            return false;
            // LCOV_EXCL_STOP
        }
        return true;
    };

    // handle keys passed as arguments
    if(argc > 3) {
        for(int i = 3; i < argc; ++i) {
            if(!delete_key(argv[i])) {
                return EXIT_FAILURE;  // LCOV_EXCL_LINE
            }
        }
        return EXIT_SUCCESS;
    }

    // Or handle keys passed on stdin.
    std::string line;
    while(std::getline(std::cin, line)) {
        if(!delete_key(line)) {
            return EXIT_FAILURE;  // LCOV_EXCL_LINE
        }
    }

    return EXIT_SUCCESS;
}
