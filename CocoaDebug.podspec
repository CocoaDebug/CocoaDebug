Pod::Spec.new do |s|
  s.name                = "CocoaDebug"
  s.version             = "1.7.7"
  s.summary             = "iOS Debug Tool"
  s.homepage            = "https://github.com/CocoaDebug/CocoaDebug"
  s.author              = {"CocoaDebug" => "CocoaDebug@gmail.com"}
  s.license             = "MIT"
  s.source_files        = "Sources", "Sources/**/*.{h,m,mm,swift,c}"
  s.public_header_files = "Sources/**/*.h"
  s.resources           = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks          = 'UIKit', 'Foundation', 'JavaScriptCore', 'QuickLook'
  s.platform            = :ios, "12.0"
  s.swift_version       = '5.0'
  s.source              = { :git => "https://github.com/CocoaDebug/CocoaDebug.git", :branch => 'master', :tag => s.version.to_s }
  s.requires_arc        = false
  s.requires_arc        = 
                          [
                          'Sources/App/**/*.m',
                          'Sources/Categories/**/*.m',
                          'Sources/Core/**/*.m',
                          'Sources/CustomHTTPProtocol/**/*.m',
                          'Sources/Logs/**/*.m',
                          'Sources/Network/**/*.m',
                          'Sources/Sandbox/**/*.m',
                          'Sources/Swizzling/**/*.m',
                          'Sources/Window/**/*.m',
                          'Sources/fishhook/**/*.c',
                          ]
  # s.dependency "React/Core"
  # s.dependency "Protobuf"
end
