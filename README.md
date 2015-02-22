Managed Mongo
=============
[![Build Status](https://travis-ci.org/jimsimon/managed_mongo.svg?branch=master)](https://travis-ci.org/jimsimon/managed_mongo)
(Currently failing on Dart 1.8 because Dart Test Runner doesn't support the --enable-async VM flag)

Managed Mongo is a simple wrapper for downloading and running a MongoDB server from inside a dart application.

Use Case 1: Utilizing a real MongoDB instance inside unit and integration tests
--------------
```dart
import "package:unittest/unittest.dart";
import "package:managed_mongo/managed_mongo.dart";

main() {
  MongoDB mongodb;
  setUp(() async {
    var downloadUrl = "https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz";
    mongodb = new MongoDB(downloadUrl);
    await mongodb.start();
  });

  tearDown(() async {
    await mongodb.stop();
  });

  test("running flag updates when start and stop are called", () async {
    // ...your code that uses MongoDB here...
  });
```

Use Case 2: Automatic installation and creation of MongoDB on an end-user's machine
---------
```dart
import "package:managed_mongo/managed_mongo.dart"

main() async {
    var downloadUrl = "https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz";
    MongoDB mongodb = new MongoDB(downloadUrl);
    await mongodb.start();
    // your code here
    int exitCode = await mongodb.stop();
    print("MongoDB completed with exit code: $exitCode");
}
```

Supported Archive Types
-----------------------
The download url must point a properly encoded file with one of the following extensions:

* .zip
* .tar
* .tar.gz
* .tgz

All other file extensions will result in an error.

TODO
-----
1. Further customization options (i.e. other command line flags)
2. General code cleanup and refactoring