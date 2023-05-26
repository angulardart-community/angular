A destination for golden file testing.

TIP: Need to update all of the tests? Run:

```shell
$ dart run build_runner build -r
$ dart run tool/update.dart
```

Currently when adding a new `a.dart` file, you must add a sibling
`a.template.dart.golden` and `a.js.golden` file.
