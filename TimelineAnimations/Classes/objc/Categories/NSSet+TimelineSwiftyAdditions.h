/*!
 *  @file NSSet+TimelineSwiftyAdditions.h
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
 *  @category NSSet_Swifty
 *  @brief A class.
 *  @details Some details.
 *  @related NSSet
 */
@interface NSSet<__covariant ObjectType> (TimelineSwiftyAdditions)

- (NSArray *)_map:(id(NS_NOESCAPE ^)(ObjectType obj))transform NS_REFINED_FOR_SWIFT;
- (id)_reduce:(id)result transform:(id(NS_NOESCAPE ^)(id partial,ObjectType obj))next NS_REFINED_FOR_SWIFT;
- (NSArray<ObjectType> *)_filter:(id(NS_NOESCAPE ^)(ObjectType obj))isIncluded NS_REFINED_FOR_SWIFT;

- (NSArray *)_flatMap:(NSArray *(NS_NOESCAPE ^)(ObjectType obj))transform NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
