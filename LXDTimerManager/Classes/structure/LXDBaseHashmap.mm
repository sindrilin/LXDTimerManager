//
//  LXDBaseHashmap.m
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#import "LXDBaseHashmap.h"
#include <string.h>


#define hash_bucket_count 15


LXDBaseHashmap::LXDBaseHashmap() {
    entries_count = hash_bucket_count;
    size_t hash_size = hash_bucket_count * sizeof(hash_entry_t);
    hash_entries = (hash_entry_t *)malloc(hash_size);
    memset(hash_entries, 0, hash_size);
}

LXDBaseHashmap::~LXDBaseHashmap() {
    free(hash_entries);
}

unsigned int LXDBaseHashmap::obj_hash_code(void *obj) {
    uint64_t *val1 = (uint64_t *)obj;
    uint64_t *val2 = val1 + 1;
    return (unsigned int)(*val1 + *val2) % hash_bucket_count;
}

