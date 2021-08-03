import 'dart:io';

void main() {
  File file = File('/home/gspencer/code/process.dart/test_file');
  FileStat stat = file.statSync();
  print("Exists: ${file.existsSync()}");
  print("Mode: 0x${stat.mode.toRadixString(16)} (0${stat.mode.toRadixString(8)})");
  print("Is executable: ${stat.mode & 0x40 != 0 ? 'YES' : 'NO'} (${stat.mode & 0x40})");
}
