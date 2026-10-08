import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import 'active_ride_page.dart';

class AvailableRidesPage extends StatelessWidget {
  const AvailableRidesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('الرحلات القريبة'), backgroundColor: Colors.transparent),
    body: StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('rideRequests').onValue,
      builder: (context, snapshot) {
        final rides = <Map<String, dynamic>>[];
        final raw = snapshot.data?.snapshot.value;
        if (raw is Map) {
          raw.forEach((key, value) {
            if (value is Map) {
              final data = Map<String, dynamic>.from(value);
              if (data['status'] == 'searching' &&
                  data['vehicleType'] == CaptainSession.vehicleType) {
                data['_key'] = key.toString();
                rides.add(data);
              }
            }
          });
        }
        rides.sort((a, b) =>
            ((b['createdAt'] as num?) ?? 0).compareTo((a['createdAt'] as num?) ?? 0));

        if (rides.isEmpty) {
          return const Center(
            child: Text(
              'مفيش رحلات متاحة حالياً\nخليك متصل وهتظهر هنا فور وصولها',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.7),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) => _RideCard(data: rides[index]),
        );
      },
    ),
  );
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final pickup = Map<String, dynamic>.from((data['pickup'] as Map?) ?? {});
    final destination = Map<String, dynamic>.from((data['destination'] as Map?) ?? {});
    final price = (data['indicativePrice'] as num?)?.toDouble() ?? 0;
    final distance = (data['distanceKm'] as num?)?.toDouble() ?? 0;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x12062B46), blurRadius: 18, offset: Offset(0, 7))],
      ),
      child: Column(
        children: [
          _place(Icons.my_location_rounded, 'من', pickup['name']?.toString() ?? 'موقع العميل'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
          _place(Icons.location_on_rounded, 'إلى', destination['name']?.toString() ?? 'الوجهة'),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text('${distance.toStringAsFixed(1)} كم', style: const TextStyle(color: AppColors.textMuted)),
              const Spacer(),
              Text('السعر الاسترشادي ${price.toStringAsFixed(0)} ج', style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _offer(context, price),
              child: const Text('قدّم عرضك'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _place(IconData icon, String title, String value) => Row(
    textDirection: TextDirection.rtl,
    children: [
      Icon(icon, color: AppColors.turquoiseDark, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          Text(value, textDirection: TextDirection.rtl, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800)),
        ],
      )),
    ],
  );

  Future<void> _offer(BuildContext context, double suggested) async {
    final controller = TextEditingController(text: suggested.ceil().toString());
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('قدّم سعرك للعميل', textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(labelText: 'السعر بالجنيه'),
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                final parsed = double.tryParse(controller.text);
                if (parsed != null && parsed > 0) Navigator.pop(sheetContext, parsed);
              },
              child: const Text('إرسال العرض'),
            )),
          ],
        ),
      ),
    );
    controller.dispose();
    if (value == null) return;

    final rideId = data['_key'].toString();
    final driverId = CaptainSession.phoneKey;
    if (driverId == null) return;
    await FirebaseDatabase.instance.ref('rideOffers/$rideId/$driverId').set({
      'driverId': driverId,
      'driverName': CaptainSession.name ?? 'كابتن Yalla Go',
      'vehicle': CaptainSession.vehicleModel ?? 'مركبة',
      'vehicleType': CaptainSession.vehicleType,
      'price': value.ceil(),
      'etaMinutes': 5,
      'rating': CaptainSession.rating,
      'tripsCount': CaptainSession.tripsCount,
      'status': 'pending',
      'createdAt': ServerValue.timestamp,
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال عرضك للعميل')),
    );
    _waitForAcceptance(context, rideId, driverId);
  }

  void _waitForAcceptance(BuildContext context, String rideId, String driverId) {
    FirebaseDatabase.instance.ref('rideRequests/$rideId').onValue.listen((event) {
      final raw = event.snapshot.value;
      if (raw is! Map || !context.mounted) return;
      final ride = Map<String, dynamic>.from(raw);
      if (ride['status'] == 'accepted' && ride['acceptedDriverId'] == driverId) {
        final acceptedOffer = ride['acceptedOfferId']?.toString();
        if (acceptedOffer == driverId) {
          final offer = FirebaseDatabase.instance.ref('rideOffers/$rideId/$driverId');
          offer.get().then((snap) {
            final offerData = snap.value;
            if (offerData is Map) {
              final price = (offerData['price'] as num?)?.toDouble();
              if (price != null) {
                FirebaseDatabase.instance.ref('rideRequests/$rideId').update({
                  'acceptedPrice': price,
                });
              }
            }
          });
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActiveRidePage(rideId: rideId)),
        );
      }
    });
  }
}
