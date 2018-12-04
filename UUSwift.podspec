Pod::Spec.new do |s|
  s.name     = 'UUSwift'
  s.version  = '1.0.0'
  s.license          = { :type => 'Apache 2.0' }
  s.summary  = "A set of useful utilities for writing apps in Cocoa"
  s.homepage = 'https://silverpine.com'
  s.author           = "Jonathan Hays"
  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.social_media_url = "https://twitter.com/cheesemaker"
  s.source   = { :git => 'https://github.com/SilverPineSoftware/UUSwift.git', :tag => '1.0.0' }
  s.swift-version = 4.0
  s.source_files = 'UUSwift'
  s.frameworks = 'UIKit', 'Foundation'
end

