Pod::Spec.new do |s|
  s.name                = "CocoaDebug"
  s.summary             = "iOS Debugging Tool"
  s.homepage            = "https://github.com/CocoaDebug/CocoaDebug"
  s.author              = { "CocoaDebug" => "CocoaDebug@gmail.com" }
  s.license             = "MIT"
  s.source_files        = "Sources", "Sources/**/*.{h,m,swift}"
  s.public_header_files = "Sources/**/*.h"
  s.resources           = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks          = 'UIKit', 'Foundation'
  s.requires_arc        = true
  s.swift_version       = '4.2'
  s.platform            = :ios, "8.0"
  s.source              = { :git => "https://github.com/CocoaDebug/CocoaDebug.git", :branch => 'master', :tag => '0.5.2' }
  s.version             = '0.5.2'
end
