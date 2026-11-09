import 'package:equatable/equatable.dart';
import '../../../../core/enums/statistics_category.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatisticsRequested extends StatisticsEvent {
  const LoadStatisticsRequested();
}

class CategoryFilterChanged extends StatisticsEvent {
  final StatisticsCategory category;

  const CategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}
