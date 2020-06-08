Pod::Spec.new do |spec|

  spec.name         = "CCKit"
  spec.version      = "0.0.1"
  spec.summary      = "Public libs."
  spec.description  = "A collection of public libs"
  spec.homepage     = "https://github.com/RachalZhou/CCKit"
  spec.author       = { "Rachal" => "zrcrachal@gmail.com" }
  spec.platform     = :ios
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/RachalZhou/CCKit.git", :tag => "#{spec.version}" }
  
  # spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.subspec "CCUIKit" do |a|
    a.source_files = "CCKit/Classes/CCUIKit/*"
    a.dependency "SnapKit"
    a.dependency "MJRefresh"
  end

end
