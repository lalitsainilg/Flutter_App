import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:qualhon_test/screen/share_screen.dart';
import 'package:qualhon_test/screen/start_screen.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];
  List<File> _recentFiles = [];
  int _currentFilterIndex = 0;
  double _filterStrength = 1.0;
  late TabController _tabController;
  Map<int, Uint8List> _filteredImages = {};
  final List<String> _filterNames = ['Normal', 'Sepia', 'Grayscale', 'Vintage', 'Cool'];
  final int _maxSelection = 10; // Maximum number of images that can be selected

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecentFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(path.join(directory.path, 'media'));

    if (await mediaDir.exists()) {
      final files = await mediaDir.list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      setState(() {
        _recentFiles = files.take(20).toList();
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (images != null) {
        if (images.length > _maxSelection) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum $_maxSelection images allowed')),
          );
          return;
        }

        await _saveFilesToAppDir(images);
        setState(() {
          _selectedImages = images;
          _filteredImages.clear();
        });

        // Apply default filter to all selected images
        for (int i = 0; i < images.length; i++) {
          await _applyFilter(i);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting images: $e')),
      );
    }
  }

  Future<void> _pickVideos() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        await _saveFilesToAppDir([video]);
        setState(() {
          _selectedImages = [video];
          _filteredImages.clear();
        });
        await _applyFilter(0);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting video: $e')),
      );
    }
  }

  Future<void> _saveFilesToAppDir(List<XFile> files) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory(path.join(directory.path, 'media'));

      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      for (final file in files) {
        final newPath = path.join(mediaDir.path, path.basename(file.path));
        await File(file.path).copy(newPath);
      }

      await _loadRecentFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving files: $e')),
      );
    }
  }

  Future<void> _applyFilter(int index) async {
    if (_selectedImages == null || _selectedImages!.isEmpty) return;

    try {
      final file = File(_selectedImages![index].path);
      final bytes = await file.readAsBytes();

      if (_selectedImages![index].mimeType?.contains('video') ?? false) {
        setState(() {
          _filteredImages[index] = bytes;
        });
        return;
      }

      final image = img.decodeImage(bytes);
      if (image == null) return;

      final filtered = _applyImageFilter(image, _currentFilterIndex, _filterStrength);
      final pngBytes = Uint8List.fromList(img.encodePng(filtered));

      setState(() {
        _filteredImages[index] = pngBytes;
      });

      // Save the filtered image
      final directory = await getApplicationDocumentsDirectory();
      final filteredDir = Directory(path.join(directory.path, 'filtered'));
      if (!await filteredDir.exists()) {
        await filteredDir.create(recursive: true);
      }

      final filteredPath = path.join(filteredDir.path, 'filtered_${path.basename(_selectedImages![index].path)}');
      await File(filteredPath).writeAsBytes(pngBytes);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying filter: $e')),
      );
    }
  }

  img.Image _applyImageFilter(img.Image image, int filterIndex, double strength) {
    final result = img.copyResize(image, width: image.width, height: image.height);

    switch (filterIndex) {
      case 1: // Sepia
        img.sepia(result, amount: (strength * 255).toInt());
        break;
      case 2: // Grayscale
        img.grayscale(result);
        img.adjustColor(result, contrast: strength);
        break;
      case 3: // Vintage
        img.sepia(result, amount: (strength * 150).toInt());
        img.vignette(result, start: strength * 0.5, end: strength * 1.5);
        break;
      case 4: // Cool
        img.colorOffset(result, blue: (strength * 50).toInt());
        img.adjustColor(result, contrast: strength * 0.5);
        break;
      default: // Normal
        break;
    }

    return result;
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _selectedImages!.length,
      itemBuilder: (context, index) {
        final imageBytes = _filteredImages[index] ??
            File(_selectedImages![index].path).readAsBytesSync();

        return _selectedImages![index].mimeType?.contains('video') ?? false
            ? const Icon(Icons.videocam, size: 50)
            : Image.memory(
          imageBytes,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildRecentMediaGrid() {
    if (_recentFiles.isEmpty) {
      return const Center(child: Text('No recent media'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _recentFiles.length,
      itemBuilder: (context, index) {
        final file = _recentFiles[index];
        final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
            file.path.toLowerCase().endsWith('.mov');

        return GestureDetector(
          onTap: () async {
            setState(() {
              _selectedImages = [XFile(file.path)];
              _filteredImages.clear();
            });
            await _applyFilter(0);
          },
          child: isVideo
              ? const Icon(Icons.videocam, size: 50)
              : Image.file(file, fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No media selected',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImages,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text('Select Media (Max $_maxSelection)'),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _getFilterPreview(int filterIndex) async {
    if (_selectedImages!.isEmpty) return Uint8List(0);

    try {
      final file = File(_selectedImages![0].path);
      final bytes = await file.readAsBytes();

      if (_selectedImages![0].mimeType?.contains('video') ?? false) {
        return bytes;
      }

      final image = img.decodeImage(bytes);
      if (image == null) return Uint8List(0);

      final filtered = _applyImageFilter(image, filterIndex, _filterStrength);
      return Uint8List.fromList(img.encodePng(filtered));
    } catch (e) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const StartScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text('New Post'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Photos'),
            Tab(text: 'Videos'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1080,
                      maxHeight: 1080,
                      imageQuality: 90,
                    );
                    if (photo != null) {
                      setState(() {
                        _selectedImages = [photo];
                        _filteredImages.clear();
                      });
                      await _applyFilter(0);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  onPressed: () {
                    if (_selectedImages!.isNotEmpty) {
                      setState(() {
                        _currentFilterIndex = (_currentFilterIndex + 1) % _filterNames.length;
                      });
                      for (int i = 0; i < _selectedImages!.length; i++) {
                        _applyFilter(i);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecentMediaGrid(),
                _selectedImages!.isEmpty ? _buildEmptyState() : _buildMediaGrid(),
                _selectedImages!.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.video_library, size: 50, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No videos selected',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickVideos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Select Video'),
                      ),
                    ],
                  ),
                )
                    : _buildMediaGrid(),
              ],
            ),
          ),
          if (_selectedImages!.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterNames.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          setState(() => _currentFilterIndex = index);
                          for (int i = 0; i < _selectedImages!.length; i++) {
                            await _applyFilter(i);
                          }
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _currentFilterIndex == index
                                        ? Colors.purple
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _selectedImages!.isNotEmpty
                                    ? FutureBuilder<Uint8List>(
                                  future: _getFilterPreview(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _filterNames[index],
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShareScreen(
                              images: _selectedImages!,
                              filterIndex: _currentFilterIndex,
                              filterStrength: _filterStrength,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Next'),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}