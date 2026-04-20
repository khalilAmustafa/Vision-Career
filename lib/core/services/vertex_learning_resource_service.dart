import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/models/learning_resource_model.dart';
import '../../data/models/subject_model.dart';
import '../constants/vertex_search_config.dart';
import 'learning_resource_cache_service.dart';

class VertexLearningResourceService {
  final LearningResourceCacheService _cacheService =
      LearningResourceCacheService();

  String get _url =>
      'https://discoveryengine.googleapis.com/v1beta/'
      'projects/${VertexSearchConfig.projectId}/locations/global/'
      'collections/default_collection/dataStores/${VertexSearchConfig.dataStoreId}/'
      'servingConfigs/default_search:searchLite?key=${VertexSearchConfig.apiKey}';

  Future<List<LearningResource>?> getCachedResourcesForSubject(
    Subject subject,
  ) {
    return _cacheService.getCachedResources(subject.code);
  }

  Future<List<LearningResource>> searchResourcesForSubject(
    Subject subject, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await getCachedResourcesForSubject(subject);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    final fresh = await fetchFreshResourcesForSubject(subject);

    if (fresh.isNotEmpty) {
      await _cacheService.saveCachedResources(subject.code, fresh);
    }

    return fresh;
  }

  Future<List<LearningResource>> fetchFreshResourcesForSubject(
    Subject subject,
  ) async {
    final queries = [
      _queryPrimary(subject),
      _querySecondary(subject),
      _queryFallback(subject),
    ];

    List<LearningResource> allResults = [];

    for (final query in queries) {
      final results = await _runSearch(query);
      allResults.addAll(results);

      final selected = _selectPriorityResults(_deduplicate(allResults));
      if (selected.isNotEmpty) {
        await _cacheService.saveCachedResources(subject.code, selected);
        return selected;
      }
    }

    return _fallbackResources(subject);
  }

  Future<void> clearCacheForSubject(Subject subject) {
    return _cacheService.clearCachedResources(subject.code);
  }
  Future<List<LearningResource>> _runSearch(String query) async {
    try {
      final payload = {
        "query": query,
        "pageSize": 10,
        "boostSpec": {
          "conditionBoostSpecs": [
            {
              "condition": 'uri: ANY("coursera.org")',
              "boost": 1.0,
            },
            {
              "condition": 'uri: ANY("udemy.com")',
              "boost": 0.6,
            },
            {
              "condition": 'uri: ANY("youtube.com")',
              "boost": 0.2,
            },
          ],
        },
      };

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      // 🔥 HANDLE PERMISSION / RATE / SERVER FAIL
      if (response.statusCode == 403 ||
          response.statusCode == 429 ||
          response.statusCode == 503) {
        return [];
      }

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (decoded['results'] as List?) ?? [];

      return results.map((item) {
        final result = item as Map<String, dynamic>;
        final document = (result['document'] as Map<String, dynamic>?) ?? {};
        final derived =
            (document['derivedStructData'] as Map<String, dynamic>?) ?? {};

        final title = _cleanTitle(
          (derived['title'] ?? 'Untitled Course').toString(),
        );

        final link = (derived['link'] ?? '').toString();
        final platform = _detectPlatform(link);

        return LearningResource(
          title: title,
          url: link,
          platform: platform,
        );
      }).where((r) {
        if (r.url.isEmpty) return false;
        if (r.platform == 'Other') return false;
        return true;
      }).toList();
    } catch (e, st) {
      debugPrint('[VertexSearch] _runSearch failed: $e\n$st');
      return [];
    }
  }

  String _cleanName(String name) {
    return name.replaceAll(RegExp(r'\(.*?\)'), '').trim();
  }

  String _queryPrimary(Subject subject) {
    final name = _cleanName(subject.name);
    return '$name course';
  }

  String _querySecondary(Subject subject) {
    final name = _cleanName(subject.name);
    final skills = subject.skills.take(2).join(' ');
    return '$name $skills full course';
  }

  String _queryFallback(Subject subject) {
    final name = _cleanName(subject.name);
    return '$name tutorial playlist';
  }

  String _detectPlatform(String url) {
    final lower = url.toLowerCase();

    if (lower.contains('coursera.org')) return 'Coursera';
    if (lower.contains('udemy.com')) return 'Udemy';
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return 'YouTube';
    }

    return 'Other';
  }

  String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<LearningResource> _deduplicate(List<LearningResource> resources) {
    final seen = <String>{};
    final output = <LearningResource>[];

    for (final resource in resources) {
      if (seen.add(resource.url)) {
        output.add(resource);
      }
    }

    return output;
  }

  List<LearningResource> _fallbackResources(Subject subject) {
    final name = Uri.encodeComponent(subject.name);
    return [
      LearningResource(
        title: "YouTube: ${subject.name} full course",
        url: "https://www.youtube.com/results?search_query=$name+full+course",
        platform: "YouTube",
      ),
      LearningResource(
        title: "Coursera: ${subject.name}",
        url: "https://www.coursera.org/search?query=$name",
        platform: "Coursera",
      ),
      LearningResource(
        title: "Udemy: ${subject.name}",
        url: "https://www.udemy.com/courses/search/?q=$name",
        platform: "Udemy",
      ),
    ];
  }

  List<LearningResource> _selectPriorityResults(List<LearningResource> input) {
    final coursera = <LearningResource>[];
    final udemy = <LearningResource>[];
    final youtube = <LearningResource>[];

    for (final resource in input) {
      switch (resource.platform) {
        case 'Coursera':
          if (coursera.length < 2) {
            coursera.add(resource);
          }
          break;
        case 'Udemy':
          udemy.add(resource);
          break;
        case 'YouTube':
          youtube.add(resource);
          break;
      }
    }

    final output = <LearningResource>[];

    output.addAll(coursera);

    for (final item in udemy) {
      if (output.length >= 4) break;
      output.add(item);
    }

    for (final item in youtube) {
      if (output.length >= 4) break;
      output.add(item);
    }

    return output;
  }
}