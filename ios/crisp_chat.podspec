Pod::Spec.new do |s|
  s.name             = 'crisp_chat'
  s.version          = '2.4.2'
  s.summary          = 'Flutter plugin for Crisp Chat'
  s.description      = 'A Flutter plugin for Crisp Chat SDK on iOS.'
  s.homepage         = 'https://github.com/alamin-karno/flutter-crisp-chat'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Md. Al-Amin' => 'alamin.karno@gmail.com' }
  s.source           = { :path => '.' }

  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'

  s.source_files     = 'Classes/**/*'

  s.dependency 'Flutter'
  s.dependency 'Crisp', '~> 2.12.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
end
