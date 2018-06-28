Pod::Spec.new do |s|
  s.name             = 'SeaworldARFramework'
  s.version          = '1.0.1'
  s.summary          = 'SeaworldARFramework'

  s.homepage         = 'https://github.com/papercloud/SeaWorldARExperience'
  s.license          = { :type => 'MIT'}
  s.author           = { 'cb@papercloud.com.au' => 'cb@papercloud.com.au' }
  s.source           = { :git => 'https://github.com/Papercloud/SeaWorldARExperience.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.ios.dependency 'SSZipArchive', '~> 1.6.2'
  s.ios.dependency 'SCNVideoWriter'
  s.ios.dependency 'Result'
  s.ios.dependency 'Spine'
  s.ios.dependency 'NYTPhotoViewer'
  s.ios.vendored_frameworks = ['BswarmFramework.framework','SeaworldARFramework.framework']
end