source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

plugin 'cocoapods-keys', {
  :project => "Eidolon",
  :keys => [
    "KitsuClientKey",
    "KitsuClientSecret"
 ]}

def project_pods
    pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master',:submodules => true
    pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master',:submodules => true
    pod 'SwiftyJSON', '3.0.0'
    pod 'Heimdallr', git: 'https://github.com/marcelofabri/Heimdallr.swift.git', branch: 'swift-3.0'
end

def testing_pods
    pod 'Quick', '~> 0.10.0'
    pod 'Nimble', '~> 5.1.1'
end

target 'Ookami' do
    project_pods
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
