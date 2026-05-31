Pod::Spec.new do |s|
  s.name             = 'crisp_chat'
  s.version          = '2.5.0'
  s.summary          = 'Flutter plugin for Crisp Chat'
  s.description      = 'A Flutter plugin for Crisp Chat SDK on iOS.'
  s.homepage         = 'https://github.com/alamin-karno/flutter-crisp-chat'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Md. Al-Amin' => 'alamin.karno@gmail.com' }
  s.source           = { :path => '.' }

  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'

  s.source_files     = 'crisp_chat/Sources/crisp_chat/**/*.swift'

  s.dependency 'Flutter'

  # Set $CrispChatWebRTC = true in your app's ios/Podfile before
  # flutter_install_all_ios_pods to enable video/audio calls (~10 MB larger).
  # Uses the Crisp/CrispWebRTC CocoaPods subspec (not a separate pod).
  # SPM: set CRISP_CHAT_WEBRTC=true before flutter build ios (see Package.swift).
  use_webrtc = defined?($CrispChatWebRTC) && $CrispChatWebRTC

  if use_webrtc
    s.dependency 'Crisp/CrispWebRTC', '~> 2.13.0'
    s.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'OTHER_SWIFT_FLAGS' => '$(inherited) -D CRISP_WEBRTC'
    }
  else
    s.dependency 'Crisp/Crisp', '~> 2.13.0'
    s.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES'
    }
  end
end
