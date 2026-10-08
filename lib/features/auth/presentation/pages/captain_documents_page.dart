import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/captain_home_page.dart';

class CaptainDocumentsPage extends StatefulWidget {
  const CaptainDocumentsPage({super.key, required this.phoneKey});
  final String phoneKey;

  @override
  State<CaptainDocumentsPage> createState() => _CaptainDocumentsPageState();
}

class _CaptainDocumentsPageState extends State<CaptainDocumentsPage> {
  final picker = ImagePicker();
  final Map<String, String> images = {};
  bool loading = false;

  Future<void> _pick(String key) async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 28,
      maxWidth: 600,
      maxHeight: 800,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => images[key] = base64Encode(bytes));
  }

  Future<void> _submit() async {
    const required = ['profile', 'idFront', 'idBack', 'license', 'vehicle'];
    if (required.any((key) => !images.containsKey(key))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ارفع كل الصور المطلوبة أولاً')),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انتهت جلسة الدخول. سجل دخولك مرة أخرى.')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      // RTDB has a per-write size limit. Sending five Base64 images in one
      // set() can exceed it, so upload each compressed document separately.
      final docsRef = FirebaseDatabase.instance
          .ref('captainDocuments/${widget.phoneKey}');

      await Future.wait([
        docsRef.child('profileBase64').set(images['profile']),
        docsRef.child('nationalIdFrontBase64').set(images['idFront']),
        docsRef.child('nationalIdBackBase64').set(images['idBack']),
        docsRef.child('driverLicenseBase64').set(images['license']),
        docsRef.child('vehiclePhotoBase64').set(images['vehicle']),
      ]);
      await docsRef.child('updatedAt').set(ServerValue.timestamp);

      await FirebaseDatabase.instance

          .ref('captains/${widget.phoneKey}')
          .update({
        'documentsComplete': true,
        'status': 'pending',
        'updatedAt': ServerValue.timestamp,
      });
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CaptainHomePage()),
        (_) => false,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? 'Firebase رفض حفظ المستندات بسبب صلاحيات قاعدة البيانات.'
          : 'تعذر رفع المستندات: ${e.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, textDirection: TextDirection.rtl)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر رفع المستندات: $e',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('توثيق حساب الكابتن'),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'ارفع صور واضحة للمراجعة',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'هنضغط الصور ونحفظها مؤقتاً داخل قاعدة البيانات لحين مراجعة الحساب.',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        _UploadTile(label: 'صورتك الشخصية', done: images.containsKey('profile'), onTap: () => _pick('profile')),
        _UploadTile(label: 'البطاقة - الوجه الأمامي', done: images.containsKey('idFront'), onTap: () => _pick('idFront')),
        _UploadTile(label: 'البطاقة - الوجه الخلفي', done: images.containsKey('idBack'), onTap: () => _pick('idBack')),
        _UploadTile(label: 'رخصة القيادة', done: images.containsKey('license'), onTap: () => _pick('license')),
        _UploadTile(label: 'صورة المركبة', done: images.containsKey('vehicle'), onTap: () => _pick('vehicle')),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: loading ? null : _submit,
          child: Text(loading ? 'جاري رفع المستندات...' : 'إرسال للمراجعة'),
        ),
      ],
    ),
  );
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.label, required this.done, required this.onTap});
  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: done ? const Color(0xFFE5FAF2) : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.add_photo_alternate_outlined,
                  color: done ? AppColors.success : AppColors.turquoiseDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                done ? 'تم' : 'اختيار',
                style: TextStyle(
                  color: done ? AppColors.success : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
