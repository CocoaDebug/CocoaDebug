Pod::Spec.new do |s|
  s.name                = "CocoaDebug"
  s.summary             = "iOS Debugging Tool"
  s.homepage            = "https://github.com/CocoaDebug/CocoaDebug"
  s.author              = {"CocoaDebug" => "man.li@shopee.com"}
  s.license             = "MIT"
  s.source_files        = "Sources", "Sources/**/*.{h,m,swift,c}"
  s.public_header_files = "Sources/**/*.h"
  s.resources           = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks          = 'UIKit', 'Foundation'
  s.requires_arc        = true
  s.platform            = :ios, "8.0"
  s.swift_version       = '5.0'
  s.version             = '1.0.3'
  s.source              = { :git => "https://github.com/CocoaDebug/CocoaDebug.git", :branch => 'master', :tag => s.version.to_s }
  s.requires_arc        = false
  s.requires_arc        = 
                          [
                          'Classes/App', 
                          'Classes/Categories', 
                          'Classes/Core', 
                          'Classes/CustomHTTPProtocol', 
                          'Classes/Logs',
                          'Classes/Network',
                          'Classes/Sandbox',
                          'Classes/Swizzling',
                          'Classes/WHDebugTool', 
                          'Classes/Window'
                          ]

end
