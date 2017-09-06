//
//  TimelineAnimationsBlankLayer.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

@import QuartzCore;
#import "AnimationsKeyPath.h"

@interface TimelineAnimationsBlankLayer : CALayer
@property (nonatomic, assign) id blank;

@property (nonatomic, class, readonly) AnimationKeyPath keyPath;
@end
