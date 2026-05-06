import 'package:dio/dio.dart';

class DashboardRemoteDs {
  DashboardRemoteDs(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> fetchSummary() async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data since the backend API is not yet available
    return {
      'accessRequests': 80,
      'lawyerRequests': 87,
      'unassignedCases': 57,
    };
  }
}
