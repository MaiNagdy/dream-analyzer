import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../services/iap_service.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class BuyCreditsScreen extends StatefulWidget {
  const BuyCreditsScreen({super.key});
  @override State<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends State<BuyCreditsScreen> {
  final _iap = IAPService();
  bool _loading = true;
  List<ProductDetails> _prods = [];

  @override
  void initState() { super.initState(); _boot(); }
  Future<void> _boot() async {
    await _iap.init(_handle);
    _prods = await _iap.products();
    setState(() => _loading = false);
  }

  Future<void> _handle(PurchaseDetails p) async {
    if (p.status != PurchaseStatus.purchased) return;

    // 1- server-side verify
    await http.post(Uri.parse('${AppConfig.baseUrl}/api/purchases/verify'),
        headers: {'Content-Type':'application/json',
                  'Authorization':'Bearer ${await AuthService().getToken()}'},
        body: jsonEncode({
          'productId': p.productID,
          'purchaseToken': p.verificationData.serverVerificationData
        }));

    // 2- local credits
    context.read<AuthProvider>()
           .addCredits(p.productID == IAPService.k10 ? 10 : 40);

    // 3- acknowledge so it can be repurchased
    await _iap.finish(p);

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('✔ تمت إضافة الرصيد'),));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('شراء الرصيد')),
    body: _loading ? const Center(child:CircularProgressIndicator())
      : ListView(
          children: _prods.map((p)=>Card(
            child: ListTile(
              title: Text(p.title), subtitle: Text(p.description),
              trailing: Text(p.price), onTap: ()=>_iap.buy(p),
            ))).toList()));

  @override void dispose() { _iap.dispose(); super.dispose(); }
}
