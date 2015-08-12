#
# Be sure to run `pod lib lint GFPlayerView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GFPlayerView"
  s.version          = "0.1.0"
  s.summary          = "A subclass on UIView that displays gifs."
  s.description      = <<-DESC
                       GFPlayerView lets you display gifs inside a modern player that also enables creators to link gifs back to their website or social network.

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/GifYoutube/GFPlayerView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "jeon97" => "j.jeon971@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/GFPlayerView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GFPlayerView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
