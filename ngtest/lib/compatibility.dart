/// Additional API to be used when migrating existing code to `ngtest`.
///
/// It is **highly recommended** not to use this and only stick to
/// `ngtest.dart` for any new code or for new users of this package. APIs
/// may change at _any time_ without adhering strictly to sem-ver.
@experimental
library angular_test.compatibility;

import 'package:meta/meta.dart';

export 'src/frontend/fixture.dart' show injectFromFixture;
