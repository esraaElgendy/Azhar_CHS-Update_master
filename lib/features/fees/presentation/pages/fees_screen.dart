import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/bloc/settings_cubit.dart';
import 'payment_details_screen.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Static data matching the design
    const double totalFees = 12500;
    const double paidAmount = 7500;
    const double remainingAmount = 5000;
    const double paidPercent = 0.60;
    const String dueDate = '15 نوفمبر 2023';
    const String dueDateEn = '15 Nov 2023';

    final String level = isAr ? 'المستوى الثالث' : 'Level 3';
    final String semester = isAr ? 'الفصل الدراسي الخريف - 2023/2024' : 'Fall Semester - 2023/2024';
    final String totalLabel = isAr ? 'إجمالي المصروفات' : 'Total Fees';
    final String paidLabel = isAr ? 'المبلغ المدفوع' : 'Paid Amount';
    final String remainingLabel = isAr ? 'المبلغ المتبقي' : 'Remaining';
    final String paymentStatusLabel = isAr ? 'حالة السداد' : 'Payment Status';
    final String dueDateLabel = isAr ? 'تاريخ الاستحقاق' : 'Due Date';
    final String feeDetailsLabel = isAr ? 'تفاصيل الرسوم' : 'Fee Details';
    final String payNowLabel = isAr ? 'ادفع الآن' : 'Pay Now';
    final String currencySymbol = 'ج.م';

    final List<_FeeItem> feeItems = [
      _FeeItem(
        title: isAr ? 'رسوم الساعات المعتمدة' : 'Credit Hours Fees',
        subtitle: isAr ? '١٨ ساعة معتمدة' : '18 credit hours',
        amount: 9000,
        icon: Icons.school_outlined,
        color: AppColors.primary,
      ),
      _FeeItem(
        title: isAr ? 'رسوم التسجيل' : 'Registration Fees',
        subtitle: isAr ? 'رسوم إدارية سنوية' : 'Annual administrative fees',
        amount: 2500,
        icon: Icons.assignment_ind_outlined,
        color: AppColors.accent1,
      ),
      _FeeItem(
        title: isAr ? 'رسوم الخدمات' : 'Services Fees',
        subtitle: isAr ? 'مكتبة، تأمين، أنشطة' : 'Library, insurance, activities',
        amount: 1000,
        icon: Icons.medical_services_outlined,
        color: AppColors.success,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.fees,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
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
              tooltip: isDark ? (isAr ? 'الوضع الفاتح' : 'Light Mode') : (isAr ? 'الوضع الداكن' : 'Dark Mode'),
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: AppColors.primary,
              ),
              onPressed: () => ctx.read<SettingsCubit>().toggleTheme(!isDark),
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Level & semester header
            _buildLevelHeader(
              context: context,
              isDark: isDark,
              level: level,
              semester: semester,
            ),
            const SizedBox(height: 16),

            // Total fees summary card
            _buildSummaryCard(
              context: context,
              isDark: isDark,
              isAr: isAr,
              totalFees: totalFees,
              paidAmount: paidAmount,
              remainingAmount: remainingAmount,
              paidPercent: paidPercent,
              totalLabel: totalLabel,
              paidLabel: paidLabel,
              remainingLabel: remainingLabel,
              paymentStatusLabel: paymentStatusLabel,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: 16),

            // Due date warning
            _buildDueDateCard(
              context: context,
              isDark: isDark,
              isAr: isAr,
              dueDate: isAr ? dueDate : dueDateEn,
              dueDateLabel: dueDateLabel,
            ),
            const SizedBox(height: 24),

            // Fee details section
            Text(
              feeDetailsLabel,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // Fee items
            ...feeItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildFeeItemCard(
                context: context,
                isDark: isDark,
                isAr: isAr,
                item: item,
                currencySymbol: currencySymbol,
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
      // Pay Now button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentDetailsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.payment_outlined, size: 22),
            label: Text(
              payNowLabel,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelHeader({
    required BuildContext context,
    required bool isDark,
    required String level,
    required String semester,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                level,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              Text(
                semester,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : AppColors.textGrey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required bool isDark,
    required bool isAr,
    required double totalFees,
    required double paidAmount,
    required double remainingAmount,
    required double paidPercent,
    required String totalLabel,
    required String paidLabel,
    required String remainingLabel,
    required String paymentStatusLabel,
    required String currencySymbol,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xffBEBEBE),
            const Color(0xffD0D0D0),
            const Color(0xffE8E8E8),
            Colors.white,
          ],
          stops: [0.0, paidPercent * 0.33, paidPercent * 0.66, 1.0],
          begin: isAr ? Alignment.centerRight : Alignment.centerLeft,
          end: isAr ? Alignment.centerLeft : Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppTypography.radiusL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Icon + total label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isAr)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.primary, size: 26),
                ),
              Text(
                totalLabel,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textGrey600,
                ),
              ),
              if (isAr)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.primary, size: 26),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Total amount
          Text(
            '${_formatAmount(totalFees)} $currencySymbol',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Paid & remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountChip(
                label: remainingLabel,
                amount: remainingAmount,
                currencySymbol: currencySymbol,
                isAr: isAr,
              ),
              _buildAmountChip(
                label: paidLabel,
                amount: paidAmount,
                currencySymbol: currencySymbol,
                isAr: isAr,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    paymentStatusLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textGrey600,
                    ),
                  ),
                  Text(
                    '${(paidPercent * 100).toInt()}٪',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: paidPercent,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip({
    required String label,
    required double amount,
    required String currencySymbol,
    required bool isAr,
  }) {
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.textGrey600,
          ),
        ),
        Text(
          '${_formatAmount(amount)} $currencySymbol',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateCard({
    required BuildContext context,
    required bool isDark,
    required bool isAr,
    required String dueDate,
    required String dueDateLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.error.withOpacity(0.15)
            : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(AppTypography.radiusM),
        border: Border.all(
          color: AppColors.error.withOpacity(isDark ? 0.4 : 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isAr)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.error, size: 20),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isAr ? 0 : 12),
              child: Column(
                crossAxisAlignment:
                    isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    dueDateLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.error.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    dueDate,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAr)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.error, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildFeeItemCard({
    required BuildContext context,
    required bool isDark,
    required bool isAr,
    required _FeeItem item,
    required String currencySymbol,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isAr) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.textGrey600,
                  ),
                ),
              ],
            ),
          ),
          if (isAr) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
          ],
          const SizedBox(width: 12),
          Text(
            '${_formatAmount(item.amount)} $currencySymbol',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.toInt()) {
      final str = amount.toInt().toString();
      final buffer = StringBuffer();
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buffer.write(',');
        buffer.write(str[i]);
        count++;
      }
      return buffer.toString().split('').reversed.join();
    }
    return amount.toStringAsFixed(2);
  }
}

class _FeeItem {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color color;

  const _FeeItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
  });
}
