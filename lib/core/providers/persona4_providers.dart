import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositorio/api_client.dart';
import '../repositorio/telemedicina_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final cliente = ApiClient();
  ref.onDispose(cliente.cerrar);
  return cliente;
});

final telemedicinaRepositoryProvider = Provider<TelemedicinaRepository>(
  (ref) => TelemedicinaRepository(ref.watch(apiClientProvider)),
);

final panelDatosProvider = FutureProvider<PanelDatos>(
  (ref) => ref.watch(telemedicinaRepositoryProvider).cargarPanel(),
);
