import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import 'ng_control_group_test.template.dart' as ng;

void main() {
  group('NgControlGroup', () {
    late NgTestFixture<NgControlGroupTest> fixture;

    tearDown(() => disposeAnyRunningTest());

    setUp(() async {
      var testBed =
          NgTestBed<NgControlGroupTest>(ng.createNgControlGroupTestFactory());
      fixture = await testBed.create();
    });

    test('should reexport control properties', () async {
      await fixture.update((cmp) {
        var controlGroup = cmp.controlGroup!;
        expect(controlGroup.control, cmp.groupModel);
        expect(controlGroup.value, cmp.groupModel.value);
        expect(controlGroup.valid, cmp.groupModel.valid);
        expect(controlGroup.errors, cmp.groupModel.errors);
        expect(controlGroup.pristine, cmp.groupModel.pristine);
        expect(controlGroup.dirty, cmp.groupModel.dirty);
        expect(controlGroup.touched, cmp.groupModel.touched);
        expect(controlGroup.untouched, cmp.groupModel.untouched);
      });
    });

    test('should disable child controls', () async {
      await fixture.update((cmp) {
        cmp.disabled = true;
      });
      expect(fixture.assertOnlyInstance.inputElement!.disabled, true);
      await fixture.update((cmp) {
        cmp.disabled = false;
      });
      expect(fixture.assertOnlyInstance.inputElement!.disabled, false);
    });
  });
}

@Component(
  selector: 'ng-control-group-test',
  directives: [
    formDirectives,
    NgIf,
  ],
  template: '''
<div [ngFormModel]="formModel">
  <div [ngControlGroup]="'group'" #controlGroup="ngForm" [ngDisabled]="disabled">
    <input [ngControl]="'login'" #input />
  </div>
</div>
''',
)
class NgControlGroupTest {
  @ViewChild('controlGroup')
  NgControlGroup? controlGroup;

  @ViewChild('input')
  HTMLInputElement? inputElement;

  bool disabled = false;

  ControlGroup formModel = FormBuilder.controlGroup({
    'group': FormBuilder.controlGroup({'login': Control(null)})
  });

  ControlGroup get groupModel => formModel.controls['group'] as ControlGroup;
}
