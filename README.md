# NumberSelector [![Build Status](https://app.travis-ci.com/guidotheelen/number_selector.svg?branch=master)](guidotheelen/number_selector) [![Coverage Status](https://coveralls.io/repos/github/guidotheelen/number_selector/badge.svg?branch=master)](https://coveralls.io/github/guidotheelen/number_selector?branch=master)

 Customizable widget designed for choosing an integer number.

## Features

- Increment and decrement buttons
- Skip to first and last number buttons
- Cancel by pressing ESC
- Update by pressing Enter or loosing focus
- Negative and positive integers
- Tooltips for buttons

### Number selector with minimum and maximum value

![Number selector with min and max](images/picker.png)

### Simple number selector

![Simple number selector](images/picker2.png)

### Plain number selector

![Plain number selector](images/picker3.png)

## Usage

```dart
  NumberSelector(
    current: 47,
    min: 1,
    max: 50,
    onUpdate: (number) {
      // Your magic here
    },
  );

  NumberSelector.plain(
    current: 47,
    min: 1,
    max: 50,
    onUpdate: (number) {
      // More magic here
    },
  );
```
