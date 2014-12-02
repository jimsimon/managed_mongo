import "package:unittest/unittest.dart";
import "package:managed_mongo/managed_mongo.dart";

main() {
  MongoDB mongod;
  setUp(() {
    mongod = new MongoDB("https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz", "", "host", 123);
  });

  test("running flag updates when start and stop are called", () {
    expect(mongod.running, isFalse);

    return mongod.start().then((result){
      expect(mongod.running, isTrue);
    }).then((result){
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

  test("throws error when host is null", () {
    expect(() => new MongoDB("downloadUrl", "", null, 123), throwsArgumentError);
  });

  test("throws error when host is empty", () {
    expect(() => new MongoDB("downloadUrl", "", " ", 123), throwsArgumentError);
  });

  test("throws error when port is null", () {
    expect(() => new MongoDB("downloadUrl", "", "host", null), throwsArgumentError);
  });
}