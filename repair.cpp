/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#include <cassert>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <memory>

#include "db.hpp"
#include "mcbekey.hpp"

int repair_main(int argc, char *argv[]) {
    if(argc < 3 || strcmp("help", argv[1]) == 0) {
        printf("Usage: %s repair <minecraft_world_dir>\n", argv[0]);
        return EXIT_FAILURE;
    }

    // construct path for Minecraft BE database
    std::string path = std::string(argv[2]) + "/db";

    leveldb::ZlibCompressorRaw zlib_raw;
    leveldb::ZlibCompressor zlib;

    leveldb::Options options;
    options.compressors[0] = &zlib_raw;
    options.compressors[1] = &zlib;

    leveldb::Status status;
    status = leveldb::RepairDB(path, options);

    if(!status.ok()) {
        fprintf(stderr, "ERROR: Repairing '%s' failed --- %s\n", path.c_str(),
                status.ToString().c_str());
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
