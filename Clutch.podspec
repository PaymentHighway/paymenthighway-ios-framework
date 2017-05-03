Pod::Spec.new do |s|

  s.name         = "Clutch"
  s.version      = "1.0.4" # TODO change
  s.summary      = "Solinor Payment Highway framework for iOS."
  s.description  = <<-DESC
		   Solinor Payment Highway framework for iOS.
                   DESC
  s.homepage     = "https://paymenthighway.fi"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Juha Salo" => "juha.salo@solinor.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "git@github.com:solinor/paymenthighway-ios-framework.git", :tag => "#{s.version}" } # TODO change tag
  s.requires_arc = true

  s.resources = ["Clutch/*.{storyboard,lproj,xcassets,png}", "Clutch/IQKeybordManagerSwift/Resources/IQKeyboardManager.bundle/*.png"]
  s.source_files  = "Clutch", "Clutch/*.{h,swift}"
  s.frameworks  = "Foundation", "UIKit"

  s.dependency "Alamofire", "~> 4.4.0"
  s.dependency "SwiftyJSON", "~> 3.1.4"
  s.dependency "CryptoSwift", "~> 0.6.9"

end
