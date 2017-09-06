/*!
 *  @file NSDictionary+TimelineSwiftyAdditions.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 03/04/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

#import "NSDictionary+TimelineSwiftyAdditions.h"

@implementation NSDictionary (TimelineSwiftyAdditions)

- (NSDictionary *)_mapValues:(id(^)(id))transform {
    @autoreleasepool {
        id sharedKeyes = [NSDictionary sharedKeySetForKeys:self.allKeys];
        NSMutableDictionary *new = [NSMutableDictionary sharedKeySetForKeys:sharedKeyes];
        [new enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            new[key] = transform(obj);
        }];
        return [new copy];
    }
}

- (NSDictionary *)_map:(id(^)(id,id))transform {
    id sharedKeyes = [NSDictionary sharedKeySetForKeys:self.allKeys];
    NSMutableDictionary *new = [NSMutableDictionary sharedKeySetForKeys:sharedKeyes];
    
    [new enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        new[key] = transform(key,obj);
    }];
    return [new copy];
}

- (id)_reduce:(id)result transform:(id(^)(id,id,id))next {
    __block id res = result;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        res = next(res,key,obj);
    }];
    return res;
}

- (NSDictionary *)_filter:(id(^)(id,id))isIncluded {
    id sharedKeyes = [NSDictionary sharedKeySetForKeys:self.allKeys];
    NSMutableDictionary *new = [NSMutableDictionary sharedKeySetForKeys:sharedKeyes];
    [new enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (isIncluded(key,obj)) {
            new[key] = obj;
        }
    }];
    return [new copy];
}

@end
