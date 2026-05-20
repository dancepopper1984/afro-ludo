import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'core/performance_manager.dart';
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

  PerformanceManager().startMonitoring();
  SchedulerBinding.instance.addTimingsCallback(
    PerformanceManager().onFrameTimings,
  );

  runApp(const AfroLudoApp());
}
