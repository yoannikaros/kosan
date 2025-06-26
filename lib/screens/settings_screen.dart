import 'package:flutter/material.dart';
import 'package:kosan/models/setting.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/repositories/setting_repository.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingRepository = SettingRepository();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  Setting? _setting;
  
  final _businessNameController = TextEditingController();
  final _noteHeaderController = TextEditingController();
  final _noteFooterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _noteHeaderController.dispose();
    _noteFooterController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final setting = await _settingRepository.getSettingByOwnerId(widget.user.ownerId ?? 0);
      
      setState(() {
        _setting = setting;
        if (setting != null) {
          _businessNameController.text = setting.businessName ?? '';
          _noteHeaderController.text = setting.noteHeader ?? '';
          _noteFooterController.text = setting.noteFooter ?? '';
        }
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

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      try {
        final setting = Setting(
          id: _setting?.id,
          ownerId: widget.user.ownerId ?? 0,
          businessName: _businessNameController.text.isNotEmpty ? _businessNameController.text : null,
          noteHeader: _noteHeaderController.text.isNotEmpty ? _noteHeaderController.text : null,
          noteFooter: _noteFooterController.text.isNotEmpty ? _noteFooterController.text : null,
        );
        
        await _settingRepository.updateSetting(setting);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengaturan Usaha',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Usaha',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pengaturan Nota',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteHeaderController,
                      decoration: const InputDecoration(
                        labelText: 'Header Nota',
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: Terima kasih telah menyewa di tempat kami',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteFooterController,
                      decoration: const InputDecoration(
                        labelText: 'Footer Nota',
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: Hubungi kami di 08123456789',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Simpan Pengaturan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
