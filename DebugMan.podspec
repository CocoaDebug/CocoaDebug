Pod::Spec.new do |s|

  s.name         = "DebugMan"
  s.version      = "4.7.9"
  s.summary      = "Debugger tool for iOS"
  s.description  = <<-DESC
                    DebugMan is an debugger tool for iOS, support both Swift and Objective-C language :

                    - Display all app network http requests details, including SDKs and image preview.
                    - Display app device informations and app identity informations.
                    - Display all app logs in different colors as you like.
                    - Display app crash logs.
                    - Preview and share sandbox files on device/simulator.
                    - Shake device/simulator to hide/show the black bubble.
                    - App memory real-time monitoring displayed in the black bubble.
                    - Long press the black bubble to show Apple's UIDebuggingInformationOverlay. (also available in iOS11)
                    
                    Welcome to star and fork. If you have any questions, welcome to open issues.
                   DESC
  s.homepage     = "https://github.com/liman123/DebugMan"
  s.license      = "MIT"
  s.author             = { "liman" => "723661989@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/liman123/DebugMan.git", :tag => "#{s.version}" }
  s.source_files  = "Sources", "Sources/**/*.{h,m,swift}"
  s.public_header_files = "Sources/**/*.h"
  s.resources = "Sources/**/*.{png,xib,storyboard}"
  s.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
  s.pod_target_xcconfig = {'SWIFT_VERSION' => '4.0'}

end
