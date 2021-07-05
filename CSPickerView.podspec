#
# Be sure to run `pod lib lint CSPickerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CSPickerView'
  s.version          = '1.0.1'
  s.summary          = 'CSPickerView'
  s.description      = "多样式底部弹出样式选择器"
  s.homepage         = 'https://github.com/Coder-Star/CSPickerView'
  s.screenshots     = 'https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/startAndEndDate.png', 'https://github.com/Coder-Star/CSPickerView/raw/main/Sceenshots/date.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CoderStar' => '1340529758@qq.com' }
  s.source           = { :git => 'https://github.com/Coder-Star/CSPickerView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://coder-star.github.io/'
  s.ios.deployment_target = '9.0'
  s.swift_version = ["5","4.2"]

  s.default_subspec = 'framework'

  s.subspec 'source' do |source|
    source.source_files = 'LTXiOSUtils/Classes/Util/**/*.swift'
    source.source_files = 'CSPickerView/Classes/**/*'
    source.resource_bundles = {
      'CSPickerView' => ['CSPickerView/Assets/**/*']
    }
    source.frameworks = 'Foundation', 'UIKit'
  end

  s.subspec 'framework' do |framework|
    framework.frameworks = 'Foundation', 'UIKit'
    framework.ios.vendored_framework = 'CSPickerView/Frameworks/*.framework'
    framework.resources = 'CSPickerView/Frameworks/*.bundle'
  end
end
