import 'package:_tests/compiler.dart';
import 'package:ngcompiler/v2/context.dart';
import 'package:test/test.dart';

void main() {
  CompileContext.overrideForTesting();

  test('should refuse to compile late final fields marked @Input()', () async {
    await compilesExpecting("""
      import '$ngImport';

      @Component(
        selector: 'example-comp',
        template: '',
      )
      class ExampleComp {
        @Input()
        late final String name;
      }
    """, errors: [
      contains('Inputs cannot be "late final"'),
    ]);
  });

  test('should refuse to compile non-nullable single child query', () async {
    await compilesExpecting("""
      import 'package:web/web.dart';
      import '$ngImport';

      @Component(
        selector: 'example-comp',
        template: '<div></div>',
      )
      class ExampleComp {
        @ViewChild('div')
        set div(Element div) {}
      }
    """, errors: [
      contains('queries must be nullable'),
    ]);
  });

  test('should refuse to compile late fields with a child query', () async {
    await compilesExpecting("""
      import 'package:web/web.dart';
      import '$ngImport';

      @Component(
        selector: 'example-comp',
        template: '<div></div>',
      )
      class ExampleComp {
        @ViewChild('div')
        late Element? div;
      }
    """, errors: [
      contains('View and content queries cannot be "late"'),
    ]);
  });

  test('should refuse to compile late fields with a children query', () async {
    await compilesExpecting("""
      import 'package:web/web.dart';
      import '$ngImport';

      @Component(
        selector: 'example-comp',
        template: '<div></div>',
      )
      class ExampleComp {
        @ViewChildren('div')
        late List<Element> div;
      }
    """, errors: [
      contains('View and content queries cannot be "late"'),
    ]);
  });

  test('should compile non-nullable fields with a children query', () async {
    await compilesNormally("""
      import 'package:web/web.dart';
      import '$ngImport';

      @Component(
        selector: 'example-comp',
        template: '<div></div>',
      )
      class ExampleComp {
        @ViewChildren('div')
        set divs(List<Element> divs) {}
      }
    """);
  });
}
