class Routes {
  // ================== Core / Splash & Auth ==================
  static const String splashScreen = '/';
  static const String moduleSelection = '/module-selection';

  // Auth Flow
  static const String welcomeScreen = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String registerEnterprise = '/register-enterprise';
  static const String registerStudent = '/register-student';
  static const String forgetPassword = '/forgetPassword';
  static const String resetPassword = '/resetPassword';
  static const String accountCreationSuccess = '/accountCreationSuccess';
  static const String verifyOtp = '/verifyOtp';
  static const String paymentScreen = '/paymentScreen';
  static const String paymentWebView = '/payment-webview';
  static const String rewards = '/rewards';

  // ================== Viewer ==================
  static const String viewerHome = '/viewer-home';
  static const String changeLanguage = '/changeLanguage';
  static const String changePassword = '/changePassword';
  static const String continueWatching = '/continueWatching';
  static const String seriesAndMovies = '/seriesAndMovies';
  static const String movieDetails = '/movie_details';
  static const String exploreViewer = '/explore_viewer';
  static const String homeSearch = '/home-search';
  static const String prfileViewer = '/prfile_viewer';
  static const String editViewerProfile = '/editViewerProfile';
  static const String viewerProfileDetails = '/viewer-profile-details';
  static const String technicalSupport = '/technicalSupport';
  static const String deleteAccount = '/deleteAccount';
  static const String favoriteArtwork = '/favoriteArtwork';
  static const String historyScreen = '/historyScreen';
  static const String swapAccounts = '/swap-accounts';
  static const String pendingApproval = '/pending-approval';
  static const String completeViewerProfile = '/complete-viewer-profile';

  // ================== Enterprise ==================
  static const String enterpriseOnboarding = '/enterprise-onboarding';
  static const String enterpriseHome = '/enterprise-home';
  static const String enterpriseExplore = '/enterpriseExplore';
  static const String enterpriseCommunity = '/enterpriseCommunity';
  static const String enterpriseBookings = '/enterpriseBookings';
  static const String enterpriseProfile = '/enterpriseProfile';
  static const String editEnterpriseProfile = '/editEnterpriseProfile';
  static const String yourProfile = '/yourProfile';
  static const String userProfile = '/user-profile';
  static const String allWorks = '/all-works';
  static const String findTalent = '/find-talent';
  static const String findStudent = '/find-student';
  static const String findWorkshops = '/find-workshops';
  static const String trending = '/trending';
  static const String recentTransactions = '/recent-transactions';
  static const String talentProfile = '/talent-profile';
  static const String withdraw = '/withdraw';

  // ================== Work Enterprise - Add Work ==================
  static const String selectArtworkType = '/select-artwork-type';
  static const String uploadMovie = '/upload-movie';
  static const String uploadSeries = '/upload-series';
  static const String uploadAdvertising = '/upload-advertising';
  static const String addAdvertiseDetailsScreen = '/add-advertise-details';
  static const String addActorsPriceScreen = '/add-actors-price';
  static const String moviePreview = '/movie-preview';
  static const String advertisePreview = '/advertise-preview';
  static const String addWorkshop = '/add-workshop';
  static const String workshopApplications = '/workshop-applications';
  static const String addBooking = '/add-booking';
  static const String bookingDetails = '/booking-details';
  static const String rentedPeople = '/rented-people';
  static const String allBookings = '/all-bookings';

  // ================== Chat ==================
  static const String chatRooms = '/chat-rooms';
  static const String chat = '/chat';
  static const String chatMessages = '/chat/:roomId';

  // ================== Testing ==================
  static const String testVideoUpload = '/test-video-upload';

  // ================== Video Player ==================
  static const String videoPlayer = '/video-player/:contentType/:contentId';
  static const String trailerPlayer = '/trailer-player/:contentType/:contentId';
  static const String verticalTrailerPlayer = '/vertical-trailer-player';

  // ================== Student ==================
  static const String studentOnboarding = '/student-onboarding';
  static const String studentHome = '/student-home';
  static const String studentExplore = '/studentExplore';
  static const String studentCommunity = '/studentCommunity';
  static const String studentBookings = '/studentBookings';
  static const String studentProfile = '/studentProfile';
  static const String editStudentProfile = '/editStudentProfile';

  // Legacy

  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String appLocked = '/appLocked';
}
