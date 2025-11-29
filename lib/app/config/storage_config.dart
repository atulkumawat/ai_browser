enum StorageType { hive, sqlite }
class StorageConfig {
  static const StorageType defaultStorage = StorageType.hive;
  static bool get useHive => defaultStorage == StorageType.hive;
  static bool get useSQLite => defaultStorage == StorageType.sqlite;
}
