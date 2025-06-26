import 'package:flutter/material.dart';
import 'package:kosan/models/owner.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/owner_repository.dart';

class OwnersScreen extends StatefulWidget {
  final User user;

  const OwnersScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  final _ownerRepository = OwnerRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  List<Owner> _owners = [];
  bool _isLoading = true;
  Owner? _selectedOwner;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadOwners() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final owners = await _ownerRepository.getAllOwners();
      setState(() {
        _owners = owners;
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
    _selectedOwner = null;
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
  }

  void _showOwnerForm({Owner? owner}) {
    _resetForm();
    
    if (owner != null) {
      _selectedOwner = owner;
      _nameController.text = owner.name;
      _emailController.text = owner.email ?? '';
      _phoneController.text = owner.phone ?? '';
      _addressController.text = owner.address ?? '';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(owner == null ? 'Tambah Pemilik' : 'Edit Pemilik'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
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
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final owner = Owner(
                    id: _selectedOwner?.id,
                    name: _nameController.text,
                    email: _emailController.text.isNotEmpty ? _emailController.text : null,
                    phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                    address: _addressController.text.isNotEmpty ? _addressController.text : null,
                  );
                  
                  if (_selectedOwner == null) {
                    await _ownerRepository.insertOwner(owner);
                  } else {
                    await _ownerRepository.updateOwner(owner);
                  }
                  
                  Navigator.pop(context);
                  _loadOwners();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedOwner == null
                            ? 'Pemilik berhasil ditambahkan'
                            : 'Pemilik berhasil diperbarui',
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

  void _showDeleteConfirmation(Owner owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pemilik'),
        content: Text('Apakah Anda yakin ingin menghapus pemilik ${owner.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _ownerRepository.deleteOwner(owner.id!);
                Navigator.pop(context);
                _loadOwners();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pemilik berhasil dihapus'),
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
        title: const Text('Daftar Pemilik'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _owners.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada data pemilik',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showOwnerForm(),
                        child: const Text('Tambah Pemilik'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _owners.length,
                  itemBuilder: (context, index) {
                    final owner = _owners[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            owner.name.substring(0, 1).toUpperCase(),
                          ),
                        ),
                        title: Text(
                          owner.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (owner.email != null) Text('Email: ${owner.email}'),
                            if (owner.phone != null) Text('Telepon: ${owner.phone}'),
                          ],
                        ),
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
                              _showOwnerForm(owner: owner);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(owner);
                            }
                          },
                        ),
                        onTap: () {
                          // Detail pemilik
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOwnerForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
