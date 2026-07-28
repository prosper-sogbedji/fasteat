import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('api-1.json');
  final content = await file.readAsString();
  final data = jsonDecode(content);
  
  void search(List items) {
    for (var item in items) {
      if (item['item'] != null) {
        search(item['item']);
      } else if (item['request'] != null) {
        final url = item['request']['url'];
        final urlString = url is Map ? url['raw'] : url.toString();
        if (urlString != null && urlString.contains('login')) {
          print('Found login: ' + item['name'].toString());
          if (item['request']['body'] != null) {
            print('Request body: ' + item['request']['body']['raw'].toString());
          }
        }
      }
    }
  }
  
  if (data['item'] != null) {
    search(data['item']);
  }
}
