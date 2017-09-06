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

- (NSDictionary<KeyType, id> *)_mapValues:(id(NS_NOESCAPE ^)(ObjectType obj))transform NS_REFINED_FOR_SWIFT;

- (NSDictionary<KeyType, ObjectType> *)_map:(id(NS_NOESCAPE ^)(KeyType key,ObjectType obj))transform NS_REFINED_FOR_SWIFT;
- (id)_reduce:(id)result transform:(id(NS_NOESCAPE ^)(id partial,KeyType key,ObjectType obj))next NS_REFINED_FOR_SWIFT;
- (NSDictionary<KeyType, ObjectType> *)_filter:(id(NS_NOESCAPE ^)(KeyType key,ObjectType obj))isIncluded NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
