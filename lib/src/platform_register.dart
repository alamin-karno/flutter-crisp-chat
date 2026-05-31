export 'platform_register_stub.dart'
    if (dart.library.html) 'platform_register_web.dart'
    if (dart.library.io) 'platform_register_io.dart';
