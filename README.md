**NOTE: This project is still under heavy development and is subject to change.**

Managed Mongo
=============

Managed Mongo is a simple wrapper for downloading and running a MongoDB server from inside a dart application.

Use cases
----------
1. Utilizing a real MongoDB instance inside unit and integration tests
2. Automatic installation and creation of MongoDB on an end-user's machine

Example Code
-------------
```dart
import "package:managed_mongo/managed_mongo.dart"

main() async {
    var downloadUrl = "https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz";
    var workDirectory = "mongo_work_directory";
    var host = "localhost";
    var port = 27015;
    MongoDB mongodb = new MongoDB(downloadUrl, workDirectory, host, port);
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

Dependency Entry (pubspec.yaml)
----------------
```
dependencies:
  managed_mongo:
    git: https://github.com/jimsimon/managed_mongo.git
```

TODO
-----
2. Add documentation -- dartdoc
3. Further customization options (i.e. other command line flags)
4. General code cleanup and refactoring