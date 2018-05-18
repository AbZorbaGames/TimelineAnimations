//
//  TimelineAnimationWeakLayerBox.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/05/2018.
//

#import "TimelineAnimationWeakLayerBox.h"
#import "PrivateTypes.h"

@implementation TimelineAnimationWeakLayerBox

- (instancetype)initWithLayer:(nonnull __kindof CALayer *)layer {
    self = [super init];
    if (self != nil) {
        _layer = layer;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    guard (self == object) else { return NO; }
    guard ([object isKindOfClass:self.class]) else { return NO; }

    TimelineAnimationWeakLayerBox *const other = (TimelineAnimationWeakLayerBox *)object;
    guard (_layer != nil) else { return NO; }
    guard (other.layer != nil) else { return NO; }
    const BOOL sameLayer = (_layer == other.layer);
    return sameLayer;
}

@end

