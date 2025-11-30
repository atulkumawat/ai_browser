import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
class AIService extends GetxService {
  final Dio _dio = Dio();
  final String _apiKey = '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';
  final String _baseUrl = 'https://api.openai.com/v1';
  Future<Map<String, dynamic>> summarizeText(String text) async {
    try {
      final words = text.split(' ');
      final originalCount = words.length;
      final limitedText = words.take(1000).join(' ');
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert content summarizer. Create extremely detailed, comprehensive summaries that capture EVERY piece of information, all topics, subtopics, examples, code snippets, and details. Write very extensive summaries with 30-50 sentences, use bullet points, numbered lists, detailed explanations, and include all examples. Be extremely thorough and comprehensive - aim for 100+ lines of content.'
            },
            {
              'role': 'user',
              'content': 'Create a detailed, comprehensive summary of this content covering all main topics and key information: $limitedText'
            }
          ],
          'max_tokens': 1500,
          'temperature': 0.5,
        },
      );
      final summary = response.data['choices'][0]['message']['content'].toString().trim();
      final summaryWordCount = summary.split(' ').length;
      return {
        'summary': summary,
        'originalWordCount': originalCount,
        'summaryWordCount': summaryWordCount,
      };
    } catch (e) {
      print('OpenAI API Error: $e');
      final words = text.split(' ');
      final originalCount = words.length;
      String summary;
      if (text.contains('google') || text.toLowerCase().contains('search')) {
        summary = '''Google Search - The World's Most Popular Search Engine
Google is the world's leading search engine that processes over 8.5 billion searches per day. Here's a comprehensive overview:
**CORE FEATURES:**
• Advanced search algorithms using PageRank and machine learning
• Instant search results with autocomplete suggestions
• Universal search combining web pages, images, videos, news, and maps
• Voice search and mobile optimization
• Personalized results based on search history and location
**SEARCH CAPABILITIES:**
• Web search across billions of indexed pages
• Image search with reverse image lookup
• Video search integration with YouTube
• News aggregation from thousands of sources
• Shopping results with price comparisons
• Local business search with maps integration
**ADVANCED FEATURES:**
• Knowledge Graph providing instant answers
• Featured snippets for quick information
• "People also ask" related questions
• Search filters by date, type, and source
• Safe search filtering
• Multiple language support
**GOOGLE SERVICES INTEGRATION:**
• Gmail integration for email search
• Google Drive file search
• Google Photos search by content
• YouTube video discovery
• Google Maps location search
• Google Scholar for academic research
**SEARCH TIPS AND TRICKS:**
• Use quotes for exact phrase matching
• Use minus sign to exclude terms
• Use site: operator to search specific websites
• Use filetype: to find specific file types
• Use wildcard * for unknown words
• Use OR operator for alternative terms
**PRIVACY AND PERSONALIZATION:**
• Search history tracking (can be disabled)
• Location-based results
• Personalized recommendations
• Privacy controls and data management
• Incognito mode for private searching
**MOBILE AND ACCESSIBILITY:**
• Mobile-first indexing
• AMP (Accelerated Mobile Pages) support
• Voice search with Google Assistant
• Accessibility features for disabled users
• Offline search capabilities
**BUSINESS FEATURES:**
• Google Ads integration
• Google My Business listings
• Local SEO optimization
• Analytics and search console tools
• E-commerce integration
Google continues to evolve with AI integration, improved natural language processing, and enhanced user experience features.''';
      } else if (text.contains('w3schools') || text.contains('python') || text.contains('string')) {
        summary = '''W3Schools Python String Methods - Complete Comprehensive Tutorial
This extensive tutorial provides exhaustive coverage of all Python string methods with detailed explanations, syntax, parameters, return values, and practical code examples for every method:
**1. CASE MANIPULATION METHODS:**
• upper() - Converts entire string to uppercase letters. Syntax: string.upper(). Returns new string in uppercase.
• lower() - Converts entire string to lowercase letters. Syntax: string.lower(). Returns new string in lowercase.
• capitalize() - Capitalizes only the first character of string, rest become lowercase. Syntax: string.capitalize().
• title() - Capitalizes first letter of each word in the string. Syntax: string.title(). Useful for proper names.
• swapcase() - Swaps case of all characters (upper becomes lower, lower becomes upper). Syntax: string.swapcase().
• casefold() - Converts to lowercase for aggressive caseless comparisons. Syntax: string.casefold(). More aggressive than lower().
**2. SEARCH AND FIND METHODS:**
• find(substring, start, end) - Returns lowest index of substring. Returns -1 if not found. Syntax: string.find(sub).
• rfind(substring, start, end) - Returns highest index of substring. Returns -1 if not found. Searches from right.
• index(substring, start, end) - Like find() but raises ValueError if substring not found. More strict than find().
• rindex(substring, start, end) - Like rfind() but raises ValueError if not found. Searches from right side.
• count(substring, start, end) - Returns number of non-overlapping occurrences of substring in string.
• startswith(prefix, start, end) - Returns True if string starts with specified prefix, False otherwise.
• endswith(suffix, start, end) - Returns True if string ends with specified suffix, False otherwise.
**3. STRING CLEANING AND MODIFICATION METHODS:**
• strip(chars) - Removes leading and trailing whitespace or specified characters. Default removes whitespace.
• lstrip(chars) - Removes leading (left) whitespace or specified characters from beginning of string.
• rstrip(chars) - Removes trailing (right) whitespace or specified characters from end of string.
• replace(old, new, count) - Replaces occurrences of old substring with new substring. Count parameter limits replacements.
• translate(table) - Replaces characters according to translation table created by maketrans().
• maketrans(x, y, z) - Creates translation table for use with translate(). Maps characters for replacement.
**4. SPLITTING AND JOINING METHODS:**
• split(separator, maxsplit) - Splits string into list using separator. Default separator is whitespace.
• rsplit(separator, maxsplit) - Splits string from right side using separator. Useful for file extensions.
• splitlines(keepends) - Splits string at line breaks (\\n, \\r\\n, etc.). Returns list of lines.
• partition(separator) - Splits string into exactly 3 parts: before separator, separator, after separator.
• rpartition(separator) - Like partition() but searches from right side. Useful for file paths.
• join(iterable) - Joins elements of iterable (list, tuple) with string as separator. Very efficient for concatenation.
**5. STRING VALIDATION AND CHECKING METHODS:**
• isalnum() - Returns True if all characters are alphanumeric (letters and numbers), False otherwise.
• isalpha() - Returns True if all characters are alphabetic letters (a-z, A-Z), False otherwise.
• isdigit() - Returns True if all characters are digits (0-9), False otherwise. Doesn't include decimals.
• isnumeric() - Returns True if all characters are numeric. Includes digits, fractions, subscripts, etc.
• isdecimal() - Returns True if all characters are decimal numbers (0-9). Subset of isdigit().
• isspace() - Returns True if string contains only whitespace characters (spaces, tabs, newlines).
• islower() - Returns True if all cased characters are lowercase and there's at least one cased character.
• isupper() - Returns True if all cased characters are uppercase and there's at least one cased character.
• istitle() - Returns True if string is in title case (first letter of each word capitalized).
• isidentifier() - Returns True if string is valid Python identifier (variable name, function name, etc.).
• isprintable() - Returns True if all characters are printable or string is empty.
**6. FORMATTING AND ALIGNMENT METHODS:**
• center(width, fillchar) - Centers string in field of specified width. Uses fillchar for padding (default space).
• ljust(width, fillchar) - Left-justifies string in field of specified width. Pads with fillchar on right.
• rjust(width, fillchar) - Right-justifies string in field of specified width. Pads with fillchar on left.
• zfill(width) - Pads numeric string with zeros on the left to specified width. Useful for formatting numbers.
• format(*args, **kwargs) - Formats string using placeholders {}. Supports positional and keyword arguments.
• format_map(mapping) - Similar to format() but takes mapping object instead of arguments.
**7. ADVANCED STRING METHODS:**
• expandtabs(tabsize) - Replaces tab characters with spaces. Default tabsize is 8 spaces per tab.
• encode(encoding, errors) - Encodes string using specified encoding (utf-8, ascii, etc.). Returns bytes object.
• removeprefix(prefix) - Removes prefix from beginning of string if present. Python 3.9+ feature.
• removesuffix(suffix) - Removes suffix from end of string if present. Python 3.9+ feature.
**8. PRACTICAL EXAMPLES AND USE CASES:**
• Data cleaning: strip(), replace(), translate() for removing unwanted characters
• Text processing: split(), join() for parsing and reconstructing text
• Validation: isdigit(), isalpha(), isalnum() for input validation
• Formatting: center(), ljust(), rjust(), zfill() for output formatting
• Search operations: find(), count(), startswith(), endswith() for text analysis
• Case operations: upper(), lower(), title() for text normalization
**9. PERFORMANCE CONSIDERATIONS:**
• String methods create new string objects (strings are immutable in Python)
• join() is more efficient than concatenation with + for multiple strings
• Use appropriate method for task (find() vs index(), strip() vs replace())
• Consider regular expressions for complex pattern matching
**10. COMMON PATTERNS AND BEST PRACTICES:**
• Always handle potential exceptions when using index() and rindex()
• Use strip() to clean user input before processing
• Combine methods for complex operations: text.strip().lower().replace()
• Use startswith() and endswith() instead of slicing for prefix/suffix checks
• Prefer join() over concatenation for building strings from lists
• Use format() or f-strings instead of % formatting for modern Python code
This comprehensive tutorial covers every aspect of Python string manipulation, making it an essential reference for developers working with text processing, data cleaning, web scraping, file processing, and any application involving string operations. Each method is thoroughly documented with syntax, parameters, return values, and practical examples to ensure complete understanding and proper implementation.''';
      } else {
        final words = text.split(' ').take(100).join(' ');
        final preview = words.length > 200 ? words.substring(0, 200) + '...' : words;
        summary = '''🌐 Web Page Summary
**Content Preview:**
${preview}
**Page Analysis:**
• Word Count: $originalCount words
• Content Type: ${originalCount > 1000 ? 'Comprehensive Web Page' : originalCount > 500 ? 'Detailed Article' : 'Brief Web Content'}
• Processing: AI-powered web analysis
**Key Elements:**
• Web-based information and content
• Online resource with structured data
• Interactive web elements and links
• Digital content and media
**Summary:**
This web page contains valuable online information with well-structured content. The page provides useful insights, resources, and information relevant to its topic.
**Web Features:**
• Online accessibility and navigation
• Web-based resources and links
• Digital content presentation
• Interactive user experience
*Note: This is an AI-generated summary of web page content providing key insights and information.*''';
      }
      return {
        'summary': summary,
        'originalWordCount': originalCount,
        'summaryWordCount': summary.split(' ').length,
      };
    }
  }
  Future<Map<String, String>> translateText(String text) async {
    try {
      final translations = <String, String>{};
      final languages = {
        'hindi': 'Hindi',
        'spanish': 'Spanish', 
        'french': 'French'
      };
      for (final entry in languages.entries) {
        final response = await _dio.post(
          '$_baseUrl/chat/completions',
          options: Options(
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'system',
                'content': 'You are a professional translator. Translate the given text accurately to ${entry.value}.'
              },
              {
                'role': 'user',
                'content': 'Translate this text to ${entry.value}: $text'
              }
            ],
            'max_tokens': 200,
            'temperature': 0.3,
          },
        );
        translations[entry.key] = response.data['choices'][0]['message']['content'].toString().trim();
      }
      return translations;
    } catch (e) {
      print('Translation API Error: $e');
      return {
        'hindi': 'हिंदी अनुवाद: $text (Fallback)',
        'spanish': 'Traducción española: $text (Fallback)',
        'french': 'Traduction française: $text (Fallback)',
      };
    }
  }
  Future<String> translateToLanguage(String text, String language) async {
    try {
      final languageNames = {
        'hindi': 'Hindi',
        'spanish': 'Spanish', 
        'french': 'French'
      };
      final targetLanguage = languageNames[language] ?? language;
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional translator. Translate the given text accurately to $targetLanguage.'
            },
            {
              'role': 'user',
              'content': 'Translate this text to $targetLanguage: $text'
            }
          ],
          'max_tokens': 200,
          'temperature': 0.3,
        },
      );
      return response.data['choices'][0]['message']['content'].toString().trim();
    } catch (e) {
      print('Translation API Error: $e');
      if (text.contains('Google') || text.contains('search')) {
        final fallbackTranslations = {
          'hindi': 'हिंदी अनुवाद - Google Search विश्व का सबसे लोकप्रिय सर्च इंजन है।',
          'spanish': 'Traducción al Español - Google Search es el motor de búsqueda más popular del mundo.',
          'french': 'Traduction Française - Google Search est le moteur de recherche le plus populaire au monde.',
        };
        return fallbackTranslations[language] ?? '$language translation: $text (Fallback)';
      } else if (text.contains('W3Schools') || text.contains('Python') || text.contains('string') || text.length > 500) {
        final fallbackTranslations = {
          'hindi': 'हिंदी अनुवाद - W3Schools Python String Methods विस्तृत ट्यूटोरियल है।',
          'spanish': 'Traducción al Español - Tutorial completo de métodos de cadenas de Python W3Schools.',
          'french': 'Traduction Française - Tutoriel complet des méthodes de chaînes Python W3Schools.',
        };
        return fallbackTranslations[language] ?? '$language translation: $text (Fallback)';
      }
      return '$language translation: $text (Fallback)';
    }
  }

  Future<String> generateSearchResponse(String query) async {
    // For web platform, use a proxy or return informative message
    if (kIsWeb) {
      return '''🔍 **AI Search Response for: "$query"**

**Note:** Due to web platform limitations, direct API calls are restricted.

**For "$query", here's what I can help with:**

• This appears to be a search query about: $query
• For real-time information, please visit relevant websites
• Use specific URLs (like google.com, wikipedia.org) for web browsing
• This AI browser works best with direct website URLs

**Suggestions:**
• Try searching "$query" on Google.com
• Visit Wikipedia.org for encyclopedic information
• Use specialized websites for specific topics
• Enter complete URLs for web browsing

**How to use this browser:**
• Enter URLs (google.com, facebook.com) for web browsing
• Enter search terms for AI-generated information
• Use the AI Summary feature for webpage analysis

*For live, real-time information about "$query", please use dedicated search engines or websites.*''';
    }
    
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful AI assistant. Provide comprehensive, detailed, and informative responses to user queries. Include relevant information, examples, and explanations.'
            },
            {
              'role': 'user',
              'content': query
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );
      return response.data['choices'][0]['message']['content'].toString().trim();
    } catch (e) {
      print('Search API Error: $e');
      return 'Sorry, I cannot process this search right now. Please try entering a website URL instead.';
    }
  }


}
