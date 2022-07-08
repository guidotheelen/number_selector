# NumberSelector [![Build Status](https://app.travis-ci.com/guidotheelen/number_selector.svg?branch=master)](guidotheelen/number_selector) [![Coverage Status](https://coveralls.io/repos/github/guidotheelen/number_selector/badge.svg?branch=master)](https://coveralls.io/github/guidotheelen/number_selector?branch=master)

 Customizable widget designed for choosing an integer number by buttons or TextField.

## Features

- Increment and decrement buttons
- Skip to first and last page buttons
- Number TextField with safe parser

### Number selector with minimum and maximum value

![Number selector with min and max](images/picker.png)

### simple number selector

![Simple number selector](images/picker2.png)


## Usage

```dart
    NumberSelector(
      current: 1,
      min: 1,
      max: 20,
      onUpdate: (number) {
        // Your magic here
      },
    ),
```
