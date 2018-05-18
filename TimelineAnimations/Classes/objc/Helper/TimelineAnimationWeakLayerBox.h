//
//  TimelineAnimationWeakLayerBox.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/05/2018.
//

@import Foundation;

@interface TimelineAnimationWeakLayerBox: NSObject

@property (nonatomic, weak) __kindof CALayer *layer;

- (instancetype)initWithLayer:(nonnull __kindof CALayer *)layer;

@end

