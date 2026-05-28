import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:synapse_state/synapse_state.dart';

class MindhearthSynapseConfig {
  const MindhearthSynapseConfig._();

  static const String synapseApiBaseUrlOverride = String.fromEnvironment(
    'MINDHEARTH_SYNAPSE_API_BASE_URL',
    defaultValue: '',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'MINDHEARTH_API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static String get synapseApiBaseUrl {
    final override = synapseApiBaseUrlOverride.trim();
    if (override.isNotEmpty) return override;

    final api = apiBaseUrl.trim();
    if (api.endsWith('/api/v1')) {
      return api.substring(0, api.length - '/api/v1'.length);
    }
    if (api.endsWith('/api')) {
      return api.substring(0, api.length - '/api'.length);
    }
    return api;
  }
}

/// Product-runtime Synapse overrides for Mindhearth.
///
/// These overrides establish Mindhearth as a consumer host. Application API
/// keys remain on the product host/BFF; Flutter receives only a bounded host
/// handoff containing end-user bearer and runtime package context.
List<Override> mindhearthSynapseProviderOverrides({String? baseUrl}) {
  return synapseConsumerBootstrapOverrides(
    baseUrl: baseUrl ?? MindhearthSynapseConfig.synapseApiBaseUrl,
  );
}

final mindhearthSynapseHostHandoffControllerProvider =
    Provider<MindhearthSynapseHostHandoffController>(
      (ref) => MindhearthSynapseHostHandoffController(ref),
    );

class MindhearthSynapseHostHandoffController {
  MindhearthSynapseHostHandoffController(this._ref);

  final Ref _ref;

  void applyHostHandoffJson(Map<String, dynamic> json) {
    final bootstrap = SynapseConsumerHostBootstrap.fromJson(json);
    _ref
        .read(synapseConsumerRuntimeFacadeProvider)
        .applyHostBootstrap(bootstrap);
  }

  String? get resolvedPackageId =>
      _ref.read(synapseConsumerRuntimeFacadeProvider).resolvedRuntimePackageId;

  String? get endUserBearer => _ref.read(synapseEndUserBearerProvider);
}
