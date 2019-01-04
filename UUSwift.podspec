Pod::Spec.new do |s|
  	s.name             = "UUSwift"
  	s.version          = "0.0.9"

  	s.description      = <<-DESC
                       UUSwift is a framework to extend the base Foundation and UIKit classes.
                       DESC
  	s.summary          = "UUSwift extends Foundation and UIKit to add additional functionality."

  	s.homepage         = "https://github.com/SilverPineSoftware/UUSwift"
  	s.author           = "Silverpine Software"
  	s.license          = { :type => 'Apache 2.0' }
  	s.source           = { :git => "https://github.com/SilverPineSoftware/UUSwift.git", :tag => s.version.to_s }

	s.ios.deployment_target = "8.0"
	s.osx.deployment_target = "10.10"

	s.swift_version = "4.0"

	s.subspec 'Core' do |ss|
    	ss.source_files = 'UUSwift/**/*.{h,m,swift}'
    	ss.ios.frameworks = 'UIKit', 'Foundation'
		ss.osx.frameworks = 'CoreFoundation'
  	end

end

