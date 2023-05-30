/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */
#ifndef MC-Toolkit_DB_HPP
#define MC-Toolkit_DB_HPP

#include "leveldb/cache.h"
#include "leveldb/db.h"
#include "leveldb/decompress_allocator.h"
#include "leveldb/env.h"
#include "leveldb/filter_policy.h"
#include "leveldb/zlib_compressor.h"

namespace MC-Toolkit {

class NullLogger : public leveldb::Logger {
   public:
    void Logv(const char*, va_list) override {}
};

class DB {
   public:
    explicit DB(const char* path, bool create_if_missing = false,
                bool error_if_exists = false)
        : options_{},
          filter_policy_{leveldb::NewBloomFilterPolicy(10)},
          block_cache_{leveldb::NewLRUCache(40 * 1024 * 1024)},
          info_log{},
          zlib_raw_{},
          zlib_{},
          db_{} {
        // create a bloom filter to quickly tell if a key is in the database or
        // not
        options_.filter_policy = filter_policy_.get();
        // create a 40 mb cache (we use this on ~1gb devices)
        options_.block_cache = block_cache_.get();
        // create a 4mb write buffer, to improve compression and touch the disk
        // less
        options_.write_buffer_size = 4 * 1024 * 1024;
        // disable internal logging.
        options_.info_log = &info_log;
        // use the new raw-zip compressor to write (and read)
        options_.compressors[0] = &zlib_raw_;
        // also setup the old, slower compressor for backwards compatibility.
        // This will only be used to read old compressed blocks.
        options_.compressors[1] = &zlib_;

        options_.create_if_missing = create_if_missing;
        options_.error_if_exists = error_if_exists;

        leveldb::DB* pdb = nullptr;
        leveldb::Status status = leveldb::DB::Open(options_, path, &pdb);
        if(status.ok()) {
            db_.reset(pdb);
        }
    }

    explicit operator bool() { return static_cast<bool>(db_); }

    leveldb::DB& operator()() { return *db_; }

   protected:
    leveldb::Options options_;

    std::unique_ptr<const leveldb::FilterPolicy> filter_policy_;
    std::unique_ptr<leveldb::Cache> block_cache_;

    NullLogger info_log;
    leveldb::ZlibCompressorRaw zlib_raw_;
    leveldb::ZlibCompressor zlib_;

    std::unique_ptr<leveldb::DB> db_;
};

}  // namespace MC-Toolkit

#endif  // MC-Toolkit_DB_HPP
