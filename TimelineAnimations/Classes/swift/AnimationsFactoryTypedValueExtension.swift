//
//  AnimationsFactoryTypedValueExtension.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 11/01/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation
import QuartzCore

public protocol TypedValueConvertible {
    var asTypedValue: AnimationsFactory.TypedValue { get }
}

public extension CAKeyframeAnimation {

    public enum CalculationMode {
        case linear
        case discrete
        case paced
        case cubic
        case cubicPaced
        
        internal var value: CAAnimationCalculationMode {
            switch self {
            case CAKeyframeAnimation.CalculationMode.linear:
                return CAAnimationCalculationMode.linear
            case CAKeyframeAnimation.CalculationMode.discrete:
                return CAAnimationCalculationMode.discrete
            case CAKeyframeAnimation.CalculationMode.paced:
                return CAAnimationCalculationMode.paced
            case CAKeyframeAnimation.CalculationMode.cubic:
                return CAAnimationCalculationMode.cubic
            case CAKeyframeAnimation.CalculationMode.cubicPaced:
                return CAAnimationCalculationMode.cubicPaced
            }
        }
    }

    public enum RotationMode {
        case auto
        case autoreverse
        
        internal var value: CAAnimationRotationMode {
            switch self {
            case CAKeyframeAnimation.RotationMode.auto:
                return CAAnimationRotationMode.rotateAuto
            case CAKeyframeAnimation.RotationMode.autoreverse:
                return CAAnimationRotationMode.rotateAutoReverse
            }
        }
    }
}

public extension AnimationsFactory {
    
    
    public static func convertToTypedValues<T: TypedValueConvertible>(_ array: [T]) -> [AnimationsFactory.TypedValue] {
        return array.map { $0.asTypedValue }
    }

    public enum TypedValue {
        case point(CGPoint) // CGPoint
        case transform(CATransform3D) // CATransform3D
        case value(CGFloat) // CGFloat
        case frame(CGRect) // CGFloat
        case float(Float) // Float
        case size(CGSize) // CGSize
        case array([Any]) // [Any]
        case bool(Bool) // Bool
        case null // nil
        case custom(Any)

        public var value: Any? {
            switch self {
            case TypedValue.point(let point):
                return NSValue(cgPoint: point)
            case TypedValue.transform(let transform):
                return NSValue(caTransform3D: transform)
            case TypedValue.value(let v):
                return NSNumber(value: Double(v))
            case TypedValue.frame(let frame):
                return NSValue(cgRect: frame)
            case TypedValue.float(let v):
                return NSNumber(value: Float(v))
            case TypedValue.size(let size):
                return NSValue(cgSize: size)
            case TypedValue.array(let array):
                return array
            case TypedValue.bool(let b):
                return NSNumber(value: b)
            case TypedValue.null:
                return nil
            case let TypedValue.custom(o):
                return o
            }
        }
    }

    final public class func animate(keyPath: AnimationKeyPath,
                                    fromValue: AnimationsFactory.TypedValue?,
                                    toValue: AnimationsFactory.TypedValue?,
                                    duration: TimeInterval = TimeInterval(1.0),
                                    timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CAPropertyAnimation {
        let animation = { () -> CAPropertyAnimation in
            if EasingTimingHandler.isSpecialTimingFunction(tf) {
                let animation = CAKeyframeAnimation.animation(keyPath: keyPath,
                                                              function: EasingTimingHandler.easingFunction(from: tf),
                                                              from: fromValue!,
                                                              to: toValue!)
                return animation as CAPropertyAnimation
            }
            else {
                let animation = CABasicAnimation(keyPath: keyPath)
                animation.fromValue = fromValue?.value
                animation.toValue = toValue?.value
                animation.timingFunction = EasingTimingHandler.function(withType: tf)
                return animation as CAPropertyAnimation
            }
        }()
        animation.duration = CFTimeInterval(duration)
        return animation
    }

    final public class func keyframeAnimation(keyPath: AnimationKeyPath,
                                              values: [AnimationsFactory.TypedValue],
                                              keyTimes: [RelativeTime]? = nil,
                                              duration: TimeInterval = TimeInterval(1.0),
                                              calculationMode: CAKeyframeAnimation.CalculationMode = CAKeyframeAnimation.CalculationMode.linear,
                                              rotationMode: CAKeyframeAnimation.RotationMode? = nil,
                                              timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CAKeyframeAnimation {

        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.values = values.map { $0.value as Any }
        if let kt = keyTimes {
            animation.keyTimes = kt.map { NSNumber(value: $0) } as [NSNumber]
            assert(values.count == kt.count)
        }
        animation.timingFunction = EasingTimingHandler.function(withType: tf)
        animation.calculationMode = calculationMode.value
        animation.rotationMode = rotationMode?.value
        return animation
    }

    final public class func keyframeAnimation(keyPath: AnimationKeyPath,
                                              path: CGPath,
                                              duration: TimeInterval = TimeInterval(1.0),
                                              calculationMode: CAKeyframeAnimation.CalculationMode = CAKeyframeAnimation.CalculationMode.linear,
                                              rotationMode: CAKeyframeAnimation.RotationMode? = nil,
                                              timingFunction tf: ECustomTimingFunction = ECustomTimingFunction.linear) -> CAKeyframeAnimation {

        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.path = path
        animation.timingFunction = EasingTimingHandler.function(withType: tf)
        animation.calculationMode = calculationMode.value
        animation.rotationMode = rotationMode?.value
        return animation
    }
}


extension CATransform3D: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.transform(self)
    }
}

extension CGAffineTransform: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.transform(CATransform3DMakeAffineTransform(self))
    }
}

extension CGFloat: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.value(self)
    }
}

extension Double: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.value(CGFloat(self))
    }
}

extension Float: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.float(self)
    }
}

extension Int: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.value(CGFloat(self))
    }
}

extension CGPoint: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.point(self)
    }
}

extension CGRect: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.frame(self)
    }
}

extension CGSize: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.size(self)
    }
}

extension Bool: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.bool(self)
    }
}

extension Array: TypedValueConvertible {
    public var asTypedValue: AnimationsFactory.TypedValue {
        return AnimationsFactory.TypedValue.array(self)
    }
}

extension Optional where Wrapped: TypedValueConvertible {
    var asTypedValue: AnimationsFactory.TypedValue {
        if let value = self {
            return value.asTypedValue
        }
        else {
            return AnimationsFactory.TypedValue.null
        }
    }
}
