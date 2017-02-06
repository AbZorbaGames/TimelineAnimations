//
//  TimelineAnimation+Audio.h
//  BlackJack
//
//  Created by Georges Boumis on 15/12/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

@import Foundation;
#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TimelineAudio <NSObject>
@property (nonatomic, readonly) NSTimeInterval duration;
- (void)play;
- (void)stop:(BOOL)fadeOut;
@end

NS_ASSUME_NONNULL_END
