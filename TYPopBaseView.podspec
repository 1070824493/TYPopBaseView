Pod::Spec.new do |s|
  s.name         = "TYPopBaseView" # 项目名称
  s.version      = "4.0.1"        # 版本号 与 你仓库的 标签号 对应
  s.license      = "MIT"          # 开源证书
  s.summary      = "对弹窗类视图的统一处理" # 项目简介

  s.homepage     = "https://github.com/1070824493" # 仓库的主页
  s.source       = { :git => "https://github.com/1070824493/TYPopBaseView.git", :tag => "#{s.version}" }#你的仓库地址，不能用SSH地址
  s.source_files  = "Sources/**/*.{swift}"
  s.requires_arc = true

  s.platform     = :ios, "8.0" #平台及支持的最低版本
  # s.frameworks = "UIKit", "Foundation" #支持的框架
  # s.dependency = "AFNetworking" # 依赖库
  
  # User
  s.author             = { "ty-home" => "tangyi.get@gmail.com" }# 作者信息
  s.social_media_url   = "http://tangyi.ml" # 个人主页

end