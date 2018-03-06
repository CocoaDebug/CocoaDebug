Pod::Spec.new do |s|
  s.name                = "DotzuX"
  s.summary             = "DotzuX"
  s.description         = <<-DESC
                              Next Generation of Dotzu
                             DESC
  s.homepage            = "https://github.com/DotzuX/DotzuX"
  s.license             = "MIT"
  s.author              = { "liman" => "723661989@163.com" }
  s.source_files        = "Sources", "Sources/**/*.{h,m,swift}"
  s.public_header_files = "Sources/**/*.h"
  s.resources           = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks          = 'UIKit', 'Foundation'
  s.requires_arc        = true
  s.platform            = :ios, "8.0"
  s.swift_version       = '4.0'
  s.version             = "0.0.1"
  s.source              = { :git => "https://github.com/DotzuX/DotzuX.git", :branch => 'master', :tag => '0.0.1' }
end
