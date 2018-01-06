//
//  LXDReceiverHashmap.cpp
//  LXDTimerManager
//
//  Created by didi on 2018/1/5.
//  Copyright © 2018年 didi. All rights reserved.
//

#include "LXDReceiverHashmap.h"


#pragma mark - Public
LXDReceiverHashmap::LXDReceiverHashmap(): LXDBaseHashmap() {
    for (int offset = 0; offset < entries_count; offset++) {
        hash_entry_t *entry = hash_entries + offset;
        LXDReceiverNode *header = new LXDReceiverNode();
        entry->entry = (void *)header;
    }
}

LXDReceiverHashmap::~LXDReceiverHashmap() {
    for (int offset = 0; offset < entries_count; offset++) {
        hash_entry_t *entry = hash_entries + offset;
        LXDReceiverNode *node = (LXDReceiverNode *)entry->entry;
        
        while (node != NULL) {
            LXDReceiverNode *next = node->next;
            destoryNode(node);
            node = next;
        }
    }
}

bool LXDReceiverHashmap::insertReceiver(void *obj, LXDReceiverCallback callback, unsigned long lefttime) {
    unsigned int offset = obj_hash_code(obj);
    hash_entry_t *entry = hash_entries + offset;
    LXDReceiverNode *header = (LXDReceiverNode *)entry->entry;
    LXDReceiverNode *node = header->next;
    
    if (node == NULL) {
        LXDReceiver *receiver = create_receiver(obj, callback, lefttime);
        node = new LXDReceiverNode(receiver, header);
        header->next = node;
        header->count++;
        return true;
    }
    
    do {
        if (compare(node, obj) == true) {
            node->receiver->callback = callback;
            node->receiver->lefttime = lefttime;
            return false;
        }
    } while (node->next != NULL && (node = node->next));
    
    if (compare(node, obj) == true) {
        node->receiver->callback = callback;
        node->receiver->lefttime = lefttime;
        return false;
    }
    
    LXDReceiver *receiver = create_receiver(obj, callback, lefttime);
    node->next = new LXDReceiverNode(receiver, node);
    header->count++;
    return true;
}

LXDReceiverNode *LXDReceiverHashmap::lookupReceiver(void *obj) {
    unsigned int offset = obj_hash_code(obj);
    hash_entry_t *entry = hash_entries + offset;
    LXDReceiverNode *node = (LXDReceiverNode *)entry->entry;
    node = node->next;
    
    while (node != NULL) {
        if (compare(node, obj) == true) {
            return node;
        }
        node = node->next;
    }
    return NULL;
}

void LXDReceiverHashmap::destoryNode(LXDReceiverNode *node) {
    if (node->next != NULL) {
        node->next->previous = node->previous;
        node->previous->next = node->next;
    } else {
        node->previous->next = NULL;
    }
    delete node->receiver;
    delete node;
}


#pragma mark - Private
bool LXDReceiverHashmap::compare(LXDReceiverNode *node, void *obj) {
    return (node->receiver->objaddr == (uintptr_t)obj);
}

LXDReceiver *LXDReceiverHashmap::create_receiver(void *obj, LXDReceiverCallback callback, long lefttime) {
    LXDReceiver *receiver = new LXDReceiver();
    receiver->objaddr = (uintptr_t)obj;
    receiver->callback = callback;
    receiver->lefttime = lefttime;
    return receiver;
}
