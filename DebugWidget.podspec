Pod::Spec.new do |s|
  s.name                = "DebugWidget"
  s.summary             = "DebugWidget"
  s.description         = <<-DESC
                              Debug Widget for iOS
                             DESC
  s.homepage            = "https://github.com/DebugWidget/DebugWidget"
  s.author              = { "DebugWidget" => "DebugWidget@protonmail.com" }
  s.license             = "MIT"
  s.source_files        = "Sources", "Sources/**/*.{h,m,swift}"
  s.public_header_files = "Sources/**/*.h"
  s.resources           = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks          = 'UIKit', 'Foundation'
  s.requires_arc        = true
  s.swift_version       = '4.0'
  s.platform            = :ios, "8.0"
  s.source              = { :git => "https://github.com/DebugWidget/DebugWidget.git", :branch => 'master', :tag => '0.0.2' }
  s.version             = '0.0.2'
end
