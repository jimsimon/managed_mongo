import "package:unittest/unittest.dart";
import "package:managed_mongo/managed_mongo.dart";

main() {
  Mongod mongod;
  setUp(() {
    mongod = new Mongod("https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.6.5.tgz", "", "host", 123);
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
    expect(() => new Mongod(null, "host", "", 123), throwsArgumentError);
  });

  test("throws error when downloadUrl is empty", () {
    expect(() => new Mongod(" ", "host", "", 123), throwsArgumentError);
  });

  test("throws error when host is null", () {
    expect(() => new Mongod("downloadUrl", "", null, 123), throwsArgumentError);
  });

  test("throws error when host is empty", () {
    expect(() => new Mongod("downloadUrl", "", " ", 123), throwsArgumentError);
  });

  test("throws error when port is null", () {
    expect(() => new Mongod("downloadUrl", "", "host", null), throwsArgumentError);
  });
}