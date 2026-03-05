import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
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
final String columnDiscardedAt = 'discarded_at';
final String tableEntry = 'entry';

class Entry {
  int? id;
  String? content;
  String date;
  List<String>? images;
  String? mood;
  String? audio;
  String? discardedAt;

  Map<String, Object?> toMap() {
    var jsonImages = images == null ? null : jsonEncode(images);
    var map = <String, Object?>{
      columnContent: content,
      columnDate: date,
      columnImages: jsonImages,
      columnMood: mood,
      columnAudio: audio,
      columnDiscardedAt: discardedAt
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
      this.images,
      this.mood,
      this.audio,
      this.discardedAt});

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
      discardedAt: map[columnDiscardedAt],
    );
  }
}

class EntryProvider {
  late Database db;

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String? _injectedPassword;

  EntryProvider({String? password}) : _injectedPassword = password;

  Future<void> _open() async {
    // Use injected password if available (background isolate),
    // otherwise fall back to secure storage (foreground use)
    String? securePassword = _injectedPassword ?? await secureStorage.read(key: 'password');

    if (securePassword == null) return;

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'happy_journal.db');

    db = await openDatabase(path, version: 3, password: securePassword,
        onCreate: (Database db, int version) async {
      await db.execute('''
                create table $tableEntry (
                  $columnId integer primary key autoincrement,
                  $columnContent text,
                  $columnDate text not null,
                  $columnImages text,
                  $columnMood text,
                  $columnAudio text,
                  $columnDiscardedAt text)
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
        await db
            .execute('''alter table $tableEntry add column new_text text''');
        await db
            .execute('''update $tableEntry set new_text = $columnContent''');
        await db
            .execute('''alter table $tableEntry drop column $columnContent''');
        await db.execute(
            '''alter table $tableEntry rename column new_text to $columnContent''');
        await db.execute(
            '''alter table $tableEntry add column $columnDiscardedAt text''');
        await db.execute('''
              alter table $tableEntry add column date_iso text;
            ''');
        await db.execute('''
              UPDATE entry
              SET date_iso =
                substr($columnDate, -4) || '-' ||
                printf('%02d',
                  CASE substr($columnDate, 1, 3)
                    WHEN 'Jan' THEN 1
                    WHEN 'Feb' THEN 2
                    WHEN 'Mar' THEN 3
                    WHEN 'Apr' THEN 4
                    WHEN 'May' THEN 5
                    WHEN 'Jun' THEN 6
                    WHEN 'Jul' THEN 7
                    WHEN 'Aug' THEN 8
                    WHEN 'Sep' THEN 9
                    WHEN 'Oct' THEN 10
                    WHEN 'Nov' THEN 11
                    WHEN 'Dec' THEN 12
                  END
                ) || '-' ||
                printf('%02d',
                  CAST(trim(substr($columnDate, 5, instr($columnDate, ',') - 5)) AS INTEGER)
                )
          ''');
        await db.execute('''update $tableEntry set date = date_iso''');
        await db.execute('''
          CREATE INDEX idx_entry_date
          ON $tableEntry($columnDate)''');
        await db
            .execute('''alter table $tableEntry drop column date_iso''');
      }
    });
  }

  Future<void> reEncryptDb(String newPassword) async {
    await _open();
    await db.execute("PRAGMA rekey = '$newPassword'");
    await db.close();
  }

  Future<Entry> upsert(Entry entry) async {
    return entry.id == null ? insert(entry) : update(entry);
  }

  Future<Entry> insert(Entry entry) async {
    await _open();
    entry.id = await db.insert(tableEntry, entry.toMap());
    return entry;
  }

  Future<Entry> update(Entry entry) async {
    await _open();
    await db.update(tableEntry, entry.toMap(),
        where: '$columnId = ?', whereArgs: [entry.id]);
    return entry;
  }

  Future<bool> delete(int? id) async {
    if (id == null) {
      return true;
    }
    try {
      await _open();
      await db.execute(
          '''update $tableEntry set $columnDiscardedAt=? where $columnId = ?''', [(DateFormat('yyyy/MM/dd').format(DateTime.now())), id]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Entry?> getRandomEntry(int? excludeId) async {
    await _open();
    try {
      String whereCondition = excludeId == null ? '' : '_id != $excludeId and';
      List<Map> maps = await db.rawQuery(
          '''select * from $tableEntry where $whereCondition $columnDiscardedAt is null order by random() limit 1;''');
      if (maps.isNotEmpty) {
        Entry result = Entry.fromMap(maps.first as Map<String, dynamic>);
        return result;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Entry?> getEntryById(int id) async {
    await _open();
    try {
      List<Map> maps = await db.rawQuery(
          '''select * from $tableEntry where $columnId = ? and $columnDiscardedAt is null order by random() limit 1;''', [id]);
      if (maps.isNotEmpty) {
        Entry result = Entry.fromMap(maps.first as Map<String, dynamic>);
        return result;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int> getCount() async {
    try {
      await _open();
      int? count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $tableEntry where $columnDiscardedAt is null'));

      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getDiscardedCount() async {
    try {
      await _open();
      int? count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $tableEntry where $columnDiscardedAt is not null'));
      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getCountWithAudio() async {
    try {
      await _open();
      int? count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $tableEntry where $columnDiscardedAt is null and $columnAudio is not null'));
      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getCountWithImages() async {
    try {
      await _open();
      int? count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $tableEntry where $columnDiscardedAt is null and $columnImages is not null'));
      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getImageCount() async {
    try {
      await _open();
      int? count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $tableEntry, json_each($tableEntry.$columnImages) where $columnDiscardedAt is null and $columnImages is not null'));
      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<String> getFrequentMood() async {
    try {
      await _open();
      final frequentMood = await db.rawQuery('''
          SELECT $columnMood, COUNT(*) as total
          FROM $tableEntry
          WHERE $columnDiscardedAt IS NULL
          AND $columnMood IS NOT NULL
          GROUP BY $columnMood
          ORDER BY total DESC
          LIMIT 1
        ''');
      if (frequentMood.isEmpty) return '-';

      return '${frequentMood.first[columnMood]} - ${frequentMood.first["total"]}';
    } catch (_) {
      return '-';
    }
  }

  Future<Map<String, int>> getMonthlyCounts() async {
    await _open();
    final now = DateTime.now();
    final endMonth = '${now.year}-12';

    final rows = await db.rawQuery('''
      WITH RECURSIVE months(month) AS (
        -- Start from January of earliest available year
        SELECT strftime('%Y-01', MIN($columnDate))
        FROM $tableEntry
        WHERE $columnDiscardedAt IS NULL

        UNION ALL

        -- Add one month each recursion
        SELECT strftime('%Y-%m', date(month || '-01', '+1 month'))
        FROM months
        WHERE month < ?
      )

      SELECT
        months.month,
        COUNT($tableEntry.$columnDate) as total
      FROM months
      LEFT JOIN $tableEntry
        ON substr($tableEntry.$columnDate, 1, 7) = months.month
        AND $tableEntry.$columnDiscardedAt IS NULL
      GROUP BY months.month
      ORDER BY months.month
    ''', [endMonth]);

    return {for (var row in rows) row['month'] as String: row['total'] as int};
  }

  Future<Map<String, int>> getYearlyCumulativeCounts(int year) async {
    await _open();
    final now = DateTime.now();
    final isCurrentYear = year == now.year;

    final endDate = isCurrentYear
        ? now.toIso8601String().substring(0, 10) // YYYY-MM-DD
        : '$year-12-31';
    final rows = await db.rawQuery('''
      WITH RECURSIVE days(day) AS (
          SELECT date(? || '-01-01')
          UNION ALL
          SELECT date(day, '+1 day')
          FROM days
          WHERE day < date(?)
      ),
      daily_counts AS (
          SELECT $columnDate AS day, COUNT(*) AS total
          FROM $tableEntry
          WHERE substr($columnDate,1,4) = ?
            AND $columnDiscardedAt IS NULL
          GROUP BY $columnDate
      )
      SELECT
          days.day,
          SUM(COALESCE(daily_counts.total,0))
              OVER (ORDER BY days.day
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_total
      FROM days
      LEFT JOIN daily_counts
        ON days.day = daily_counts.day
      ORDER BY days.day;
    ''', [year.toString(), endDate, year.toString()]);

    return {
      for (var row in rows) row['day'] as String: row['cumulative_total'] as int
    };
  }

  Future<int?> getEarliestYear() async {
    await _open();
    final result = await db.rawQuery('''
      SELECT CAST(strftime('%Y', MIN($columnDate)) AS INTEGER) AS earliest_year
      FROM $tableEntry
      WHERE $columnDiscardedAt IS NULL
    ''');

    if (result.isEmpty || result.first['earliest_year'] == null) {
      return null;
    }

    return result.first['earliest_year'] as int;
  }

  Future<String?> getDayWithMostEntries() async {
    await _open();
    final result = await db.rawQuery('''
      WITH daily_counts AS (
          SELECT
              date($columnDate) AS day,
              COUNT(*) AS total
          FROM $tableEntry
          where $columnDiscardedAt is null
          GROUP BY date($columnDate)
      )

      SELECT day, total
      FROM daily_counts
      WHERE total = (
          SELECT MAX(total) FROM daily_counts
      )
      ORDER BY day;
    ''');

    if (result.isEmpty) {
      return null;
    }
    return '${result.first['day']} = ${result.first['total']}';
  }

  Future<int> getDaysWithEntries() async {
    await _open();

    final count = Sqflite.firstIntValue(await db.rawQuery('''
        SELECT COUNT(DISTINCT $columnDate) FROM $tableEntry;
      '''));

    return count ?? 0;
  }

  Future<Map<String, int>> fetchMoodFrequencies() async {
    await _open();
    final rows = await db.rawQuery('''
      SELECT $columnMood, COUNT(*) as count
      FROM $tableEntry
      WHERE $columnMood IS NOT NULL AND TRIM($columnMood) != '' and $columnDiscardedAt is null
      GROUP BY $columnMood
      ORDER BY count DESC
    ''');

    return {
      for (final row in rows) row['mood'] as String: row['count'] as int,
    };
  }

  Future<int> getLongestStreak() async {
    await _open();
    // This query finds the longest consecutive-day streak of entries.
    // It uses a classic SQL technique called "gaps and islands".

    final result = await db.rawQuery('''
      WITH distinct_days AS (
          -- Step 1:
          -- Get unique calendar days that have at least one entry.
          -- We use DISTINCT so multiple entries on the same day
          -- do not artificially increase the streak length.
          SELECT DISTINCT date($columnDate) AS day
          FROM $tableEntry
      ),

      numbered_days AS (
          -- Step 2:
          -- Assign a row number to each day in chronological order.
          -- This creates a sequential index: 1, 2, 3, 4, ...
          SELECT
              day,
              ROW_NUMBER() OVER (ORDER BY day) AS rn
          FROM distinct_days
      ),

      grouped_days AS (
          -- Step 3 (The key trick):
          -- Subtract the row number (in days) from each date.
          --
          -- For consecutive dates:
          --   day - rn days = constant value
          --
          -- That constant value becomes a "group key".
          -- When there is a gap in dates, the value changes,
          -- creating a new group.
          SELECT
              day,
              date(day, '-' || rn || ' days') AS grp
          FROM numbered_days
      )

      -- Step 4:
      -- Count how many days exist in each group (each streak),
      -- then take the maximum streak length.
      SELECT MAX(streak_length) AS longest_streak
      FROM (
          SELECT COUNT(*) AS streak_length
          FROM grouped_days
          GROUP BY grp
      );
    ''');

    // If table is empty, return 0 instead of null.
    return (result.first['longest_streak'] as int?) ?? 0;
  }

  Future<int> getCurrentStreak() async {
    await _open();

    final result = await db.rawQuery('''
      WITH distinct_days AS (
      SELECT DISTINCT date($columnDate) AS day
          FROM $tableEntry
      ),

      latest_day AS (
          SELECT MAX(day) AS max_day
          FROM distinct_days
      ),

      numbered_days AS (
          SELECT
              day,
              ROW_NUMBER() OVER (ORDER BY day DESC) AS rn
          FROM distinct_days
      ),

      grouped_days AS (
          SELECT
              day,
              julianday(day) + rn AS grp
          FROM numbered_days
      ),

      streaks AS (
          SELECT
              grp,
              COUNT(*) AS streak_length,
              MAX(day) AS max_day
          FROM grouped_days
          GROUP BY grp
      )

      SELECT
          CASE
              -- If latest entry older than yesterday → no active streak
              WHEN date((SELECT max_day FROM latest_day)) < date('now', '-1 day')
                  THEN 0
              ELSE (
                  -- Return streak that contains the latest day
                  SELECT streak_length
                  FROM streaks
                  WHERE max_day = (SELECT max_day FROM latest_day)
              )
          END AS current_streak;
    ''');

    // If table is empty, return 0 instead of null.
    return (result.first['current_streak'] as int?) ?? 0;
  }

  Future<bool> hasEntryToday() async {
    await _open();
    final result = await db.rawQuery('''
      SELECT EXISTS (
          SELECT 1
          FROM $tableEntry
          WHERE date($columnDate) = date('now') and $columnDiscardedAt is null
      ) AS has_entry
    ''');

    return (result.first['has_entry'] as int) == 1;
  }

  Future<int> countLastWeek() async {
    await _open();

    final res = await db.rawQuery('''
      SELECT COUNT(*)
        FROM $tableEntry
        WHERE date($columnDate) >= date('now', '-8 days')
        AND date($columnDate) <= date('now', '-1 day')
        AND $columnDiscardedAt is null
    ''');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<Entry?> memoryFromLastYear() async {
    await _open();
    List<Map> result = await db.rawQuery('''
      SELECT *
      FROM $tableEntry
      WHERE strftime('%m-%d', $columnDate) = strftime('%m-%d', 'now')
      AND strftime('%Y', $columnDate) != strftime('%Y', 'now')
      AND $columnDiscardedAt is null
      ORDER BY RANDOM()
      LIMIT 1
    ''');

    if (result.isNotEmpty) {
      Entry ent = Entry.fromMap(result.first as Map<String, dynamic>);
      return ent;
    }
    return null;
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
          if (!entity.path.endsWith('.jpg') &&
              !entity.path.endsWith('.db') &&
              !entity.path.endsWith('.m4a')) {
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
    await _open();
    await db.close();

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
