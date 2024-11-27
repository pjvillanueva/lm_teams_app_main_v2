import 'package:equatable/equatable.dart';
import 'dispensed_book_model.dart';

enum StatisticsDateRangeContext { day, week, month, year }

class StatisticsObject extends Equatable {
  const StatisticsObject({
    required this.ownerId,
    required this.date,
    required this.notes,
    required this.card,
    required this.coins,
    required this.books,
    required this.prayers,
    required this.contacts,
  });
  final String? ownerId;
  final DateTime date;
  final double notes;
  final double card;
  final double coins;
  final int prayers;
  final int contacts;
  final List<DispensedBook> books;

  @override
  List<Object?> get props => [ownerId, date, notes, card, coins, books, prayers, contacts];

  @override
  String toString() =>
      'StatisticsObject: ownerId: $ownerId, date: $date, notes: $notes, card: $card, coins, $coins, books, $books, prayers: $prayers, contacts: $contacts';

  Map<String, dynamic> toJson() => {
        'ownerId': ownerId,
        'date': date.toIso8601String(),
        'notes': notes,
        'card': card,
        'coins': coins,
        'books': books,
        'prayers': prayers,
        'contacts': contacts
      };

  StatisticsObject.fromJson(Map<String, dynamic> json)
      : ownerId = json['ownerId'],
        date = DateTime.parse(json['date']),
        notes = double.parse(json['notes'].toString()),
        card = double.parse(json['card'].toString()),
        coins = double.parse(json['coins'].toString()),
        books = json['books'] != null
            ? List.from(json['books'].map((t) => DispensedBook.fromJson(t)).toList())
            : [],
        prayers = json['prayers'],
        contacts = json['contacts'];

  double get incomeTotal {
    return notes + card + coins;
  }

  int get booksTotal {
    return books.length - dropdownsTotal;
  }

  int get dropdownsTotal {
    int dropdownCount = 0;
    var _allBooks = books;
    for (var book in _allBooks) {
      if (book.tags.contains('dropdown')) {
        dropdownCount++;
      }
    }
    return dropdownCount;
  }

  static StatisticsObject presentObj = StatisticsObject(
      ownerId: null,
      date: DateTime.now(),
      notes: 0.0,
      card: 0.0,
      coins: 0.0,
      books: const [],
      prayers: 0,
      contacts: 0);

  static StatisticsObject empty = StatisticsObject(
      ownerId: null,
      date: DateTime(2000, 1, 1),
      notes: 0.0,
      card: 0.0,
      coins: 0.0,
      books: const [],
      prayers: 0,
      contacts: 0);
}
