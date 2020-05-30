Pod::Spec.new do |spec|
  spec.name         = "XSound"
  spec.version      = "0.0.1"
  spec.summary      = "基于AudioToolbox的音频播放"
  
  spec.description  = <<-DESC
  基于AudioToolbox的音频播放
  DESC
  
  spec.ios.deployment_target = "9.0"
  
  spec.homepage     = "https://github.com/oogh/XSound"
  spec.author       = { "oogh" => "oogh216@163.com" }
  spec.source       = { :git => "https://github.com/oogh/XSound.git", :tag => "#{spec.version}" }
  
  spec.subspec 'coresound' do |coresound|
    coresound.source_files  = "coresound/**/*.{h,hpp,cpp}", "coresound/iOS/**/*.{h,hpp,cpp,m,mm}"
    coresound.exclude_files = "coresound/Android"
    
    coresound.public_header_files = "coresound/**/*.{h,hpp}", "coresound/iOS/**/*.{h,hpp}", "coresound/iOS/*.{h,hpp}"
    
    coresound.frameworks = "GLKit"
    coresound.libraries = "c++"
  end
end
