import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_lab_6/main.dart';

// 1x1 transparent PNG bytes to mock network image loading in widget tests
final Uint8List _transparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _TestHttpClient();
}

class _TestHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

class _TestHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _TestHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

class _TestHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('Lab 6 - Responsive layout tests on Phone (<800px) and Tablet (>=800px)',
      (WidgetTester tester) async {
    // ------------------------------------------------------------------------
    // 1. TEST PHONE LAYOUT (< 800px)
    // ------------------------------------------------------------------------
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ResponsiveMovieApp());
    await tester.pumpAndSettle();

    // Check title and phone badge
    expect(find.text('Find a Movie'), findsOneWidget);
    expect(find.text('Phone (<800px)'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // In phone mode (< 800px), a ListView is used for the movie list
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    // ------------------------------------------------------------------------
    // 2. TEST TABLET LAYOUT (>= 800px)
    // ------------------------------------------------------------------------
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const ResponsiveMovieApp());
    await tester.pumpAndSettle();

    // Check tablet badge and GridView presence
    expect(find.text('Tablet/Web (≥800px)'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    // ------------------------------------------------------------------------
    // 3. TEST FILTER CHIPS & SEARCH INTERACTION
    // ------------------------------------------------------------------------
    // Tap on Action chip
    final actionChip = find.widgetWithText(FilterChip, 'Action');
    expect(actionChip, findsOneWidget);
    await tester.tap(actionChip);
    await tester.pumpAndSettle();

    // Verify genre selection badge appears with count 1
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    // Tap Clear filters
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Clear filters'), findsNothing);
  });
}
