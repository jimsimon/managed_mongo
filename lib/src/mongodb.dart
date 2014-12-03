part of managed_mongo;

class MongoDB {
  final RegExp EXTENSION_REG_EXP = new RegExp(r"(.zip|.tar.gz|.tar|.tgz)");

  Process _mongodProcess;
  String downloadUrl, workFolder, host, _extension;
  int port;
  bool running = false;

  String checkFileExtension(String variableName, String fileNameOrPath) {
    if (!EXTENSION_REG_EXP.hasMatch(fileNameOrPath)) {
      throw new ArgumentError.value(fileNameOrPath, "downloadUrl");
    }
    return EXTENSION_REG_EXP.firstMatch(fileNameOrPath).group(0);
  }

  MongoDB(String downloadUrl, String workFolder, String host, int port) {
    checkNotNull(downloadUrl, "downloadUrl cannot be null");
    checkArgument(downloadUrl.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(host, "host cannot be null");
    checkArgument(host.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(port, "port cannot be null");

    this._extension = checkFileExtension("downloadUrl", downloadUrl);
    this.downloadUrl = downloadUrl;
    this.workFolder = Strings.nonNullOrEmpty(workFolder);
    this.host = host;
    this.port = port;
  }

  void stop() {
    _mongodProcess.kill();
    running = false;
  }

  Future start() {
    return _download().then(_extract).then(_run).whenComplete(() => running = true);
  }

  Future _download() {
    Completer completer = new Completer();

    Uri uri = Uri.parse(downloadUrl);
    String filename = uri.pathSegments.last;

    String downloadFilePath = join(workFolder, filename);
    File downloadFile = new File(downloadFilePath);
    if (!downloadFile.existsSync()) {
      new HttpClient().getUrl(uri)
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) => response.pipe(downloadFile.openWrite()))
        .then((_) => completer.complete(downloadFile));
    } else {
      completer.complete(downloadFile);
    }
    return completer.future;
  }

  Directory _extract(File file) {
    String extractedDirectoryName = Strings.replaceLast(file.path, _extension, "");
    Directory extractedDirectory = new Directory(join(workFolder, extractedDirectoryName));
    if (!extractedDirectory.existsSync()) {
      var archive = _getArchiveForFile(file);
      _unpackArchive(archive);
    }
    return extractedDirectory;
  }

  Future _run(Directory mongoDirectory) {
    String mongodPath = join(mongoDirectory.path, "bin", "mongod");

    if (Platform.isLinux || Platform.isMacOS) {
      Process.runSync("chmod", ["+x", mongodPath], runInShell: true);
    }

    String dataDbPath = join(mongoDirectory.path, "data", "db");
    Directory dataDbDirectory = new Directory(dataDbPath);
    dataDbDirectory.createSync(recursive: true);
    return Process.start(mongodPath, ["--dbpath", dataDbPath])
      .then((Process process) {
        stdout.addStream(process.stdout);
        stderr.addStream(process.stderr);
        _mongodProcess = process;
      });
  }

  Archive _getArchiveForFile(File file) {
    Archive archive;
    if (_extension == ".zip") {
      archive = new ZipDecoder().decodeBytes(file.readAsBytesSync());
    } else if (_extension == ".tar") {
      archive = new TarDecoder().decodeBytes(file.readAsBytesSync());
    } else if (_extension == ".tar.gz" || _extension == ".tgz") {
      List<int> unGzippedBytes = GZIP.decode(file.readAsBytesSync());
      archive = new TarDecoder().decodeBytes(unGzippedBytes);
    }
    return archive;
  }

  void _unpackArchive(Archive archive) {
    for (ArchiveFile file in archive) {
      String filename = file.name;
      List<int> data = file.content;
      String filePath = join(workFolder, filename);
      new File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }

}