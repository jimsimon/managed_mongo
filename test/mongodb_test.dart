import "package:unittest/unittest.dart";
import "package:managed_mongo/managed_mongo.dart";
import "package:mongo_dart/mongo_dart.dart";

main() {
  MongoDB mongod;
  setUp(() async {
    mongod = new MongoDB("https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz", "", host: "127.0.0.1", port: 27015);
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
    expect(() => new MongoDB(null, "workfolder"), throwsArgumentError);
  });

  test("throws error when downloadUrl is empty", () {
    expect(() => new MongoDB(" ", "workfolder"), throwsArgumentError);
  });

  test("throws error when downloadUrl has an invalid extension", () {
    expect(() => new MongoDB("downloadUrl.bat", "workfolder"), throwsArgumentError);
  });

  test("throws error when host is null", () {
    expect(() => new MongoDB("downloadUrl.zip", "workfolder", host: null), throwsArgumentError);
  });

  test("throws error when host is empty", () {
    expect(() => new MongoDB("downloadUrl.tgz", "workfolder", host: " "), throwsArgumentError);
  });

  test("throws error when port is null", () {
    expect(() => new MongoDB("downloadUrl.tar", "workfolder", port: null), throwsArgumentError);
  });

  test("does not throw an error when workFolder is null", () {
    expect(() => new MongoDB("downloadUrl.tar.gz", null), returnsNormally);
  });

}