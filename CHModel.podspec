Pod::Spec.new do |s|
  s.name         = "CHModel"
  s.version      = "0.3.0"
  s.summary      = "analytical network data"
  s.description  = <<-DESC
                   1.you can use it analytiacal network data
                   2.you can use it analytical the custom Json data
                   DESC
  s.homepage     = "https://github.com/jhchenhao/CHModel"
  s.license      = "MIT"
  s.author       = { "chenhao" => "jhtxchenhao@163.com" }
  s.source       = { :git => "https://github.com/jhchenhao/CHModel.git", :tag => s.version}
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = "class/objc/*.{h,m}"
  s.frameworks   = 'UIKit','Foundation'
  s.dependency 'AFNetworking', '~> 3.0.4'
end
