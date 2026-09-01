import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qline_app/core/network/api_client.dart';
import 'package:qline_app/features/organizations/data/api_organization_repository.dart';

void main() {
  test('loads organizations from the API', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/organizations');

      return http.Response(
        jsonEncode([
          {
            'id': 'citizen-center',
            'name': 'مركز خدمة المواطن',
            'category': 'خدمات حكومية',
            'branchCount': 3,
            'isActive': true,
          },
        ]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final repository = ApiOrganizationRepository(ApiClient(client: client));

    final organizations = await repository.getOrganizations();

    expect(organizations, hasLength(1));
    expect(organizations.single.id, 'citizen-center');
    expect(organizations.single.name, 'مركز خدمة المواطن');
  });
}
