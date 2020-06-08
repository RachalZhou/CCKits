Pod::Spec.new do |spec|

  spec.name         = "CCKits"
  spec.version      = "0.0.4"
  spec.summary      = "Public libs."
  spec.description  = "A collection of public libs"
  spec.homepage     = "https://github.com/RachalZhou/CCKits"
  spec.author       = { "Rachal" => "zrcrachal@gmail.com" }
  spec.platform     = :ios
  spec.platform     = :ios, "10.0"
  spec.swift_version = '5.0'
  spec.source       = { :git => "https://github.com/RachalZhou/CCKits.git", :tag => "#{spec.version}" }
  
  spec.subspec "CCUIKit" do |a|
    a.source_files = "CCKits/Classes/CCUIKit/*"
    a.dependency "SnapKit"
    a.dependency "MJRefresh"
  end

end
