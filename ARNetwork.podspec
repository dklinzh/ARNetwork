#
# Be sure to run `pod lib lint ARNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ARNetwork'
  s.version          = '0.4.0'
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

  s.prefix_header_file = 'ARNetwork/Classes/ARNetwork-Prefix.pch'
  s.default_subspecs = 'Default'

  s.subspec 'Default' do |ss|
    ss.dependency 'ARNetwork/HTTP'
    ss.dependency 'ARNetwork/DNS'
    ss.dependency 'ARNetwork/Cache'
    ss.dependency 'ARNetwork/Detector'
  end

  s.subspec 'HTTP' do |ss|
    ss.dependency 'AFNetworking', '~> 3.1'

    ss.source_files = 'ARNetwork/Classes/HTTP/*.{h,m}'
  end

  s.subspec 'DNS' do |ss|
    ss.dependency 'ARNetwork/HTTP'
    ss.dependency 'AlicloudHTTPDNS'
    ss.libraries = 'resolv'
    # ss.vendored_frameworks = 'ARNetwork/Frameworks/HTTPDNS/*.framework'
    # ss.frameworks = 'CoreTelephony', 'SystemConfiguration'

    ss.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/AlicloudHTTPDNS/**" "$(PODS_ROOT)/AlicloudUtils/**" "$(PODS_ROOT)/AlicloudUTDID/**"',
      'OTHER_LDFLAGS'          => '$(inherited) -framework AlicloudHttpDNS -framework AlicloudUtils -framework UTDID'
    }

    ss.source_files = 'ARNetwork/Classes/HTTP/DNS/*.{h,m}'
  end

  s.subspec 'Cache' do |ss|
    ss.dependency 'ARNetwork/HTTP'
    ss.dependency 'Realm', '~> 2.9'

    ss.source_files = 'ARNetwork/Classes/Cache/*.{h,m}'
  end

  s.subspec 'Detector' do |ss|
    ss.dependency 'AFNetworking/UIKit', '~> 3.1'

    ss.source_files = 'ARNetwork/Classes/Detector/*.{h,m}'
  end

end
