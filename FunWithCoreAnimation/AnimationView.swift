//
//  AnimationView.swift
//  FunWithCoreAnimation
//
//  Created by Nguyen, Cong on 2020/12/29.
//

import UIKit

private let rightPadding: CGFloat = 200
private let duration: TimeInterval = 5.2
private let rocketAnimationDurationPortion: Double = 0.05
private let transformAnimationStartPortion: Double = 0.06
private let opacityAnimationStartPortion: Double = 0.2
private let rotationAnimationStartPortion: Double = 0.06

/// A view that holds and manages like animations.
final class AnimationView: UIView {
  /// Emit a new heart animation.
  func emit() {
    let name = "ballon\((1...6).randomElement()!)"
    let image = UIImage(named: name)!

    performHeartAnimation(for: image)
  }
}

private extension AnimationView {
  func performHeartAnimation(for image: UIImage) {
    let iconView = UIImageView(image: image)

    /// Make sure that the iconView is not in the visible area of the super view.
    iconView.frame.origin = CGPoint(x: -1000, y: -1000)
    iconView.frame.size = CGSize(width: 40, height: 40)

    addSubview(iconView)

    iconView.layer.transform = CATransform3DMakeTranslation(0, 0, CGFloat.random(in: -10000...10000))

    let posX = bounds.width - rightPadding

    let rocketStartPoint = CGPoint(x: posX, y: bounds.height + iconView.frame.height)
    let rocketEndPoint = CGPoint(
      x: posX + CGFloat.random(in: -rightPadding...rightPadding),
      y: bounds.height * 0.8 + CGFloat.random(in: -30...30))

    let animationGroup = CAAnimationGroup()
    animationGroup.animations = [
      makeRocketAnimation(from: rocketStartPoint, to: rocketEndPoint),
      makeSpringAnimation(originalTransform: iconView.layer.transform, from: rocketStartPoint, to: rocketEndPoint),
      makeBezierAnimation(startPoint: rocketEndPoint, posX: posX),
      makeOpacityAnimation(),
      makeRotationAnimation(originalTransform: iconView.layer.transform),
    ]
    animationGroup.duration = duration
    animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      iconView.removeFromSuperview()
    }
    iconView.layer.add(animationGroup, forKey: nil)
    CATransaction.commit()
  }

  func makeRocketAnimation(from point1: CGPoint, to point2: CGPoint) -> CAAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
    animation.fromValue = point1
    animation.toValue = point2
    animation.beginTime = 0
    animation.duration = rocketAnimationDurationPortion * duration
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false

    return animation
  }

  func makeSpringAnimation(originalTransform: CATransform3D, from point1: CGPoint, to point2: CGPoint) -> CAAnimation {
    let dx = point2.x - point1.x
    let dy = point1.y - point2.y
    let angle = atan(dx / dy)

    let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform))
    animation.timingFunction =
      CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    let rotationTransform = CATransform3DRotate(originalTransform, angle, 0, 0, 1)
    let finalScale = CGFloat.random(in: 1.5...2.0)
    animation.values = [
      CATransform3DScale(rotationTransform, 0.0001, 1, 1), // Use a value that's close to zero instead of zero here to avoid a wierd issue with CAAnimation.
      CATransform3DScale(rotationTransform, 0.2, 1.7, 1),
      CATransform3DScale(rotationTransform, 1.3, 0.7, 1),
      CATransform3DScale(rotationTransform, finalScale, finalScale, 1),
    ]
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false
    animation.keyTimes = [0, 0.4, 0.7, 1]
    animation.duration = transformAnimationStartPortion * duration
    animation.fillMode = .forwards

    return animation
  }

  func makeBezierAnimation(startPoint: CGPoint, posX: CGFloat) -> CAAnimation {
    let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))

    let path = UIBezierPath()
    path.move(to: startPoint)

    let endPoint = CGPoint(
      x: posX + CGFloat.random(in: -rightPadding...rightPadding),
      y: 0)
    let controlPoint1 = CGPoint(
      x: startPoint.x,
      y: bounds.height * 0.3)
    let controlPoint2 = CGPoint(
      x: endPoint.x,
      y: bounds.height * 0.1)
    path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)

    animation.path = path.cgPath

    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    animation.beginTime = rocketAnimationDurationPortion * duration
    animation.duration = duration * (1 - rocketAnimationDurationPortion)

    return animation
  }

  func makeOpacityAnimation() -> CAAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    animation.toValue = 0
    animation.duration = duration * (1 - opacityAnimationStartPortion)
    animation.beginTime = opacityAnimationStartPortion * duration
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false

    return animation
  }

  func makeRotationAnimation(originalTransform: CATransform3D) -> CAAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
    let rotation = CATransform3DRotate(originalTransform, CGFloat.random(in: 1...3) * CGFloat.pi, 0, 1, 0)
    let finalScale = CGFloat.random(in: 2...5)
    animation.toValue = CATransform3DScale(rotation, finalScale, finalScale, 1)
    animation.beginTime = rotationAnimationStartPortion * duration
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false
    return animation
  }
}
