import 'package:flutter_dotenv/flutter_dotenv.dart';

class VertexSearchConfig {
  const VertexSearchConfig._();

  static const String projectId = 'project-31722430-64b6-45ea-a4c';
  static const String dataStoreId = 'visioncareer_1773921415472';

  static String get apiKey => dotenv.env['VERTEX_API_KEY']!;
}