# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'boba' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  platform :ios, '9.0'

  # Pods for boba
  pod 'MBProgressHUD', '~> 1.0'
  pod 'SegueCoordinator', :git => 'https://github.com/npu3pak/ios-lib-segue-coordinator.git'
  pod 'FormEditor', :git => 'https://github.com/npu3pak/ios-lib-form-editor.git'
  pod 'SwiftDate', '~> 4.3.0'
  pod 'LGSideMenuController', '2.1.1'
  pod 'XLPagerTabStrip', '~> 7.0'
  pod 'KeychainSwift', '~> 9.0.2'
  pod 'SVPullToRefresh', '0.4.1'

  target 'bobaTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.3'
  end
  
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings.delete('SWIFT_VERSION')
          config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
  end
end
