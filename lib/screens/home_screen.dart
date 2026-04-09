import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/aes_decoder.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  String _selectedMode = 'file';

  Future<void> _decodeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      setState(() => _isLoading = true);
      
      // ✅ الطريقة الصحيحة لقراءة الملف
      String filePath = result.files.first.path!;
      File file = File(filePath);
      String content = await file.readAsString();
      
      String decoded = AESDecoder.decode(content.trim());
      
      setState(() {
        _result = decoded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _decodeText() {
    if (_inputController.text.isEmpty) {
      _showErrorDialog('الرجاء إدخال النص المشفر');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      try {
        String decoded = AESDecoder.decode(_inputController.text.trim());
        setState(() {
          _result = decoded;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('خطأ', style: TextStyle(color: AppTheme.errorRed)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ النص إلى الحافظة'),
        backgroundColor: AppTheme.primaryGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareResult() {
    Share.share(_result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('DECODER v1.0'),
        backgroundColor: Colors.black.withOpacity(0.9),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryGreen),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Alaa & PY_Code'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  Colors.grey[900]!,
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.terminalBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryGreen),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMode = 'file'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedMode == 'file' ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '📁 ملف',
                                style: TextStyle(
                                  color: _selectedMode == 'file' ? AppTheme.primaryGreen : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMode = 'text'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedMode == 'text' ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '⌨️ نص',
                                style: TextStyle(
                                  color: _selectedMode == 'text' ? AppTheme.primaryGreen : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                if (_selectedMode == 'file')
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _decodeFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('اختيار ملف my.nm'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                else
                  Column(
                    children: [
                      TextField(
                        controller: _inputController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'أدخل النص المشفر هنا',
                          hintText: 'Paste encrypted base64 text...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _decodeText,
                        icon: const Icon(Icons.code),
                        label: const Text('فك التشفير'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 30),
                
                if (_result.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🔓 النتيجة المفكوكة',
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _copyResult,
                                    icon: const Icon(Icons.copy, size: 20),
                                    color: AppTheme.primaryGreen,
                                  ),
                                  IconButton(
                                    onPressed: _shareResult,
                                    icon: const Icon(Icons.share, size: 20),
                                    color: AppTheme.primaryGreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(color: AppTheme.primaryGreen),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.terminalBlack,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              _result,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                Center(
                  child: Text(
                    'Developed by Alaa & PY_Code',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'جاري فك التشفير...',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
