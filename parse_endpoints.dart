1import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('api-1.json');
  if (!await file.exists()) {
    print('api-1.json not found');
    return;
  }
  final content = await file.readAsString();
  final data = jsonDecode(content);
  
  Set<String> urls = {};

  void search(List items) {
    for (var item in items) {
      if (item['item'] != null) {
        search(item['item']);
      } else if (item['request'] != null) {
        final url = item['request']['url'];
        String? urlString;
        if (url is Map && url['raw'] != null) {
          urlString = url['raw'].toString();
        } else if (url is String) {
          urlString = url;
        }
        if (urlString != null) {
          urls.add(item['request']['method'] + ' ' + urlString);
        }
      }
    }
  }
  
  if (data['item'] != null) {
    search(data['item']);
  }
  
  for (final u in urls) {
    print(u);
  }
}
