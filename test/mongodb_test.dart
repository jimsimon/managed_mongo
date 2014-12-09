import "package:unittest/unittest.dart";
import "package:managed_mongo/managed_mongo.dart";
import "package:mongo_dart/mongo_dart.dart";

main() {
  MongoDB mongod;
  setUp(() {
    mongod = new MongoDB("https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz", "", "host", 123);
  });

  test("running flag updates when start and stop are called", () async {
    await mongod.start();
    Db db = new Db("mongodb://localhost:27017");
    await db.open();
    await db.close();
    var exitCode = await mongod.stop();
    expect(exitCode, equals(0));
  });

  test("throws error when downloadUrl is null", () {
    expect(() => new MongoDB(null, "host", "", 123), throwsArgumentError);
  });

  test("throws error when downloadUrl is empty", () {
    expect(() => new MongoDB(" ", "host", "", 123), throwsArgumentError);
  });

  test("throws error when downloadUrl has an invalid extension", () {
    expect(() => new MongoDB("downloadUrl.bat", "host", "", 123), throwsArgumentError);
  });

  test("throws error when host is null", () {
    expect(() => new MongoDB("downloadUrl.zip", "", null, 123), throwsArgumentError);
  });

  test("throws error when host is empty", () {
    expect(() => new MongoDB("downloadUrl.tgz", "", " ", 123), throwsArgumentError);
  });

  test("throws error when port is null", () {
    expect(() => new MongoDB("downloadUrl.tar", "", "host", null), throwsArgumentError);
  });

  test("does not throw an error when workFolder is null", () {
    expect(() => new MongoDB("downloadUrl.tar.gz", null, "host", 123), returnsNormally);
  });
}