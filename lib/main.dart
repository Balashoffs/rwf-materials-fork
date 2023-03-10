import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:quote_details/quote_details.dart';
import 'package:quote_list/quote_list.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_repository/user_repository.dart';
import 'package:wonder_words/l10n/app_localizations.dart';
import 'package:wonder_words/routing_table.dart';
import 'package:wonder_words/screen_view_observer.dart';

void main() async {
  // Has to be late so it doesn't instantiate before the
  // `initializeMonitoringPackage()` call.
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeMonitoringPackage();

      final remoteValueService = RemoteValueService();
      await remoteValueService.load();

      FlutterError.onError = errorReportingService.recordFlutterError;

      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await errorReportingService.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
          );
        }).sendPort,
      );

      runApp(
        WonderWords(
          remoteValueService: remoteValueService,
        ),
      );
    },
    (error, stack) => errorReportingService.recordError(
      error,
      stack,
      fatal: true,
    ),
  );
}

class WonderWords extends StatefulWidget {
  const WonderWords({
    required this.remoteValueService,
    Key? key,
  }) : super(key: key);

  final RemoteValueService remoteValueService;

  @override
  _WonderWordsState createState() => _WonderWordsState();
}

class _WonderWordsState extends State<WonderWords> {
  final _keyValueStorage = KeyValueStorage();
  final _analyticsService = AnalyticsService();
  final _dynamicLinkService = DynamicLinkService();
  late final FavQsApi _favQsApi;
  late final QuoteRepository _quoteRepository;
  late final UserRepository _userRepository;
  late StreamSubscription _incomingDynamicLinksSubscription;
  late final RoutemasterDelegate _routerDelegate;
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  void initState() {
    super.initState();

    _favQsApi = FavQsApi(
      userTokenSupplier: () => _userRepository.getUserToken(),
    );

    _quoteRepository = QuoteRepository(
      remoteApi: _favQsApi,
      keyValueStorage: _keyValueStorage,
    );

    _userRepository = UserRepository(
      remoteApi: _favQsApi,
      noSqlStorage: _keyValueStorage,
    );

    _routerDelegate = RoutemasterDelegate(
      observers: [
        ScreenViewObserver(
          analyticsService: _analyticsService,
        ),
      ],
      routesBuilder: (context) {
        return RouteMap(
          routes: buildRoutingTable(
            routerDelegate: _routerDelegate,
            userRepository: _userRepository,
            quoteRepository: _quoteRepository,
            remoteValueService: widget.remoteValueService,
            dynamicLinkService: _dynamicLinkService,
          ),
        );
      },
    );

    _openInitialDynamicLinkIfAny();

    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath.listen((event) {
      _routerDelegate.push;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DarkModePreference>(
      stream: _userRepository.getDarkModePreference(),
      builder: (context, snapshot) {
        final darkModePreference = snapshot.data;

        return WonderTheme(
          lightTheme: _lightTheme,
          darkTheme: _darkTheme,
          child: MaterialApp.router(
            theme: _lightTheme.materialThemeData,
            darkTheme: _darkTheme.materialThemeData,
            themeMode: darkModePreference?.toThemeMode(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ComponentLibraryLocalizations.delegate,
              ProfileMenuLocalizations.delegate,
              QuoteListLocalizations.delegate,
              QuoteDetailsLocalizations.delegate,
              SignInLocalizations.delegate,
              ForgotMyPasswordLocalizations.delegate,
              SignUpLocalizations.delegate,
              UpdateProfileLocalizations.delegate,
            ],
            routerDelegate: _routerDelegate,
            routeInformationParser: const RoutemasterParser(),
          ),
        );
      },
    );
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      log(path);
      _routerDelegate.push(path);
    }
  }

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    super.dispose();
  }
}

extension on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings:
        return ThemeMode.system;
      case DarkModePreference.alwaysLight:
        return ThemeMode.light;
      case DarkModePreference.alwaysDark:
        return ThemeMode.dark;
    }
  }
}
