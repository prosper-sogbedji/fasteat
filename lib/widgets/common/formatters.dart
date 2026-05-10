String fcfa(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    b.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      b.write(' ');
    }
  }
  return '${b.toString()} FCFA';
}
