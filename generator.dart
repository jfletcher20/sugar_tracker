import 'dart:io';

void main(List<String> args) async {
  // Process and validate command line arguments
  if (args.length < 2) {
    _printUsage();
    exit(1);
  }

  // Validate architecture argument
  final architecture = args[0].toLowerCase();
  if (architecture != 'mvvm' && architecture != 'clean') {
    print('Error: Architecture must be either "mvvm" or "clean".');
    _printUsage();
    exit(1);
  }

  // Get feature name
  final featureName = args[1];

  // Check for optional arguments
  bool isEmpty = false;
  String? customDir;

  for (int i = 2; i < args.length; i++) {
    if (args[i] == '--empty') {
      isEmpty = true;
    } else if (args[i].startsWith('--dir=')) {
      customDir = args[i].substring('--dir='.length);
    }
  }

  // Setup base directory
  Directory baseDir;
  if (customDir != null) {
    baseDir = Directory(customDir);
  } else {
    // Check if we're in a Flutter project
    if (!await _isFlutterProject()) {
      print('Error: Not in a Flutter project directory.');
      print(
          'Please run this command from a Flutter project directory or specify a directory with --dir=');
      exit(1);
    }

    // Create the base directory
    final currentDir = Directory.current;
    String libPath;

    if (currentDir.path.endsWith('lib')) {
      // Already in the lib directory
      libPath = currentDir.path;
    } else {
      // Not in the lib directory, so check if lib exists
      final libDir = Directory('${currentDir.path}/lib');
      if (await libDir.exists()) {
        libPath = libDir.path;
      } else {
        print('Error: Could not find lib directory in current project.');
        exit(1);
      }
    }

    baseDir = Directory('$libPath/features/$featureName');
  }

  try {
    // Create the generator based on architecture
    final generator = (architecture == 'mvvm')
        ? MVVMGenerator(featureName, baseDir.path, isEmpty)
        : CleanGenerator(featureName, baseDir.path, isEmpty);

    // Generate the files
    await generator.generate();

    print('Successfully generated $architecture architecture for feature "$featureName".');
    print('Files created in: ${baseDir.path}');
  } catch (e) {
    print('Error generating files: $e');
    exit(1);
  }
}

void _printUsage() {
  print('Usage: dart generator.dart <mvvm|clean> <featureName> [--empty] [--dir=path]');
  print('  --empty    Creates empty template files');
  print('  --dir=path Specifies base directory for file generation');
}

Future<bool> _isFlutterProject() async {
  // Check for pubspec.yaml with flutter dependency
  final pubspecFile = File('pubspec.yaml');
  if (await pubspecFile.exists()) {
    final content = await pubspecFile.readAsString();
    return content.contains('flutter:') || content.contains('sdk: flutter');
  }

  // Check if we're in the lib directory
  final currentDir = Directory.current.path;
  if (currentDir.endsWith('lib')) {
    final parentDir = Directory(currentDir.substring(0, currentDir.length - 4));
    final pubspecInParent = File('${parentDir.path}/pubspec.yaml');
    if (await pubspecInParent.exists()) {
      final content = await pubspecInParent.readAsString();
      return content.contains('flutter:') || content.contains('sdk: flutter');
    }
  }

  return false;
}

// Base Generator abstract class
abstract class FeatureGenerator {
  final String featureName;
  final String baseDir;
  final bool isEmpty;

  FeatureGenerator(this.featureName, this.baseDir, this.isEmpty);

  Future<void> generate();

  Future<void> createDirectoryIfNotExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> createFile(String path, String content) async {
    final file = File(path);
    await file.create(recursive: true);
    if (!isEmpty) {
      await file.writeAsString(content);
    }
  }

  String get snakeCaseName => featureName
      .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
      .toLowerCase();

  String get pascalCaseName => featureName
      .split('_')
      .map((part) =>
          part.isNotEmpty ? '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}' : '')
      .join('');

  String get camelCaseName {
    final pascal = pascalCaseName;
    return pascal.isNotEmpty ? pascal[0].toLowerCase() + pascal.substring(1) : '';
  }
}

// MVVM Architecture Generator
class MVVMGenerator extends FeatureGenerator {
  MVVMGenerator(String featureName, String baseDir, bool isEmpty)
      : super(featureName, baseDir, isEmpty);

