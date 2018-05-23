/*!
 *  @file NSArray+TimelineSwiftyAdditions.h
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
 *  @category NSArray_Swifty
 *  @brief A class.
 *  @details Some details.
 *  @related NSArray
 */
@interface NSArray<__covariant ObjectType> (TimelineSwiftyAdditions)

- (NSArray *)_map:(id(NS_NOESCAPE ^)(ObjectType obj))transform NS_REFINED_FOR_SWIFT;
- (id)_reduce:(id)result transform:(id(NS_NOESCAPE ^)(id partial,ObjectType obj))next NS_REFINED_FOR_SWIFT;
- (NSArray<ObjectType> *)_filter:(BOOL(NS_NOESCAPE ^)(ObjectType obj))isIncluded NS_REFINED_FOR_SWIFT;

- (NSArray<ObjectType> *)_objectsPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))predicate NS_REFINED_FOR_SWIFT;

- (NSArray *)_flatMap:(NSArray *(NS_NOESCAPE ^)(ObjectType obj))transform NS_REFINED_FOR_SWIFT;

- (nullable ObjectType)_max:(BOOL(NS_NOESCAPE ^)(ObjectType o1, ObjectType o2))areInIncreasingOrder NS_REFINED_FOR_SWIFT;
- (nullable ObjectType)_min:(BOOL(NS_NOESCAPE ^)(ObjectType o1, ObjectType o2))areInIncreasingOrder NS_REFINED_FOR_SWIFT;

- (NSDictionary<id<NSCopying>, NSArray<ObjectType> *> *)_groupingBy:(id<NSCopying> _Nonnull (^)(ObjectType value))keyForValue;

@end

NS_ASSUME_NONNULL_END
