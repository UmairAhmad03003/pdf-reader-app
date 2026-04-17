import 'package:go_router/go_router.dart';
import 'package:pdftest/presentation/screens/home_screen.dart';
import 'package:pdftest/features/pdf_reader/presentation/pdf_reader_screen.dart';
import 'package:pdftest/features/pdf_merger/presentation/pdf_merger_screen.dart';
import 'package:pdftest/features/image_to_pdf/presentation/image_to_pdf_screen.dart';
import 'package:pdftest/features/pdf_splitter/presentation/pdf_splitter_screen.dart';
import 'package:pdftest/features/signature/presentation/signature_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/reader',
        builder: (context, state) => PdfReaderScreen(path: state.extra as String),
      ),
      GoRoute(
        path: '/merger',
        builder: (context, state) => const PdfMergerScreen(),
      ),
      GoRoute(
        path: '/image-to-pdf',
        builder: (context, state) => const ImageToPdfScreen(),
      ),
      GoRoute(
        path: '/splitter',
        builder: (context, state) => const PdfSplitterScreen(),
      ),
      GoRoute(
        path: '/signature',
        builder: (context, state) => SignatureScreen(pdfPath: state.extra as String),
      ),
    ],
  );
}
