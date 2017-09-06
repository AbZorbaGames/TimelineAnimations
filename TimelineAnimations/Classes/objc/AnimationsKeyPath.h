//
//  AnimationsKeyPath.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 08/09/2015.
//  Copyright (c) 2015-2016 AbZorba Games. All rights reserved.
//

@import Foundation;

typedef NSString *const AnimationKeyPath NS_EXTENSIBLE_STRING_ENUM;


// CALayer
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathPosition; // CGPoint
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathPositionX; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathPositionY; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathZposition; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathAnchorPoint; // CGPoint
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathAnchorPointZ; // CGPoint
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathBounds; // CGRect
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathWidth; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathHeight; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathFrame; // CGRect
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathFrameSize; // CGSize

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathTransform; // CATransform3D
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathSublayerTransform; // CATransform3D

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathRotation; // CGFloat in radians
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathRotationY; // CGFloat in radians

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathScale; // CGFloat?
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathScaleX; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathScaleY; // CGFloat

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathOpacity; // CGFloat

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathShadowOpacity; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathShadowRadius; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathShadowOffset; // CGSize
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathShadowColor; // CGColor
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathShadowPath; // CGPath

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathContents; // Any
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathContentsRect; // CGRect
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathContentsCenter; // CGRect
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathMasksToBounds; // Bool
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathIsDoubleSided; // Bool
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathCornerRadius; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathBorderWidth; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathBorderColor; // CGColor
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathIsHidden; // CGColor
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathBackgroundColor; // CGColor

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathFilters; // [CIFilter]
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathCompositingFilter; // CIFilter
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathBackgroundFilters; // [CIFilter]

FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathShouldRasterize; // Bool

// CAEmitterLayer
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathEmitterPosition; // CGPoint
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathEmitterZposition; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathEmitterSize; // CGSize
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathSpin; // Float
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathVelocity; // Float
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathBirthRate; // Float
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathLifetime; // Float

// CAShapeLayer
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathFillColor; // CGColor
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathStrokeColor; // CGColor
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathLineDashPhase; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathLineWidth; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathMisterLimit; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathStrokeEnd; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathStrokeStart; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathPath; // CGPath

// CATextLayer
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathFontSize; // CGFloat
FOUNDATION_EXTERN AnimationKeyPath kAnimationKeyPathForegroundColor; // CGColor
