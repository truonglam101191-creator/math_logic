class FinalPointAPI {
  FinalPointAPI._();
  static const login = '/v1/auth/login';
  static const loginguest = '/v1/auth/guest';
  static const register = '/v1/auth/register';
  static const getInfoMe = '/v1/users/me';
  static const changePass = '/v1/auth/change-password';
  static const verifyPass = '/v1/auth/verify-password';
  static const logout = '/v1/auth/logout';
  static const logoutDevice = '/v1/auth/logout/device';
  static const uploadAvatarUser = '/v1/users/avatar';
  static const uploadFiles = 'upload';
  static const updateUserMe = '/v1/users/me';
   static const updateUser= '/v1/users';
  static const chattext = '/v1/chat/completions';
  static const chatCreateImage = '/v1/images/generations';
  static const infoApp = '/v1/apps';
  static const address = '/v1/address';
  static const deleteAccount = '/v1/auth/delete';
}
