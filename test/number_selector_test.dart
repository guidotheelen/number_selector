import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_selector/number_selector.dart';

void main() {
  group('$NumberSelector', () {
    const min = 1;
    const max = 20;
    const start = 10;

    late Widget numberSelector;
    late int callbackCounter;
    late int callbackValue;

    setUp(() async {
      callbackCounter = 0;
      callbackValue = 0;
      numberSelector = MaterialApp(
        home: Material(
          child: NumberSelector(
            start: start,
            min: min,
            max: max,
            onNumberChange: (value) {
              callbackValue = value;
              callbackCounter++;
            },
          ),
        ),
      );
    });

    testWidgets('shows components', (tester) async {
      await tester.pumpWidget(numberSelector);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('$start'), findsNWidgets(2));
      expect(incrementFinder, findsOneWidget);
      expect(decrementFinder, findsOneWidget);
    });

    group('buttons', () {
      testWidgets('increment current number', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(incrementFinder);
        await tester.pump();

        expect(callbackCounter, 1);
        expect(callbackValue, start + 1);
      });

      testWidgets('decrement current number', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(decrementFinder);
        await tester.pump();

        expect(callbackCounter, 1);
        expect(callbackValue, start - 1);
      });

      testWidgets('do not exceed min when current is min', (tester) async {
        numberSelector = MaterialApp(
          home: Material(
            child: NumberSelector(
              start: min,
              onNumberChange: (value) {
                callbackValue = value;
                callbackCounter++;
              },
              min: min,
              max: max,
            ),
          ),
        );
        await tester.pumpWidget(numberSelector);

        await tester.tap(decrementFinder);
        await tester.pump();

        expect(callbackCounter, 0);
      });

      testWidgets('do not exceed max when current is max', (tester) async {
        numberSelector = MaterialApp(
          home: Material(
            child: NumberSelector(
              start: max,
              onNumberChange: (value) {
                callbackValue = value;
                callbackCounter++;
              },
              min: min,
              max: max,
            ),
          ),
        );
        await tester.pumpWidget(numberSelector);

        await tester.tap(incrementFinder);
        await tester.pump();

        expect(callbackCounter, 0);
      });
    });

    group('text field', () {
      testWidgets('updates current number by input', (tester) async {
        const input = 10;
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '$input');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(callbackCounter, 1);
        expect(callbackValue, input);
      });

      testWidgets('ignores empty input', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(callbackCounter, 0);
      });

      testWidgets('updates to max when input exceeds max', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '${max + 1}');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(callbackCounter, 1);
        expect(callbackValue, max);
      });

      testWidgets('updates to min when input exceeds min', (tester) async {
        await tester.pumpWidget(numberSelector);

        await tester.tap(inputFinder);
        await tester.enterText(inputFinder, '${min - 1}');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(callbackCounter, 1);
        expect(callbackValue, min);
      });
    });
  });
}

final inputFinder = find.byType(TextField);
final incrementFinder = find.byKey(const Key('Increment'));
final decrementFinder = find.byKey(const Key('Decrement'));