  @override
  Future<void> generate() async {
    // Create feature directory structure
    await createDirectoryIfNotExists(baseDir);

    // Create directories
    await createDirectoryIfNotExists('$baseDir/models');
    await createDirectoryIfNotExists('$baseDir/views');
    await createDirectoryIfNotExists('$baseDir/view_models');
    await createDirectoryIfNotExists('$baseDir/services');
    await createDirectoryIfNotExists('$baseDir/repositories');

    // Generate model files
    await createFile(
      '$baseDir/models/${snakeCaseName}_model.dart',
      _generateMVVMModel(),
    );

    // Generate view files
    await createFile(
      '$baseDir/views/${snakeCaseName}_view.dart',
      _generateMVVMView(),
    );

    // Generate view model files
    await createFile(
      '$baseDir/view_models/${snakeCaseName}_view_model.dart',
      _generateMVVMViewModel(),
    );

    // Generate service files
    await createFile(
      '$baseDir/services/${snakeCaseName}_service.dart',
      _generateMVVMService(),
    );

    // Generate repository files
    await createFile(
      '$baseDir/repositories/${snakeCaseName}_repository.dart',
      _generateMVVMRepository(),
    );
  }

  String _generateMVVMModel() {
    return '''
// Generated MVVM model for $featureName feature
class ${pascalCaseName}Model {
  final int id;
  final String name;
  final String description;
  
  ${pascalCaseName}Model({
    required this.id,
    required this.name,
    required this.description,
  });
  
  factory ${pascalCaseName}Model.fromJson(Map<String, dynamic> json) {
    return ${pascalCaseName}Model(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
''';
  }

  String _generateMVVMView() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/${snakeCaseName}_view_model.dart';

class ${pascalCaseName}View extends ConsumerWidget {
  const ${pascalCaseName}View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(${camelCaseName}ViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${pascalCaseName}'),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.hasError
              ? Center(child: Text('Error: \${viewModel.errorMessage}'))
              : _buildContent(context, viewModel),
    );
  }
  
  Widget _buildContent(BuildContext context, ${pascalCaseName}ViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text(item.description),
          onTap: () => viewModel.selectItem(item),
        );
      },
    );
  }
}
''';
  }

  String _generateMVVMViewModel() {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/${snakeCaseName}_model.dart';
import '../repositories/${snakeCaseName}_repository.dart';

// Provider definition
final ${camelCaseName}RepositoryProvider = Provider<${pascalCaseName}Repository>(
  (ref) => ${pascalCaseName}Repository(),
);

final ${camelCaseName}ViewModelProvider = StateNotifierProvider<${pascalCaseName}ViewModel, ${pascalCaseName}State>(
  (ref) => ${pascalCaseName}ViewModel(ref.read(${camelCaseName}RepositoryProvider)),
);

// State class
class ${pascalCaseName}State {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<${pascalCaseName}Model> items;
  final ${pascalCaseName}Model? selectedItem;

  ${pascalCaseName}State({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.items = const [],
    this.selectedItem,
  });

  ${pascalCaseName}State copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<${pascalCaseName}Model>? items,
    ${pascalCaseName}Model? selectedItem,
  }) {
    return ${pascalCaseName}State(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
    );
  }
}

// ViewModel class
class ${pascalCaseName}ViewModel extends StateNotifier<${pascalCaseName}State> {
  final ${pascalCaseName}Repository _repository;

  ${pascalCaseName}ViewModel(this._repository) : super(${pascalCaseName}State()) {
    fetchItems();
  }

  Future<void> fetchItems() async {
    state = state.copyWith(isLoading: true, hasError: false);
    
    try {
      final items = await _repository.getAll();
      state = state.copyWith(
        isLoading: false,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void selectItem(${pascalCaseName}Model item) {
    state = state.copyWith(selectedItem: item);
  }
}
''';
  }

  String _generateMVVMService() {
    return '''
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/${snakeCaseName}_model.dart';

class ${pascalCaseName}Service {
  static const String baseUrl = 'http://localhost:3000/${snakeCaseName}s';

  Future<List<${pascalCaseName}Model>> fetchAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ${pascalCaseName}Model.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load ${snakeCaseName}s. Status code: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch ${snakeCaseName}s: \$e');
    }
  }

  Future<${pascalCaseName}Model> fetchById(int id) async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/\$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ${pascalCaseName}Model.fromJson(data);
      } else {
        throw Exception('Failed to load ${snakeCaseName}. Status code: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch ${snakeCaseName}: \$e');
    }
  }

  Future<${pascalCaseName}Model> create(${pascalCaseName}Model model) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(model.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ${pascalCaseName}Model.fromJson(data);
      } else {
        throw Exception('Failed to create ${snakeCaseName}. Status code: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create ${snakeCaseName}: \$e');
    }
  }

  Future<${pascalCaseName}Model> update(${pascalCaseName}Model model) async {
    try {
      final response = await http.put(
        Uri.parse('\$baseUrl/\${model.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(model.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ${pascalCaseName}Model.fromJson(data);
      } else {
        throw Exception('Failed to update ${snakeCaseName}. Status code: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update ${snakeCaseName}: \$e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await http.delete(Uri.parse('\$baseUrl/\$id'));
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete ${snakeCaseName}. Status code: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete ${snakeCaseName}: \$e');
    }
  }
}
''';
  }

  String _generateMVVMRepository() {
    return '''
import '../models/${snakeCaseName}_model.dart';
import '../services/${snakeCaseName}_service.dart';

class ${pascalCaseName}Repository {
  final ${pascalCaseName}Service _service = ${pascalCaseName}Service();
  
  // Optional local cache
  List<${pascalCaseName}Model> _cache = [];
  
  Future<List<${pascalCaseName}Model>> getAll() async {
    // Check if we need to fetch or can use cache
    if (_cache.isEmpty) {
      _cache = await _service.fetchAll();
    }
    return _cache;
  }
  
  Future<${pascalCaseName}Model> getById(int id) async {
    // Try to find in cache first
    final cached = _cache.firstWhere((item) => item.id == id, 
      orElse: () => ${pascalCaseName}Model(id: -1, name: '', description: ''));
    
    if (cached.id != -1) {
      return cached;
    }
    
    // Otherwise fetch from service
    return await _service.fetchById(id);
  }
  
  Future<${pascalCaseName}Model> create(${pascalCaseName}Model model) async {
    final created = await _service.create(model);
    _cache.add(created);
    return created;
  }
  
  Future<${pascalCaseName}Model> update(${pascalCaseName}Model model) async {
    final updated = await _service.update(model);
    
    // Update cache
    final index = _cache.indexWhere((item) => item.id == model.id);
    if (index != -1) {
      _cache[index] = updated;
    }
    
    return updated;
  }
  
  Future<void> delete(int id) async {
    await _service.delete(id);
    
    // Update cache
    _cache.removeWhere((item) => item.id == id);
  }
  
  void clearCache() {
    _cache = [];
  }
}
''';
  }
}

