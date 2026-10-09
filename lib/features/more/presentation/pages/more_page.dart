import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/captain_profile_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../../../history/presentation/pages/ride_history_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  Widget tile(BuildContext context,IconData icon,String title,VoidCallback onTap)=>Container(
    margin:const EdgeInsets.only(bottom:9),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),
    child:ListTile(onTap:onTap,leading:const Icon(Icons.chevron_left_rounded),trailing:Icon(icon,color:AppColors.turquoiseDark),title:Text(title,textDirection:TextDirection.rtl,textAlign:TextAlign.right,style:const TextStyle(fontWeight:FontWeight.w800))),
  );

  @override
  Widget build(BuildContext context)=>Scaffold(
    backgroundColor:AppColors.background,
    appBar:AppBar(title:const Text('المزيد'),backgroundColor:Colors.transparent),
    body:ListView(padding:const EdgeInsets.all(18),children:[
      tile(context,Icons.person_outline_rounded,'حسابي',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const CaptainProfilePage()))),
      tile(context,Icons.account_balance_wallet_outlined,'المحفظة',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const WalletPage()))),
      tile(context,Icons.history_rounded,'سجل الرحلات',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const RideHistoryPage()))),
      tile(context,Icons.help_outline_rounded,'المساعدة',()=>showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('المساعدة',textDirection:TextDirection.rtl),content:const Text('للدعم الفني تواصل مع إدارة Yalla Go.',textDirection:TextDirection.rtl),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('حسناً'))]))),
      const SizedBox(height:12),
      OutlinedButton.icon(
        onPressed:() async {
          await FirebaseAuth.instance.signOut();
          await CaptainSession.logout();
          if(context.mounted) Navigator.of(context).popUntil((route)=>route.isFirst);
        },
        icon:const Icon(Icons.logout_rounded),label:const Text('تسجيل الخروج'),
        style:OutlinedButton.styleFrom(foregroundColor:Colors.red.shade700,minimumSize:const Size.fromHeight(52)),
      ),
    ]),
  );
}
