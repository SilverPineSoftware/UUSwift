Pod::Spec.new do |s|
  	s.name             = "UUSwift"
  	s.version          = "0.0.13"

  	s.description      = <<-DESC
                       UUSwift is a framework to extend the base Foundation and UIKit classes. UUSwift eliminates many of the tedious tasks associated with Swift development such as date formating and string manipulation.
                       DESC
  	s.summary          = "UUSwift extends Foundation and UIKit to add additional functionality to make development more efficient."

  	s.homepage         = "https://github.com/SilverPineSoftware/UUSwift"
  	s.author           = "Silverpine Software"
  	s.license          = { :type => 'MIT' }
  	s.source           = { :git => "https://github.com/SilverPineSoftware/UUSwift.git", :tag => s.version.to_s }

	s.ios.deployment_target = "8.0"
	s.osx.deployment_target = "10.10"
	s.tvos.deployment_target = "10.0"
	s.swift_version = "5.0"

	s.subspec 'Core' do |ss|
    	ss.source_files = 'UUSwift/**/*.{h,m,swift}'
    	ss.ios.frameworks = 'UIKit', 'Foundation'
		ss.osx.frameworks = 'CoreFoundation'
		ss.tvos.frameworks = 'UIKit', 'Foundation'
  	end

end

