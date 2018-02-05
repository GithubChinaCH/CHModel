Pod::Spec.new do |s|
  s.name         = "CHModel"
  s.version      = "3.0.0"
  s.summary      = "analytical network data/3.0.0以后的版本是swift"
  s.description  = <<-DESC
                   1.you can use it analytiacal network data
                   2.you can use it analytical the custom Json data
                   DESC
  s.homepage     = "https://github.com/GithubChinaCH/CHModel"
  s.license      = "MIT"
  s.author       = { "chenhao" => "jhtxchenhao@163.com" }
  s.source       = { :git => "https://github.com/GithubChinaCH/CHModel.git", :tag => s.version}
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = "class/*.swift"
  s.frameworks   = 'UIKit','Foundation'
end