// Clean Architecture Generator
class CleanGenerator extends FeatureGenerator {
  CleanGenerator(String featureName, String baseDir, bool isEmpty)
      : super(featureName, baseDir, isEmpty);

  @override
  Future<void> generate() async {
    // Create feature directory structure
    await createDirectoryIfNotExists(baseDir);

    // Create directories
    await createDirectoryIfNotExists('$baseDir/domain');
    await createDirectoryIfNotExists('$baseDir/domain/entities');
    await createDirectoryIfNotExists('$baseDir/domain/repositories');
    await createDirectoryIfNotExists('$baseDir/domain/usecases');

    await createDirectoryIfNotExists('$baseDir/data');
    await createDirectoryIfNotExists('$baseDir/data/datasources');
    await createDirectoryIfNotExists('$baseDir/data/models');
    await createDirectoryIfNotExists('$baseDir/data/repositories');

    await createDirectoryIfNotExists('$baseDir/presentation');
    await createDirectoryIfNotExists('$baseDir/presentation/bloc');
    await createDirectoryIfNotExists('$baseDir/presentation/pages');
    await createDirectoryIfNotExists('$baseDir/presentation/widgets');

    // Generate domain layer files
    await createFile(
      '$baseDir/domain/entities/${snakeCaseName}_entity.dart',
      _generateEntity(),
    );

    await createFile(
      '$baseDir/domain/repositories/${snakeCaseName}_repository.dart',
      _generateDomainRepository(),
    );

    await createFile(
      '$baseDir/domain/usecases/get_${snakeCaseName}.dart',
      _generateGetUseCase(),
    );

    await createFile(
      '$baseDir/domain/usecases/get_all_${snakeCaseName}s.dart',
      _generateGetAllUseCase(),
    );

    // Generate data layer files
    await createFile(
      '$baseDir/data/models/${snakeCaseName}_model.dart',
      _generateModel(),
    );

    await createFile(
      '$baseDir/data/datasources/${snakeCaseName}_remote_data_source.dart',
      _generateRemoteDataSource(),
    );

    await createFile(
      '$baseDir/data/repositories/${snakeCaseName}_repository_impl.dart',
      _generateRepositoryImpl(),
    );

    // Generate presentation layer files
    await createFile(
      '$baseDir/presentation/bloc/${snakeCaseName}_bloc.dart',
      _generateBloc(),
    );

    await createFile(
      '$baseDir/presentation/bloc/${snakeCaseName}_event.dart',
      _generateEvent(),
    );

    await createFile(
      '$baseDir/presentation/bloc/${snakeCaseName}_state.dart',
      _generateState(),
    );

    await createFile(
      '$baseDir/presentation/pages/${snakeCaseName}_page.dart',
      _generatePage(),
    );

    await createFile(
      '$baseDir/presentation/widgets/${snakeCaseName}_list_widget.dart',
      _generateListWidget(),
    );

    await createFile(
      '$baseDir/presentation/widgets/${snakeCaseName}_detail_widget.dart',
      _generateDetailWidget(),
    );
  }

