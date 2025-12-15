import 'package:cloud_firestore/cloud_firestore.dart';

// MediaFile class to represent individual media files
class MediaFile {
  final String name;
  final int size;
  final String type;
  final String url;

  const MediaFile({
    required this.name,
    required this.size,
    required this.type,
    required this.url,
  });

  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      name: map['name'] ?? '',
      size: map['size'] ?? 0,
      type: map['type'] ?? '',
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'size': size, 'type': type, 'url': url};
  }

  bool get isVideo {
    return type.toLowerCase() == 'video' ||
        name.toLowerCase().contains('.mp4') ||
        name.toLowerCase().contains('.mov') ||
        name.toLowerCase().contains('.avi') ||
        url.toLowerCase().contains('video') ||
        url.toLowerCase().contains('youtube') ||
        url.toLowerCase().contains('vimeo') ||
        url.toLowerCase().contains('youtu.be');
  }

  bool get isPdf {
    return type.toLowerCase() == 'pdf' ||
        name.toLowerCase().contains('.pdf') ||
        url.toLowerCase().contains('.pdf');
  }

  bool get isImage {
    return type.toLowerCase() == 'image' ||
        name.toLowerCase().contains('.jpg') ||
        name.toLowerCase().contains('.jpeg') ||
        name.toLowerCase().contains('.png') ||
        name.toLowerCase().contains('.gif') ||
        name.toLowerCase().contains('.webp');
  }

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024)
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @override
  String toString() {
    return 'MediaFile(name: $name, type: $type, size: $formattedSize)';
  }
}

class BlogPost {
  final String id;
  final String admin;
  final String content;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime? endDate;
  final bool isPublished;
  final String? linkedQuizId;
  final List<MediaFile> media;
  final DateTime publishedAt;
  final String slug;
  final DateTime? startDate;
  final List<String> tags;
  final String title;
  final String type;
  final DateTime updatedAt;
  final String? author;
  final String? excerpt;
  final String? coverImageUrl;
  final String? actualiteCategory;
  final String? youtubeVideoUrl;

  const BlogPost({
    required this.id,
    required this.admin,
    required this.content,
    this.coverImage,
    required this.createdAt,
    this.endDate,
    required this.isPublished,
    this.linkedQuizId,
    required this.media,
    required this.publishedAt,
    required this.slug,
    this.startDate,
    required this.tags,
    required this.title,
    required this.type,
    required this.updatedAt,
    this.author,
    this.excerpt,
    this.coverImageUrl,
    this.actualiteCategory,
    this.youtubeVideoUrl,
  });

  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Try different possible field names for media
    dynamic mediaData =
        data['media'] ??
        data['mediaFiles'] ??
        data['files'] ??
        data['attachments'];

