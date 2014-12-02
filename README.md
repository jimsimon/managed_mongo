**NOTE: This project is still under development.  It is not 100% functional yet!  As of right now mongodb will not be started up, only the download and extract portions are currently working.**
=============

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

main() {
    var downloadUrl = "https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz";
    var workDirectory = "mongo_work_directory";
    var host = "localhost";
    var port = 27015;
    MongoDB mongodb = new MongoDB(downloadUrl, workDirectory, host, port);
    mongodb.start().then(() {
        // your code here
        mongodb.stop();
    });
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
1. Finish implementing start and stop methods
2. Add documentation -- dartdoc
3. Further customization options (i.e. other command line flags)
4. General code cleanup and refactoring