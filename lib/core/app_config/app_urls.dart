class AppUrls {
  const AppUrls._();
  static const String base = 'https://admin.askcrews.com';
  static String imageLink(String image) => '$base$image';
  static String storageImageLink(String image) => '$base/storage$image';
  static String svgImageLink(String svgImage) => '$base/storage$svgImage';
  static const String baseApi = 'https://admin.askcrews.com/api';
  static const String _baseApi = baseApi;

  // Auth endpoints
  static const String login = '$_baseApi/v1/auth/login';
  static const String viewerSignup = '$_baseApi/v1/auth/signup';
  static const String enterpriseSignup = '$_baseApi/v1/auth/enterprise/signup';
  static const String studentSignup = '$_baseApi/v1/auth/student/signup';
  static const String specifications = '$_baseApi/v1/auth/specifications';
  static const String refreshToken = '$_baseApi/v1/auth/token/refresh';
  static const String resetPassword = '$_baseApi/v1/auth/reset-password';
  static const String resendSms = '$_baseApi/v1/auth/resend-sms';
  static const String activate = '$_baseApi/v1/auth/verify-sms';
  static const String logout = '$_baseApi/v1/auth/logout';
  static const String plans = '$_baseApi/v1/auth/plans';
  static const String activatePlan = '$_baseApi/v1/auth/activate-plan';
  static const String planDiscounts = '$_baseApi/v1/auth/plans/discounts';
  static const String getCategories = '$_baseApi/v1/auth/categories';
  static const String rateUser = '$_baseApi/v1/auth/rate-user';
  static String getUserProfile(int userId) =>
      '$_baseApi/v1/auth/profiles/$userId/';
  static const String getMyProfile = '$_baseApi/v1/auth/profiles/my-profile/';
  static const String getAllProfiles = '$_baseApi/v1/auth/profiles/';
  static const String updateProfile =
      '$_baseApi/v1/auth/profiles/update-profile/';
  static const String changePassword = '$_baseApi/v1/auth/change-password';
  static const String deleteAccount =
      '$_baseApi/v1/auth/profiles/delete-my-account/';
  static const String swapToEnterprise =
      '$_baseApi/v1/auth/profiles/swap-to-enterprise/';
  static const String swapToStudent =
      '$_baseApi/v1/auth/profiles/swap-to-student/';
  static const String swapToViewer =
      '$_baseApi/v1/auth/profiles/swap-to-viewer/';
  static const String completeEnterpriseProfile =
      '$_baseApi/v1/auth/profiles/complete-enterprise-profile/';
  static const String completeStudentProfile =
      '$_baseApi/v1/auth/profiles/complete-student-profile/';
  static const String completeViewerProfile =
      '$_baseApi/v1/auth/profiles/complete-viewer-profile/';
  static const String contentCatalogSearch =
      '$_baseApi/v1/auth/content-catalog/search';
  static const String addUserRole = '$_baseApi/v1/auth/profiles/user_roles/';
  static String deleteUserRole(int roleId) =>
      '$_baseApi/v1/auth/roles/$roleId/';

  // Google Sign-In endpoints (mobile)
  static const String googleSignupViewer =
      '$_baseApi/v1/auth/google/signup-viewer-mobile';
  static const String googleLoginViewer =
      '$_baseApi/v1/auth/google/signup-viewer-mobile';

  static const String getMyStats = '$_baseApi/v1/auth/my-stats';
  static const String rewardHistoryEndpoint = '$_baseApi/v1/reward/history/';
  static const String rewardCodesEndpoint = '$_baseApi/v1/reward/codes/';

  // Payment endpoints
  static const String savePaymentStatus = '$baseApi/payment/save-status';
  static const String subscribeToPackage = '$baseApi/payment/subscribe-package';
  static const String subscribeToPromotion =
      '$baseApi/payment/subscribe-promotion';
  static const String savePromotionStatus =
      '$baseApi/payment/save-promotion-status';
  static const String payForContent = '$_baseApi/v1/payment/content/payment';
  static const String walletAdd = '$_baseApi/v1/payment/wallet/add';
  static const String collectRequests =
      '$_baseApi/v1/payment/collect-requests/';
  static const String getMyPayments = '$_baseApi/v1/payment/my/payments';
  static const String watermarkPayment = '$_baseApi/v1/payment/watermark';
  static const String payForBooking = '$_baseApi/v1/payment/booking/payment';

  // Community endpoints
  static String getAnswers(String id) => '$_baseApi/v1/community/answers';
  static String deleteJobs(int id) => '$_baseApi/v1/community/jobs/$id/';
  static String updateAnswer(int id) => '$_baseApi/v1/community/answers/$id/';
  static String updateQuestion(int id) =>
      '$_baseApi/v1/community/questions/$id/';
  static String deleteQuestion(int id) =>
      '$_baseApi/v1/community/questions/$id/';
  static String deleteAnswer(int id) => '$_baseApi/v1/community/answers/$id/';
  static String createAnswers = '$_baseApi/v1/community/answers/';
  static const String communityQuestions = '$_baseApi/v1/community/questions/';
  static const String getQuestions = '$_baseApi/v1/community/questions';

  // Jobs endpoints
  static const String jobs = '$_baseApi/v1/community/jobs';
  static const String createJob = '$_baseApi/v1/community/jobs/';
  static String updateJob(int id) => '$_baseApi/v1/community/jobs/$id/';
  static String updateJobApplicationStatus(int applicationId) =>
      '$_baseApi/v1/community/applications/$applicationId/';
  static const String applyToJob = '$_baseApi/v1/community/applications/';
  static const String getJobApplications =
      '$_baseApi/v1/community/applications';

  // Chat endpoints
  static const String chatRooms = '$_baseApi/v1/chat/rooms/';
  static const String getOrCreateChatRoom =
      '$_baseApi/v1/chat/rooms/get-or-create/';
  static String chatMessages(int roomId) =>
      '$_baseApi/v1/chat/rooms/$roomId/messages/';
  static String sendChatMessage(int roomId) =>
      '$_baseApi/v1/chat/rooms/$roomId/send-message/';

  // WebSocket URL for chat
  static String chatWebSocket(int roomId) =>
      'wss://admin.askcrews.com/chat/$roomId/';

  // Content endpoints
  static const String addWork = '$_baseApi/v1/content/movies/';
  static const String createSeries = '$_baseApi/v1/content/series/';
  static const String createSeason = '$_baseApi/v1/content/seasons/';
  static const String createEpisode = '$_baseApi/v1/content/episodes/';
  static const String getMovies = '$_baseApi/v1/content/movies';
  static String updateMovie(int id) => '$_baseApi/v1/content/movies/$id/';
  static String deleteMovie(int id) => '$_baseApi/v1/content/movies/$id/';
  static const String initializeVideo =
      '$_baseApi/v1/content/initialize-video/';
  static const String initializeExploreVideo = '$_baseApi/v1/content/explore/';
  static const String getExploreContent = '$_baseApi/v1/content/explore/';
  static const String getMoviesWithSeries =
      '$_baseApi/v1/content/movies_with_series/';
  static const String getContinueWatching =
      '$_baseApi/v1/content/continue-watching/';
  static const String updateContinueWatching =
      '$_baseApi/v1/content/continue-watching/update/';
  static String getContentVideoToken(String contentType, int contentId) =>
      '$_baseApi/v1/content/videos/$contentType/$contentId/token/';

  static String getTrailerToken(String contentType, int contentId) =>
      '$_baseApi/v1/content/videos/$contentType/$contentId/trailer-token/';

  static const String getSeries = '$_baseApi/v1/content/series';
  static String updateSeries(int id) => '$_baseApi/v1/content/series/$id/';
  static String deleteSeries(int id) => '$_baseApi/v1/content/series/$id/';

  static const String getSeasons = '$_baseApi/v1/content/seasons';
  static String updateSeason(int id) => '$_baseApi/v1/content/seasons/$id/';
  static String deleteSeason(int id) => '$_baseApi/v1/content/seasons/$id/';

  static const String getEpisodes = '$_baseApi/v1/content/episodes';
  static String updateEpisode(int id) => '$_baseApi/v1/content/episodes/$id/';
  static String deleteEpisode(int id) => '$_baseApi/v1/content/episodes/$id/';

  static const String getTrending = '$_baseApi/v1/content/trending/';
  static const String getBanners = '$_baseApi/v1/content/banners/';
  static const String rateContent = '$_baseApi/v1/content/ratings/';

  static const String addAdvertise = '$_baseApi/v1/content/advertise/';
  static const String getAdvertises = '$_baseApi/v1/content/advertise/';
  static String updateAdvertise(int id) =>
      '$_baseApi/v1/content/advertise/$id/';
  static String deleteAdvertise(int id) =>
      '$_baseApi/v1/content/advertise/$id/';

  // Workshop endpoints
  static const String getWorkshops = '$_baseApi/v1/workshop/';
  static const String getMyWorkshops = '$_baseApi/v1/workshop/mine/';
  static String getWorkshopById(int id) => '$_baseApi/v1/workshop/$id/';
  static const String createWorkshop = '$_baseApi/v1/workshop/';
  static String updateWorkshop(int id) => '$_baseApi/v1/workshop/$id/';
  static String deleteWorkshop(int id) => '$_baseApi/v1/workshop/$id/';

  // Workshop registration endpoints
  static const String applyToWorkshop = '$_baseApi/v1/workshop/registrations/';
  static String approveWorkshopRegistration(int id) =>
      '$_baseApi/v1/workshop/registrations/$id/approve/';
  static String rejectWorkshopRegistration(int id) =>
      '$_baseApi/v1/workshop/registrations/$id/reject/';
  static String getWorkshopRegistrations(int workshopId) =>
      '$_baseApi/v1/workshop/registrations/workshop/$workshopId/';

  // Booking endpoints
  static const String getBookingItems = '$_baseApi/v1/booking/items/';
  static const String createBookingItem = '$_baseApi/v1/booking/items/';
  static String updateBookingItem(int id) => '$_baseApi/v1/booking/items/$id/';
  static String deleteBookingItem(int id) => '$_baseApi/v1/booking/items/$id/';
  static String getItemBookings(int itemId) =>
      '$_baseApi/v1/booking/items/$itemId/bookings';

  // Booking requests endpoints
  static const String getBookings = '$_baseApi/v1/booking/bookings/';
  static const String createBooking = '$_baseApi/v1/booking/bookings/';
  static String getBookingById(int id) => '$_baseApi/v1/booking/bookings/$id/';
  static String updateBooking(int id) => '$_baseApi/v1/booking/bookings/$id/';
  static String deleteBooking(int id) => '$_baseApi/v1/booking/bookings/$id/';

  // Favorites endpoints
  static const String getFavorites = '$_baseApi/v1/content/favorites/';
  static const String addFavorite = '$_baseApi/v1/content/favorites/add/';
  static const String removeFavorite = '$_baseApi/v1/content/favorites/remove/';

  // Rewards endpoints
  static const String rewardsEndpoint = '$_baseApi/v1/reward/rewards/';
  static const String redeemReward = '$_baseApi/v1/reward/redeem/';

  // Notifications endpoints
  static String notificationsStreamUrl(String token) =>
      '$_baseApi/v1/notifications/stream/?token=$token';
  static const String getNotifications = '$_baseApi/v1/notifications/';
  static String getNotificationById(int id) =>
      '$_baseApi/v1/notifications/$id/';
  static String markNotificationRead(int id) =>
      '$_baseApi/v1/notifications/$id/mark-read/';
  static const String markAllNotificationsRead =
      '$_baseApi/v1/notifications/mark-all-read/';
  static const String saveFcmToken = '$_baseApi/v1/notifications/fcm-token/';
}
