Pod::Spec.new do |s|

  s.name         = "DebugMan"
  s.version      = "4.4.0"
  s.summary      = "debugger tool for iOS in Swift"
  s.description  = <<-DESC
                    DebugMan is an debugger tool for iOS in Swift, released under the MIT License. The author stole the idea from remirobert/Dotzu and JxbSir/JxbDebugTool so that people can make crappy clones.

                    DebugMan has the following features:

                    ● display all app logs in different colors as you like.
                    ● display all app network http requests details, including third-party SDK in app.
                    ● display app device informations and app identity informations.
                    ● display app crash logs.
                    ● filter keywords in app logs and app network http requests.
                    ● app memory real-time monitoring.

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
