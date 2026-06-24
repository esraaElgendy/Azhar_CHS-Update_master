import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/bloc/settings_cubit.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  int _selectedPaymentMethod = 1; // 0=VodafoneCash, 1=CreditCard, 2=Fawry, 3=InstaPay
  bool _saveCard = false;

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final paymentMethods = [
      _PaymentMethod(
        titleAr: 'فودافون كاش',
        titleEn: 'Vodafone Cash',
        icon: Icons.phone_android_outlined,
        color: const Color(0xFFE60000),
      ),
      _PaymentMethod(
        titleAr: 'بطاقة ائتمان',
        titleEn: 'Credit Card',
        icon: Icons.credit_card,
        color: AppColors.primary,
      ),
      _PaymentMethod(
        titleAr: 'فوري',
        titleEn: 'Fawry',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFF5A623),
      ),
      _PaymentMethod(
        titleAr: 'انستا باي',
        titleEn: 'InstaPay',
        icon: Icons.swap_horiz_outlined,
        color: AppColors.success,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppColors.primaryDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAr ? 'تفاصيل الدفع' : 'Payment Details',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
        centerTitle: false,
        actions: [
          // Language toggle
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (ctx, s) => IconButton(
              tooltip: isAr ? 'English' : 'عربي',
              icon: Text(
                isAr ? 'EN' : 'ع',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              onPressed: () => ctx.read<SettingsCubit>().toggleLocale(),
            ),
          ),
          // Theme toggle
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (ctx, s) => IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: AppColors.primary,
              ),
              onPressed: () => ctx.read<SettingsCubit>().toggleTheme(!isDark),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount due card
            _buildAmountDueCard(context, isDark, isAr),
            const SizedBox(height: 24),

            // Payment method section title
            Text(
              isAr ? 'اختر وسيلة الدفع' : 'Choose Payment Method',
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // Payment methods grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.0,
              ),
              itemCount: paymentMethods.length,
              itemBuilder: (ctx, index) => _buildPaymentMethodCard(
                context: context,
                isDark: isDark,
                isAr: isAr,
                method: paymentMethods[index],
                isSelected: _selectedPaymentMethod == index,
                onTap: () => setState(() => _selectedPaymentMethod = index),
              ),
            ),
            const SizedBox(height: 24),

            // Card details form (shown when credit card selected)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _selectedPaymentMethod == 1
                  ? _buildCardForm(context, isDark, isAr)
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTypography.radiusL),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _showConfirmationDialog(context, isDark, isAr),
                icon: const Icon(Icons.verified_user_outlined, size: 22),
                label: Text(
                  isAr ? 'تأكيد الدفع' : 'Confirm Payment',
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              isAr
                  ? 'عملية دفع آمنة مشفرة بمعايير PCI-DSS'
                  : 'Secure payment encrypted with PCI-DSS standards',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: isDark ? Colors.white38 : AppColors.textGrey600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDueCard(
      BuildContext context, bool isDark, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(AppTypography.radiusL),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'المبلغ المطلوب سداده' : 'Amount Due',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? Colors.white60 : AppColors.textGrey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '4,250.00 ج.م',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? '٢٠٢٤' : '2024',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : AppColors.textGrey600,
                ),
              ),
              Text(
                isAr ? 'الترم الدراسي الثاني' : 'Second Semester',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : AppColors.textGrey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'ساعة معتمدة' : 'credit hours',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : AppColors.textMuted,
                ),
              ),
              Text(
                isAr ? '١٥ ساعة معتمدة' : '15 credit hours',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required BuildContext context,
    required bool isDark,
    required bool isAr,
    required _PaymentMethod method,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(isDark ? 0.2 : 0.08)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 0.8,
          ),
          boxShadow: isDark || isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              method.icon,
              color: isSelected ? AppColors.primary : method.color,
              size: 22,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isAr ? method.titleAr : method.titleEn,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white : AppColors.primaryDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm(
      BuildContext context, bool isDark, bool isAr) {
    final fillColor =
        isDark ? AppColors.inputFillDark : AppColors.inputFillLight;
    final labelColor = isDark ? Colors.white70 : AppColors.primary;
    final hintColor = isDark ? Colors.white38 : AppColors.textMuted;

    InputDecoration _decoration(String hint, IconData prefixIcon) {
      return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(fontSize: 13, color: hintColor),
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(prefixIcon, color: labelColor.withOpacity(0.6), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTypography.radiusL),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment:
            isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Card number
          Text(
            isAr ? 'رقم البطاقة' : 'Card Number',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: _decoration(
              '0000 0000 0000 0000',
              Icons.credit_card,
            ).copyWith(counterText: ''),
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),

          // Card holder
          Text(
            isAr ? 'اسم صاحب البطاقة' : 'Card Holder Name',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cardHolderController,
            decoration: _decoration(
              isAr
                  ? 'الاسم كما هو موضح على البطاقة'
                  : 'Name as shown on the card',
              Icons.person_outline,
            ),
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),

          // Expiry + CVV row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: isAr
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'تاريخ الانتهاء' : 'Expiry Date',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      decoration:
                          _decoration('MM/YY', Icons.date_range_outlined),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: isAr
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'الرمز السري (CVV)' : 'CVV Code',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      decoration:
                          _decoration('• • •', Icons.help_outline).copyWith(
                        counterText: '',
                      ),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Save card checkbox
          Row(
            mainAxisAlignment: isAr
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isAr) ...[
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: _saveCard,
                    onChanged: (v) => setState(() => _saveCard = v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                isAr
                    ? 'حفظ وسيلة الدفع للمرات القادمة'
                    : 'Save payment method for next time',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.primaryDark,
                ),
              ),
              if (isAr) ...[
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: _saveCard,
                    onChanged: (v) => setState(() => _saveCard = v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, bool isDark, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusXL),
        ),
        title: Text(
          isAr ? 'تأكيد الدفع' : 'Confirm Payment',
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
        content: Text(
          isAr
              ? 'هل تريد تأكيد دفع مبلغ ٤٬٢٥٠.٠٠ ج.م؟'
              : 'Do you want to confirm payment of 4,250.00 EGP?',
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.cairo(
            color: isDark ? Colors.white70 : AppColors.textGrey600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isAr ? 'إلغاء' : 'Cancel',
              style: GoogleFonts.cairo(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTypography.radiusM),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAr ? '✅ تم الدفع بنجاح' : '✅ Payment successful!',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTypography.radiusM),
                  ),
                ),
              );
            },
            child: Text(
              isAr ? 'تأكيد' : 'Confirm',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final Color color;

  const _PaymentMethod({
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    required this.color,
  });
}
