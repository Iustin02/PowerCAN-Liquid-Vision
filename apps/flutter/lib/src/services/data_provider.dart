import '../models/obd_data.dart';

abstract class DataProvider {
  Stream<OBDData> get obdDataStream;
  Stream<ConnectionState> get connectionStateStream;
  OBDData get currentData;
  ConnectionState get connectionState;

  Future<void> start();
  Future<void> stop();
  void dispose();
}
