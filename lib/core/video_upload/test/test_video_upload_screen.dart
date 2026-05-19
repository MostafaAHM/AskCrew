import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/video_upload/video_upload.dart';

/// شاشة اختبار بسيطة لتجربة رفع الفيديو
class TestVideoUploadScreen extends StatefulWidget {
  const TestVideoUploadScreen({super.key});

  @override
  State<TestVideoUploadScreen> createState() => _TestVideoUploadScreenState();
}

class _TestVideoUploadScreenState extends State<TestVideoUploadScreen> {
  File? _selectedVideo;
  String? _uploadedVideoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار رفع الفيديو'),
        backgroundColor: Colors.purple,
      ),
      body: BlocListener<VideoUploadCubit, VideoUploadState>(
        listener: (context, state) {
          if (state is VideoUploadSuccess) {
            setState(() {
              _uploadedVideoId = state.videoId;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ تم رفع الفيديو بنجاح!\nVideo ID: ${state.videoId}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is VideoUploadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ فشل رفع الفيديو: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات عن الاختبار
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 خطوات الاختبار:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1️⃣ اختر ملف فيديو من جهازك'),
                    Text('2️⃣ اضغط على "ابدأ الرفع"'),
                    Text('3️⃣ انتظر حتى يكتمل الرفع'),
                    Text('4️⃣ سيظهر لك video_id عند النجاح'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // زر اختيار الفيديو
              ElevatedButton.icon(
                onPressed: _uploadedVideoId == null ? _pickVideo : null,
                icon: const Icon(Icons.video_library, size: 28),
                label: const Text(
                  'اختر ملف فيديو',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // عرض الفيديو المختار
              if (_selectedVideo != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'تم اختيار الفيديو:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedVideo!.path.split('/').last,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<int>(
                        future: _selectedVideo!.length(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final sizeMB = (snapshot.data! / (1024 * 1024))
                                .toStringAsFixed(2);
                            return Text(
                              'الحجم: $sizeMB MB',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // زر بدء الرفع
                if (_uploadedVideoId == null)
                  ElevatedButton.icon(
                    onPressed: _startUpload,
                    icon: const Icon(Icons.cloud_upload, size: 28),
                    label: const Text(
                      'ابدأ الرفع',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              // عرض حالة الرفع
              const VideoUploadProgressWidget(),

              const SizedBox(height: 24),

              // عرض video_id عند النجاح
              if (_uploadedVideoId != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade400, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.celebration,
                            color: Colors.green,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '🎉 نجح الرفع!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Video ID:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _uploadedVideoId!,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'monospace',
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        '✅ الخطوة التالية:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'استخدم هذا الـ video_id لإنشاء سجل الفيلم أو الحلقة:\n\n'
                        '• للأفلام: POST /v1/content/movies/\n'
                        '• للحلقات: POST /v1/content/episodes/',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // زر لإعادة الاختبار
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('اختبار فيديو آخر'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: const BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
    }
  }

  void _startUpload() {
    if (_selectedVideo != null) {
      context.read<VideoUploadCubit>().uploadVideo(videoFile: _selectedVideo!);
    }
  }

  void _reset() {
    setState(() {
      _selectedVideo = null;
      _uploadedVideoId = null;
    });
    context.read<VideoUploadCubit>().reset();
  }
}
