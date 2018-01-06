//
//  LXDBaseHashmap.h
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#import <stdio.h>
#import <stdlib.h>


/*!
 *  @structure  hash_entry_t
 *  hash表实体结构
 *
 *  @var    entry    存储的数据指针
 */
typedef struct hash_entry_t {
    void *entry;
} hash_entry_t;


/*!
 *  @class  LXDBaseHashmap
 *  hash表类
 */
class LXDBaseHashmap {
public:
    LXDBaseHashmap();
    virtual ~LXDBaseHashmap();
    unsigned int entries_count;
    hash_entry_t *hash_entries;
    
protected:
    unsigned int obj_hash_code(void *obj);
};
