import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/aes_decoder.dart';
import '../theme/app_theme.dart';
import '../widgets/matrix_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  String _selectedMode = 'file';
  late AnimationController _glowController;
  
  final String _telegramUrl = "https://t.me/PX_Code";

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _decodeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['nm'],  // ✅ فقط ملفات .nm
      );
      if (result == null) return;

      setState(() => _isLoading = true);
      
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
      _showErrorDialog('⚠️ الرجاء إدخال النص المشفر');
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
        title: Row(
          children: const [
            Icon(Icons.error, color: AppTheme.errorRed),
            SizedBox(width: 10),
            Text('خطأ', style: TextStyle(color: AppTheme.errorRed)),
          ],
        ),
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
        content: Text('✅ تم نسخ النص إلى الحافظة'),
        backgroundColor: AppTheme.primaryGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareResult() {
    Share.share(_result);
  }

  void _openTelegram() async {
    final Uri uri = Uri.parse(_telegramUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog('لا يمكن فتح Telegram');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MatrixBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Text(
                'Py_Coder v1.0',
                style: GoogleFonts.shareTechMono(
                  fontSize: 20,
                  color: AppTheme.primaryGreen.withOpacity(0.7 + _glowController.value * 0.3),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              );
            },
          ),
          backgroundColor: Colors.black.withOpacity(0.8),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryGreen, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  'Py_Coder™',
                  style: GoogleFonts.shareTechMono(
                    color: AppTheme.primaryGreen,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شاشة دخول فخامة
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryGreen.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.security,
                          size: 50,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'AES-256 DECRYPTOR',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 16,
                            color: AppTheme.primaryGreen,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Secure • Fast • Professional',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // اختيار الوضع
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGreen, width: 1),
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '📁 FILE',
                                  style: GoogleFonts.shareTechMono(
                                    color: _selectedMode == 'file' ? AppTheme.primaryGreen : Colors.grey,
                                    fontWeight: FontWeight.bold,
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '⌨️ TEXT',
                                  style: GoogleFonts.shareTechMono(
                                    color: _selectedMode == 'text' ? AppTheme.primaryGreen : Colors.grey,
                                    fontWeight: FontWeight.bold,
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
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return ElevatedButton.icon(
                          onPressed: _isLoading ? null : _decodeFile,
                          icon: const Icon(Icons.code, size: 24),
                          label: Text(
                            'SELECT .nm FILE',
                            style: GoogleFonts.shareTechMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: AppTheme.primaryGreen.withOpacity(0.5 + _glowController.value * 0.5),
                              width: 2,
                            ),
                            elevation: 5,
                            shadowColor: AppTheme.primaryGreen,
                          ),
                        );
                      },
                    )
                  else
                    Column(
                      children: [
                        TextField(
                          controller: _inputController,
                          maxLines: 6,
                          style: GoogleFonts.shareTechMono(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'ENCRYPTED TEXT',
                            labelStyle: GoogleFonts.shareTechMono(color: AppTheme.primaryGreen),
                            hintText: 'Paste base64 encrypted text here...',
                            hintStyle: GoogleFonts.shareTechMono(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primaryGreen),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _decodeText,
                          icon: const Icon(Icons.lock_open, size: 24),
                          label: Text(
                            'DECRYPT',
                            style: GoogleFonts.shareTechMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 30),
                  
                  // عرض النتيجة
                  if (_result.isNotEmpty)
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: value,
                            child: Card(
                              elevation: 10,
                              shadowColor: AppTheme.primaryGreen,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              'DECRYPTED DATA',
                                              style: GoogleFonts.shareTechMono(
                                                color: AppTheme.primaryGreen,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: _copyResult,
                                              icon: const Icon(Icons.copy, size: 20),
                                              color: AppTheme.primaryGreen,
                                              tooltip: 'Copy',
                                            ),
                                            IconButton(
                                              onPressed: _shareResult,
                                              icon: const Icon(Icons.share, size: 20),
                                              color: AppTheme.primaryGreen,
                                              tooltip: 'Share',
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
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                                      ),
                                      child: SelectableText(
                                        _result,
                                        style: GoogleFonts.shareTechMono(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // زر التواصل مع المطور
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.telegram, color: AppTheme.primaryGreen),
                      ),
                      title: Text(
                        'Contact Developer',
                        style: GoogleFonts.shareTechMono(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '@PX_Code',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: _openTelegram,
                        icon: const Icon(Icons.send, color: AppTheme.primaryGreen),
                      ),
                      onTap: _openTelegram,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Center(
                    child: Text(
                      'Py_Coder • Advanced AES Decryption Tool',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Text(
                            'DECRYPTING...',
                            style: GoogleFonts.shareTechMono(
                              fontSize: 18,
                              color: AppTheme.primaryGreen.withOpacity(0.5 + _glowController.value * 0.5),
                              letterSpacing: 4,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please wait',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
