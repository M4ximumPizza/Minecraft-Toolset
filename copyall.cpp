/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#include <cassert>
#include <cstdio>
#include <iostream>
#include <memory>

#include "db.hpp"
#include "mcbekey.hpp"

int copyall_main(int argc, char *argv[]) {
    if(argc < 4 || strcmp("help", argv[1]) == 0) {
        printf(
            "Usage: %s copyall <source_minecraft_world_dir> "
            "<dest_minecraft_world_dir>\n",
            argv[0]);
        return EXIT_FAILURE;
    }

    // construct path for Minecraft BE database
    std::string path = std::string(argv[2]) + "/db";
    std::string copy_path = std::string(argv[3]) + "/db";

    // open the input database
    MC-Toolkit::DB db{path.c_str()};

    if(!db) {
        fprintf(stderr, "ERROR: Opening '%s' failed.\n", path.c_str());
        return EXIT_FAILURE;
    }

    // open the destination database
    MC-Toolkit::DB copy_db{copy_path.c_str(), true, true};

    if(!copy_db) {
        fprintf(stderr, "ERROR: Opening '%s' failed.\n", copy_path.c_str());
        return EXIT_FAILURE;
    }

    // create a reusable memory space for decompression so it allocates less
    leveldb::ReadOptions readOptions;
    leveldb::DecompressAllocator decompress_allocator;
    readOptions.decompress_allocator = &decompress_allocator;
    readOptions.verify_checksums = true;
    readOptions.fill_cache = false;

    // create an iterator for the database
    auto it = std::unique_ptr<leveldb::Iterator>{db().NewIterator(readOptions)};

    leveldb::Status status;

    for(it->SeekToFirst(); it->Valid(); it->Next()) {
        auto key = it->key();
        auto value = it->value();
        status = copy_db().Put({}, key, value);
        if(!status.ok()) {
            // LCOV_EXCL_START
            fprintf(stderr, "ERROR: copying key '%s' failed: %s\n",
                    key.ToString().c_str(), status.ToString().c_str());
            return EXIT_FAILURE;
            // LCOV_EXCL_STOP
        }
    }
    copy_db().CompactRange(nullptr, nullptr);

    if(!status.ok()) {
        // LCOV_EXCL_START
        fprintf(stderr, "ERROR: copying '%s' to '%s' failed: %s\n",
                path.c_str(), copy_path.c_str(), status.ToString().c_str());
        return EXIT_FAILURE;
        // LCOV_EXCL_STOP
    }
    return EXIT_SUCCESS;
}