Pod::Spec.new do |s|

  s.name         = "Clutch"
  s.version      = "1.0.4"
  s.summary      = "Solinor Payment Highway framework for iOS."
  s.description  = <<-DESC
		   This is the Solinor Payment Highway iOS SDK. Solinor Payment Highway is the smoothest service for accepting card payments, one-click payments, recurring charging and for tailor made payment solutions.
                   DESC
  s.homepage     = "https://paymenthighway.fi"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Juha Salo" => "juha.salo@solinor.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "git@github.com:solinor/paymenthighway-ios-framework.git", :tag => "v-#{s.version}" }
  s.requires_arc = true

  s.resources = ["Clutch/*.{storyboard,lproj,xcassets,png}", "Clutch/IQKeybordManagerSwift/Resources/IQKeyboardManager.bundle/*.png"]
  s.source_files  = "Clutch", "Clutch/*.{h,swift}"
  s.frameworks  = "Foundation", "UIKit"

  s.dependency "Alamofire", "~> 4.4.0"
  s.dependency "SwiftyJSON", "~> 3.1.4"
  s.dependency "CryptoSwift", "~> 0.6.9"

end