  String _generateEntity() {
    return '''
class ${pascalCaseName}Entity {
  final int id;
  final String name;
  final String description;
  
  ${pascalCaseName}Entity({
    required this.id,
    required this.name,
    required this.description,
  });
}
''';
  }

  String _generateDomainRepository() {
    return '''
import 'package:dartz/dartz.dart';
import '../entities/${snakeCaseName}_entity.dart';

abstract class ${pascalCaseName}Repository {
  Future<Either<Exception, List<${pascalCaseName}Entity>>> getAllItems();
  Future<Either<Exception, ${pascalCaseName}Entity>> getItem(int id);
  Future<Either<Exception, ${pascalCaseName}Entity>> createItem(${pascalCaseName}Entity item);
  Future<Either<Exception, ${pascalCaseName}Entity>> updateItem(${pascalCaseName}Entity item);
  Future<Either<Exception, void>> deleteItem(int id);
}
''';
  }

  String _generateGetUseCase() {
    return '''
import 'package:dartz/dartz.dart';
import '../entities/${snakeCaseName}_entity.dart';
import '../repositories/${snakeCaseName}_repository.dart';

class Get${pascalCaseName} {
  final ${pascalCaseName}Repository repository;
  
  Get${pascalCaseName}(this.repository);
  
  Future<Either<Exception, ${pascalCaseName}Entity>> call(int id) async {
    return await repository.getItem(id);
  }
}
''';
  }

  String _generateGetAllUseCase() {
    return '''
import 'package:dartz/dartz.dart';
import '../entities/${snakeCaseName}_entity.dart';
import '../repositories/${snakeCaseName}_repository.dart';

class GetAll${pascalCaseName}s {
  final ${pascalCaseName}Repository repository;
  
  GetAll${pascalCaseName}s(this.repository);
  
  Future<Either<Exception, List<${pascalCaseName}Entity>>> call() async {
    return await repository.getAllItems();
  }
}
''';
  }

  String _generateModel() {
    return '''
import '../../domain/entities/${snakeCaseName}_entity.dart';

class ${pascalCaseName}Model extends ${pascalCaseName}Entity {
  ${pascalCaseName}Model({
    required int id,
    required String name,
    required String description,
  }) : super(
    id: id,
    name: name,
    description: description,
  );
  
  factory ${pascalCaseName}Model.fromJson(Map<String, dynamic> json) {
    return ${pascalCaseName}Model(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
  
  factory ${pascalCaseName}Model.fromEntity(${pascalCaseName}Entity entity) {
    return ${pascalCaseName}Model(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }
}
''';
  }

