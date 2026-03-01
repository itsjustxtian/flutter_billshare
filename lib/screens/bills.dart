import 'package:flutter/material.dart';
import 'package:flutter_billshare/screens/dashboard.dart';
import 'package:flutter_billshare/utils/dashboard_services.dart';
import 'package:flutter_billshare/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tabs = ['All', 'Pending', 'Paid'];
  final DashboardServices _services = DashboardServices();

  List<Map<String, dynamic>> _allBills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Listen to tab changes to trigger rebuilds for filtering
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    // Call your Supabase function here
    final data = await _services.getAllBillInstances();
    if (mounted) {
      setState(() {
        _allBills = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadBills();
    if (!mounted) return;

    final id = DateTime.now().millisecondsSinceEpoch;
    ShadSonner.of(
      context,
    ).show(ShadToast(id: id, title: const Text('Bills updated!')));
  }

  // Filter logic based on tab index
  List<Map<String, dynamic>> _getFilteredBills(int tabIndex) {
    if (tabIndex == 0) return _allBills;
    String statusCriteria = tabs[tabIndex]; // 'Pending' or 'Paid'
    return _allBills.where((bill) => bill['status'] == statusCriteria).toList();
  }

  Widget _buildTabContent(int tabIndex) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredBills = _getFilteredBills(tabIndex);

    if (filteredBills.isEmpty) {
      return Center(
        child: Text(
          "No ${tabs[tabIndex].toLowerCase()} bills found.",
          style: GoogleFonts.poppins(),
        ),
      );
    }

    return Container(
      color: context.lightBackground,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBills.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bill = filteredBills[index];
          final DateTime rawDate = DateTime.parse(bill['due_date']);
          final String formattedDate = DateFormat(
            'MMM dd, yyyy',
          ).format(rawDate);

          return BillCard(
            title: bill['title'],
            date: formattedDate,
            amount: bill['amount_due'].toString(),
            tagColor: bill['tag_color'] ?? '#FFFFFF',
            status: bill['status'],
            billData: bill,
            onRefresh: _loadBills,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      floatingActionButton: ShadButton(
        onPressed: _handleRefresh,
        backgroundColor: context.lightGreen,
        width: 56,
        height: 56,
        child: Icon(LucideIcons.refreshCw, color: context.darkGreen),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: MoonTabBar(
              isExpanded: true,
              tabController: _tabController,
              tabs: tabs.asMap().entries.map((entry) {
                int idx = entry.key;
                return MoonTab(
                  label: Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontWeight: _tabController.index == idx
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  tabStyle: MoonTabStyle(
                    indicatorColor: Colors.transparent,
                    selectedTextColor: context.white,
                    decoration: _tabController.index == idx
                        ? BoxDecoration(
                            color: context.lightBackground,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          )
                        : const BoxDecoration(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(0), // All
            _buildTabContent(1), // Pending
            _buildTabContent(2), // Paid
          ],
        ),
      ),
    );
  }
}
