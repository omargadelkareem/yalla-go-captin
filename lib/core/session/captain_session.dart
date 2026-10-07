class CaptainSession {
  CaptainSession._();

  static String? phoneKey;
  static String? phone;
  static String? name;
  static String? status;
  static String? vehicleType;
  static double walletBalance = 0;

  static bool get hasCaptain => phoneKey != null;

  static void hydrate(String key, Map<String, dynamic> data) {
    phoneKey = key;
    phone = data['phone']?.toString();
    name = data['name']?.toString();
    status = data['status']?.toString() ?? 'pending';
    vehicleType = data['vehicleType']?.toString();
    walletBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0;
  }

  static void clear() {
    phoneKey = null;
    phone = null;
    name = null;
    status = null;
    vehicleType = null;
    walletBalance = 0;
  }
}
