import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';

class ActiveRidePage extends StatelessWidget {
  const ActiveRidePage({super.key, required this.rideId});
  final String rideId;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('الرحلة الحالية'), backgroundColor: Colors.transparent),
    body: StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('rideRequests/$rideId').onValue,
      builder: (context, snapshot) {
        final raw = snapshot.data?.snapshot.value;
        if (raw is! Map) return const Center(child: Text('الرحلة غير متاحة'));
        final data = Map<String, dynamic>.from(raw);
        final pickup = Map<String, dynamic>.from((data['pickup'] as Map?) ?? {});
        final destination = Map<String, dynamic>.from((data['destination'] as Map?) ?? {});
        final status = data['status']?.toString() ?? 'accepted';
        final fare = (data['acceptedPrice'] as num?)?.toDouble() ??
            (data['indicativePrice'] as num?)?.toDouble() ?? 0;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(25)),
              child: Column(children: [
                const Icon(Icons.local_taxi_rounded, color: AppColors.turquoise, size: 42),
                const SizedBox(height: 8),
                Text(
                  status == 'accepted' ? 'اتقبل عرضك' : status == 'in_progress' ? 'الرحلة شغالة' : 'تمت الرحلة',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            _place('مكان العميل', pickup['name']?.toString() ?? '—', Icons.my_location_rounded),
            const SizedBox(height: 10),
            _place('الوجهة', destination['name']?.toString() ?? '—', Icons.location_on_rounded),
            const SizedBox(height: 16),
            Text('قيمة الرحلة ${fare.toStringAsFixed(0)} ج', textDirection: TextDirection.rtl, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            if (status == 'accepted') FilledButton(onPressed: _start, child: const Text('بدء الرحلة')),
            if (status == 'in_progress') FilledButton(onPressed: () => _finish(fare), child: const Text('إنهاء الرحلة')),
            if (status == 'completed') FilledButton(onPressed: () => Navigator.pop(context), child: const Text('العودة للرئيسية')),
          ],
        );
      },
    ),
  );

  Widget _place(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19)),
    child: Row(textDirection: TextDirection.rtl, children: [
      Icon(icon, color: AppColors.turquoiseDark),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(label, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        Text(value, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800)),
      ])),
    ]),
  );

  Future<void> _start() => FirebaseDatabase.instance.ref('rideRequests/$rideId').update({
    'status': 'in_progress',
    'startedAt': ServerValue.timestamp,
  });

  Future<void> _finish(double fare) async {
    final key = CaptainSession.phoneKey;
    if (key == null) return;
    final captainRef = FirebaseDatabase.instance.ref('captains/$key');
    final result = await captainRef.runTransaction((current) {
      if (current is! Map) return Transaction.abort();
      final data = Map<String, dynamic>.from(current);
      final balance = (data['walletBalance'] as num?)?.toDouble() ?? 0;
      final trips = (data['tripsCount'] as num?)?.toInt() ?? 0;
      final fee = fare * 0.15;
      data['walletBalance'] = balance - fee;
      data['tripsCount'] = trips + 1;
      return Transaction.success(data);
    });
    if (!result.committed) return;
    final fee = fare * 0.15;
    await FirebaseDatabase.instance.ref('walletTransactions/$key').push().set({
      'type': 'ride_fee',
      'rideId': rideId,
      'amount': -fee,
      'label': 'رسوم الرحلة',
      'createdAt': ServerValue.timestamp,
    });
    await FirebaseDatabase.instance.ref('rideRequests/$rideId').update({
      'status': 'completed',
      'completedAt': ServerValue.timestamp,
      'finalFare': fare,
    });
    CaptainSession.walletBalance -= fee;
    CaptainSession.tripsCount += 1;
  }
}