  String _generateRemoteDataSource() {
    return '''
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/${snakeCaseName}_model.dart';

abstract class ${pascalCaseName}RemoteDataSource {
  Future<List<${pascalCaseName}Model>> getAllItems();
  Future<${pascalCaseName}Model> getItem(int id);
  Future<${pascalCaseName}Model> createItem(${pascalCaseName}Model item);
  Future<${pascalCaseName}Model> updateItem(${pascalCaseName}Model item);
  Future<void> deleteItem(int id);
}

class ${pascalCaseName}RemoteDataSourceImpl implements ${pascalCaseName}RemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://localhost:3000/${snakeCaseName}s';
  
  ${pascalCaseName}RemoteDataSourceImpl({required this.client});
  
  @override
  Future<List<${pascalCaseName}Model>> getAllItems() async {
    final response = await client.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ${pascalCaseName}Model.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ${snakeCaseName}s. Status code: \${response.statusCode}');
    }
  }
  
  @override
  Future<${pascalCaseName}Model> getItem(int id) async {
    final response = await client.get(
      Uri.parse('\$baseUrl/\$id'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ${pascalCaseName}Model.fromJson(data);
    } else {
      throw Exception('Failed to load ${snakeCaseName}. Status code: \${response.statusCode}');
    }
  }
  
  @override
  Future<${pascalCaseName}Model> createItem(${pascalCaseName}Model item) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return ${pascalCaseName}Model.fromJson(data);
    } else {
      throw Exception('Failed to create ${snakeCaseName}. Status code: \${response.statusCode}');
    }
  }
  
  @override
  Future<${pascalCaseName}Model> updateItem(${pascalCaseName}Model item) async {
    final response = await client.put(
      Uri.parse('\$baseUrl/\${item.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ${pascalCaseName}Model.fromJson(data);
    } else {
      throw Exception('Failed to update ${snakeCaseName}. Status code: \${response.statusCode}');
    }
  }
  
  @override
  Future<void> deleteItem(int id) async {
    final response = await client.delete(
      Uri.parse('\$baseUrl/\$id'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete ${snakeCaseName}. Status code: \${response.statusCode}');
    }
  }
}
''';
  }

  String _generateRepositoryImpl() {
    return '''
import 'package:dartz/dartz.dart';
import '../../domain/entities/${snakeCaseName}_entity.dart';
import '../../domain/repositories/${snakeCaseName}_repository.dart';
import '../datasources/${snakeCaseName}_remote_data_source.dart';
import '../models/${snakeCaseName}_model.dart';

class ${pascalCaseName}RepositoryImpl implements ${pascalCaseName}Repository {
  final ${pascalCaseName}RemoteDataSource remoteDataSource;
  
  ${pascalCaseName}RepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Exception, List<${pascalCaseName}Entity>>> getAllItems() async {
    try {
      final models = await remoteDataSource.getAllItems();
      return Right(models);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
  
  @override
  Future<Either<Exception, ${pascalCaseName}Entity>> getItem(int id) async {
    try {
      final model = await remoteDataSource.getItem(id);
      return Right(model);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
  
  @override
  Future<Either<Exception, ${pascalCaseName}Entity>> createItem(${pascalCaseName}Entity item) async {
    try {
      final model = ${pascalCaseName}Model.fromEntity(item);
      final result = await remoteDataSource.createItem(model);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
  
  @override
  Future<Either<Exception, ${pascalCaseName}Entity>> updateItem(${pascalCaseName}Entity item) async {
    try {
      final model = ${pascalCaseName}Model.fromEntity(item);
      final result = await remoteDataSource.updateItem(model);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
  
  @override
  Future<Either<Exception, void>> deleteItem(int id) async {
    try {
      await remoteDataSource.deleteItem(id);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
''';
  }

