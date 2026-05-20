import 'package:flutter/material.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/crashlytics_service.dart';
import 'services/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CrashlyticsService.init();
  await StorageService.init();
  await AudioService().init();
  await AdService.init();
  runApp(const AfroLudoApp());
}
