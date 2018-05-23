/*!
 *  @file NSArray+TimelineSwiftyAdditions.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 03/04/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

#import "NSArray+TimelineSwiftyAdditions.h"

@implementation NSArray (TimelineSwiftyAdditions)

- (NSArray *)_map:(NS_NOESCAPE id(^)(id))transform {
    NSParameterAssert(transform != nil);
    NSMutableArray *new = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id newObj = transform(obj);
        [new addObject:newObj];
    }];
    return [new copy];
}

- (id)_reduce:(id)result transform:(NS_NOESCAPE id(^)(id,id))next {
    NSParameterAssert(next != nil);
    __block id res = result;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        res = next(res,obj);
    }];
    return res;
}

- (NSArray *)_filter:(NS_NOESCAPE BOOL(^)(id))isIncluded {
    NSParameterAssert(isIncluded != nil);
    NSMutableArray *new = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isIncluded(obj)) {
            [new addObject:obj];
        }
    }];
    return [new copy];
}


- (NSArray *)_objectsPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    NSParameterAssert(predicate != nil);
    NSIndexSet *indexes = [self indexesOfObjectsPassingTest:predicate];
    return [self objectsAtIndexes:indexes];
}

- (NSArray *)_flatMap:(NSArray *(NS_NOESCAPE ^)(id obj))transform  {
    NSParameterAssert(transform != nil);
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *new = transform(obj);
        if (new != nil) {
            [array addObjectsFromArray:new];
        }
    }];
    return [array copy];
}

- (NSDictionary<id<NSCopying>, NSArray *> *)_groupingBy:(id<NSCopying> _Nonnull (^)(id value))keyForValue {
    NSParameterAssert(keyForValue != nil);
    NSMutableDictionary<id<NSCopying>, id> *const dictionary =
    [self _reduce:[[NSMutableDictionary alloc] initWithCapacity:self.count]
        transform:^NSMutableDictionary<id<NSCopying>, id> * _Nonnull(NSMutableDictionary<id<NSCopying>, id> * _Nonnull partial, id  _Nonnull value) {
            id<NSCopying> key = keyForValue(value);
            NSMutableArray *array = partial[key];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                partial[key] = array;
            }
            [array addObject:value];
            return partial;
        }];
    return [dictionary copy];
}

- (id)_max:(BOOL(NS_NOESCAPE ^)(id o1, id o2))areInIncreasingOrder {
    NSParameterAssert(areInIncreasingOrder != nil);
    if (self.count == 0) { return nil; }
    
    __block id max = self.firstObject;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull o2, NSUInteger idx, BOOL * _Nonnull stop) {
        if (areInIncreasingOrder(max, o2)) {
            max = o2;
        }
    }];
    return max;
}

- (id)_min:(BOOL(NS_NOESCAPE ^)(id o1, id o2))areInIncreasingOrder {
    NSParameterAssert(areInIncreasingOrder != nil);
    if (self.count == 0) { return nil; }
    
    __block id min = self.firstObject;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull o2, NSUInteger idx, BOOL * _Nonnull stop) {
        if (areInIncreasingOrder(o2, min)) {
            min = o2;
        }
    }];
    return min;
}

@end
