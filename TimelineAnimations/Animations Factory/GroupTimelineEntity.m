//
//  GroupTimelineEntity.m
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "GroupTimelineEntity.h"
#import "TimelineAnimationProtected.h"

@interface GroupTimelineEntity ()
@property (nonatomic, copy) VoidBlock timelineOnStart;
@property (nonatomic, copy) BoolBlock timelineCompletion;

@property (nonatomic, copy) VoidBlock playOnStart;
@property (nonatomic, copy) BoolBlock playCompletion;
@end

@implementation GroupTimelineEntity

#pragma mark - Initilizers

- (instancetype)init {
    return [self initWithTimeline:nil];
}

- (instancetype)initWithTimeline:(nullable __kindof TimelineAnimation *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

+ (instancetype)groupTimelineEntityWithTimeline:(nullable __kindof  TimelineAnimation *)timeline {
    return [[self alloc] initWithTimeline:timeline];
}


#pragma mark - NSObject overrides

- (BOOL)isEqual:(id)object {
    if (self == object)
        return YES;

    if (![object isKindOfClass:self.class])
        return NO;

    GroupTimelineEntity *other = (GroupTimelineEntity *)object;
    BOOL same = [self.timeline isEqual:other.timeline];
    return same;
}

- (NSUInteger)hash {
    return _timeline.hash;
}

#pragma mark - Public methods

- (void)playOnStart:(VoidBlock)onStart onComplete:(BoolBlock)complete {
    self.playOnStart                   = onStart;
    self.playCompletion                = complete;

    self.timelineCompletion            = _timeline.completion;
    self.timelineOnStart               = _timeline.onStart;

    __weak typeof(self) welf           = self;
    __weak typeof(_timeline) wtimeline = _timeline;

    _timeline.onStart = ^{
        __strong typeof(_timeline) timeline = wtimeline;
        __strong typeof(welf) sself = welf;
        if (sself.playOnStart) {
            sself.playOnStart();
        }

        timeline.onStart = sself.timelineOnStart;
        if (timeline.onStart) {
            timeline.onStart();
        }
        sself.playOnStart     = nil;
        sself.timelineOnStart = nil;
    };
    
    _timeline.completion = ^(BOOL result) {
        __strong typeof(_timeline) timeline = wtimeline;
        __strong typeof(welf) sself = welf;
        timeline.completion = sself.timelineCompletion;
        if (timeline.completion) {
            timeline.completion(result);
        }
        if (sself.playCompletion) {
            sself.playCompletion(result);
        }
        sself.timelineCompletion = nil;
        sself.playCompletion     = nil;
    };

    [_timeline play];
}

- (void)reset {
    _timelineCompletion = nil;
    _timelineOnStart    = nil;
    _playCompletion     = nil;
    _playOnStart        = nil;
    [_timeline reset];
}

- (void)pause {
    [_timeline pause];
}

- (void)resume {
    [_timeline resume];
}

- (void)clear {
    [_timeline clear];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    GroupTimelineEntity *copy = [[GroupTimelineEntity alloc] initWithTimeline:_timeline];
    return copy;
}

- (instancetype)reversedCopyWithDuration:(NSTimeInterval)duration {
    GroupTimelineEntity *reversedCopy = [self copy];
    NSTimeInterval newDuration = duration;
    if ([_timeline isKindOfClass:[GroupTimelineAnimation class]]) {
        newDuration = _timeline.duration;
    }
    reversedCopy.timeline = [_timeline reversedWithDuration:newDuration];
    return reversedCopy;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<<%@: %p> TimelineAnimation:%@>", NSStringFromClass(self.class), self, _timeline.debugDescription];
}


@end