    return BlogPost(
      id: doc.id,
      admin: data['admin'] ?? '',
      content: data['content'] ?? '',
      coverImage: data['coverImage'],
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      endDate: _parseTimestamp(data['endDate']),
      isPublished: data['isPublished'] ?? false,
      linkedQuizId: data['linkedQuizId'],
      media: _parseMediaFiles(mediaData),
      publishedAt: _parseTimestamp(data['publishedAt']) ?? DateTime.now(),
      slug: data['slug'] ?? '',
      startDate: _parseTimestamp(data['startDate']),
      tags: List<String>.from(data['tags'] ?? []),
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      author: data['author'],
      excerpt: data['excerpt'],
      coverImageUrl: data['coverImageUrl'],
      actualiteCategory: data['actualiteCategory'],
      youtubeVideoUrl: data['youtubeVideoUrl'],
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  static List<MediaFile> _parseMediaFiles(dynamic mediaData) {
    if (mediaData == null) return [];

    try {
      if (mediaData is List) {
        List<MediaFile> result = [];

        for (final item in mediaData) {
          if (item is Map<String, dynamic>) {
            result.add(MediaFile.fromMap(item));
          } else if (item is String) {
            // Handle legacy string format
            result.add(
              MediaFile(
                name: item.split('/').last,
                size: 0,
                type: _getTypeFromUrl(item),
                url: item,
              ),
            );
          }
        }

        return result;
      }
    } catch (e) {
      // Error parsing media files
    }

    return [];
  }

  static String _getTypeFromUrl(String url) {
    if (url.toLowerCase().contains('.mp4') ||
        url.toLowerCase().contains('.mov') ||
        url.toLowerCase().contains('video')) {
      return 'video';
    }
    if (url.toLowerCase().contains('.pdf')) {
      return 'pdf';
    }
    if (url.toLowerCase().contains('.jpg') ||
        url.toLowerCase().contains('.png') ||
        url.toLowerCase().contains('.jpeg')) {
      return 'image';
    }
    return 'file';
  }

  // Helper method to check if this is a formation
  bool get isFormation => type == 'formation';

  // Helper method to get formatted publish date
  String get formattedPublishedAt {
    return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
  }

  // Helper method to get formatted start date
  String get formattedStartDate {
    if (startDate == null) return '';
    return '${startDate!.day}/${startDate!.month}/${startDate!.year}';
  }

  // Helper method to get formatted end date
  String get formattedEndDate {
    if (endDate == null) return '';
    return '${endDate!.day}/${endDate!.month}/${endDate!.year}';
  }

  // Helper method to check if formation is currently active
  bool get isActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  // Helper method to get tags as comma-separated string
  String get tagsString => tags.join(', ');

  // Media type detection methods
  bool get hasVideo {
    return media.any((file) => file.isVideo) ||
        (youtubeVideoUrl != null && youtubeVideoUrl!.isNotEmpty);
  }

  bool get hasPdf {
    return media.any((file) => file.isPdf);
  }

  bool get hasClinicalStudy {
    return media.any(
      (file) =>
          file.name.toLowerCase().contains('clinical') ||
          file.name.toLowerCase().contains('study') ||
          file.name.toLowerCase().contains('etude') ||
          file.name.toLowerCase().contains('clinique') ||
          file.name.toLowerCase().contains('research') ||
          file.url.toLowerCase().contains('clinical') ||
          file.url.toLowerCase().contains('study'),
    );
  }

  // Get all video files
  List<MediaFile> get videoFiles {
    return media.where((file) => file.isVideo).toList();
  }

  // Get all PDF files
  List<MediaFile> get pdfFiles {
    return media.where((file) => file.isPdf).toList();
  }

  // Get all image files
  List<MediaFile> get imageFiles {
    return media.where((file) => file.isImage).toList();
  }

  // Get all other files (not video, PDF, or image)
  List<MediaFile> get otherFiles {
    return media
        .where((file) => !file.isVideo && !file.isPdf && !file.isImage)
        .toList();
  }

  bool get hasQuiz => linkedQuizId != null && linkedQuizId!.isNotEmpty;

  // Get specific media URLs by type
  String? get videoUrl {
    // Prioritize youtubeVideoUrl over media files
    if (youtubeVideoUrl != null && youtubeVideoUrl!.isNotEmpty) {
      return youtubeVideoUrl;
    }
    final videoFiles = media.where((file) => file.isVideo);
    return videoFiles.isNotEmpty ? videoFiles.first.url : null;
  }

  String? get pdfUrl {
    final pdfFiles = media.where((file) => file.isPdf);
    return pdfFiles.isNotEmpty ? pdfFiles.first.url : null;
  }

  String? get clinicalStudyUrl {
    final studyFiles = media.where(
      (file) =>
          file.name.toLowerCase().contains('clinical') ||
          file.name.toLowerCase().contains('study') ||
          file.name.toLowerCase().contains('etude') ||
          file.name.toLowerCase().contains('clinique') ||
          file.name.toLowerCase().contains('research'),
    );
    return studyFiles.isNotEmpty ? studyFiles.first.url : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admin': admin,
      'content': content,
      'coverImage': coverImage,
      'createdAt': createdAt,
      'endDate': endDate,
      'isPublished': isPublished,
      'linkedQuizId': linkedQuizId,
      'media': media.map((file) => file.toMap()).toList(),
      'publishedAt': publishedAt,
      'slug': slug,
      'startDate': startDate,
      'tags': tags,
      'title': title,
      'type': type,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'BlogPost(id: $id, title: $title, type: $type, isPublished: $isPublished)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlogPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
