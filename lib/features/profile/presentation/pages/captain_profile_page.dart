import 'package:flutter/material.dart';
import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';

class CaptainProfilePage extends StatelessWidget {
  const CaptainProfilePage({super.key});

  Widget row(IconData icon,String label,String value)=>Container(
    margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17)),
    child:Row(textDirection:TextDirection.rtl,children:[
      Icon(icon,color:AppColors.turquoiseDark),const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
        Text(label,textDirection:TextDirection.rtl,style:const TextStyle(color:AppColors.textMuted,fontSize:11)),
        Text(value,textDirection:TextDirection.rtl,style:const TextStyle(color:AppColors.textDark,fontWeight:FontWeight.w800)),
      ])),
    ]),
  );

  @override
  Widget build(BuildContext context)=>Scaffold(
    backgroundColor:AppColors.background,
    appBar:AppBar(title:const Text('حسابي'),backgroundColor:Colors.transparent),
    body:ListView(padding:const EdgeInsets.all(18),children:[
      const CircleAvatar(radius:42,backgroundColor:AppColors.navy,child:Icon(Icons.person_rounded,size:44,color:Colors.white)),
      const SizedBox(height:10),
      Text(CaptainSession.name??'كابتن Yalla Go',textAlign:TextAlign.center,textDirection:TextDirection.rtl,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:AppColors.textDark)),
      const SizedBox(height:22),
      row(Icons.phone_rounded,'رقم الهاتف',CaptainSession.phone??'—'),
      row(Icons.directions_car_rounded,'المركبة',CaptainSession.vehicleModel??'—'),
      row(Icons.pin_rounded,'رقم اللوحة',CaptainSession.plateNumber??'—'),
      row(Icons.star_rounded,'التقييم',CaptainSession.rating.toStringAsFixed(1)),
      row(Icons.route_rounded,'عدد الرحلات','${CaptainSession.tripsCount}'),
    ]),
  );
}
