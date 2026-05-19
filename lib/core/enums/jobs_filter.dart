import 'package:easy_localization/easy_localization.dart';

enum JobsFilter { yourOwn, suggested }

String jobsFilterLabel(JobsFilter filter) {
  switch (filter) {
    case JobsFilter.yourOwn:
      return 'jobs_filter_your_own'.tr();
    case JobsFilter.suggested:
      return 'jobs_filter_suggested'.tr();
  }
}

String jobsFilterApiValue(JobsFilter filter) {
  switch (filter) {
    case JobsFilter.yourOwn:
      return 'mine';
    case JobsFilter.suggested:
      return 'suggested';
  }
}
