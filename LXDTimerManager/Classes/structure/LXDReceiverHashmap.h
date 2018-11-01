//
//  LXDReceiverHashmap.hpp
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#ifndef LXDReceiverHashmap_hpp
#define LXDReceiverHashmap_hpp

#include <stdio.h>
#include "LXDBaseHashmap.h"
#include "LXDTimerStructure.h"


class LXDReceiverHashmap: public LXDBaseHashmap {
public:
    LXDReceiverHashmap();
    ~LXDReceiverHashmap();
    
    bool insertReceiver(void *obj, LXDReceiverCallback callback, unsigned long lefttime);
    bool compare(LXDReceiverNode *node, void *obj);
    LXDReceiverNode *lookupReceiver(void *obj);
    void destoryNode(LXDReceiverNode *node);
    
private:
    LXDReceiver *create_receiver(void *obj, LXDReceiverCallback callback, long lefttime);
};


#endif /* LXDReceiverHashmap_hpp */
