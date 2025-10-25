import 'package:equatable/equatable.dart';

class SearchState extends Equatable {
  final bool isLoading;
  final List<Map<String, dynamic>> results;
  final String? error;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? results,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, results, error];
}
