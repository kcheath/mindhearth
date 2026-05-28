import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/synapse/mindhearth_synapse_integration.dart';
import 'package:synapse_state/synapse_state.dart';

const _tenantId = 'local-rehearsal-tenant';
const _applicationId = 'app-de2e9911d516';

Map<String, dynamic> _hostHandoffJson({
  String endUserBearer = 'runtime.jwt.value',
}) {
  return <String, dynamic>{
    'tenant_id': _tenantId,
    'tenant_label': 'Mindhearth tenant',
    'application_id': _applicationId,
    'application_label': 'Mindhearth',
    'backend_profile': 'cortex',
    'end_user_bearer': endUserBearer,
    'resolved_package_context': <String, dynamic>{
      'package_id': 'pkg-mindhearth-production',
      'package_version_number': 1,
      'source': 'application_production',
      'runtime_status': 'ready',
    },
  };
}

void main() {
  group('Mindhearth Synapse integration', () {
    test('provider overrides install consumer runtime posture', () {
      final c = ProviderContainer(
        overrides: mindhearthSynapseProviderOverrides(
          baseUrl: 'https://cortex.example',
        ),
      );
      addTearDown(c.dispose);

      expect(
        c.read(synapseHostRuntimeKindProvider),
        SynapseHostRuntimeKind.consumer,
      );
      expect(c.read(synapseConsumerProductHostProvider), isTrue);
      expect(
        c.read(synapseRuntimeBindingProvider),
        isA<ConsumerSynapseRuntimeBinding>(),
      );
    });

    test('host handoff applies bounded runtime material', () {
      final c = ProviderContainer(
        overrides: mindhearthSynapseProviderOverrides(
          baseUrl: 'https://cortex.example',
        ),
      );
      addTearDown(c.dispose);

      c
          .read(mindhearthSynapseHostHandoffControllerProvider)
          .applyHostHandoffJson(_hostHandoffJson());

      final controller = c.read(mindhearthSynapseHostHandoffControllerProvider);
      final facade = c.read(synapseConsumerRuntimeFacadeProvider);
      expect(controller.endUserBearer, 'runtime.jwt.value');
      expect(controller.resolvedPackageId, 'pkg-mindhearth-production');
      expect(facade.runtimeState.selection.tenantId, _tenantId);
      expect(facade.runtimeState.selection.applicationId, _applicationId);
      expect(
        facade.resolvedRuntimePackageContext?.explicitOverrideAllowed,
        isFalse,
      );
    });

    test('host handoff rejects Fortessa API key leakage', () {
      final c = ProviderContainer(
        overrides: mindhearthSynapseProviderOverrides(),
      );
      addTearDown(c.dispose);

      final unsafe = _hostHandoffJson()
        ..['api_key'] = 'fta_app_live_keyid_tailvalue';

      expect(
        () => c
            .read(mindhearthSynapseHostHandoffControllerProvider)
            .applyHostHandoffJson(unsafe),
        throwsStateError,
      );
      expect(c.read(synapseEndUserBearerProvider), isNull);
    });
  });
}
