Pod::Spec.new do |s|

  s.name         = "NetworkManager"
  s.version      = "0.0.8"
  s.summary      = "Network Manager"

  s.homepage     = "https://github.com/vitkuzmenko/NetworkManager.git"

  s.license = 'MIT'

  s.author             = { "Vitaliy" => "kuzmenko.v.u@gmail.com" }
  s.social_media_url   = "http://twitter.com/vitkuzmenko"

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.source       = { :git => s.homepage, :tag => s.version.to_s }

  s.source_files  = "Source/*/*.swift"
  
  s.requires_arc = 'true'
  
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '4.0',
  }
  
  s.dependency 'Alamofire', '~> 4.9.1'
  s.dependency 'ReachabilitySwift', '~> 5.0.0'
  s.dependency 'ObjectMapper', '3.5.1'

  end
