import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

final String columnId = '_id';
final String columnContent = 'content';
final String columnDate = 'date';
final String columnImages = "images";
final String columnMood = 'mood';
final String columnAudio = 'audio';
final String tableEntry = 'entry';

class Entry {
  int? id;
  String? content;
  String date;
  List<String> images;
  String? mood;
  String? audio;

  Map<String, Object?> toMap() {
    var jsonImages = jsonEncode(images);
    var map = <String, Object?>{
      columnContent: content,
      columnDate: date,
      columnImages: jsonImages,
      columnMood: mood,
      columnAudio: audio
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  Entry(
      {this.id,
      this.content,
      required this.date,
      this.images = const [],
      this.mood,
      this.audio});

  factory Entry.fromMap(Map<String, dynamic> map) {
    String? jsonImages = map[columnImages];
    List<String> images;
    if (jsonImages == null || jsonImages == 'null') {
      images = [];
    } else {
      images = List<String>.from(jsonDecode(jsonImages));
    }

    return Entry(
      id: map[columnId] as int,
      content: map[columnContent] as String,
      date: map[columnDate] as String,
      images: images,
      mood: map[columnMood] as String?,
      audio: map[columnAudio],
    );
  }
}

class EntryProvider {
  late Database db;

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  EntryProvider();

  Future<void> _open() async {
    String? securePassword = await secureStorage.read(key: 'password');

    if (securePassword == null) {
      return;
    }

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'happy_journal.db');

    db = await openDatabase(path, version: 3, password: securePassword,
        onCreate: (Database db, int version) async {
      await db.execute('''
                create table $tableEntry (
                  $columnId integer primary key autoincrement,
                  $columnContent text,
                  $columnDate text not null,
                  $columnImages images,
                  $columnMood mood,
                  $columnAudio audio)
              ''');
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
            alter table $tableEntry add column $columnImages text
          ''');
      }
      if (oldVersion < 3) {
        await db.execute('''
          alter table $tableEntry add column $columnMood text
        ''');
        await db.execute('''
          alter table $tableEntry add column $columnAudio text
        ''');
        await db.execute('''alter table $tableEntry add column new_text text''');
        await db.execute('''update $tableEntry set new_text = $columnContent''');
        await db.execute('''alter table $tableEntry drop column $columnContent''');
        await db.execute('''alter table $tableEntry rename column new_text to $columnContent''');
      }
    });
  }

  Future<Entry> upsert(Entry entry) async {
    return entry.id == null ? insert(entry) : update(entry);
  }

  Future<Entry> insert(Entry entry) async {
    await _open();
    entry.id = await db.insert(tableEntry, entry.toMap());
    db.close();
    return entry;
  }

  Future<Entry> update(Entry entry) async {
    await _open();
    await db.update(tableEntry, entry.toMap(),
        where: '$columnId = ?', whereArgs: [entry.id]);
    db.close();
    return entry;
  }

  Future<Entry?> getRandomEntry(int? excludeId) async {
    await _open();
    try {
      String whereCondition =
          excludeId == null ? '' : 'where _id != $excludeId';
      List<Map> maps = await db.rawQuery(
          '''select * from $tableEntry $whereCondition order by random() limit 1;''');
      if (maps.isNotEmpty) {
        Entry result = Entry.fromMap(maps.first as Map<String, dynamic>);
        return result;
      }
      db.close();
      return null;
    } catch (e) {
      db.close();
      return null;
    }
  }

  Future<int> getCount() async {
    try {
      await _open();
      int? count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableEntry'));
      db.close();
      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!await Permission.manageExternalStorage.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }

  Future<String> export() async {
    if (Platform.isAndroid) {
      if (!await requestStoragePermission()) {
        throw Exception("No permission granted");
      }
    }

    final archive = Archive();

    final Directory imagesDirectory = await getApplicationDocumentsDirectory();
    final String imagesDirectoryPath = imagesDirectory.path;

    final String dbPath = await getDatabasesPath();
    final Directory dbDirectory = Directory(dbPath);

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      throw Exception('No directory selected');
    }

    Future<void> addFiles(
        Archive archive, Directory dir, String basePath) async {
      for (var entity in dir.listSync(recursive: true)) {
        if (entity is Directory) {
          continue;
        }

        if (entity is File) {
          if (!entity.path.endsWith('.jpg') && !entity.path.endsWith('.db') && !entity.path.endsWith('.m4a')) {
            continue;
          }
          final relativePath = entity.path.replaceFirst('$basePath/', '');
          final bytes = await entity.readAsBytes();

          // Add to archive
          final archiveFile = ArchiveFile(
            relativePath,
            bytes.length,
            bytes,
          );
          archive.addFile(archiveFile);
        }
      }
    }

    await addFiles(archive, imagesDirectory, imagesDirectoryPath);

    await addFiles(archive, dbDirectory, dbPath);

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    final zipPath = join(selectedDirectory,
        'ADiary_${DateTime.now().millisecondsSinceEpoch}.zip');
    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipData);

    return zipPath;
  }

  Future<void> import() async {
    if (Platform.isAndroid) {
      if (!await requestStoragePermission()) {
        throw Exception("No permission granted");
      }
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      throw Exception('No Files Selected');
    }
    if (result.files.single.extension != 'zip') {
      throw Exception('Can only import .zip files');
    }
    final bytes = await File(result.files.single.path!).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Get directories
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = await getDatabasesPath();

    // Extract files
    for (final file in archive) {
      final filename = file.name;

      if (file.isFile) {
        final data = file.content as List<int>;

        if (filename.endsWith('.db')) {
          final dbFile = File('$dbPath/$filename');
          await dbFile.create();
          await dbFile.writeAsBytes(data);
        } else {
          final imageFile = File('${documentsDirectory.path}/$filename');
          await imageFile.create();
          await imageFile.writeAsBytes(data);
        }
      }
    }
  }
}
