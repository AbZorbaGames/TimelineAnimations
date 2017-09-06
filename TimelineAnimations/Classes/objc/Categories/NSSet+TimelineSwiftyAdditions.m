/*!
 *  @file NSSet+TimelineSwiftyAdditions.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 03/04/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

#import "NSSet+TimelineSwiftyAdditions.h"

@implementation NSSet (TimelineSwiftyAdditions)

- (NSArray *)_map:(id(^)(id))transform {
    NSMutableArray *new = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        id newObj = transform(obj);
        [new addObject:newObj];
    }];
    return [new copy];
}

- (id)_reduce:(id)result transform:(id(^)(id,id))next {
    __block id res = result;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        res = next(res,obj);
    }];
    return res;
}

- (NSArray *)_filter:(id(^)(id))isIncluded {
    NSMutableArray *new = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (isIncluded(obj)) {
            [new addObject:obj];
        }
    }];
    return [new copy];
}

- (NSArray *)_flatMap:(NSArray *(NS_NOESCAPE ^)(id obj))transform  {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *new = transform(obj);
        if (new != nil) {
            [array addObjectsFromArray:new];
        }
    }];
    return [array copy];
}

@end
