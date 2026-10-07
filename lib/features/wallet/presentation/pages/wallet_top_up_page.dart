import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/session/captain_session.dart';
import '../../../../core/theme/app_colors.dart';

class WalletTopUpPage extends StatefulWidget {
  const WalletTopUpPage({super.key});

  @override
  State<WalletTopUpPage> createState() => _WalletTopUpPageState();
}

class _WalletTopUpPageState extends State<WalletTopUpPage> {
  static const transferPhone = '01115057318';
  final amountController = TextEditingController(text: '100');
  Uint8List? receiptBytes;
  String? receiptName;
  bool submitting = false;

  Future<void> _pickReceipt() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 1400,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      receiptBytes = bytes;
      receiptName = file.name;
    });
  }

  Future<void> _submit() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أقل مبلغ للشحن هو 100 جنيه')),
      );
      return;
    }
    if (receiptBytes == null || CaptainSession.phoneKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ارفق صورة إيصال التحويل أولاً')),
      );
      return;
    }

    setState(() => submitting = true);
    try {
      final request = FirebaseDatabase.instance.ref('walletTopUpRequests').push();
      await request.set({
        'requestId': request.key,
        'captainId': CaptainSession.phoneKey,
        'captainName': CaptainSession.name,
        'captainPhone': CaptainSession.phone,
        'amount': amount,
        'transferPhone': transferPhone,
        'receiptBase64': base64Encode(receiptBytes!),
        'receiptName': receiptName,
        'status': 'pending',
        'createdAt': ServerValue.timestamp,
        'reviewedAt': null,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الشحن للمراجعة')),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إرسال الطلب: ${e.code}')),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: const Text('شحن المحفظة', style: TextStyle(fontWeight: FontWeight.w900)),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: AppColors.turquoise, size: 34),
                SizedBox(height: 18),
                Text('حوّل المبلغ على الرقم', textDirection: TextDirection.rtl, style: TextStyle(color: Color(0xFFC9D8E1), fontSize: 13)),
                SizedBox(height: 5),
                SelectableText(transferPhone, textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: 1)),
                SizedBox(height: 9),
                Text('بعد التحويل ارفع صورة الإيصال وسيتم مراجعة الطلب قبل إضافة الرصيد.', textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFC9D8E1), height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('المبلغ', textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 9),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(suffixText: 'جنيه', hintText: '100'),
          ),
          const SizedBox(height: 20),
          const Text('إيصال التحويل', textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 9),
          InkWell(
            onTap: _pickReceipt,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: receiptBytes == null ? const Color(0xFFDDE6EB) : AppColors.turquoise, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: receiptBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(radius: 27, backgroundColor: Color(0xFFE7FAFB), child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.turquoise, size: 28)),
                        SizedBox(height: 12),
                        Text('اضغط لإرفاق صورة الإيصال', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 5),
                        Text('صورة واضحة للتحويل', textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(receiptBytes!, fit: BoxFit.cover),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Material(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(50),
                            child: IconButton(onPressed: _pickReceipt, icon: const Icon(Icons.edit_rounded, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 26),
          FilledButton(
            onPressed: submitting ? null : _submit,
            child: submitting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                : const Text('إرسال طلب الشحن للمراجعة'),
          ),
        ],
      ),
    ),
  );
}
