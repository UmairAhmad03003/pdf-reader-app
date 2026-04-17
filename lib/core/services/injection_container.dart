import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdftest/core/services/file_service.dart';
import 'package:pdftest/data/repositories/pdf_repository_impl.dart';
import 'package:pdftest/domain/repositories/pdf_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FileService());
  
  // Repositories
  sl.registerLazySingleton<PdfRepository>(() => PdfRepositoryImpl(sl()));
}
