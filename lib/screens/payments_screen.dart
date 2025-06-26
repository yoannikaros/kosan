import 'package:flutter/material.dart';
import 'package:kosan/models/payment.dart';
import 'package:kosan/models/rental.dart';
import 'package:kosan/models/room.dart';
import 'package:kosan/models/tenant.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/payment_repository.dart';
import 'package:kosan/repositories/rental_repository.dart';
import 'package:kosan/repositories/room_repository.dart';
import 'package:kosan/repositories/tenant_repository.dart';
import 'package:kosan/screens/payment_receipt_screen.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatefulWidget {
  final User user;

  const PaymentsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  final _paymentRepository = PaymentRepository();
  final _rentalRepository = RentalRepository();
  final _roomRepository = RoomRepository();
  final _tenantRepository = TenantRepository();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _controller;
  late Animation<double> _animation;
  
  List<Payment> _payments = [];
  List<Rental> _rentals = [];
  List<Room> _rooms = [];
  List<Tenant> _tenants = [];
  bool _isLoading = true;
  Payment? _selectedPayment;
  
  int? _selectedRentalId;
  DateTime _paymentDate = DateTime.now();
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
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
    _amountController.dispose();
    _paymentMethodController.dispose();
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

  Widget _buildPaymentStatistics() {
    final totalPayments = _payments.length;
    final totalAmount = _payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final thisMonthPayments = _payments.where((payment) {
      final paymentDate = DateTime.parse(payment.paymentDate);
      final now = DateTime.now();
      return paymentDate.year == now.year && paymentDate.month == now.month;
    }).length;
    final thisMonthAmount = _payments.where((payment) {
      final paymentDate = DateTime.parse(payment.paymentDate);
      final now = DateTime.now();
      return paymentDate.year == now.year && paymentDate.month == now.month;
    }).fold<double>(0, (sum, payment) => sum + payment.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Pembayaran',
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
                  'Total Pembayaran',
                  totalPayments.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Nominal',
                  _currencyFormat.format(totalAmount),
                  Icons.payments,
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
                  'Pembayaran Bulan Ini',
                  thisMonthPayments.toString(),
                  Icons.date_range,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Nominal Bulan Ini',
                  _currencyFormat.format(thisMonthAmount),
                  Icons.account_balance_wallet,
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
      final payments = await _paymentRepository.getAllPayments();
      final rentals = await _rentalRepository.getAllRentals();
      final rooms = await _roomRepository.getAllRooms();
      final tenants = await _tenantRepository.getAllTenants();
      
      setState(() {
        _payments = payments;
        _rentals = rentals;
        _rooms = rooms;
        _tenants = tenants;
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
    _selectedPayment = null;
    _selectedRentalId = null;
    _paymentDate = DateTime.now();
    _amountController.clear();
    _paymentMethodController.clear();
    _noteController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  void _showPaymentForm({Payment? payment}) {
    _resetForm();
    
    if (payment != null) {
      _selectedPayment = payment;
      _selectedRentalId = payment.rentalId;
      _paymentDate = DateTime.parse(payment.paymentDate);
      _amountController.text = payment.amount.toString();
      _paymentMethodController.text = payment.paymentMethod ?? '';
      _noteController.text = payment.note ?? '';
    } else {
      // Default untuk kontrak yang dipilih
      if (_rentals.isNotEmpty) {
        _selectedRentalId = _rentals.first.id;
        _amountController.text = _rentals.first.rentPrice.toString();
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          payment == null ? 'Tambah Pembayaran' : 'Edit Pembayaran',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedRentalId,
                  decoration: InputDecoration(
                    labelText: 'Kontrak Sewa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.assignment),
                  ),
                  items: _rentals.map((rental) {
                    final tenant = _tenants.firstWhere(
                      (tenant) => tenant.id == rental.tenantId,
                      orElse: () => Tenant(id: 0, name: 'Unknown'),
                    );
                    final room = _rooms.firstWhere(
                      (room) => room.id == rental.roomId,
                      orElse: () => Room(id: 0, ownerId: 0, roomNumber: 'Unknown', price: 0),
                    );
                    return DropdownMenuItem<int>(
                      value: rental.id,
                      child: Text('${tenant.name} - Kamar ${room.roomNumber}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRentalId = value;
                      // Update jumlah sesuai harga sewa
                      if (value != null) {
                        final rental = _rentals.firstWhere((rental) => rental.id == value);
                        _amountController.text = rental.rentPrice.toString();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kontrak sewa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Pembayaran',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _dateFormat.format(_paymentDate),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Pembayaran',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah pembayaran tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Jumlah pembayaran harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: InputDecoration(
                    labelText: 'Metode Pembayaran',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.payment),
                  ),
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
                  final payment = Payment(
                    id: _selectedPayment?.id,
                    rentalId: _selectedRentalId!,
                    paymentDate: _paymentDate.toIso8601String(),
                    amount: double.parse(_amountController.text),
                    paymentMethod: _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : null,
                    note: _noteController.text.isNotEmpty ? _noteController.text : null,
                  );
                  
                  late Payment savedPayment;
                  
                  if (_selectedPayment == null) {
                    // Insert new payment
                    final paymentId = await _paymentRepository.insertPayment(payment);
                    final newPayment = await _paymentRepository.getPaymentById(paymentId);
                    if (newPayment != null) {
                      savedPayment = newPayment;
                    } else {
                      savedPayment = payment;
                    }
                  } else {
                    // Update existing payment
                    await _paymentRepository.updatePayment(payment);
                    savedPayment = payment;
                  }
                  
                  Navigator.pop(context);
                  _loadData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedPayment == null
                            ? 'Pembayaran berhasil ditambahkan'
                            : 'Pembayaran berhasil diperbarui',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Tampilkan kwitansi
                  _viewReceipt(savedPayment);
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

  String _getRentalInfo(int rentalId) {
    final rental = _rentals.firstWhere(
      (rental) => rental.id == rentalId,
      orElse: () => Rental(
        id: 0,
        tenantId: 0,
        roomId: 0,
        startDate: '',
        endDate: '',
        rentPrice: 0,
      ),
    );
    
    if (rental.id == 0) return 'Unknown';
    
    final tenant = _tenants.firstWhere(
      (tenant) => tenant.id == rental.tenantId,
      orElse: () => Tenant(id: 0, name: 'Unknown'),
    );
    
    final room = _rooms.firstWhere(
      (room) => room.id == rental.roomId,
      orElse: () => Room(id: 0, ownerId: 0, roomNumber: 'Unknown', price: 0),
    );
    
    return '${tenant.name} - Kamar ${room.roomNumber}';
  }

  void _viewReceipt(Payment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentReceiptScreen(
          payment: payment,
          ownerId: widget.user.ownerId ?? 0,
        ),
      ),
    );
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
            : _payments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.payment,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada data pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Pembayaran'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => _showPaymentForm(),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _animation,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildPaymentStatistics(),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final payment = _payments[index];
                                return Card(
                                  elevation: 4,
                                  shadowColor: Colors.blue.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => _viewReceipt(payment),
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
                                                  color: Colors.blue.shade100,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.receipt,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _getRentalInfo(payment.rentalId),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _dateFormat.format(DateTime.parse(payment.paymentDate)),
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _currencyFormat.format(payment.amount),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  if (payment.paymentMethod != null)
                                                    Text(
                                                      payment.paymentMethod!,
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (payment.note != null && payment.note!.isNotEmpty) ...[
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
                                                      payment.note!,
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
                                                icon: const Icon(Icons.receipt_long, size: 18),
                                                label: const Text('Lihat Kwitansi'),
                                                onPressed: () => _viewReceipt(payment),
                                              ),
                                              TextButton.icon(
                                                icon: const Icon(Icons.edit, size: 18),
                                                label: const Text('Edit'),
                                                onPressed: () => _showPaymentForm(payment: payment),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _payments.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pembayaran'),
      ),
    );
  }
}
