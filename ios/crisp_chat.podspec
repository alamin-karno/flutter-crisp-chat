#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint crisp_chat.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'crisp_chat'
  s.version          = '2.4.1'
  s.summary          = 'A flutter plugin package for using crisp chat natively on Android & iOS.'
  s.description      = <<-DESC
  A flutter plugin package for using crisp chat natively on Android & iOS.
                       DESC
  s.homepage         = 'https://github.com/alamin-karno/flutter-crisp-chat'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Md. Al-Amin' => 'amin15-1951@diu.edu.bd' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Crisp', '~> 2.12.0'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
