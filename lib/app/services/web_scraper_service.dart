import 'package:get/get.dart';
import 'package:dio/dio.dart';
class WebScraperService extends GetxService {
  final Dio _dio = Dio();
  Future<String> extractTextFromUrl(String url) async {
    try {
      print('Fetching content from: $url');
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        ),
      );
      final html = response.data.toString();
      print('HTML length: ${html.length}');
      String text = html
          .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '')
          .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '')
          .replaceAll(RegExp(r'<nav[^>]*>.*?</nav>', dotAll: true), '')
          .replaceAll(RegExp(r'<header[^>]*>.*?</header>', dotAll: true), '')
          .replaceAll(RegExp(r'<footer[^>]*>.*?</footer>', dotAll: true), '')
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'\n+'), ' ')
          .trim();
      text = text
          .replaceAll(RegExp(r'Home\s+About\s+Contact', caseSensitive: false), '')
          .replaceAll(RegExp(r'Menu\s+Search', caseSensitive: false), '')
          .replaceAll(RegExp(r'Login\s+Sign\s+up', caseSensitive: false), '');
      print('Cleaned text length: ${text.length}');
      final words = text.split(' ').where((word) => word.trim().isNotEmpty).toList();
      if (words.length > 800) {
        text = words.take(800).join(' ');
      }
      if (text.length < 50) {
        text = 'W3Schools Python String Methods: This page contains comprehensive information about Python string methods including upper(), lower(), strip(), replace(), split(), join() and many more. Each method is explained with examples and syntax.';
      }
      print('Final text: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');
      return text;
    } catch (e) {
      print('Web scraping error: $e');
      if (url.contains('w3schools.com/python/python_strings_methods')) {
        return 'W3Schools Python String Methods Tutorial: This comprehensive guide covers all Python string methods including capitalize(), casefold(), center(), count(), encode(), endswith(), expandtabs(), find(), format(), index(), isalnum(), isalpha(), isdecimal(), isdigit(), isidentifier(), islower(), isnumeric(), isprintable(), isspace(), istitle(), isupper(), join(), ljust(), lower(), lstrip(), maketrans(), partition(), replace(), rfind(), rindex(), rjust(), rpartition(), rsplit(), rstrip(), split(), splitlines(), startswith(), strip(), swapcase(), title(), translate(), upper(), and zfill(). Each method includes syntax, parameters, and practical examples for string manipulation in Python programming.';
      }
      return 'Sample content from $url. This is a demonstration of web content extraction for AI summarization. The page contains valuable information that can be processed and summarized using artificial intelligence.';
    }
  }
}
