enum UserType { viewer, enterprise, student }

extension UserTypeMapper on UserType {
  int get homeBranchIndex {
    switch (this) {
      case UserType.viewer:
        return 0;
      case UserType.enterprise:
        return 3;
      case UserType.student:
        return 8;
    }
  }

  static UserType fromApi(String type) {
    switch (type) {
      case 'enterprise':
        return UserType.enterprise;
      case 'student':
        return UserType.student;
      case 'viewer':
      default:
        return UserType.viewer;
    }
  }
}
