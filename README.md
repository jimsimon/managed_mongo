Managed MongoDB
=============

Managed MongoDB is a simple wrapper for downloading and running a mongodb server from inside a dart application.

Use cases
----------
1. Utilizing a real MongoDB instance inside unit and integration tests
2. Automatic installation and creation of MongoDB on an end-user's machine

Example Code
-------------
```dart
import "package:managed_mongodb/managed_mongodb.dart"

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
