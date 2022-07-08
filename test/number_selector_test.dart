import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_selector/number_selector.dart';

void main() {
  group('$NumberSelector', () {
    const min = 1;
    const max = 20;
    const current = 10;

    late Widget numberSelector;
    late int updateCounter;
    late int updateValue;

    setUp(() async {
      updateCounter = 0;
      updateValue = 0;
      numberSelector = MaterialApp(
        home: Material(
          child: NumberSelector(
            current: current,
            min: min,
            max: max,
            onUpdate: (value) {
              updateValue = value;
              updateCounter++;
            },
          ),
        ),
      );
    });

    testWidgets('shows components', (tester) async {
      await tester.pumpWidget(numberSelector);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('$current'), findsNWidgets(2));
      expect(incrementFinder, findsOneWidget);
      expect(decrementFinder, findsOneWidget);
    });

    group('buttons', () {
      testWidgets('increment current number', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(incrementFinder);
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, current + 1);
      });

      testWidgets('decrement current number', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(decrementFinder);
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, current - 1);
      });

      testWidgets('turn current number into max', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(maxFinder);
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, max);
      });

      testWidgets('turn current number into min', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(minFinder);
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, min);
      });

      testWidgets('do not exceed min when current is min', (tester) async {
        numberSelector = MaterialApp(
          home: Material(
            child: NumberSelector(
              current: min,
              onUpdate: (value) {
                updateValue = value;
                updateCounter++;
              },
              min: min,
              max: max,
            ),
          ),
        );
        await tester.pumpWidget(numberSelector);

        await tester.tap(decrementFinder);
        await tester.tap(minFinder);
        await tester.pump();

        expect(updateCounter, 0);
      });

      testWidgets('do not exceed max when current is max', (tester) async {
        numberSelector = MaterialApp(
          home: Material(
            child: NumberSelector(
              current: max,
              onUpdate: (value) {
                updateValue = value;
                updateCounter++;
              },
              min: min,
              max: max,
            ),
          ),
        );
        await tester.pumpWidget(numberSelector);

        await tester.tap(incrementFinder);
        await tester.tap(maxFinder);
        await tester.pump();

        expect(updateCounter, 0);
      });

      testWidgets('do not show min/max if not set', (tester) async {
        numberSelector = const MaterialApp(
          home: Material(
            child: NumberSelector(
              current: current,
            ),
          ),
        );
        await tester.pumpWidget(numberSelector);

        expect(maxFinder, findsNothing);
        expect(minFinder, findsNothing);
      });

      testWidgets('do not show min/max if turned off', (tester) async {
        numberSelector = const MaterialApp(
          home: Material(
            child: NumberSelector(
              current: current,
              max: 200,
              min: 0,
              showMinMax: false,
            ),
          ),
        );
        await tester.pumpWidget(numberSelector);

        expect(maxFinder, findsNothing);
        expect(minFinder, findsNothing);
      });
    });

    group('text field', () {
      testWidgets('updates on Enter', (tester) async {
        const input = 15;
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '$input');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, input);
      });

      testWidgets('updates on losing focus', (tester) async {
        const input = 15;
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '$input');
        FocusManager.instance.primaryFocus!.unfocus();
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, input);
      });

      testWidgets('ignores similar input', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '$current');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(updateCounter, 0);
      });

      testWidgets('ignores empty input', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(updateCounter, 0);
      });

      testWidgets('click decrement with empty input', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '');
        await tester.tap(decrementFinder);
        await tester.pump();

        expect(updateCounter, 1);
        expect(find.text('${current - 1}'), findsNWidgets(2));
      });

      testWidgets('click increment with empty input', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '');
        await tester.tap(incrementFinder);
        await tester.pump();

        expect(updateCounter, 1);
        expect(find.text('${current + 1}'), findsNWidgets(2));
      });

      testWidgets('resets on ESC', (tester) async {
        const input = 15;
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '$input');
        await simulateKeyDownEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(updateCounter, 0);
        expect(find.text('$current'), findsNWidgets(2));
      });

      testWidgets('resets on ESC when input is empty', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '');
        await simulateKeyDownEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(updateCounter, 0);
        expect(find.text('$current'), findsNWidgets(2));
      });

      testWidgets('updates to max when input exceeds max', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '${max + 1}');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, max);
      });

      testWidgets('updates to min when input exceeds min', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '${min - 1}');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(updateCounter, 1);
        expect(updateValue, min);
      });

      testWidgets('does not accept letters', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, 'a');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(updateCounter, 0);
        expect(find.text('$current'), findsNWidgets(2));
      });
    });
  });
}

final inputFinder = find.byType(TextField);
final incrementFinder = find.byKey(const Key('Increment'));
final decrementFinder = find.byKey(const Key('Decrement'));
final maxFinder = find.byKey(const Key('Max'));
final minFinder = find.byKey(const Key('Min'));
