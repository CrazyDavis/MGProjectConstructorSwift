Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "MGProjectConstructorSwift"
  s.version      = "1.0.3"
  s.summary      = "A Project Base Constructor."

  s.description  = <<-DESC
                   A Project Base Constructor.
                   DESC

  s.homepage     = "https://github.com/MagicalWater/MGProjectConstructorSwift"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "water" => "crazydennies@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/MagicalWater/MGProjectConstructorSwift.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "MGProjectConstructorSwift/MGProjectConstructorSwift/Classes/**/*"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.resources = "MGProjectConstructorSwift/MGProjectConstructorSwift/Classes/raw/*.*"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.framework  = "UIKit"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.dependency 'MGUtilsSwift'
  s.dependency 'MGExtensionSwift'
  s.dependency 'R.swift', '~> 5.0.0.alpha.2'
  s.dependency 'SwiftyJSON', '~> 4.2.0'

end
