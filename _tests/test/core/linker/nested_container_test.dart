import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';

import 'nested_container_test.template.dart' as ng;

void main() {
  test('should append after last root node of view container', () async {
    var testBed = NgTestBed<TestComponent>(ng.createTestComponentFactory());
    var testFixture = await testBed.create();
    expect(testFixture.text, '1');
    // Appending to the inner view container should work.
    await testFixture.update((component) {
      component.matrix[0].add(2); // Now [[1, 2]]
    });
    expect(testFixture.text, '12');
    // Appending to the outer view container should work.
    await testFixture.update((component) {
      component.matrix.add([3, 4]);
    });
    expect(testFixture.text, '1234');
  });
}

@Component(
  selector: 'test',
  template: r'''
    <ul>
      <ng-container *ngFor="let row of matrix">
        <li *ngFor="let cell of row">
          {{cell}}
        </li>
      </ng-container>
    </ul>
  ''',
  directives: [NgFor],
)
class TestComponent {
  var matrix = [
    [1],
  ];
}
