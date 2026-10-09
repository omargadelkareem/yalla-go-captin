import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallet/presentation/pages/wallet_top_up_page.dart';
import '../../../rides/presentation/pages/available_rides_page.dart';
import '../../../history/presentation/pages/ride_history_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../../../more/presentation/pages/more_page.dart';

class CaptainHomePage extends StatefulWidget {
  const CaptainHomePage({super.key});

  @override
  State<CaptainHomePage> createState() => _CaptainHomePageState();
}

class _CaptainHomePageState extends State<CaptainHomePage> {
  bool online = false;
  StreamSubscription<DatabaseEvent>? _captainSubscription;

  @override
  void initState() {
    super.initState();
    final key = CaptainSession.phoneKey;
    if (key != null) {
      _captainSubscription = FirebaseDatabase.instance.ref('captains/$key').onValue.listen((event) {
        final raw = event.snapshot.value;
        if (raw is Map) {
          final data = Map<String, dynamic>.from(raw);
          CaptainSession.hydrate(key, data);
          if (mounted) setState(() => online = data['isOnline'] == true);
        }
      });
    }
  }

  @override
  void dispose() {
    _captainSubscription?.cancel();
    super.dispose();
  }

  bool get approved => CaptainSession.status == 'approved';
  bool get activated => approved &&
      CaptainSession.initialTopUpCompleted &&
      CaptainSession.rideAccessEnabled;

  Future<void> _toggleOnline() async {
    if (!activated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('استقبال الرحلات غير مفعل. راجع حالة الحساب والمحفظة')),
      );
      return;
    }
    final next = !online;
    setState(() => online = next);
    try {
      await FirebaseDatabase.instance
          .ref('captains/${CaptainSession.phoneKey}')
          .update({
        'isOnline': next,
        'lastOnlineAt': ServerValue.timestamp,
      });
    } catch (_) {
      if (mounted) setState(() => online = !next);
    }
  }

  void _openWallet() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalletTopUpPage()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F4),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _MapBackground()),
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    icon: Icons.menu_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MorePage()),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.94),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12062B46),
                          blurRadius: 20,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        _MiniBrandMark(),
                        SizedBox(width: 8),
                        Text(
                          'Yalla Go',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _GlassButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Positioned(
              top: 94,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: _toggleOnline,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: online ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1B062B46),
                        blurRadius: 28,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: online
                              ? AppColors.turquoise
                              : AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          online
                              ? Icons.power_settings_new_rounded
                              : Icons.power_settings_new_rounded,
                          color: online ? Colors.white : AppColors.navy,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              online ? 'متصل وجاهز' : 'أنت غير متصل',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: online
                                    ? Colors.white
                                    : AppColors.textDark,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              online
                                  ? 'هنعرض لك الرحلات القريبة فور وصولها'
                                  : activated
                                      ? 'اضغط هنا وابدأ استقبال الرحلات'
                                      : 'استقبال الرحلات غير مفعل من الإدارة',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: online
                                    ? Colors.white.withOpacity(.68)
                                    : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: online
                              ? const Color(0xFF56E29A)
                              : const Color(0xFFBCC8CE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 210,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x10000000), blurRadius: 16),
                  ],
                ),
                child: const Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      size: 15,
                      color: AppColors.turquoiseDark,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'سوهاج',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned.fill(
              top: 180,
              bottom: 250,
              child: Center(child: _CaptainMapMarker()),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _BottomPanel(
                activated: activated,
                approved: approved,
                online: online,
                onWallet: _openWallet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.activated,
    required this.approved,
    required this.online,
    required this.onWallet,
  });

  final bool activated;
  final bool approved;
  final bool online;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    final subtitle = !approved
        ? 'حسابك قيد المراجعة'
        : !activated
            ? 'اشحن المحفظة لتبدأ استقبال الرحلات'
            : online
                ? 'أنت الآن متاح للرحلات القريبة'
                : 'اتصل علشان تبدأ استقبال الرحلات';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24062B46),
            blurRadius: 34,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE5E9),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FAFB),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.turquoiseDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'رصيد المحفظة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${CaptainSession.walletBalance.toStringAsFixed(0)} جنيه',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              subtitle,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 13),
          if (activated)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvailableRidesPage(),
                  ),
                ),
                icon: const Icon(Icons.local_taxi_rounded),
                label: const Text('الرحلات المتاحة'),
              ),
            ),
          if (activated) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RideHistoryPage()),
                  ),
                  icon: const Icon(Icons.history_rounded, size: 19),
                  label: const Text('رحلاتي'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletPage()),
                  ),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 19),
                  label: const Text('المحفظة'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onWallet,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 21),
              label: const Text(
                'شحن المحفظة',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'حوّل على 01115057318 وارفع الإيصال للمراجعة',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: AppColors.navy, size: 22),
          ),
        ),
      );
}

class _MiniBrandMark extends StatelessWidget {
  const _MiniBrandMark();

  @override
  Widget build(BuildContext context) => Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(
          Icons.near_me_rounded,
          color: AppColors.turquoise,
          size: 15,
        ),
      );
}

class _CaptainMapMarker extends StatelessWidget {
  const _CaptainMapMarker();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: const BoxDecoration(
              color: Color(0x1F08B8C5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0x3008B8C5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33062B46),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              size: 14,
              color: AppColors.turquoise,
            ),
          ),
        ],
      );
}

class _MapBackground extends StatefulWidget {
  const _MapBackground();

  @override
  State<_MapBackground> createState() => _MapBackgroundState();
}

class _MapBackgroundState extends State<_MapBackground> {
  Position? position;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final value = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) setState(() => position = value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final center = position == null
        ? const LatLng(26.5569, 31.6948)
        : LatLng(position!.latitude, position!.longitude);
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: position == null ? 13.5 : 16,
        minZoom: 4,
        maxZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.yalla_go_captain',
          maxNativeZoom: 19,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 96,
              height: 96,
              child: const _CaptainMapMarker(),
            ),
          ],
        ),
        RichAttributionWidget(
          attributions: const [
            TextSourceAttribution('OpenStreetMap contributors'),
            TextSourceAttribution('CARTO'),
          ],
        ),
      ],
    );
  }
}
