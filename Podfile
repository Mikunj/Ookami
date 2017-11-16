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
    pod 'RealmSwift', '~> 3.0.2'
    pod 'SwiftyJSON', '~> 3.1.4'
    pod 'Alamofire', '~> 4.5'
    pod 'Heimdallr', '~> 3.6.1'
end

def testing_pods
    pod 'Quick', '~> 1.1'
    pod 'Nimble', '~> 7.0'
    pod 'OHHTTPStubs', '~> 6.0'
    pod 'OHHTTPStubs/Swift'
end

def ui_pods
    pod 'Cartography', '~> 1.1'
    pod 'Kingfisher', '~> 3.13'
    pod 'Reusable', '~> 4.0'
    pod 'XLPagerTabStrip', '~> 8.0'
    pod 'NVActivityIndicatorView', '~> 3.7'
    pod 'BTNavigationDropdownMenu', :git => 'https://github.com/PhamBaTho/BTNavigationDropdownMenu.git', :branch => 'swift-3.0'
    pod 'DynamicColor', '~> 3.3'
    pod 'ActionSheetPicker-3.0', '~> 2.2.0'
    pod 'IQKeyboardManager', '5.0.0'
    pod 'Diff', '~> 0.5.3'
    pod 'SKPhotoBrowser', '~> 5.0'
    pod 'XCDYouTubeKit', '~> 2.5.5'
    pod 'DZNEmptyDataSet', '~> 1.8'
    pod 'FBSDKLoginKit', '~> 4.25'
    pod '1PasswordExtension', '~> 1.8.4'
    pod 'Siren', '~> 2.0.7'
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
