library shelf_static.basic_file_test;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:scheduled_test/scheduled_test.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_static/src/util.dart';

void main() {
  group('/index.html', () {
    test('body is correct', () {
      return _testFileContents('index.html');
    });

    // Content-Type:text/html
    // Date:Fri, 02 May 2014 22:29:02 GMT
  });

  group('/favicon.ico', () {
    test('body is correct', () {
      return _testFileContents('favicon.ico');
    });

    // Content-Type: ???
    // Date:Fri, 02 May 2014 22:29:02 GMT
  });
}

Future _testFileContents(String filename) {
  var uri = Uri.parse('http://localhost/$filename');
  var filePath = p.join(_samplePath, filename);
  var file = new File(filePath);
  var fileContents = file.readAsBytesSync();
  var length = file.statSync().size;

  return _request(new Request('GET', uri)).then((response) {
    expect(response.contentLength, length);
    return _expectCompletesWithBytes(response, fileContents);
  });
}

Future _expectCompletesWithBytes(Response response, List<int> expectedBytes) {
  return response.read().toList().then((List<List<int>> bytes) {
    var flatBytes = bytes.expand((e) => e);
    expect(flatBytes, orderedEquals(expectedBytes));
  });
}

Future<Response> _request(Request request) {
  var handler = getHandler(_samplePath);

  return syncFuture(() => handler(request));
}

String get _samplePath {
  var scriptDir = p.dirname(p.fromUri(Platform.script));
  var sampleDir = p.join(scriptDir, 'sample_files');
  assert(FileSystemEntity.isDirectorySync(sampleDir));
  return sampleDir;
}
