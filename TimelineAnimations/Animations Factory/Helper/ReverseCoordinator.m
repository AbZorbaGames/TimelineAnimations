//
//  ReverseCoordinator.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 22/06/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "ReverseCoordinator.h"
#import "TimelineAnimation.h"

@interface ReverseCoordinator ()
@property (nonatomic, copy) ReverseCoordinatorCompletionBlock completion;
@end

@implementation ReverseCoordinator

- (instancetype)init {
    return [self initWithTimeline:[TimelineAnimation timelineAnimation] completion:^(__kindof TimelineAnimation * _Nonnull timeline){}];
}

- (instancetype)initWithTimeline:(__kindof TimelineAnimation *)timelineAnimation
                      completion:(ReverseCoordinatorCompletionBlock)completion {
    self = [super init];
    if (self) {
        _completion = completion;
        _timeline = timelineAnimation;
        [_timeline addObserver:self
                    forKeyPath:@"finished"
                       options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                       context:NULL];
    }
    return self;
}

- (void)dealloc {
    [_timeline removeObserver:self forKeyPath:@"finished"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"finished"]) {
        NSNumber *old = change[NSKeyValueChangeOldKey];
        NSNumber *new = change[NSKeyValueChangeNewKey];
        if (old.boolValue == NO && new.boolValue == YES) {
            if (_completion) {
                _completion(_timeline);
            }
            _completion = nil;
        }
        return;
    }

    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

@end
