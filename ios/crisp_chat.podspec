Pod::Spec.new do |s|
  s.name             = 'crisp_chat'
  s.version          = '3.0.0'
  s.summary          = 'Flutter plugin for Crisp Chat'
  s.description      = 'A Flutter plugin for Crisp Chat SDK on iOS.'
  s.homepage         = 'https://github.com/alamin-karno/flutter-crisp-chat'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Md. Al-Amin' => 'alamin.karno@gmail.com' }
  s.source           = { :path => '.' }

  s.platform         = :ios, '14.0'
  s.swift_version    = '5.0'

  s.source_files     = 'crisp_chat/Sources/crisp_chat/**/*.swift'

  s.dependency 'Flutter'

  # Crisp iOS SDK 3.x ships audio/video calls in the single `Crisp` pod —
  # the 2.x `Crisp/CrispWebRTC` subspec (and `$CrispChatWebRTC`) is gone.
  s.dependency 'Crisp', '~> 3.0.1'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
end
