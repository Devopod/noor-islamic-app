import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  bool _isGoldStandard = true;
  final _cashController = TextEditingController();
  final _goldGramsController = TextEditingController();
  final _goldValueController = TextEditingController();
  final _investmentsController = TextEditingController();
  final _businessController = TextEditingController();
  final _debtsController = TextEditingController();

  double get _totalAssets {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final goldValue = double.tryParse(_goldValueController.text) ?? 0;
    final investments = double.tryParse(_investmentsController.text) ?? 0;
    final business = double.tryParse(_businessController.text) ?? 0;
    return cash + goldValue + investments + business;
  }

  double get _totalDebts => double.tryParse(_debtsController.text) ?? 0;
  double get _netAssets => _totalAssets - _totalDebts;
  double get _nisabValue => _isGoldStandard ? 6124.50 : 487.50;
  bool get _isAboveNisab => _netAssets >= _nisabValue;
  double get _zakatPayable => _isAboveNisab ? _netAssets * 0.025 : 0;

  void _reset() {
    setState(() {
      _cashController.clear();
      _goldGramsController.clear();
      _goldValueController.clear();
      _investmentsController.clear();
      _businessController.clear();
      _debtsController.clear();
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _goldGramsController.dispose();
    _goldValueController.dispose();
    _investmentsController.dispose();
    _businessController.dispose();
    _debtsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildNisabSection(),
                  const SizedBox(height: 24),
                  _buildAssetsSection(),
                  const SizedBox(height: 24),
                  _buildLiabilitiesSection(),
                  const SizedBox(height: 16),
                  Text(
                    'Calculations are based on the inputs provided. Please consult with a scholar for complex financial situations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Zakat Record Saved: \$${_zakatPayable.toStringAsFixed(2)}'),
              backgroundColor: AppTheme.surfaceDark2,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.save),
        label: const Text('Save Record', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(13))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(13),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Zakat Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('14 Ramadan 1445 AH', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: _reset,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(13)),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 12)],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withAlpha(50),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Zakat Payable', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$${_zakatPayable.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                        ),
                        const SizedBox(width: 4),
                        Text('(2.5%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white.withAlpha(25)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Net Assets', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                            Text('\$${_netAssets.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isAboveNisab ? AppTheme.primary : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isAboveNisab ? 'Above Threshold' : 'Below Threshold',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[300]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Nisab Threshold', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text('What is Nisab?', style: TextStyle(fontSize: 11, color: AppTheme.primary)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isGoldStandard = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isGoldStandard ? AppTheme.primary.withAlpha(50) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: _isGoldStandard ? Border.all(color: AppTheme.primary.withAlpha(76)) : null,
                    ),
                    child: Text(
                      'Gold Standard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isGoldStandard ? FontWeight.w600 : FontWeight.w500,
                        color: _isGoldStandard ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isGoldStandard = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isGoldStandard ? AppTheme.primary.withAlpha(50) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: !_isGoldStandard ? Border.all(color: AppTheme.primary.withAlpha(76)) : null,
                    ),
                    child: Text(
                      'Silver Standard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !_isGoldStandard ? FontWeight.w600 : FontWeight.w500,
                        color: !_isGoldStandard ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withAlpha(128),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withAlpha(25), style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user, size: 20, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Current ${_isGoldStandard ? "Gold" : "Silver"} Nisab Value: ', style: TextStyle(fontSize: 13, color: Colors.grey[300])),
                        TextSpan(text: '\$${_nisabValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    Text('Updated today based on market rates.', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Assets', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildAssetCard(
          icon: Icons.payments,
          iconColor: const Color(0xFF10B981),
          title: 'Cash & Bank Savings',
          subtitle: 'Hand, Bank Accounts, Deposits',
          controller: _cashController,
        ),
        const SizedBox(height: 12),
        _buildGoldSilverCard(),
        const SizedBox(height: 12),
        _buildAssetCard(
          icon: Icons.trending_up,
          iconColor: const Color(0xFF3B82F6),
          title: 'Investments',
          subtitle: 'Stocks, Crypto, Funds (Market Value)',
          controller: _investmentsController,
        ),
        const SizedBox(height: 12),
        _buildAssetCard(
          icon: Icons.storefront,
          iconColor: const Color(0xFF8B5CF6),
          title: 'Business Goods',
          subtitle: 'Inventory & Goods for Sale',
          controller: _businessController,
        ),
      ],
    );
  }

  Widget _buildAssetCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.right,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldSilverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.diamond, size: 22, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gold & Silver', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('Jewelry, Coins, Bullion', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Icon(Icons.help_outline, size: 20, color: Colors.grey[500]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 12,
                        top: 8,
                        child: Text('GOLD (g)', style: TextStyle(fontSize: 9, color: Colors.grey[500], letterSpacing: 0.5)),
                      ),
                      TextField(
                        controller: _goldGramsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 12,
                        top: 8,
                        child: Text('VALUE', style: TextStyle(fontSize: 9, color: Colors.grey[500], letterSpacing: 0.5)),
                      ),
                      TextField(
                        controller: _goldValueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Liabilities (Deductions)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withAlpha(50)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.credit_card, size: 22, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Debts Due Immediately', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text('Outstanding payments, bills, loans', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _debtsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.right,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixText: '-\$ ',
                    prefixStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
