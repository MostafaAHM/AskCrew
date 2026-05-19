import 'package:aflam/core/models/movie_model.dart';
import 'enterprise_profile_model.dart';
import 'performance_metric_model.dart';
import 'talent_model.dart';
import 'workshop_model.dart';

class EnterpriseDummyData {
  static EnterpriseProfileModel get dummyProfile => EnterpriseProfileModel(
    id: '1',
    name: 'Abdelrahman Ahmed',
    profession: 'Actor',
    profileImage: 'https://via.placeholder.com/150',
    isVerified: true,
    waterMark: true,
    rating: 4.2,
    reviewsCount: 20,
    isAvailable: true,
  );

  static List<PerformanceMetricModel> get dummyMetrics => [
    PerformanceMetricModel(
      id: '1',
      type: 'views',
      label: 'Views',
      value: '230.40',
    ),
    PerformanceMetricModel(
      id: '2',
      type: 'bookings',
      label: 'Bookings',
      value: '340',
    ),
    PerformanceMetricModel(
      id: '3',
      type: 'topWork',
      label: 'Top Work',
      value: '120.560',
      topWorkTitle: 'The Conjuring',
    ),
  ];

  static List<WorkshopModel> get dummyWorkshops => [
    WorkshopModel(
      id: '1',
      title: 'Acting Workshop',
      instructor: 'Mohamed Sobhy',
      date: DateTime(2024, 10, 12),
      imageUrl: 'https://via.placeholder.com/300x200',
    ),
    WorkshopModel(
      id: '2',
      title: 'Singing Workshop',
      instructor: 'Mohamed Monir',
      date: DateTime(2024, 10, 30),
      imageUrl: 'https://via.placeholder.com/300x200',
    ),
  ];

  static List<MovieModel> get dummyForRent => [
    MovieModel(
      id: '1',
      title: 'Siko Siko',
      posterUrl: 'https://via.placeholder.com/200x300',
      releaseDate: DateTime(2025, 4, 24),
      rating: 4.9,
    ),
    MovieModel(
      id: '2',
      title: 'Respin',
      posterUrl: 'https://via.placeholder.com/200x300',
      releaseDate: DateTime(2024, 3, 21),
      rating: 4.5,
    ),
    MovieModel(
      id: '3',
      title: 'The Conjuring',
      posterUrl: 'https://via.placeholder.com/200x300',
      releaseDate: DateTime(2023, 6, 15),
      rating: 4.8,
    ),
  ];

  static List<TalentModel> get dummyTalents => [
    TalentModel(
      id: '1',
      name: 'Ali Mohamed',
      role: 'Actor',
      imageUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    TalentModel(
      id: '2',
      name: 'Ali Mohamed',
      role: 'Actor',
      imageUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    TalentModel(
      id: '3',
      name: 'Ali Mohamed',
      role: 'Actor',
      imageUrl: 'https://i.pravatar.cc/150?img=3',
    ),
  ];

  static List<TalentModel> get dummyStudents => [
    TalentModel(
      id: '1',
      name: 'Ali Mohamed',
      role: 'Actor',
      imageUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    TalentModel(
      id: '2',
      name: 'Ali Mohamed',
      role: 'Actor',
      imageUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    TalentModel(
      id: '3',
      name: 'Ali Mohamed',
      role: 'Actor',
      imageUrl: 'https://i.pravatar.cc/150?img=6',
    ),
  ];
}
