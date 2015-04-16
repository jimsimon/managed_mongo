part of managed_mongo;

class MongoDB {
  final RegExp _EXTENSION_REG_EXP = new RegExp(r"(.zip|.tar.gz|.tar|.tgz)");

  String downloadUrl, workFolder, host, _extension;
  int port;

  Process _mongodProcess;

  /**
   * Facilitates the management of a MongoDB instance.
   *
   * [downloadUrl] - A URL for a valid MongoDB distribution (supported file extensions are zip, tar, tar.gz, and tgz).
   * (Optional) [workFolder] - The folder to download, extract, and run the MongoDB distribution from.  Defaults to the root of the library or application.
   * (Optional) [host] - The hostname to bind the MongoDB instance to.  Defaults to "localhost".
   * (optional) [port] - The port number to bind the MongoDB instance to.  Defaults to 27017.
   *
   * If the distribution specified by [downloadUrl] has already been downloaded, the download is skipped and the cached distribution is used.
   */
  MongoDB(String downloadUrl, {String workFolder: "", String host: "localhost", int port: 27017}) {
    checkNotNull(downloadUrl, "downloadUrl cannot be null");
    checkArgument(downloadUrl.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(host, "host cannot be null");
    checkArgument(host.trim().isNotEmpty, "downloadUrl cannot be an empty string");
    checkNotNull(port, "port cannot be null");

    this._extension = _checkFileExtension("downloadUrl", downloadUrl);
    this.downloadUrl = downloadUrl;
    this.workFolder = Strings.nonNullOrEmpty(workFolder);
    this.host = host;
    this.port = port;
  }

  /**
   * Downloads and starts the MongoDB instance.
   */
  Future start() async {
    Directory workFolderDirectory = new Directory(workFolder);
    if (workFolder != "" && !workFolderDirectory.existsSync()) {
      workFolderDirectory.create(recursive: true);
    }
    File file = await _download();
    Directory mongoDirectory = await _extract(file);
    return _run(mongoDirectory);
  }

  /**
   * Stops the MongoDB instance and returns the process's exit code.
   *
   * This method does nothing if
   */
  Future<int> stop() async {
    if (_mongodProcess != null) {
      _mongodProcess.kill();
      return _mongodProcess.exitCode;
    }
    return new Future.value();
  }

  String _checkFileExtension(String variableName, String fileNameOrPath) {
    if (!_EXTENSION_REG_EXP.hasMatch(fileNameOrPath)) {
      throw new ArgumentError.value(fileNameOrPath, "downloadUrl");
    }
    return _EXTENSION_REG_EXP.firstMatch(fileNameOrPath).group(0);
  }

  Future _download() async {
    Uri uri = Uri.parse(downloadUrl);
    String filename = uri.pathSegments.last;

    String downloadFilePath = join(workFolder, filename);
    File downloadFile = new File(downloadFilePath);
    if (!downloadFile.existsSync()) {
      HttpClientRequest request = await new HttpClient().getUrl(uri);
      print("Downloading $downloadUrl, this may take awhile.");
      HttpClientResponse response = await request.close();
      await response.pipe(downloadFile.openWrite());
      print("Download complete!");
    }
    return downloadFile;
  }

  Directory _extract(File file) {
    String extractedDirectoryPath = Strings.replaceLast(file.path, _extension, "");
    Directory extractedDirectory = new Directory(extractedDirectoryPath);
    if (!extractedDirectory.existsSync()) {
      print("Extracting ${file.path}");
      var archive = _getArchiveForFile(file);
      _unpackArchive(archive);
      print("Extraction complete!");
    }
    return extractedDirectory;
  }


  _ensureMongodIsExecutable(String mongodPath) {
    if (Platform.isLinux || Platform.isMacOS) {
      return Process.run("chmod", ["+x", mongodPath], runInShell: true);
    }
  }

  Future<Process> _createProcess(String mongodPath, String dataDbPath) async {
    Directory dataDbDirectory = new Directory(dataDbPath);
    dataDbDirectory.createSync(recursive: true);
    var arguments = ["--dbpath", dataDbPath, "--bind_ip", host, "--port", port.toString()];
    return await Process.start(mongodPath, arguments);
  }

  Future _run(Directory mongoDirectory) async {
    Completer completer = new Completer();

    String mongodPath = join(mongoDirectory.path, "bin", "mongod");
    if (Platform.isWindows) {
      mongodPath = join(mongodPath, ".exe");
    }
    String dataDbPath = join(mongoDirectory.path, "data", "db");

    await _ensureMongodIsExecutable(mongodPath);
    Process process = await _createProcess(mongodPath, dataDbPath);

    var processStdout = process.stdout.asBroadcastStream();
    process.stderr.pipe(stderr);

    processStdout.listen((data) {
      String line = new String.fromCharCodes(data);
      if (line.contains("waiting for connections on port")) {
        completer.complete();
      }
      stdout.write(line);
    });

    process.exitCode.then((exitCode) {
      if (exitCode != 0) {
        completer.completeError("Failed to start mongod due to error code $exitCode");
      }
    });

    _mongodProcess = process;
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