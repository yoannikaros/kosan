import 'package:flutter/material.dart';
import 'package:kosan/models/room.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/room_repository.dart';
import 'package:kosan/screens/facility_screen.dart';
import 'package:intl/intl.dart';

class RoomsScreen extends StatefulWidget {
  final User user;

  const RoomsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> with SingleTickerProviderStateMixin {
  final _roomRepository = RoomRepository();
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late AnimationController _controller;
  late Animation<double> _animation;
  
  List<Room> _rooms = [];
  bool _isLoading = true;
  Room? _selectedRoom;
  
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
    _loadRooms();
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _floorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStatCard(String title, String value, Color color) {
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

  Widget _buildRoomStatistics() {
    final totalRooms = _rooms.length;
    final availableRooms = _rooms.where((room) => room.status == 'available').length;
    final occupiedRooms = _rooms.where((room) => room.status == 'occupied').length;
    final maintenanceRooms = _rooms.where((room) => room.status == 'maintenance').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Kamar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Kamar', totalRooms.toString(), Colors.blue),
              _buildStatCard('Kamar Tersedia', availableRooms.toString(), Colors.green),
              _buildStatCard('Kamar Terisi', occupiedRooms.toString(), Colors.orange),
              _buildStatCard('Dalam Perawatan', maintenanceRooms.toString(), Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final rooms = await _roomRepository.getAllRooms();
      setState(() {
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
    _selectedRoom = null;
    _roomNumberController.clear();
    _floorController.clear();
    _priceController.clear();
    _descriptionController.clear();
  }

  void _showRoomForm({Room? room}) {
    _resetForm();
    
    if (room != null) {
      _selectedRoom = room;
      _roomNumberController.text = room.roomNumber;
      _floorController.text = room.floor?.toString() ?? '';
      _priceController.text = room.price.toString();
      _descriptionController.text = room.description ?? '';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          room == null ? 'Tambah Kamar' : 'Edit Kamar',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _roomNumberController,
                  decoration: InputDecoration(
                    labelText: 'Nomor Kamar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.meeting_room),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor kamar tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    labelText: 'Lantai',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.stairs),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Harga Sewa',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
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
                  maxLines: 3,
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
                  final room = Room(
                    id: _selectedRoom?.id,
                    ownerId: widget.user.ownerId ?? 0,
                    roomNumber: _roomNumberController.text,
                    floor: _floorController.text.isNotEmpty
                        ? int.parse(_floorController.text)
                        : null,
                    price: double.parse(_priceController.text),
                    description: _descriptionController.text,
                    status: _selectedRoom?.status ?? 'available',
                  );
                  
                  if (_selectedRoom == null) {
                    await _roomRepository.insertRoom(room);
                  } else {
                    await _roomRepository.updateRoom(room);
                  }
                  
                  Navigator.pop(context);
                  _loadRooms();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedRoom == null
                            ? 'Kamar berhasil ditambahkan'
                            : 'Kamar berhasil diperbarui',
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

  void _showDeleteConfirmation(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kamar'),
        content: Text('Apakah Anda yakin ingin menghapus kamar ${room.roomNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              try {
                await _roomRepository.deleteRoom(room.id!);
                Navigator.pop(context);
                _loadRooms();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kamar berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _navigateToFacilities(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacilityScreen(
          user: widget.user,
          roomId: room.id!,
          roomNumber: room.roomNumber,
        ),
      ),
    ).then((_) => _loadRooms());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
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
            : _rooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.meeting_room,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada data kamar',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Kamar'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => _showRoomForm(),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _animation,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildRoomStatistics(),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final room = _rooms[index];
                                return Card(
                                  elevation: 4,
                                  shadowColor: _getStatusColor(room.status).withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => _showRoomForm(room: room),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            _getStatusColor(room.status).withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(room.status).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  room.status,
                                                  style: TextStyle(
                                                    color: _getStatusColor(room.status),
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
                                                    value: 'delete',
                                                    child: Text('Hapus'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'facilities',
                                                    child: Text('Kelola Fasilitas'),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _showRoomForm(room: room);
                                                  } else if (value == 'delete') {
                                                    _showDeleteConfirmation(room);
                                                  } else if (value == 'facilities') {
                                                    _navigateToFacilities(room);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Kamar ${room.roomNumber}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (room.floor != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Lantai ${room.floor}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Text(
                                            _currencyFormat.format(room.price),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton.icon(
                                            icon: const Icon(Icons.chair),
                                            label: const Text('Fasilitas'),
                                            onPressed: () => _navigateToFacilities(room),
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _rooms.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoomForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kamar'),
      ),
    );
  }
}
