/*!
 *  @file NSDictionary+TimelineSwiftyAdditions.h
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 03/04/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @public
 *  @category NSDictionary_Swifty
 *  @brief A class.
 *  @details Some details.
 *  @related NSDictionary
 */
@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (TimelineSwiftyAdditions)

- (NSDictionary<KeyType, id> *)_mapValues:(id(NS_NOESCAPE ^)(ObjectType value))transform NS_REFINED_FOR_SWIFT;

- (NSDictionary<KeyType, ObjectType> *)_map:(id(NS_NOESCAPE ^)(KeyType key, ObjectType value))transform NS_REFINED_FOR_SWIFT;
- (id)_reduce:(id)result transform:(id(NS_NOESCAPE ^)(id partial,KeyType key, ObjectType value))next NS_REFINED_FOR_SWIFT;
- (NSDictionary<KeyType, ObjectType> *)_filter:(id(NS_NOESCAPE ^)(KeyType key, ObjectType value))isIncluded NS_REFINED_FOR_SWIFT;

- (NSDictionary<KeyType, ObjectType> *)_mergingWith:(NSDictionary<KeyType, ObjectType> *)other
                                   uniquingKeysWith:(ObjectType(NS_NOESCAPE ^)(ObjectType current, ObjectType new))combine NS_REFINED_FOR_SWIFT;

+ (void)_zip:(NSDictionary *)dictionary1
        with:(NSDictionary *)dictionary2
enumerateUsingBlock:(void (NS_NOESCAPE ^)(id key1, id value1, id key2, id value2))block;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (TimelineSwiftyAdditions)
- (void)_mergeWith:(NSDictionary<KeyType, ObjectType> *)other
  uniquingKeysWith:(ObjectType(NS_NOESCAPE ^)(ObjectType current, ObjectType new))combine NS_REFINED_FOR_SWIFT;

- (void)_mapInPlace:(id(NS_NOESCAPE ^)(KeyType key, ObjectType value))transform NS_REFINED_FOR_SWIFT;

- (void)_mapValuesInPlace:(id(NS_NOESCAPE ^)(ObjectType value))transform NS_REFINED_FOR_SWIFT;
@end

NS_ASSUME_NONNULL_END
