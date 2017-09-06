//
//  KeyValueBlockObservation.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

#import "KeyValueBlockObservation.h"
#import "PrivateTypes.h"

@interface ObservationBlockWrapper : NSObject
@property (nonatomic, copy) ObservationBlock block;
@property (nonatomic, readwrite) const void *UUID;
@end

@implementation ObservationBlockWrapper

- (instancetype)initWithBlock:(ObservationBlock)block
{
    self = [super init];
    if (self) {
        _block = block;
        _UUID  = &self;
    }
    return self;
}

+ (instancetype)wrapperWithBlock:(ObservationBlock)block {
    return [(ObservationBlockWrapper *)[self alloc] initWithBlock:block];
}

@end


typedef NSMutableArray<ObservationBlockWrapper *> ObservationBlockArray; // an array of wrappers

typedef NSMutableDictionary<NSString *, ObservationBlockArray *> KeyPathAssociations; // a keypath to wrappers association

@interface KeyValueBlockObservation ()
@property (nonatomic, strong) NSMapTable<id, KeyPathAssociations *> *associations;
@end


@implementation KeyValueBlockObservation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _associations = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsOpaquePersonality
                                              valueOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

+ (instancetype)observatory {
    static dispatch_once_t onceToken;
    static KeyValueBlockObservation *__sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] init];
    });
    return __sharedInstance;
}

#pragma mark - Public methods

- (ObservationID)addObservationBlock:(ObservationBlock)block
                              object:(id)object
                          forKeyPath:(NSString *)keypath
                             options:(NSKeyValueObservingOptions)options
                             context:(nullable void *)context {
    NSParameterAssert(block);
    NSParameterAssert(object);
    NSParameterAssert(keypath);

    guard (block != NULL)  else { return NULL; }
    guard (object != NULL) else { return NULL; }
    guard (keypath != nil) else { return NULL; }

    KeyPathAssociations *associationsOfObject = nil;
    // check to see if there is a KeyPathAssociations for the provided `object`.
    // if not then create it and associate it.
    @synchronized (_associations) {
        associationsOfObject = [_associations objectForKey:object];
        if (associationsOfObject == nil) {
            associationsOfObject = [[KeyPathAssociations alloc] init];
            [_associations setObject:associationsOfObject forKey:object];
        }
    }

    // check to see if there is a array of wrappers already associated with the keypath
    // if not then create it and associate it
    ObservationBlockArray *arrayOfBlock = nil;
    @synchronized (associationsOfObject) {
        arrayOfBlock = associationsOfObject[keypath];
        if (arrayOfBlock == nil) {
            arrayOfBlock = [[ObservationBlockArray alloc] init];
            associationsOfObject[keypath] = arrayOfBlock;
        }
    }

    ObservationBlockWrapper *wrapper = [ObservationBlockWrapper wrapperWithBlock:block];
    @synchronized (arrayOfBlock) {
        [arrayOfBlock addObject:wrapper];
    }

    [object addObserver:self
             forKeyPath:keypath
                options:options
                context:context];

    return wrapper.UUID;
}

- (void)removeObservationBlocksOfObject:(id)object
                             forKeyPath:(NSString *)keypath
                          observationID:(ObservationID)observationID
                                context:(nullable void *)context {
    NSParameterAssert(object);
    NSParameterAssert(keypath);
    NSParameterAssert(observationID);

    guard (object != NULL) else { return; }
    guard (observationID != NULL) else { return; }
    guard (keypath != nil) else { return; }

    KeyPathAssociations *associationsOfObject = nil;
    @synchronized (_associations) {
        associationsOfObject = [_associations objectForKey:object];
    }

    ObservationBlockArray *arrayOfBlocks = nil;
    @synchronized (associationsOfObject) {
        arrayOfBlocks = associationsOfObject[keypath];
    }

    __block NSUInteger found = NSNotFound;
    @synchronized (arrayOfBlocks) {
        [arrayOfBlocks enumerateObjectsUsingBlock:^(ObservationBlockWrapper * _Nonnull wrapper, NSUInteger idx, BOOL * _Nonnull stop) {
            if (wrapper.UUID == observationID) {
                found = idx;
                *stop = YES;
            }
        }];
        if (found != NSNotFound) {
            [arrayOfBlocks removeObjectAtIndex:found];
            if (arrayOfBlocks.count == 0) {
                // no observers
                [object removeObserver:self
                            forKeyPath:keypath
                               context:context];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    __block BOOL handled = NO;
    KeyPathAssociations *associationsOfObject = [_associations objectForKey:object];
    ObservationBlockArray *arrayOfBlock = associationsOfObject[keyPath];
    for (ObservationBlockWrapper *wrapper in arrayOfBlock) {
        wrapper.block(keyPath, object, change, context);
        handled = YES;
    }
    if (!handled)
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
