import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('رحلاتي'), backgroundColor: Colors.transparent),
    body: StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('rideRequests').onValue,
      builder: (context, snapshot) {
        final items = <Map<String,dynamic>>[];
        final raw = snapshot.data?.snapshot.value;
        if (raw is Map) {
          raw.forEach((key,value) {
            if (value is Map) {
              final d=Map<String,dynamic>.from(value);
              if (d['acceptedDriverId']==CaptainSession.phoneKey && d['status']=='completed') {
                d['_key']=key.toString(); items.add(d);
              }
            }
          });
        }
        items.sort((a,b)=>((b['completedAt'] as num?)??0).compareTo((a['completedAt'] as num?)??0));
        if(items.isEmpty) return const Center(child: Text('لسه مفيش رحلات مكتملة', textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.textMuted)));
        return ListView.separated(
          padding: const EdgeInsets.all(16), itemCount: items.length,
          separatorBuilder: (_,__)=>const SizedBox(height:10),
          itemBuilder: (_,i) {
            final d=items[i];
            final pickup=Map<String,dynamic>.from((d['pickup'] as Map?)??{});
            final dest=Map<String,dynamic>.from((d['destination'] as Map?)??{});
            final fare=((d['finalFare']??d['acceptedPrice']??d['indicativePrice']) as num?)?.toDouble()??0;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(18)),
              child: Column(children:[
                Row(textDirection: TextDirection.rtl,children:[
                  const Icon(Icons.check_circle_rounded,color: AppColors.turquoiseDark),
                  const SizedBox(width:8),
                  Expanded(child: Text(dest['name']?.toString()??'الوجهة',textDirection: TextDirection.rtl,style: const TextStyle(fontWeight:FontWeight.w900))),
                  Text('${fare.toStringAsFixed(0)} ج',style: const TextStyle(color:AppColors.navy,fontWeight:FontWeight.w900)),
                ]),
                const SizedBox(height:8),
                Align(alignment:Alignment.centerRight,child:Text('من: ${pickup['name']??'—'}',textDirection:TextDirection.rtl,style:const TextStyle(color:AppColors.textMuted,fontSize:12))),
              ]),
            );
          },
        );
      },
    ),
  );
}
