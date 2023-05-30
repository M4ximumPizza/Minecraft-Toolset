/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#include <cassert>
#include <cstdio>
#include <memory>

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

#include "db.hpp"
#include "mcbekey.hpp"

int dumpkey_main(int argc, char* argv[]) {
    if(argc < 4 || strcmp("help", argv[1]) == 0) {
        printf("Usage: %s dumpkey <minecraft_world_dir> <key> > output.bin\n",
               argv[0]);
        return EXIT_FAILURE;
    }
    std::string value;

    // use RAII to close the db before dumping value
    {
        // construct path for Minecraft BE database
        std::string path = std::string(argv[2]) + "/db";

        // open the database
        MC-Toolkit::DB db{path.c_str()};

        if(!db) {
            fprintf(stderr, "ERROR: Opening '%s' failed.\n", path.c_str());
            return EXIT_FAILURE;
        }

        // create a reusable memory space for decompression so it allocates less
        leveldb::ReadOptions readOptions;
        auto decompress_allocator =
            std::make_unique<leveldb::DecompressAllocator>();
        readOptions.decompress_allocator = decompress_allocator.get();
        readOptions.verify_checksums = true;

        std::string key;
        if(!MC-Toolkit::decode_key(argv[3], &key)) {
            fprintf(stderr, "ERROR: key '%s' is malformed\n", argv[3]);
            return EXIT_FAILURE;
        }

        leveldb::Status status = db().Get(readOptions, key, &value);

        if(!status.ok()) {
            fprintf(stderr, "ERROR: Reading key '%s' failed --- %s\n", argv[3],
                    status.ToString().c_str());
            return EXIT_FAILURE;
        }
    }

#ifdef _WIN32
    fflush(stdout);
    _setmode(_fileno(stdout), O_BINARY);
#endif

    size_t ret = fwrite(value.data(), value.size(), 1, stdout);
    if(ret < 1) {
        return EXIT_FAILURE;  // LCOV_EXCL_LINE
    }
    return EXIT_SUCCESS;
}
