#
# Be sure to run `pod lib lint XBPushChat.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "XBPushChat"
  s.version          = "0.5.2.5"
  s.summary          = "XBPushChat is a part of XBMobile family, which support you build up a chat application with minimum config & requirement of server"
  s.description      = <<-DESC
                       XBPushChat is a part of XBMobile family, which support you build up a chat application with minimum config & requirement of server
Requirement:
iOS 7.0
PushChat server code (which will be publish soon :D sorry about this)
                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/EugeneNguyen/XBPushChat"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "eugenenguyen" => "xuanbinh91@gmail.com" }
  s.source           = { :git => "https://github.com/EugeneNguyen/XBPushChat.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'XBPushChat' => ['Pod/Assets/*']
  }

  #s.library = 'xml2'
  #s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'JSQMessagesViewController', , '7.0.0'
  s.dependency 'XBMobile'
  s.dependency 'UIImage+ImageCompress'
  s.dependency 'IDMPhotoBrowser'
  s.dependency 'XBLanguage'
  s.dependency 'XBGallery'
end
