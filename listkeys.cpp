/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#include <cassert>
#include <cstdio>
#include <memory>

#include "db.hpp"
#include "mcbekey.hpp"

int listkeys_main(int argc, char* argv[]) {
    if(argc < 3 || strcmp("help", argv[1]) == 0) {
        printf("Usage: %s listkeys <minecraft_world_dir> > list.tsv\n",
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

    // Print header
    printf("key\tbytes\tx\tz\tdimension\ttag\tsubtag\n");

    // create a reusable memory space for decompression so it allocates less
    leveldb::ReadOptions readOptions;
    leveldb::DecompressAllocator decompress_allocator;
    readOptions.decompress_allocator = &decompress_allocator;
    readOptions.verify_checksums = true;
    readOptions.fill_cache = false;

    // create an iterator for the database
    auto it = std::unique_ptr<leveldb::Iterator>{db().NewIterator(readOptions)};

    for(it->SeekToFirst(); it->Valid(); it->Next()) {
        auto key = it->key();
        // print an encoded key
        std::string enckey = MC-Toolkit::encode_key({key.data(), key.size()});
        printf("%s", enckey.c_str());
        printf("\t%zu", it->value().size());

        // Identify keys that might represent chunks
        if(MC-Toolkit::is_chunk_key({key.data(), key.size()})) {
            // read chunk key
            auto chunk = MC-Toolkit::parse_chunk_key({key.data(), key.size()});
            // print chunk information
            printf("\t%d\t%d\t%d\t%d\t", chunk.x, chunk.z, chunk.dimension,
                   chunk.tag);
            if(chunk.subtag != -1) {
                printf("%d", chunk.subtag);
            }
        } else {
            printf("\t\t\t\t\t");
        }

        printf("\n");
    }

    if(!it->status().ok()) {
        // LCOV_EXCL_START
        fprintf(stderr, "ERROR: Reading '%s' failed: %s\n", path.c_str(),
                it->status().ToString().c_str());
        return EXIT_FAILURE;
        // LCOV_EXCL_STOP
    }
    return EXIT_SUCCESS;
}
