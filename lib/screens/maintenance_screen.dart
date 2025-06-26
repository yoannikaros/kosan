import 'package:flutter/material.dart';
import 'package:kosan/models/maintenance.dart';
import 'package:kosan/models/room.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/maintenance_repository.dart';
import 'package:kosan/repositories/room_repository.dart';
import 'package:intl/intl.dart';

class MaintenanceScreen extends StatefulWidget {
  final User user;

  const MaintenanceScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  final _maintenanceRepository = MaintenanceRepository();
  final _roomRepository = RoomRepository();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _controller;
  late Animation<double> _animation;
  
  List<Maintenance> _maintenanceList = [];
  List<Room> _rooms = [];
  bool _isLoading = true;
  Maintenance? _selectedMaintenance;
  
  int? _selectedRoomId;
  DateTime _maintenanceDate = DateTime.now();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
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
    _costController.dispose();
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

  Widget _buildMaintenanceStatistics() {
    final totalMaintenances = _maintenanceList.length;
    final totalCost = _maintenanceList.fold<double>(
      0,
      (sum, m) => sum + (m.cost ?? 0),
    );
    final pendingMaintenances = _maintenanceList
        .where((m) => m.status?.toLowerCase() == 'pending')
        .length;
    final completedMaintenances = _maintenanceList
        .where((m) => m.status?.toLowerCase() == 'completed')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Perawatan',
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
                  'Total Perawatan',
                  totalMaintenances.toString(),
                  Icons.build,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Biaya',
                  _currencyFormat.format(totalCost),
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
                  'Menunggu',
                  pendingMaintenances.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Selesai',
                  completedMaintenances.toString(),
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
      final maintenances = await _maintenanceRepository.getAllMaintenances();
      final rooms = await _roomRepository.getAllRooms();
      
      setState(() {
        _maintenanceList = maintenances;
        _rooms = rooms;
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
    _selectedMaintenance = null;
    _selectedRoomId = null;
    _maintenanceDate = DateTime.now();
    _descriptionController.clear();
    _costController.clear();
    _statusController.clear();
    _noteController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _maintenanceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _maintenanceDate = picked;
      });
    }
  }

  void _showMaintenanceForm({Maintenance? maintenance}) {
    _resetForm();
    
    if (maintenance != null) {
      _selectedMaintenance = maintenance;
      _selectedRoomId = maintenance.roomId;
      _maintenanceDate = DateTime.parse(maintenance.maintenanceDate);
      _descriptionController.text = maintenance.description;
      _costController.text = maintenance.cost?.toString() ?? '';
      _statusController.text = maintenance.status ?? '';
      _noteController.text = maintenance.note ?? '';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          maintenance == null ? 'Tambah Perawatan' : 'Edit Perawatan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                      child: Text('Kamar ${room.roomNumber}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomId = value;
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
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Perawatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _dateFormat.format(_maintenanceDate),
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
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costController,
                  decoration: InputDecoration(
                    labelText: 'Biaya',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
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
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
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
                  final maintenance = Maintenance(
                    id: _selectedMaintenance?.id,
                    roomId: _selectedRoomId!,
                    maintenanceDate: _maintenanceDate.toIso8601String(),
                    description: _descriptionController.text,
                    cost: _costController.text.isNotEmpty
                        ? double.parse(_costController.text)
                        : null,
                    status: _statusController.text.isNotEmpty
                        ? _statusController.text
                        : null,
                    note: _noteController.text.isNotEmpty
                        ? _noteController.text
                        : null,
                  );
                  
                  if (_selectedMaintenance == null) {
                    await _maintenanceRepository.insertMaintenance(maintenance);
                  } else {
                    await _maintenanceRepository.updateMaintenance(maintenance);
                  }
                  
                  Navigator.pop(context);
                  _loadData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedMaintenance == null
                            ? 'Perawatan berhasil ditambahkan'
                            : 'Perawatan berhasil diperbarui',
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
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
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
            : _maintenanceList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.build,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada data perawatan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Perawatan'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        onPressed: () => _showMaintenanceForm(),
                      ),
                    ],
                  ),
                )
                : FadeTransition(
                    opacity: _animation,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildMaintenanceStatistics(),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final maintenance = _maintenanceList[index];
                                final room = _rooms.firstWhere(
                                  (room) => room.id == maintenance.roomId,
                                  orElse: () => Room(
                                    id: 0,
                                    ownerId: 0,
                                    roomNumber: 'Unknown',
                                    price: 0,
                                  ),
                                );
                                
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
                                                color: Colors.blue.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.build,
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
                                                    'Kamar ${room.roomNumber}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _dateFormat.format(
                                                      DateTime.parse(maintenance.maintenanceDate),
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
                                                color: _getStatusColor(maintenance.status)
                                                    .withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                maintenance.status ?? 'Pending',
                                                style: TextStyle(
                                                  color: _getStatusColor(maintenance.status),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          maintenance.description,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (maintenance.cost != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Biaya: ${_currencyFormat.format(maintenance.cost)}',
                          style: const TextStyle(
                                              color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                                        ],
                                        if (maintenance.note != null &&
                                            maintenance.note!.isNotEmpty) ...[
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
                                                    maintenance.note!,
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
                                                  _showMaintenanceForm(maintenance: maintenance),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                      ),
                    );
                  },
                              childCount: _maintenanceList.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMaintenanceForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Perawatan'),
      ),
    );
  }
}
