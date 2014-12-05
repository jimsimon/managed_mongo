part of managed_mongo;

class MongoDB {
  final RegExp EXTENSION_REG_EXP = new RegExp(r"(.zip|.tar.gz|.tar|.tgz)");

  Process _mongodProcess;
  String downloadUrl, workFolder, host, _extension;
  int port;
  bool running = false;
  Completer _stopCompleter = new Completer();

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

  Future stop() {
    _mongodProcess.kill();
    return _stopCompleter.future;
  }

  Future start() {
    return _download().then(_extract).then(_run);
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
    Completer completer = new Completer();
    String mongodPath = join(mongoDirectory.path, "bin", "mongod");

    if (Platform.isLinux || Platform.isMacOS) {
      Process.runSync("chmod", ["+x", mongodPath], runInShell: true);
    }

    String dataDbPath = join(mongoDirectory.path, "data", "db");
    Directory dataDbDirectory = new Directory(dataDbPath);
    dataDbDirectory.createSync(recursive: true);
    Process.start(mongodPath, ["--dbpath", dataDbPath])
      .then((Process process) {
        running = true;
        var processStdout = process.stdout.asBroadcastStream();
        stdout.addStream(processStdout);
        stderr.addStream(process.stderr);

        processStdout.listen((data) {
          String line = new String.fromCharCodes(data);
          if (line.contains("waiting for connections on port")) {
            completer.complete();
          }
        });

        process.exitCode.then((exitCode){
          running = false;
          if (exitCode != 0) {
            completer.completeError("Failed to start mongod due to mongod exit code $exitCode");
          }
          _stopCompleter.complete(exitCode);
        });
        _mongodProcess = process;
      });
    return completer.future;
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