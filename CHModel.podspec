Pod::Spec.new do |s|
  s.name         = "CHModel"
  s.version      = "0.0.1"
  s.summary      = "analytical network data"
  s.description  = <<-DESC
                   1.you can use it analytiacal network data
                   2.you can use it analytical the custom Json data
                   DESC
  s.homepage     = "https://github.com/GithubChinaCH/CHModel"
  s.license      = "MIT"
  s.author             = { "chenhao" => "chenh@kunion.com.cn" }
  s.source       = { :git => "https://github.com/GithubChinaCH/CHModel.git", :tag => "0.0.1" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files  = "class/*"
end
