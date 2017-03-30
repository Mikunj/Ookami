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
    pod 'RealmSwift', '~> 2.4.0'
    pod 'SwiftyJSON', '~> 3.1'
    pod 'Alamofire', '~> 4.3'

    #Heimdallr has updated it version to 3.6, but the cocoapods specs don't have it yet
    #So for the time being just get the files directly from their git, but when the specs have updated uncomment the line below
    #pod 'Heimdallr', '~> 3.6'
    pod 'Heimdallr', :git => 'https://github.com/trivago/Heimdallr.swift.git', :tag => '3.6.0'
end

def testing_pods
    pod 'Quick', '~> 1.0'
    pod 'Nimble', '~> 5.1'
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
end

def ui_pods
    pod 'Cartography', '~> 1.0'
    pod 'Kingfisher', '~> 3.5'
    pod 'Reusable', '~> 4.0'
    pod 'XLPagerTabStrip', '~> 7.0'
    pod 'NVActivityIndicatorView', '~> 3.5'
    pod 'BTNavigationDropdownMenu', :git => 'https://github.com/PhamBaTho/BTNavigationDropdownMenu.git', :branch => 'swift-3.0'
    pod 'DynamicColor', '~> 3.2.1'
    pod 'ActionSheetPicker-3.0', '~> 2.2.0'
    pod 'IQKeyboardManager', '~> 4.0.8'
    pod 'Diff', '~> 0.5'
    pod 'SKPhotoBrowser', '~> 4.0.0'
    pod 'XCDYouTubeKit', '~> 2.5.0'
    pod 'DZNEmptyDataSet', '~> 1.8'
    pod 'FBSDKLoginKit', '~> 4.20'
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

target 'OokamiUITests' do
    project_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
