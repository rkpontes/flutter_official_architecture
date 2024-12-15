import '../injector.dart';

class Config {
  final Flavor flavor;

  Config({required this.flavor});

  bool get isProduction => flavor == Flavor.production;
  bool get isDevelopment => flavor == Flavor.development;
}
