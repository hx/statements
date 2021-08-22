# Statements

Builds a database of bank account transaction history by reading PDF bank statements, and provides a simple web interface for browsing data.

## Installation

```bash
$ gem install statements
```

## Dependencies

- [`pdftotext`](http://www.foolabs.com/xpdf/download.html) for readying PDF statements.

## Usage

1. `cd` to a directory containing all your bank statements.
2. Run `statements` and wait for new statements to be parsed.
3. Open `http://localhost:57473` in a browser.

## Supported banks

- St. George Credit Cards
- St. George Cash Accounts

The list is small. Want it to grow? Send a pull request!
