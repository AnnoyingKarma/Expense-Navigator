class Expense {
  int? id;          // Unique ID in database (auto-incremented)
  String title;     // Short description, like "Groceries"
  double amount;    // How much money spent
  String category;  // Category, like "Food" or "Transport"
  DateTime date;    // Date when expense happened

  // Constructor
  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  // Convert Expense object into Map (to save in SQLite database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),  // Store date as String
    };
  }

  // Create Expense object from Map (when reading from SQLite database)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}