  String _generateBloc() {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_${snakeCaseName}s.dart';
import '../../domain/usecases/get_${snakeCaseName}.dart';
import '${snakeCaseName}_event.dart';
import '${snakeCaseName}_state.dart';

class ${pascalCaseName}Bloc extends Bloc<${pascalCaseName}Event, ${pascalCaseName}State> {
  final GetAll${pascalCaseName}s getAllItems;
  final Get${pascalCaseName} getItem;
  
  ${pascalCaseName}Bloc({
    required this.getAllItems,
    required this.getItem,
  }) : super(${pascalCaseName}Empty()) {
    on<${pascalCaseName}GetAllEvent>(_onGetAllItems);
    on<${pascalCaseName}GetItemEvent>(_onGetItem);
  }
  
  Future<void> _onGetAllItems(
    ${pascalCaseName}GetAllEvent event,
    Emitter<${pascalCaseName}State> emit,
  ) async {
    emit(${pascalCaseName}Loading());
    
    final result = await getAllItems();
    
    result.fold(
      (failure) => emit(${pascalCaseName}Error(message: failure.toString())),
      (items) => emit(${pascalCaseName}Loaded(items: items)),
    );
  }
  
  Future<void> _onGetItem(
    ${pascalCaseName}GetItemEvent event,
    Emitter<${pascalCaseName}State> emit,
  ) async {
    emit(${pascalCaseName}Loading());
    
    final result = await getItem(event.id);
    
    result.fold(
      (failure) => emit(${pascalCaseName}Error(message: failure.toString())),
      (item) => emit(${pascalCaseName}ItemLoaded(item: item)),
    );
  }
}
''';
  }

  String _generateEvent() {
    return '''
import 'package:equatable/equatable.dart';
import '../../domain/entities/${snakeCaseName}_entity.dart';

abstract class ${pascalCaseName}Event extends Equatable {
  const ${pascalCaseName}Event();
  
  @override
  List<Object?> get props => [];
}

class ${pascalCaseName}GetAllEvent extends ${pascalCaseName}Event {}

class ${pascalCaseName}GetItemEvent extends ${pascalCaseName}Event {
  final int id;
  
  const ${pascalCaseName}GetItemEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}

class ${pascalCaseName}CreateEvent extends ${pascalCaseName}Event {
  final ${pascalCaseName}Entity item;
  
  const ${pascalCaseName}CreateEvent({required this.item});
  
  @override
  List<Object?> get props => [item];
}

class ${pascalCaseName}UpdateEvent extends ${pascalCaseName}Event {
  final ${pascalCaseName}Entity item;
  
  const ${pascalCaseName}UpdateEvent({required this.item});
  
  @override
  List<Object?> get props => [item];
}

class ${pascalCaseName}DeleteEvent extends ${pascalCaseName}Event {
  final int id;
  
  const ${pascalCaseName}DeleteEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}
''';
  }

  String _generateState() {
    return '''
import 'package:equatable/equatable.dart';
import '../../domain/entities/${snakeCaseName}_entity.dart';

abstract class ${pascalCaseName}State extends Equatable {
  const ${pascalCaseName}State();
  
  @override
  List<Object?> get props => [];
}

class ${pascalCaseName}Empty extends ${pascalCaseName}State {}

class ${pascalCaseName}Loading extends ${pascalCaseName}State {}

class ${pascalCaseName}Loaded extends ${pascalCaseName}State {
  final List<${pascalCaseName}Entity> items;
  
  const ${pascalCaseName}Loaded({required this.items});
  
  @override
  List<Object?> get props => [items];
}

class ${pascalCaseName}ItemLoaded extends ${pascalCaseName}State {
  final ${pascalCaseName}Entity item;
  
  const ${pascalCaseName}ItemLoaded({required this.item});
  
  @override
  List<Object?> get props => [item];
}

class ${pascalCaseName}Error extends ${pascalCaseName}State {
  final String message;
  
  const ${pascalCaseName}Error({required this.message});
  
  @override
  List<Object?> get props => [message];
}
''';
  }

  String _generatePage() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${snakeCaseName}_bloc.dart';
import '../bloc/${snakeCaseName}_event.dart';
import '../bloc/${snakeCaseName}_state.dart';
import '../widgets/${snakeCaseName}_list_widget.dart';

class ${pascalCaseName}Page extends StatelessWidget {
  const ${pascalCaseName}Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${pascalCaseName}'),
      ),
      body: BlocBuilder<${pascalCaseName}Bloc, ${pascalCaseName}State>(
        builder: (context, state) {
          if (state is ${pascalCaseName}Empty) {
            // Trigger loading data when page is opened
            context.read<${pascalCaseName}Bloc>().add(${pascalCaseName}GetAllEvent());
            return const Center(child: Text('Start loading ${snakeCaseName}s...'));
          }
          
          if (state is ${pascalCaseName}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ${pascalCaseName}Loaded) {
            return ${pascalCaseName}ListWidget(items: state.items);
          }
          
          if (state is ${pascalCaseName}Error) {
            return Center(child: Text('Error: \${state.message}'));
          }
          
          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle creating new item
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
  }

  String _generateListWidget() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/${snakeCaseName}_entity.dart';
import '../bloc/${snakeCaseName}_bloc.dart';
import '../bloc/${snakeCaseName}_event.dart';

class ${pascalCaseName}ListWidget extends StatelessWidget {
  final List<${pascalCaseName}Entity> items;
  
  const ${pascalCaseName}ListWidget({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(child: Text('No ${snakeCaseName}s available'))
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
                onTap: () {
                  context.read<${pascalCaseName}Bloc>().add(
                        ${pascalCaseName}GetItemEvent(id: item.id),
                      );
                  // Navigate to detail page
                },
              );
            },
          );
  }
}
''';
  }

  String _generateDetailWidget() {
    return '''
import 'package:flutter/material.dart';
import '../../domain/entities/${snakeCaseName}_entity.dart';

class ${pascalCaseName}DetailWidget extends StatelessWidget {
  final ${pascalCaseName}Entity item;
  
  const ${pascalCaseName}DetailWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'ID: \${item.id}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Description:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle edit
                },
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle delete
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
''';
  }
}
