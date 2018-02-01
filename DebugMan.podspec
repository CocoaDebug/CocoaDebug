Pod::Spec.new do |s|

  s.name         = "DebugMan"
  s.version      = "4.7.5"
  s.summary      = "Debugger tool for iOS"
  s.description  = <<-DESC
                    DebugMan is an debugger tool for iOS, with the following features:

                    ● Display all app network http requests details, including SDKs and image preview.
                    ● Display app device informations and app identity informations.
                    ● Preview and share sandbox files on device/simulator.
                    ● Display all app logs in different colors as you like.
                    ● App memory real-time monitoring.
                    ● Display app crash logs.

                    Welcome to star and fork. If you have any questions, welcome to open issues.
                   DESC
  s.homepage     = "https://github.com/liman123/DebugMan"
  s.license      = "MIT"
  s.author             = { "liman" => "gg723661989@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/liman123/DebugMan.git", :tag => "#{s.version}" }
  s.source_files  = "Sources", "Sources/**/*.{h,m,swift}"
  s.public_header_files = "Sources/**/*.h"
  s.resources = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
  s.pod_target_xcconfig = {'SWIFT_VERSION' => '4.0'}

end
