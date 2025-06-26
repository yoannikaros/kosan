import 'package:flutter/material.dart';
import 'package:kosan/models/rental.dart';
import 'package:kosan/models/room.dart';
import 'package:kosan/models/tenant.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/rental_repository.dart';
import 'package:kosan/repositories/room_repository.dart';
import 'package:kosan/repositories/tenant_repository.dart';
import 'package:intl/intl.dart';

class RentalsScreen extends StatefulWidget {
  final User user;

  const RentalsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> with SingleTickerProviderStateMixin {
  final _rentalRepository = RentalRepository();
  final _roomRepository = RoomRepository();
  final _tenantRepository = TenantRepository();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _controller;
  late Animation<double> _animation;
  
  List<Rental> _rentals = [];
  List<Room> _rooms = [];
  List<Tenant> _tenants = [];
  bool _isLoading = true;
  Rental? _selectedRental;
  
  int? _selectedTenantId;
  int? _selectedRoomId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final _priceController = TextEditingController();
  
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
    _priceController.dispose();
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

  Widget _buildRentalStatistics() {
    final totalRentals = _rentals.length;
    final activeRentals = _rentals.where((rental) => rental.status == 'active').length;
    final endedRentals = _rentals.where((rental) => rental.status == 'ended').length;
    final cancelledRentals = _rentals.where((rental) => rental.status == 'cancelled').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Kontrak Sewa',
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
                  'Total Kontrak',
                  totalRentals.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Kontrak Aktif',
                  activeRentals.toString(),
                  Icons.check_circle,
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
                  'Kontrak Selesai',
                  endedRentals.toString(),
                  Icons.event_available,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Kontrak Batal',
                  cancelledRentals.toString(),
                  Icons.cancel,
                  Colors.red,
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
      final rentals = await _rentalRepository.getAllRentals();
      final rooms = await _roomRepository.getAllRooms();
      final tenants = await _tenantRepository.getAllTenants();
      
      setState(() {
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
    _selectedRental = null;
    _selectedTenantId = null;
    _selectedRoomId = null;
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));
    _priceController.clear();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showRentalForm({Rental? rental}) {
    _resetForm();
    
    if (rental != null) {
      _selectedRental = rental;
      _selectedTenantId = rental.tenantId;
      _selectedRoomId = rental.roomId;
      _startDate = DateTime.parse(rental.startDate);
      _endDate = DateTime.parse(rental.endDate);
      _priceController.text = rental.rentPrice.toString();
    } else {
      // Default untuk kamar yang dipilih
      if (_rooms.isNotEmpty) {
        _selectedRoomId = _rooms.first.id;
        _priceController.text = _rooms.first.price.toString();
      }
      if (_tenants.isNotEmpty) {
        _selectedTenantId = _tenants.first.id;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          rental == null ? 'Tambah Kontrak Sewa' : 'Edit Kontrak Sewa',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedTenantId,
                  decoration: InputDecoration(
                    labelText: 'Penyewa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  items: _tenants.map((tenant) {
                    return DropdownMenuItem<int>(
                      value: tenant.id,
                      child: Text(tenant.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTenantId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih penyewa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedRoomId,
                  decoration: InputDecoration(
                    labelText: 'Kamar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.meeting_room),
                  ),
                  items: _rooms.map((room) {
                    return DropdownMenuItem<int>(
                      value: room.id,
                      child: Text('Kamar ${room.roomNumber} - ${_currencyFormat.format(room.price)}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomId = value;
                      // Update harga sesuai kamar yang dipilih
                      if (value != null) {
                        final room = _rooms.firstWhere((room) => room.id == value);
                        _priceController.text = room.price.toString();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kamar';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Mulai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _dateFormat.format(_startDate),
                        ),
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Selesai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.event),
                        ),
                        controller: TextEditingController(
                          text: _dateFormat.format(_endDate),
                        ),
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Harga Sewa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga sewa tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Harga sewa harus berupa angka';
                    }
                    return null;
                  },
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
                  final rental = Rental(
                    id: _selectedRental?.id,
                    tenantId: _selectedTenantId!,
                    roomId: _selectedRoomId!,
                    startDate: _startDate.toIso8601String(),
                    endDate: _endDate.toIso8601String(),
                    rentPrice: double.parse(_priceController.text),
                    status: _selectedRental?.status ?? 'active',
                  );
                  
                  if (_selectedRental == null) {
                    await _rentalRepository.insertRental(rental);
                    // Update status kamar menjadi 'rented'
                    await _roomRepository.updateRoomStatus(_selectedRoomId!, 'rented');
                  } else {
                    await _rentalRepository.updateRental(rental);
                  }
                  
                  Navigator.pop(context);
                  _loadData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedRental == null
                            ? 'Kontrak sewa berhasil ditambahkan'
                            : 'Kontrak sewa berhasil diperbarui',
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

  void _showStatusChangeDialog(Rental rental) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ubah Status Kontrak',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Aktif'),
              leading: Radio<String>(
                value: 'active',
                groupValue: rental.status,
                onChanged: (value) async {
                  await _updateRentalStatus(rental, value!);
                  Navigator.pop(context);
                },
              ),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            ListTile(
              title: const Text('Selesai'),
              leading: Radio<String>(
                value: 'ended',
                groupValue: rental.status,
                onChanged: (value) async {
                  await _updateRentalStatus(rental, value!);
                  Navigator.pop(context);
                },
              ),
              trailing: const Icon(Icons.event_available, color: Colors.orange),
            ),
            ListTile(
              title: const Text('Dibatalkan'),
              leading: Radio<String>(
                value: 'cancelled',
                groupValue: rental.status,
                onChanged: (value) async {
                  await _updateRentalStatus(rental, value!);
                  Navigator.pop(context);
                },
              ),
              trailing: const Icon(Icons.cancel, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRentalStatus(Rental rental, String status) async {
    try {
      await _rentalRepository.updateRentalStatus(rental.id!, status);
      
      // Jika status kontrak berubah menjadi 'ended' atau 'cancelled', update status kamar menjadi 'available'
      if (status == 'ended' || status == 'cancelled') {
        await _roomRepository.updateRoomStatus(rental.roomId, 'available');
      }
      
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status kontrak berhasil diperbarui'),
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

  String _getTenantName(int tenantId) {
    final tenant = _tenants.firstWhere(
      (tenant) => tenant.id == tenantId,
      orElse: () => Tenant(id: 0, name: 'Unknown'),
    );
    return tenant.name;
  }

  String _getRoomNumber(int roomId) {
    final room = _rooms.firstWhere(
      (room) => room.id == roomId,
      orElse: () => Room(id: 0, ownerId: 0, roomNumber: 'Unknown', price: 0),
    );
    return room.roomNumber;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'ended':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'ended':
        return Icons.event_available;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
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
            : _rentals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada data kontrak sewa',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Kontrak Sewa'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => _showRentalForm(),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _animation,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildRentalStatistics(),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final rental = _rentals[index];
                                return Card(
                                  elevation: 4,
                                  shadowColor: Colors.blue.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => _showRentalForm(rental: rental),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                _getStatusIcon(rental.status),
                                                color: _getStatusColor(rental.status),
                                                size: 24,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Kamar ${_getRoomNumber(rental.roomId)} - ${_getTenantName(rental.tenantId)}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              PopupMenuButton(
                                                icon: const Icon(Icons.more_vert),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'status',
                                                    child: Text('Ubah Status'),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _showRentalForm(rental: rental);
                                                  } else if (value == 'status') {
                                                    _showStatusChangeDialog(rental);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(rental.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              rental.status.toUpperCase(),
                                              style: TextStyle(
                                                color: _getStatusColor(rental.status),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_dateFormat.format(DateTime.parse(rental.startDate))} - ${_dateFormat.format(DateTime.parse(rental.endDate))}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.attach_money,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _currencyFormat.format(rental.rentPrice),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _rentals.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRentalForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kontrak'),
      ),
    );
  }
}
