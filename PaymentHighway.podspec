Pod::Spec.new do |s|

  s.name         = "PaymentHighway"
  s.version      = "1.0.5"
  s.summary      = "Solinor Payment Highway framework for iOS."
  s.description  = <<-DESC
		   This is the Solinor Payment Highway iOS SDK. Solinor Payment Highway is the smoothest service for accepting card payments, one-click payments, recurring charging and for tailor made payment solutions.
                   DESC
  s.homepage     = "https://paymenthighway.fi"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Juha Salo" => "juha.salo@solinor.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/solinor/paymenthighway-ios-framework.git", :tag => "v-#{s.version}" }
  s.requires_arc = true

  s.resources = ["PaymentHighway/*.{storyboard,lproj,xcassets,png}", "PaymentHighway/IQKeybordManagerSwift/Resources/IQKeyboardManager.bundle/*.png"]
  s.source_files  = "PaymentHighway", "PaymentHighway/*.{h,swift}"
  s.frameworks  = "Foundation", "UIKit"

  s.dependency "Alamofire", "~> 4.4.0"
  s.dependency "SwiftyJSON", "~> 3.1.4"
  s.dependency "CryptoSwift", "~> 0.6.9"

end
