import 'package:flutter/material.dart';

/// Reusable billing tab bar component
class BillingTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<BillingTab> tabs;

  const BillingTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabs: tabs.map((tab) => Tab(
        icon: Icon(tab.icon),
        text: tab.label,
      )).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Billing tab configuration
class BillingTab {
  final IconData icon;
  final String label;
  final String tooltip;

  const BillingTab({
    required this.icon,
    required this.label,
    required this.tooltip,
  });
}

/// Predefined billing tabs
class BillingTabs {
  static const List<BillingTab> defaultTabs = [
    BillingTab(
      icon: Icons.account_balance_wallet,
      label: 'Overview',
      tooltip: 'Credit balance and account status',
    ),
    BillingTab(
      icon: Icons.history,
      label: 'Transactions',
      tooltip: 'Transaction history and ledger',
    ),
    BillingTab(
      icon: Icons.shopping_cart,
      label: 'Purchases',
      tooltip: 'Purchase history and packages',
    ),
    BillingTab(
      icon: Icons.analytics,
      label: 'Analytics',
      tooltip: 'Usage analytics and insights',
    ),
    BillingTab(
      icon: Icons.calculate,
      label: 'Costs',
      tooltip: 'Cost estimation and breakdown',
    ),
  ];
}
