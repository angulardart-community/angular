@TestOn('browser')

import 'package:ngtest/angular_test.dart';
import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngdart/security.dart';

import 'safe_inner_html_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  group('$SafeInnerHtmlDirective', () {
    test('normally, "innerHtml" should be sanitized', () async {
      final testBed = NgTestBed(ng.createNormalInnerHtmlTestFactory());
      final testRoot = await testBed.create();
      expect(testRoot.text, contains('(Secure)'));
    });

    test('"safeInnerHtml" should be trusted', () async {
      final testBed = NgTestBed(ng.createTrustedSafeInnerHtmlTestFactory());
      final testRoot = await testBed.create();
      // TODO(GZGavinZhao): this shouldn't be needed...
      await testRoot.update();
      expect(testRoot.text, contains('(Unsafe)'));
    });

    test('"innerHtml" should be trusted', () async {
      final testBed = NgTestBed(ng.createTrustedInnerHtmlTestFactory());
      final testRoot = await testBed.create();
      expect(testRoot.text, contains('(Unsafe)'));
    });

    test('normally, interpolated innerHtml should be sanitized', () async {
      final testBed =
          NgTestBed(ng.createInterpolatedNormalInnerHtmlTestFactory());
      final testRoot = await testBed.create();
      expect(testRoot.text, contains('(Secure)'));
    });

    // TODO(GZGavinZhao): note to self: interpolation messed things up.
    // [interpolate0] converts anything to a String, which causes sanitizeHtml
    // unable to detect whether the passed HTML should be trusted...
    test('SafeHtml should be passed through interpolation', () async {
      final testBed =
          NgTestBed(ng.createInterpolatedTrustedInnerHtmlTestFactory());
      final testRoot = await testBed.create();
      print(testRoot.rootElement.innerHtml);
      await testRoot.update();
      print(testRoot.rootElement.innerHtml);
      expect(testRoot.text, contains('(Unsafe)'));
    },
        skip:
            'TODO(GZGavinZhao): interpolate0 converts anything to string, which messed up sanitizeHTML');

    test('unsafe HTML should throw', () async {
      final testBed = NgTestBed(ng.createUntrustedInnerHtmlTestFactory());
      expect(testBed.create(), throwsA(isUnsupportedError));
    });
  });
}

// <script> tags are inert in innerHTML: https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML#Security_considerations
// placeholder from //gws/suite/img/img_test.js
const String dangerousHtml = '''
  <img src='data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
       onload="document.querySelector('.other-element').innerText = 'Unsafe'">
   </img>
''';

@Component(
  selector: 'test',
  template: r'''
       (<span class="other-element">Secure</span>)
       <div [innerHtml]="trustedHtml"></div>
    ''',
)
class NormalInnerHtmlTest {
  String get trustedHtml => dangerousHtml;
}

@Component(
  selector: 'test',
  directives: [SafeInnerHtmlDirective],
  providers: [ClassProvider(DomSanitizationService)],
  template: r'''
       (<span class="other-element">Secure</span>)
       <div [safeInnerHtml]="trustedHtml"></div>
    ''',
)
class TrustedSafeInnerHtmlTest {
  /// Value will be bound directly to the DOM.
  final SafeHtml trustedHtml;

  TrustedSafeInnerHtmlTest(DomSanitizationService domSecurityService)
      : trustedHtml = domSecurityService.bypassSecurityTrustHtml(dangerousHtml);
}

@Component(
  selector: 'test',
  template: r'''
       (<span class="other-element">Secure</span>)
       <div [innerHtml]="trustedHtml"></div>
    ''',
  providers: [ClassProvider(DomSanitizationService)],
)
class TrustedInnerHtmlTest {
  /// Value will be bound directly to the DOM.
  final SafeHtml trustedHtml;

  TrustedInnerHtmlTest(DomSanitizationService domSecurityService)
      : trustedHtml = domSecurityService.bypassSecurityTrustHtml(dangerousHtml);
}

@Component(
  selector: 'test',
  template: r'''
       (<span class="other-element">Secure</span>)
       <div innerHtml="{{trustedHtml}}"></div>
    ''',
)
class InterpolatedNormalInnerHtmlTest {
  final String trustedHtml = dangerousHtml;
}

@Component(
  selector: 'test',
  template: r'''
       (<span class="other-element">Secure</span>)
       <div innerHtml="{{trustedHtml}}"></div>
    ''',
  providers: [ClassProvider(DomSanitizationService)],
)
class InterpolatedTrustedInnerHtmlTest {
  // Value will be passed through interpolate0 and then passed through the
  // HTML sanitizer.
  final SafeHtml trustedHtml;

  InterpolatedTrustedInnerHtmlTest(DomSanitizationService domSecurityService)
      : trustedHtml = domSecurityService.bypassSecurityTrustHtml(dangerousHtml);
}

@Component(
  selector: 'test',
  directives: [SafeInnerHtmlDirective],
  template: r'''
    <div [safeInnerHtml]="untrustedHtml"></div>
  ''',
)
class UntrustedInnerHtmlTest {
  String untrustedHtml = '<script>Bad thing</script>';
}
