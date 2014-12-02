part of managed_mongo;

class MongoDB {
  String downloadUrl, downloadFolder, host;
  int port;
  bool running = false;

  MongoDB(String downloadUrl, String downloadFolder, String host, int port) {
    checkNotNull(downloadUrl, "downloadUrl cannot be null");
    checkArgument(downloadUrl.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(host, "host cannot be null");
    checkArgument(host.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(port, "port cannot be null");
    this.downloadUrl = downloadUrl;
    this.downloadFolder = downloadFolder;
    this.host = host;
    this.port = port;
  }

  void stop() {
    running = false;
  }

  Future start() {
    Completer completer = new Completer();
    _download().then(_extract).whenComplete((){
      running = true;
      completer.complete();
    });
    return completer.future;
  }

  Future _download() {
    Completer completer = new Completer();

    Uri uri = Uri.parse(downloadUrl);
    String filename = uri.pathSegments.last;

    String downloadFilePath = join(downloadFolder, filename);
    File downloadFile = new File(downloadFilePath);
    if (!downloadFile.existsSync()) {
      new HttpClient().getUrl(Uri.parse(downloadUrl))
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) => response.pipe(downloadFile.openWrite()))
      .then((File file) => completer.complete(file));
    } else {
      completer.complete(downloadFile);
    }
    return completer.future;
  }

  _unzip(File file) {
    String workDirectory = file.parent.path;

    var filePath = file.path;
    Archive archive;
    if (filePath.endsWith(".zip")) {
      archive = new ZipDecoder().decodeBytes(file.readAsBytesSync());
    } else if (filePath.endsWith(".tar")) {
      archive = new TarDecoder().decodeBytes(file.readAsBytesSync());
    } else if (filePath.endsWith(".tar.gz") || filePath.endsWith(".tgz")) {
      List<int> unGzippedBytes = GZIP.decode(file.readAsBytesSync());
      archive = new TarDecoder().decodeBytes(unGzippedBytes);
    }

    // Extract the contents of the Zip archive to disk.
    for (ArchiveFile file in archive) {
      String filename = file.name;
      List<int> data = file.content;
      String filePath = join(workDirectory, filename);
      new File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }

  Future _extract(File file) {
    Completer completer = new Completer();

    completer.complete(_unzip(file));

    return completer.future;
  }
}