Pod::Spec.new do |s|
  s.name         = "WYZLRCParser"
  s.version      = "0.0.1"
  s.summary      = "Parse LRC file."

  s.homepage     = "http://gitlab.hujiang.com/ios/lrcparser"

  s.license      = 'MIT (example)'

  s.author       = { "Yozone Wang" => "wangyaozh@gmail.com" }

  s.source       = { :git => "git@gitlab.hujiang.com:ios/lrcparser.git", :tag => "0.0.1" }

  s.platform     = :ios, '5.0'

  s.source_files = '*.{h,m}'

  s.requires_arc = true
end
