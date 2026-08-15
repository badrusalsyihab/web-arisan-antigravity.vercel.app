import 'dart:core';

void main() {
  final uri = Uri.parse('http://example.com/#/?joinCode=123');
  print(uri.queryParameters);
  print(uri.fragment);
  final fragmentUri = Uri.parse(uri.fragment);
  print(fragmentUri.queryParameters);
}
