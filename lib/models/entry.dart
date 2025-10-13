import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

final String columnId = '_id';
final String columnContent = 'content';
final String columnDate = 'date';
final String columnImages = "images";
final String tableEntry = 'entry';

class Entry {
  int? id;
  String content;
  String date;
  List<String> images;

  Map<String, Object?> toMap() {
    var jsonImages = jsonEncode(images);
    var map = <String, Object?>{
      columnContent: content,
      columnDate: date,
      columnImages: jsonImages
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  Entry(
      {this.id,
      required this.content,
      required this.date,
      this.images = const []});

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

    db = await openDatabase(path, version: 2, password: securePassword,
        onCreate: (Database db, int version) async {
      await db.execute('''
                create table $tableEntry (
                  $columnId integer primary key autoincrement,
                  $columnContent text not null,
                  $columnDate text not null,
                  $columnImages images)
              ''');
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
            alter table $tableEntry add column $columnImages text
          ''');
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

  Future<Entry?> getEntry(int id) async {
    List<Map> maps = await db.query(tableEntry,
        columns: [columnId, columnContent, columnDate],
        where: '$columnId = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      db.close();
      return Entry.fromMap(maps.first as Map<String, dynamic>);
    }
    db.close();
    return null;
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

  Future<String> export() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'happy_journal.db');
    String exportDirectoryPath = '/storage/emulated/0/Download/ADiary';
    Directory exportDirectory = Directory(exportDirectoryPath);
    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }
    String filename = 'ADiary_${DateTime.now().millisecondsSinceEpoch}.db';
    String exportPath = join(exportDirectoryPath, filename);

    File sourceFile = File(path);
    await sourceFile.copy(exportPath);
    return 'Download/ADiary/$filename';
  }

  Future<void> import() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      throw Exception('No Files Selected');
    }
    if (result.files.single.extension != 'db') {
      throw Exception('Can only import .db files');
    }

    File selectedFile = File(result.files.single.path!);

    String dbPath = await getDatabasesPath();
    String currentPath = join(dbPath, 'happy_journal.db');

    await selectedFile.copy(currentPath);
  }
}
