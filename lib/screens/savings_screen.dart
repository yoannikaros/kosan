import 'package:flutter/material.dart';
import 'package:kosan/models/saving.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/saving_repository.dart';
import 'package:intl/intl.dart';

class SavingsScreen extends StatefulWidget {
  final User user;

  const SavingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> with SingleTickerProviderStateMixin {
  final _savingRepository = SavingRepository();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _controller;
  late Animation<double> _animation;
  
  List<Saving> _savings = [];
  bool _isLoading = true;
  Saving? _selectedSaving;
  
  DateTime _savingDate = DateTime.now();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _statusController = TextEditingController();
  final _noteController = TextEditingController();
  
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _loadData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _targetAmountController.dispose();
    _statusController.dispose();
    _noteController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.7),
              color,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingStatistics() {
    final totalSavings = _savings.length;
    final totalAmount = _savings.fold<double>(0, (sum, s) => sum + s.amount);
    final totalTarget = _savings.fold<double>(0, (sum, s) => sum + (s.targetAmount ?? 0));
    final completedSavings = _savings.where((s) => s.status?.toLowerCase() == 'completed').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Tabungan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tabungan',
                  totalSavings.toString(),
                  Icons.savings,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Terkumpul',
                  _currencyFormat.format(totalAmount),
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Target Total',
                  _currencyFormat.format(totalTarget),
                  Icons.flag,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Tercapai',
                  completedSavings.toString(),
                  Icons.task_alt,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final savings = await _savingRepository.getAllSavings();
      setState(() {
        _savings = savings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _selectedSaving = null;
    _savingDate = DateTime.now();
    _descriptionController.clear();
    _amountController.clear();
    _targetAmountController.clear();
    _statusController.clear();
    _noteController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _savingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _savingDate = picked;
      });
    }
  }

  void _showSavingForm({Saving? saving}) {
    _resetForm();
    
    if (saving != null) {
      _selectedSaving = saving;
      _savingDate = DateTime.parse(saving.savingDate);
      _descriptionController.text = saving.description;
      _amountController.text = saving.amount.toString();
      _targetAmountController.text = saving.targetAmount?.toString() ?? '';
      _statusController.text = saving.status ?? '';
      _noteController.text = saving.note ?? '';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          saving == null ? 'Tambah Tabungan' : 'Edit Tabungan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                  ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _dateFormat.format(_savingDate),
                  ),
                  onTap: () => _selectDate(context),
                    ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Jumlah harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Target Jumlah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _statusController.text.isEmpty ? null : _statusController.text,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                        ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'In Progress', child: Text('Dalam Proses')),
                    DropdownMenuItem(value: 'Completed', child: Text('Tercapai')),
                    DropdownMenuItem(value: 'Cancelled', child: Text('Dibatalkan')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusController.text = value ?? '';
                    });
                  },
                    ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.note),
                    ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final saving = Saving(
                    id: _selectedSaving?.id,
                    ownerId: widget.user.ownerId ?? 0,
                    savingDate: _savingDate.toIso8601String(),
                    description: _descriptionController.text,
                    amount: double.parse(_amountController.text),
                    targetAmount: _targetAmountController.text.isNotEmpty
                        ? double.parse(_targetAmountController.text)
                        : null,
                    status: _statusController.text.isNotEmpty
                        ? _statusController.text
                        : null,
                    note: _noteController.text.isNotEmpty
                        ? _noteController.text
                        : null,
                  );
                  
                  if (_selectedSaving == null) {
                    await _savingRepository.insertSaving(saving);
                  } else {
                    await _savingRepository.updateSaving(saving);
                  }
                  
                  Navigator.pop(context);
                  _loadData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedSaving == null
                            ? 'Tabungan berhasil ditambahkan'
                            : 'Tabungan berhasil diperbarui',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'in progress':
        return Icons.pending;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  double _calculateProgress(Saving saving) {
    if (saving.targetAmount == null || saving.targetAmount == 0) {
      return 0.0;
    }
    return (saving.amount / saving.targetAmount!).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
                      ],
                    ),
                  ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.savings,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada data tabungan',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Tabungan'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                                onPressed: () => _showSavingForm(),
                              ),
                            ],
                          ),
                        )
                : FadeTransition(
                    opacity: _animation,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildSavingStatistics(),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final saving = _savings[index];
                                final statusColor = _getStatusColor(saving.status);
                                final statusIcon = _getStatusIcon(saving.status);
                                final progress = _calculateProgress(saving);
                                
                            return Card(
                                  elevation: 4,
                                  shadowColor: Colors.blue.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                              ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  statusIcon,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    saving.description,
                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _dateFormat.format(
                                                      DateTime.parse(saving.savingDate),
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                saving.status ?? 'In Progress',
                                                style: TextStyle(
                                                  color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        if (saving.targetAmount != null) ...[
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              backgroundColor: Colors.grey.shade200,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                progress >= 1.0 ? Colors.green : Colors.blue,
                                              ),
                                              minHeight: 8,
                                            ),
                                ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _currencyFormat.format(saving.amount),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Text(
                                                _currencyFormat.format(saving.targetAmount),
                                      style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          Text(
                                            'Terkumpul: ${_currencyFormat.format(saving.amount)}',
                                            style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                        if (saving.note != null &&
                                            saving.note!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.note,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    saving.note!,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                        ),
                                      ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              icon: const Icon(Icons.edit, size: 18),
                                              label: const Text('Edit'),
                                              onPressed: () =>
                                                  _showSavingForm(saving: saving),
                                    ),
                                  ],
                                ),
                                      ],
                                    ),
                              ),
                            );
                          },
                              childCount: _savings.length,
                            ),
                        ),
                ),
              ],
            ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSavingForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tabungan'),
      ),
    );
  }
}
