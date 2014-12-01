part of managed_mongo;

class Mongod {
  bool running = false;

  Mongod(String downloadUrl, String host, int port) {
    checkNotNull(downloadUrl, "downloadUrl cannot be null");
    checkArgument(downloadUrl.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(host, "host cannot be null");
    checkArgument(host.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(port, "port cannot be null");
  }

  void stop() {
    running = false;
  }

  void start() {
    running = true;
  }
}