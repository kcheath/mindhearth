import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/api_response.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';
import 'package:mindhearth/core/utils/logger.dart';

class JournalService {
  final ApiService _apiService;

  JournalService(this._apiService);

  // Get journal entries with filtering
  Future<ApiResponse<JournalEntriesResponse>> getJournalEntries({
    int limit = 100,
    int offset = 0,
    String? sessionId,
    String? entryType,
  }) async {
    try {
      appLogger.debug('getJournalEntries - sending request', 'JournalService');
      
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (sessionId != null) queryParams['session_id'] = sessionId;
      if (entryType != null) queryParams['entry_type'] = entryType;
      
      final response = await _apiService.dio.get(
        '/journals/',
        queryParameters: queryParams,
      );
      
      appLogger.debug('getJournalEntries - response status: ${response.statusCode}', 'JournalService');
      appLogger.debug('getJournalEntries - response data: ${response.data}', 'JournalService');
      
      if (response.statusCode == 200) {
        final journalResponse = JournalEntriesResponse.fromJson(response.data);
        return ApiSuccess(data: journalResponse);
      } else {
        return ApiError(
          message: 'Failed to get journal entries',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      appLogger.debug('getJournalEntries - error: ${e.toString()}', 'JournalService');
      appLogger.debug('getJournalEntries - error response: ${e.response?.data}', 'JournalService');
      appLogger.debug('getJournalEntries - error status code: ${e.response?.statusCode}', 'JournalService');
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get journal entries',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Get specific journal entry
  Future<ApiResponse<JournalEntry>> getJournalEntry(String entryId) async {
    try {
      appLogger.debug('getJournalEntry - sending request to /journals/$entryId', 'JournalService');
      
      final response = await _apiService.dio.get('/journals/$entryId');
      
      appLogger.debug('getJournalEntry - response status: ${response.statusCode}', 'JournalService');
      appLogger.debug('getJournalEntry - response data: ${response.data}', 'JournalService');
      
      if (response.statusCode == 200) {
        final entry = JournalEntry.fromJson(response.data);
        return ApiSuccess(data: entry);
      } else {
        return ApiError(
          message: 'Failed to get journal entry',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      appLogger.debug('getJournalEntry - error: ${e.toString()}', 'JournalService');
      appLogger.debug('getJournalEntry - error response: ${e.response?.data}', 'JournalService');
      appLogger.debug('getJournalEntry - error status code: ${e.response?.statusCode}', 'JournalService');
      
      if (e.response?.statusCode == 404) {
        return ApiError(
          message: 'Journal entry not found',
          statusCode: 404,
        );
      }
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Create manual journal entry
  Future<ApiResponse<JournalEntry>> createJournalEntry(JournalEntryCreate request) async {
    try {
      appLogger.debug('createJournalEntry - sending request', 'JournalService');
      appLogger.debug('createJournalEntry - request data: ${request.toJson()}', 'JournalService');
      
      final response = await _apiService.dio.post(
        '/journals/',
        data: request.toJson(),
      );
      
      appLogger.debug('createJournalEntry - response status: ${response.statusCode}', 'JournalService');
      appLogger.debug('createJournalEntry - response data: ${response.data}', 'JournalService');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final entry = JournalEntry.fromJson(response.data);
        return ApiSuccess(data: entry);
      } else {
        return ApiError(
          message: 'Failed to create journal entry',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      appLogger.debug('createJournalEntry - error: ${e.toString()}', 'JournalService');
      appLogger.debug('createJournalEntry - error response: ${e.response?.data}', 'JournalService');
      appLogger.debug('createJournalEntry - error status code: ${e.response?.statusCode}', 'JournalService');
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to create journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Create AI journal summary
  Future<ApiResponse<JournalEntry>> createAIJournalSummary(AIJournalSummaryRequest request) async {
    try {
      appLogger.debug('createAIJournalSummary - sending request', 'JournalService');
      appLogger.debug('createAIJournalSummary - request data: ${request.toJson()}', 'JournalService');
      
      final response = await _apiService.dio.post(
        '/journals/ai-summary',
        data: request.toJson(),
      );
      
      appLogger.debug('createAIJournalSummary - response status: ${response.statusCode}', 'JournalService');
      appLogger.debug('createAIJournalSummary - response data: ${response.data}', 'JournalService');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final entry = JournalEntry.fromJson(response.data);
        return ApiSuccess(data: entry);
      } else {
        return ApiError(
          message: 'Failed to create AI journal summary',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      appLogger.debug('createAIJournalSummary - error: ${e.toString()}', 'JournalService');
      appLogger.debug('createAIJournalSummary - error response: ${e.response?.data}', 'JournalService');
      appLogger.debug('createAIJournalSummary - error status code: ${e.response?.statusCode}', 'JournalService');
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to create AI journal summary',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Update journal entry
  Future<ApiResponse<JournalEntry>> updateJournalEntry(String entryId, JournalEntryCreate request) async {
    try {
      appLogger.debug('updateJournalEntry - sending request to /journals/$entryId', 'JournalService');
      appLogger.debug('updateJournalEntry - request data: ${request.toJson()}', 'JournalService');
      
      final response = await _apiService.dio.put(
        '/journals/$entryId',
        data: request.toJson(),
      );
      
      appLogger.debug('updateJournalEntry - response status: ${response.statusCode}', 'JournalService');
      appLogger.debug('updateJournalEntry - response data: ${response.data}', 'JournalService');
      
      if (response.statusCode == 200) {
        final entry = JournalEntry.fromJson(response.data);
        return ApiSuccess(data: entry);
      } else {
        return ApiError(
          message: 'Failed to update journal entry',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      appLogger.debug('updateJournalEntry - error: ${e.toString()}', 'JournalService');
      appLogger.debug('updateJournalEntry - error response: ${e.response?.data}', 'JournalService');
      appLogger.debug('updateJournalEntry - error status code: ${e.response?.statusCode}', 'JournalService');
      
      if (e.response?.statusCode == 404) {
        return ApiError(
          message: 'Journal entry not found',
          statusCode: 404,
        );
      }
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to update journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
