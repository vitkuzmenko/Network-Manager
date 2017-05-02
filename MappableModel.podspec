Pod::Spec.new do |s|

  s.name         = "MappableModel"
  s.version      = "0.0.1"
  s.summary      = "MappableModel"

  s.homepage     = "https://github.com/vitkuzmenko/MappableModel.git"

  s.license = 'MIT'

  s.author             = { "Vitaliy" => "kuzmenko.v.u@gmail.com" }
  s.social_media_url   = "http://twitter.com/vitkuzmenko"

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.source       = { :git => s.homepage, :tag => s.version.to_s }

  s.source_files  = "Source/MappableModel/*.swift"
  
  s.requires_arc = 'true'
  
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0',
  }
  
  s.dependency 'ObjectMapper', '~> 2.1'
  s.dependency 'NetworkManager', :git => 'https://github.com/vitkuzmenko/NetworkManager.git'

  end
