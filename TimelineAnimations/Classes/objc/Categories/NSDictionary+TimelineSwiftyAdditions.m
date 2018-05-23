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

- (NSDictionary *)_mapValues:(id(^)(id value))transform {
    NSParameterAssert(transform != nil);
    return [self _map:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        return transform(value);
    }];
}

- (NSDictionary *)_map:(id(^)(id key, id value))transform {
    NSParameterAssert(transform != nil);
    @autoreleasepool {
        id sharedKeyes = [NSDictionary sharedKeySetForKeys:self.allKeys];
        NSMutableDictionary *const new = [NSMutableDictionary dictionaryWithSharedKeySet:sharedKeyes];

        [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            new[key] = transform(key, value);
        }];
        return [new copy];
    }
}

- (id)_reduce:(id)result transform:(id(^)(id partial, id key, id value))next {
    NSParameterAssert(next != nil);
    @autoreleasepool {
        __block id partial = result;
        [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            partial = next(partial, key, value);
        }];
        return partial;
    }
}

- (NSDictionary *)_filter:(id(^)(id key, id value))isIncluded {
    NSParameterAssert(isIncluded != nil);
    @autoreleasepool {
        id sharedKeyes = [NSDictionary sharedKeySetForKeys:self.allKeys];
        NSMutableDictionary *const new = [NSMutableDictionary dictionaryWithSharedKeySet:sharedKeyes];
        [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            if (isIncluded(key, value)) {
                new[key] = value;
            }
        }];
        return [new copy];
    }
}

- (NSDictionary *)_mergingWith:(NSDictionary *)other
              uniquingKeysWith:(id(NS_NOESCAPE ^)(id current, id new))combine {
    NSParameterAssert(combine != nil);
    @autoreleasepool {
        NSSet *const combinedKeys = [[NSSet alloc] initWithArray:[self.allKeys arrayByAddingObjectsFromArray:other.allKeys]];
        id sharedKeyes = [NSDictionary sharedKeySetForKeys:combinedKeys.allObjects];
        NSMutableDictionary *const new = [NSMutableDictionary dictionaryWithSharedKeySet:sharedKeyes];
        [other enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull newValue, BOOL * _Nonnull stop) {
            id currentValue = self[key];
            new[key] = (currentValue != nil)
            ? combine(currentValue, newValue)
            : newValue;
        }];
        return [new copy];
    }
}

+ (void)_zip:(NSDictionary *)dictionary1
        with:(NSDictionary *)dictionary2
enumerateUsingBlock:(void (NS_NOESCAPE ^)(id key1, id value1, id key2, id value2))block {
    NSParameterAssert(dictionary1 != nil);
    NSParameterAssert(dictionary2 != nil);
    NSParameterAssert(dictionary1.count == dictionary2.count);

    NSArray *const keys1 = dictionary1.allKeys;
    NSArray *const keys2 = dictionary2.allKeys;

    [keys1 enumerateObjectsUsingBlock:^(id  _Nonnull key1, NSUInteger i, BOOL * _Nonnull stop) {
        id key2 = keys2[i];
        id value1 = dictionary1[key1];
        id value2 = dictionary2[key2];
        block(key1, value1, key2, value2);
    }];
}

@end

@implementation NSMutableDictionary (TimelineSwiftyAdditions)

- (void)_mergeWith:(NSDictionary *)other
  uniquingKeysWith:(id(NS_NOESCAPE ^)(id current, id new))combine {
    NSParameterAssert(combine != nil);
    @autoreleasepool {

        [other enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull newValue, BOOL * _Nonnull stop) {
            id currentValue = self[key];
            self[key] = (currentValue != nil)
            ? combine(currentValue, newValue)
            : newValue;
        }];
    }
}

- (void)_mapInPlace:(id(NS_NOESCAPE ^)(id key, id value))transform {
    NSParameterAssert(transform != nil);
    @autoreleasepool {
        [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            self[key] = transform(key, value);
        }];
    }
}

- (void)_mapValuesInPlace:(id(NS_NOESCAPE ^)(id value))transform {
    NSParameterAssert(transform != nil);
    [self _mapInPlace:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        return transform(value);
    }];
}
@end
