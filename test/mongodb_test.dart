import "package:unittest/unittest.dart";
import "package:managed_mongo/managed_mongo.dart";

main() {
  MongoDB mongod;
  setUp(() {
    mongod = new MongoDB("https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz", "", "host", 123);
  });

  test("running flag updates when start and stop are called", () {
    expect(mongod.running, isFalse);

    return mongod.start()
      .then((result){
        expect(mongod.running, isTrue);
        mongod.stop();
        expect(mongod.running, isFalse);
      });

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