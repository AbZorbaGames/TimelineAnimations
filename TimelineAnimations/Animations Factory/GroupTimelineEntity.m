//
//  GroupTimelineEntity.m
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "GroupTimelineEntity.h"
#import "TimelineAnimationProtected.h"
#import "ReverseCoordinator.h"
#import <objc/runtime.h>

#ifndef guard
#define guard(cond) if ((cond)) {}
#endif

@implementation TimelineAnimation (GroupTimelineEntity)
@dynamic groupTimelineEntity;
- (void)setGroupTimelineEntity:(GroupTimelineEntity *)groupTimelineEntity {
    objc_setAssociatedObject(self, @selector(groupTimelineEntity), groupTimelineEntity, OBJC_ASSOCIATION_ASSIGN);
}

- (GroupTimelineEntity *)groupTimelineEntity {
    return objc_getAssociatedObject(self, @selector(groupTimelineEntity));
}

@end

@interface GroupTimelineEntity ()
@property (nonatomic, strong) ReverseCoordinator *reverseCoordinator;
@property (nonatomic, readwrite) BOOL cleared;
@end

@implementation GroupTimelineEntity

#pragma mark - Initilizers

- (instancetype)init {
    return [self initWithTimeline:[TimelineAnimation timelineAnimation]];
}

- (instancetype)initWithTimeline:(__kindof TimelineAnimation *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
        _timeline.groupTimelineEntity = self;
    }
    return self;
}

+ (instancetype)groupTimelineEntityWithTimeline:(__kindof  TimelineAnimation *)timeline {
    return [[self alloc] initWithTimeline:timeline];
}

- (void)dealloc {
    _timeline.groupTimelineEntity = nil;
}

#pragma mark - NSObject overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    GroupTimelineEntity *other = (GroupTimelineEntity *)object;
    BOOL same = [self.timeline isEqual:other.timeline];
    return same;
}

- (NSUInteger)hash {
    return _timeline.hash;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<<%@: %p> "
                    "TimelineAnimation:%@>",
            NSStringFromClass(self.class),
            (void *)self,
            _timeline.debugDescription];
}

@end

#pragma mark - NSCopying

@implementation GroupTimelineEntity (Copying)

- (id)copyWithZone:(NSZone *)zone {
    GroupTimelineEntity *copy = [[GroupTimelineEntity alloc] initWithTimeline:_timeline];
    return copy;
}

- (instancetype)copyWithDuration:(NSTimeInterval)newDuration
           shouldAdjustBeginTime:(BOOL)adjust
             usingTotalBeginTime:(RelativeTime)totalBeginTime {

    NSTimeInterval oldDuration = self.timeline.duration;
    NSTimeInterval factor      = newDuration / oldDuration;

    __kindof TimelineAnimation *timelineAnimation = [self.timeline timelineWithDuration:newDuration];

    GroupTimelineEntity *entity = [[GroupTimelineEntity alloc] initWithTimeline:timelineAnimation];
    if (adjust) {
        entity.timeline.beginTime = totalBeginTime + ((self.timeline.beginTime - totalBeginTime) * factor);
    }
    return entity;
}

@end

#pragma mark - Reverse

@implementation GroupTimelineEntity (Reverse)

- (instancetype)reversedCopyWithDuration:(NSTimeInterval)duration {
    GroupTimelineEntity *reversedCopy = [self copy];
    NSTimeInterval newDuration = duration;
    if ([_timeline isKindOfClass:[GroupTimelineAnimation class]]) {
        newDuration = _timeline.duration;
    }
    reversedCopy.timeline = [_timeline reversedWithDuration:newDuration];
    reversedCopy.timeline.groupTimelineEntity = reversedCopy;
    return reversedCopy;
}

@end

#pragma mark - Public methods

@implementation GroupTimelineEntity (Control)

- (void)playAfterReverse:(__kindof TimelineAnimation *)revereseTimeline
                 onStart:(VoidBlock)callerOnStart
              onComplete:(BoolBlock)callerCompletion {

    NSParameterAssert(callerOnStart);
    NSParameterAssert(callerCompletion);

    if (_cleared) {
        return; // do not replay clear entities
    }

    VoidBlock userOnStart = [_timeline.onStart copy];
    BoolBlock userCompletion = [_timeline.completion copy];

    __weak typeof(self) welf           = self;
    __weak typeof(_timeline) wtimeline = _timeline;

    _timeline.onStart = ^{
        __strong typeof(welf) strelf = welf;
        __strong typeof(welf.timeline) stimeline = wtimeline;
        guard (strelf != nil) else { return; }
        guard (stimeline != nil) else { return; }
        guard (strelf.cleared == NO) else { return; }

        if (callerOnStart) {
            callerOnStart();
        }

        if (userOnStart) {
            userOnStart();
        }

        stimeline.onStart = userOnStart;
    };

    _timeline.completion = ^(BOOL result) {
        __strong typeof(welf.timeline) stimeline = wtimeline;
        __strong typeof(welf) strelf = welf;
        guard (strelf != nil) else { return; }
        guard (stimeline != nil) else { return; }
        guard (strelf.cleared == NO) else { return; }

        if (userCompletion) {
            userCompletion(result);
        }

        if (callerCompletion) {
            callerCompletion(result);
        }

        stimeline.completion = userCompletion;
    };

    if (revereseTimeline) {

        __weak typeof(self) welf = self;
        ReverseCoordinator *coordinator = [[ReverseCoordinator alloc] initWithTimeline:revereseTimeline
                                                                            completion:^(__kindof TimelineAnimation * _Nonnull timeline) {
                                                                                __strong typeof(self) strelf = welf;
                                                                                __strong typeof(welf.timeline) stimeline = wtimeline;
                                                                                [stimeline play];
                                                                                strelf.reverseCoordinator = nil;
                                                                            }];
        self.reverseCoordinator = coordinator;
    } else {
        [_timeline play];
    }
}

- (void)playOnStart:(VoidBlock)onStart onComplete:(BoolBlock)complete {
    [self playAfterReverse:nil
                   onStart:onStart
                onComplete:complete];
}

- (void)reset {
    [_timeline reset];
}

- (void)pause {
    [_timeline pause];
}

- (void)resume {
    [_timeline resume];
}

- (void)clear {
    _cleared = YES;

    [_timeline clear];
}

@end
