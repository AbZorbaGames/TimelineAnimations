#
# Be sure to run `pod lib lint TimelineAnimations.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TimelineAnimations'
  s.version          = '2.10.10'
  s.summary          = 'A powerfull wrapper around CoreAnimation that facilitates the sequencing of animations.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A powerfull wrapper around CoreAnimation that facilitates the sequencing of animations.
                       DESC

  s.homepage         = 'https://github.com/AbZorbaGames/TimelineAnimations'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'boumis' => 'boumis@abzorbagames.com' }
  s.source           = { :git => 'https://github.com/AbZorbaGames/TimelineAnimations', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TimelineAnimations/Classes/**/*'
  s.public_header_files = 'TimelineAnimations/Classes/objc/AnimationsFactory.h', 'TimelineAnimations/Classes/objc/AnimationsKeyPath.h', 'TimelineAnimations/Classes/objc/SpecialEasing/CAKeyframeAnimation+SpecialEasing.h', 'TimelineAnimations/Classes/objc/EasingTiming/EasingTimingHandler.h', 'TimelineAnimations/Classes/objc/GroupTimelineAnimation.h', 'TimelineAnimations/Classes/objc/Helper/KeyValueBlockObservation.h', 'TimelineAnimations/Classes/objc/TimelineAnimation.h', 'TimelineAnimations/Classes/objc/TimelineAnimations.h', 'TimelineAnimations/Classes/objc/Audio/TimelineAudio.h', 'TimelineAnimations/Classes/objc/Audio/TimelineAudioAssociation.h', 'TimelineAnimations/Classes/objc/Types.h', 'TimelineAnimations/Classes/objc/SpecialEasing/TimelineAnimationSpecialTimingFunction.h', 'TimelineAnimations/Classes/objc/Helper/TimelineAnimationDescription.h'

  
  #s.xcconfig = { 
  #    "SWIFT_VERSION" => '4.2'
  #}

  # s.resource_bundles = {
  #   'TimelineAnimations' => ['TimelineAnimations/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'QuartzCore'
end
