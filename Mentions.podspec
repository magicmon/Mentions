#
# Be sure to run `pod lib lint Mentions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Mentions'
  s.version          = '0.1.1'
  s.summary          = 'An easy way to add mentions in UITextView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/magicmon/Mentions'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'magicmon' => 'sagun25si@gmail.com' }
  s.source           = { :git => 'https://github.com/magicmon/Mentions.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Mentions/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Mentions' => ['Mentions/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
