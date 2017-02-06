//
//  KeyValueBlockObservation.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
   @param keypath the key path, relative to object, to the value that has changed.
   @param object the source object of the key path `keypath`.
   @param change a dictionary that describes the changes that have been made to the value of the property at the key path
   `keyPath` relative to `object`. Entries are described in Change Dictionary Keys.
   @param context the value that was provided when registering
   */
typedef void (^ObservationBlock)(NSString *keypath, id object, NSDictionary *change, void *__nullable context);
/** Opaque type, identifying a registration to KVO through the `KeyValueBlockObservation` system. */
typedef const void *ObservationID;

@interface KeyValueBlockObservation : NSObject

/**
   The shared observatory.
 */
@property (class, readonly, strong) KeyValueBlockObservation *observatory;


/**
   Registers the block to receive KVO notifications for the key path relative to the object provided.

   @discussion
   When calling this method, the caller **must** keep the `ObservationID` returned. The `object` is not retained. The
   registree that calls this method must also eventually call
   -removeObservationBlocksOfObject:forKeyPath:observationID:context: when participating in KVO, providing the `ObservationID`.


   @param block the block to be called
   @param object the object at which to register for KVO notifications.
   @param keypath the key path, relative to the object receiving this message, of the property to observe. This value must not be nil.
   @param options a combination of the NSKeyValueObservingOptions values that specifies what is included in observation
   notifications. For possible values, see NSKeyValueObservingOptions.
   @param context arbitrary data that is passed to the `block`.

   @precondition `block`, `object` and `keypath` is **not** `NULL`.

   @returns An opaque type of ObservationID that **must** be provided to -removeObservationBlocksOfObject:forKeyPath:observationID:context:.

   @note If the precondition is not satisfied then this method returns `NULL` and does nothing.
 */
- (ObservationID)addObservationBlock:(ObservationBlock)block
                              object:(id)object
                          forKeyPath:(NSString *)keypath
                             options:(NSKeyValueObservingOptions)options
                             context:(nullable void *)context;

/**
   Stops the observation block to be called, for the property specified by the key path relative to the object, given the context.


   @param object the object from which to un-register for KVO notifications.
   @param keypath a key-path, relative to the observed object, for which an observation block is registered to receive KVO change notifications.
   @param observationID the id that was returned from a previous call to -addObservationBlock:object:forKeyPath:options:context:
   @param context arbitrary data that more specifically identifies the observer to be removed.

   @precondition `object`, `keypath` and `observation` is **not** `NULL`.

   @note If the precondition is not satisfied then this method does nothing.
 */
- (void)removeObservationBlocksOfObject:(id)object
                             forKeyPath:(NSString *)keypath
                          observationID:(ObservationID)observationID
                                context:(nullable void *)context;
@end

NS_ASSUME_NONNULL_END
