source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

plugin 'cocoapods-keys', {
  :project => "Ookami",
  :keys => [
    "KitsuClientKey",
    "KitsuClientSecret"
 ]}

def project_pods
    pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master',:submodules => true
    pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master',:submodules => true
    pod 'SwiftyJSON', '3.0.0'

    #https://github.com/trivago/Heimdallr.swift/pull/94#issuecomment-253346803
    pod 'Heimdallr', git: 'https://github.com/marcelofabri/Heimdallr.swift.git', branch: 'swift-3.0'

    pod 'Alamofire', '~> 4.0'
end

def testing_pods
    pod 'Quick', '~> 0.10.0'
    pod 'Nimble', '~> 5.1.1'
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
end

def ui_pods
    #Maybe remove this dependency and use pure autolayout code instead
    pod 'Cartography', '~> 1.0'
    pod 'Dwifft', '0.5'
    pod 'Kingfisher', '~> 3.0'
    pod 'Reusable', '~> 3.0'
    pod 'XLPagerTabStrip', '~> 6.0'
    pod 'NVActivityIndicatorView', '~> 3.0'
    pod 'BTNavigationDropdownMenu', '~ 0.4', :git => 'https://github.com/PhamBaTho/BTNavigationDropdownMenu.git', :branch => 'swift-3.0'
end

target 'Ookami' do
    project_pods
    ui_pods
end

target 'OokamiTests' do
    testing_pods
end

target 'OokamiKit' do
    project_pods
end

target 'OokamiKitTests' do
    testing_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
