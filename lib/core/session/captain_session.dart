import 'package:get_storage/get_storage.dart';

class CaptainSession {
  CaptainSession._();

  static final GetStorage _box = GetStorage();

  static String? phoneKey;
  static String? phone;
  static String? name;
  static String? status;
  static String? vehicleType;
  static String? vehicleModel;
  static String? plateNumber;
  static String? profilePhotoBase64;
  static double walletBalance = 0;
  static double rating = 5;
  static int tripsCount = 0;
  static bool activationPaid = false;
  static bool initialTopUpCompleted = false;
  static bool documentsComplete = false;
  static bool rideAccessEnabled = false;

  static bool get hasCaptain => phoneKey != null;

  static void hydrate(String key, Map<String, dynamic> data) {
    phoneKey = key;
    phone = data['phone']?.toString();
    name = data['name']?.toString();
    status = data['status']?.toString() ?? 'pending';
    vehicleType = data['vehicleType']?.toString();
    vehicleModel = data['vehicleModel']?.toString();
    plateNumber = data['plateNumber']?.toString();
    profilePhotoBase64 = data['profilePhotoBase64']?.toString();
    walletBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0;
    rating = (data['rating'] as num?)?.toDouble() ?? 5;
    tripsCount = (data['tripsCount'] as num?)?.toInt() ?? 0;
    activationPaid = data['activationPaid'] == true;
    initialTopUpCompleted = data['initialTopUpCompleted'] == true;
    documentsComplete = data['documentsComplete'] == true;
    rideAccessEnabled = data['rideAccessEnabled'] == true;
  }

  static Future<void> persistLogin(String key) async {
    await _box.write('captainPhoneKey', key);
  }

  static String? get savedPhoneKey => _box.read<String>('captainPhoneKey');

  static Future<void> logout() async {
    await _box.remove('captainPhoneKey');
    clear();
  }

  static void clear() {
    phoneKey = null;
    phone = null;
    name = null;
    status = null;
    vehicleType = null;
    vehicleModel = null;
    plateNumber = null;
    profilePhotoBase64 = null;
    walletBalance = 0;
    rating = 5;
    tripsCount = 0;
    activationPaid = false;
    initialTopUpCompleted = false;
    documentsComplete = false;
    rideAccessEnabled = false;
  }
}
