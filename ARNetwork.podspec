#
# Be sure to run `pod lib lint ARNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ARNetwork'
  s.version          = '0.3.3'
  s.summary          = 'An iOS network framework in combination with HTTP/HTTPS task and data cache. (AFNetworking+Realm)'
  s.description      = <<-DESC
                        An iOS network framework in combination with HTTP/HTTPS task and data cache. (AFNetworking+Realm)
                       DESC
  s.homepage         = 'https://github.com/dklinzh/ARNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel' => 'linzhdk@gmail.com' }
  s.source           = { :git => 'https://github.com/dklinzh/ARNetwork.git', :tag => s.version.to_s, :submodules => true }

  s.requires_arc = true
  s.ios.deployment_target = '7.0'

  s.public_header_files = 'ARNetwork/Classes/ARNetwork.h'
  s.source_files = 'ARNetwork/Classes/ARNetwork.h'

end
