#
# Be sure to run `pod lib lint ServiceDeskKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ServiceDeskKit'
  s.version          = '1.0.3'
  s.summary          = 'JIRA Service Desk Atlassian Tickets for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Using ServiceDeskKit you can generate forms directly for Atlassian's JIRA
                       DESC

  s.homepage         = 'https://github.com/willpowell8/ServiceDeskKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'willpowell8' => 'willpowell8@gmail.com' }
  s.source           = { :git => 'https://github.com/willpowell8/ServiceDeskKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/willpowelluk'

  s.ios.deployment_target = '8.0'
s.swift_version = '3.0'

  s.source_files = 'ServiceDeskKit/Classes/**/*'
  
  s.resource_bundles = {
     'ServiceDeskKit' => ['ServiceDeskKit/Assets/{*.png,*.xib}']
  }
  s.dependency 'MBProgressHUD'
end
