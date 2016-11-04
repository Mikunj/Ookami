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
    pod 'RealmSwift', '~> 0.100.0'
end

target 'Ookami' do
    project_pods
end

target 'OokamiTests' do

end

target 'OokamiKit' do
    project_pods
end

target 'OokamiKitTests' do

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0' # or '3.0'
    end
  end
end
