import 'package:intl/intl.dart';

class Formatters {
  // Currency Formatter (Rupiah)
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  // Number Formatter
  static String number(int number) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number);
  }
  
  // Date Formatter
  static String date(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
  
  // DateTime Formatter
  static String dateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  // Time Formatter
  static String time(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  // Relative Time (e.g., "2 jam yang lalu")
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun yang lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
  
  // Format phone number
  static String phone(String phone) {
    if (phone.length < 10) return phone;
    return phone.replaceAllMapped(
      RegExp(r'(\d{4})(\d{4})(\d+)'),
      (Match m) => '${m[1]}-${m[2]}-${m[3]}',
    );
  }
}
