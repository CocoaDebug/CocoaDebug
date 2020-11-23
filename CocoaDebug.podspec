Pod::Spec.new do |s|
  s.name                = "CocoaDebug"
  s.summary             = "iOS Debugging Tool"
  s.homepage            = "https://github.com/CocoaDebug/CocoaDebug"
  s.author              = {"CocoaDebug" => "man.li@shopee.com"}
  s.license             = "MIT"
  s.source_files        = "Sources", "Sources/**/*.{h,m,mm,swift,c}"
  s.public_header_files = "Sources/**/*.h"
  s.resources           = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks          = 'UIKit', 'Foundation'
  s.platform            = :ios, "10.0"
  s.swift_version       = '5.0'
  s.version             = '1.5.6'
  s.source              = { :git => "https://github.com/CocoaDebug/CocoaDebug.git", :branch => 'master', :tag => s.version.to_s }
  s.requires_arc        = false
  s.requires_arc        = 
                          [
                          'Sources/App/**/*.m',
                          'Sources/Categories/**/*.m',
                          'Sources/Core/**/*.m',
                          'Sources/CustomHTTPProtocol/**/*.m',
                          'Sources/LeaksFinder/**/*.m',
                          'Sources/Logs/**/*.m',
                          'Sources/Network/**/*.m',
                          'Sources/Sandbox/**/*.m',
                          'Sources/Swizzling/**/*.m',
                          'Sources/Window/**/*.m',
                          'Sources/fishhook/**/*.c',
                          ]
  s.dependency 'React'
end
