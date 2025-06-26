import 'package:flutter/material.dart';
import 'package:kosan/models/facility.dart';
import 'package:kosan/models/room.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/facility_repository.dart';
import 'package:kosan/repositories/room_repository.dart';

class FacilityScreen extends StatefulWidget {
  final User user;
  final int roomId;
  final String roomNumber;

  const FacilityScreen({
    Key? key, 
    required this.user, 
    required this.roomId,
    required this.roomNumber,
  }) : super(key: key);

  @override
  State<FacilityScreen> createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen> {
  final _facilityRepository = FacilityRepository();
  final _formKey = GlobalKey<FormState>();
  final _facilityNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<Facility> _facilities = [];
  bool _isLoading = true;
  Facility? _selectedFacility;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _facilityNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final facilities = await _facilityRepository.getFacilitiesByRoomId(widget.roomId);
      setState(() {
        _facilities = facilities;
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
    _selectedFacility = null;
    _facilityNameController.clear();
    _descriptionController.clear();
  }

  void _showFacilityForm({Facility? facility}) {
    _resetForm();
    
    if (facility != null) {
      _selectedFacility = facility;
      _facilityNameController.text = facility.facilityName;
      _descriptionController.text = facility.description ?? '';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(facility == null ? 'Tambah Fasilitas' : 'Edit Fasilitas'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _facilityNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Fasilitas',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama fasilitas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
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
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final facility = Facility(
                    id: _selectedFacility?.id,
                    roomId: widget.roomId,
                    facilityName: _facilityNameController.text,
                    description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                  );
                  
                  if (_selectedFacility == null) {
                    await _facilityRepository.insertFacility(facility);
                  } else {
                    await _facilityRepository.updateFacility(facility);
                  }
                  
                  Navigator.pop(context);
                  _loadFacilities();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedFacility == null
                            ? 'Fasilitas berhasil ditambahkan'
                            : 'Fasilitas berhasil diperbarui',
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

  void _showDeleteConfirmation(Facility facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Fasilitas'),
        content: Text('Apakah Anda yakin ingin menghapus fasilitas ${facility.facilityName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _facilityRepository.deleteFacility(facility.id!);
                Navigator.pop(context);
                _loadFacilities();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fasilitas berhasil dihapus'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fasilitas Kamar ${widget.roomNumber}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _facilities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chair,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada data fasilitas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showFacilityForm(),
                        child: const Text('Tambah Fasilitas'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _facilities.length,
                  itemBuilder: (context, index) {
                    final facility = _facilities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.chair),
                        ),
                        title: Text(
                          facility.facilityName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: facility.description != null
                            ? Text(facility.description!)
                            : null,
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showFacilityForm(facility: facility);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(facility);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFacilityForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
