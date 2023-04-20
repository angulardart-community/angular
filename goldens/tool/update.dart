import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as path;

const dartTool = '.dart_tool/build/generated/goldens';
const template = '$dartTool/test/**/*.template.dart';
const js = '$dartTool/test/**/*.js';

void main() {
  for (var entity in Glob(template).listSync()) {
    var relative = path.relative(entity.path, from: dartTool);
    entity.renameSync('$relative.golden');
  }

  for (var entity in Glob(js).listSync()) {
    var relative = path.relative(entity.path, from: dartTool);
    entity.renameSync(relative.replaceAll('.dart.js', '.js.golden'));
  }
}
