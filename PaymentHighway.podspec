Pod::Spec.new do |s|

  s.name         = "PaymentHighway"
  s.version      = "2.0.1"
  s.summary      = "Payment Highway framework for iOS."
  s.description  = <<-DESC
		   This is the Payment Highway iOS SDK. Payment Highway is the app payments toolkit built for developers who are busy building great apps.
                   DESC
  s.homepage     = "https://paymenthighway.io"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Arno Hietanen" => "arno.hietanen@paymenthighway.fi" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/paymenthighway/paymenthighway-ios-framework.git", :tag => "v-#{s.version}" }
  s.requires_arc = true

  s.swift_version = "4.1"
  s.ios.deployment_target = '9.0'
  s.resources = ["PaymentHighway/**/*.{xib,lproj,xcassets,png}"]
  s.source_files  = "PaymentHighway/**/*.{swift,h}"
  s.frameworks  = "Foundation", "UIKit"
  s.resource_bundles = {
    'PaymentHighway' => ['PaymentHighway/**/*.{xib,lproj,xcassets,png}']
  } 
  s.dependency "Alamofire", "~> 4.7.3"
  s.dependency "CryptoSwift", "~> 0.12.0"

end
