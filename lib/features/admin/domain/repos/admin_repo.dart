abstract class AdminRepo {
  Future<bool> checkAdminExists(String email);
  Future<bool> createAdmin(String email, String password);
  Future<bool> isAdmin(String email);
  Future<bool> loginAdmin(String email, String password);
  Future<List<Map<String, dynamic>>> getAllTransactions();
  Future<bool> logAdminAction(String action, String targetUser, Map<String, dynamic> details);
  Future<bool> deleteUser(String userId);
  Future<bool> resetUserPassword(String userId, String newPassword);
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId);
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<bool> addMoneyToUser(String userId, double amount, String reason, String adminEmail);
  Future<bool> removeMoneyFromUser(String userId, double amount, String reason, String adminEmail);
}