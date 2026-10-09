import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import 'wallet_top_up_page.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final key=CaptainSession.phoneKey;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('المحفظة'),backgroundColor:Colors.transparent),
      body: key==null ? const SizedBox() : StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('captains/$key').onValue,
        builder:(context,snapshot){
          final raw=snapshot.data?.snapshot.value;
          final data=raw is Map ? Map<String,dynamic>.from(raw) : <String,dynamic>{};
          final balance=(data['walletBalance'] as num?)?.toDouble()??CaptainSession.walletBalance;
          return ListView(padding:const EdgeInsets.all(18),children:[
            Container(
              padding:const EdgeInsets.all(22),
              decoration:BoxDecoration(color:AppColors.navy,borderRadius:BorderRadius.circular(24)),
              child:Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                const Text('الرصيد الحالي',textDirection:TextDirection.rtl,style:TextStyle(color:Colors.white70)),
                const SizedBox(height:6),
                Text('${balance.toStringAsFixed(2)} جنيه',textDirection:TextDirection.rtl,style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w900)),
                const SizedBox(height:16),
                SizedBox(width:double.infinity,child:FilledButton.icon(
                  onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const WalletTopUpPage())),
                  icon:const Icon(Icons.add_rounded),label:const Text('شحن المحفظة'),
                )),
              ]),
            ),
            const SizedBox(height:18),
            const Text('حركة المحفظة',textDirection:TextDirection.rtl,style:TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:AppColors.textDark)),
            const SizedBox(height:10),
            StreamBuilder<DatabaseEvent>(
              stream:FirebaseDatabase.instance.ref('walletTransactions/$key').onValue,
              builder:(context,txSnap){
                final tx=<Map<String,dynamic>>[];
                final v=txSnap.data?.snapshot.value;
                if(v is Map){v.forEach((id,x){if(x is Map){final m=Map<String,dynamic>.from(x);m['_key']=id.toString();tx.add(m);}});}
                tx.sort((a,b)=>((b['createdAt'] as num?)??0).compareTo((a['createdAt'] as num?)??0));
                if(tx.isEmpty)return const Padding(padding:EdgeInsets.only(top:30),child:Center(child:Text('لا توجد حركات حتى الآن',style:TextStyle(color:AppColors.textMuted))));
                return Column(children:tx.map((t){
                  final amount=(t['amount'] as num?)?.toDouble()??0;
                  return Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(textDirection:TextDirection.rtl,children:[
                    const Icon(Icons.receipt_long_rounded,color:AppColors.turquoiseDark),const SizedBox(width:10),
                    Expanded(child:Text(t['label']?.toString()??'حركة محفظة',textDirection:TextDirection.rtl,style:const TextStyle(fontWeight:FontWeight.w800))),
                    Text('${amount>0?'+':''}${amount.toStringAsFixed(2)} ج',style:TextStyle(fontWeight:FontWeight.w900,color:amount<0?Colors.red.shade700:AppColors.turquoiseDark)),
                  ]));
                }).toList());
              },
            ),
          ]);
        },
      ),
    );
  }
}
