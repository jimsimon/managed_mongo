import "dart:io";
import "package:unittest/unittest.dart";
import "package:managed_mongo/managed_mongo.dart";
import "package:mongo_dart/mongo_dart.dart";

createPlatformSpecificMongoDB() {
  final hostname = "127.0.0.1";
  final port = 27015;
  final workDirectory = "";
  if (Platform.isMacOS) {
    return new MongoDB("https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.7.tgz", workFolder: workDirectory, host: hostname, port: port);
  } else if (Platform.isLinux) {
    return new MongoDB("https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.7.tgz", workFolder: workDirectory, host: hostname, port: port);
  }
  return null;
}

main() {
  MongoDB mongod;
  setUp(() async {

    mongod = createPlatformSpecificMongoDB();
    await mongod.start();
  });

  tearDown(() async {
    var exitCode = await mongod.stop();
    expect(exitCode, equals(0));
  });

  test("runs and shuts down on specified host and port when start and stop are called", () async {
    Db db = new Db("mongodb://127.0.0.1:27015");
    await db.open();
    expect(db.state, equals(State.OPEN));
    await db.close();
  });

  test("throws error when downloadUrl is null", () {
    expect(() => new MongoDB(null, workFolder: "workfolder"), throwsArgumentError);
  });

  test("throws error when downloadUrl is empty", () {
    expect(() => new MongoDB(" ", workFolder: "workfolder"), throwsArgumentError);
  });

  test("throws error when downloadUrl has an invalid extension", () {
    expect(() => new MongoDB("downloadUrl.bat", workFolder: "workfolder"), throwsArgumentError);
  });

  test("throws error when host is null", () {
    expect(() => new MongoDB("downloadUrl.zip", workFolder: "workfolder", host: null), throwsArgumentError);
  });

  test("throws error when host is empty", () {
    expect(() => new MongoDB("downloadUrl.tgz", workFolder: "workfolder", host: " "), throwsArgumentError);
  });

  test("throws error when port is null", () {
    expect(() => new MongoDB("downloadUrl.tar", workFolder: "workfolder", port: null), throwsArgumentError);
  });

  test("does not throw an error when workFolder is null", () {
    expect(() => new MongoDB("downloadUrl.tar.gz", workFolder: null), returnsNormally);
  });

  test("stop has no side effects when start hasn't been called", () async {
    MongoDB mongoDb = createPlatformSpecificMongoDB();
    await mongoDb.stop();
  });
}