import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
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
import 'package:wonder_words/tab_container_screen.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
  required QuoteRepository quoteRepository,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
}) {
  return {
    _PathConstants.tabContainerPath: (_) => CupertinoTabPage(
          child: const TabContainerScreen(),
          paths: [
            _PathConstants.quoteListPath,
            _PathConstants.profileMenuPath,
          ],
        ),
    _PathConstants.quoteListPath: (route) {
      return MaterialPage(
        name: 'quotes-list',
        child: QuoteListScreen(
          quoteRepository: quoteRepository,
          userRepository: userRepository,
          onAuthenticationError: (context) {
            routerDelegate.push(_PathConstants.signInPath);
          },
          remoteValueService: remoteValueService,
          onQuoteSelected: (id) {
            final navigation = routerDelegate
                .push<Quote?>(_PathConstants.quoteDetailsPath(quoteId: id));
            return navigation.result;
          },
        ),
      );
    },
    _PathConstants.profileMenuPath: (route) {
      return MaterialPage(
        name: '',
        child: ProfileMenuScreen(
          userRepository: userRepository,
          quoteRepository: quoteRepository,
          onSignInTap: () {
            routerDelegate.push(_PathConstants.signInPath);
          },
          onSignUpTap: () {
            routerDelegate.push(_PathConstants.signUpPath);
          },
          onUpdateProfileTap: () {
            routerDelegate.push(_PathConstants.updateProfilePath);
          },
        ),
      );
    },
    _PathConstants.signInPath: (_) =>
        _sighInPageBuilder(userRepository, routerDelegate),
    _PathConstants.signUpPath: (_) =>
        _sighUpPageBuilder(userRepository, routerDelegate),
    _PathConstants.updateProfilePath: (_) =>
        _updatePageBuilder(userRepository, routerDelegate),
    _PathConstants.quoteDetailsPath(): (info) => _quoteDetailsPageBuilder(
        info, dynamicLinkService, quoteRepository, routerDelegate),
  };
}

MaterialPage _quoteDetailsPageBuilder(
    RouteData info,
    DynamicLinkService dynamicLinkService,
    QuoteRepository quoteRepository,
    RoutemasterDelegate routerDelegate) {
  return MaterialPage(
    name: 'quote-details',
    child: QuoteDetailsScreen(
      quoteRepository: quoteRepository,
      quoteId:
          int.parse(info.pathParameters[_PathConstants.idPathParameter] ?? ''),
      onAuthenticationError: () {
        routerDelegate.push(_PathConstants.signInPath);
      },
      // TODO: Specify the shareableLinkGenerator parameter.
      shareableLinkGenerator: (quote) {
        return dynamicLinkService.generateDynamicLinkUrl(
          path: _PathConstants.quoteDetailsPath(
            quoteId: quote.id,
          ),
          socialMetaTagParameters: SocialMetaTagParameters(
            title: quote.body,
            description: quote.author,
          ),
        );
      },
    ),
  );
}

MaterialPage _updatePageBuilder(
    UserRepository userRepository, RoutemasterDelegate routerDelegate) {
  return MaterialPage(
    name: 'update-profile',
    child: UpdateProfileScreen(
      userRepository: userRepository,
      onUpdateProfileSuccess: () {
        routerDelegate.pop();
      },
    ),
  );
}

MaterialPage _sighInPageBuilder(
    UserRepository userRepository, RoutemasterDelegate routerDelegate) {
  return MaterialPage(
      name: 'sigh-in',
      fullscreenDialog: true,
      child: Builder(
        builder: (context) {
          return SignInScreen(
            userRepository: userRepository,
            onSignInSuccess: () {
              routerDelegate.popRoute();
            },
            onSignUpTap: () {
              routerDelegate.push(_PathConstants.signUpPath);
            },
            onForgotMyPasswordTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ForgotMyPasswordDialog(
                      userRepository: userRepository,
                      onCancelTap: () {
                        routerDelegate.pop();
                      },
                      onEmailRequestSuccess: () {
                        routerDelegate.pop();
                      },
                    );
                  });
            },
          );
        },
      ));
}

MaterialPage _sighUpPageBuilder(
    UserRepository userRepository, RoutemasterDelegate routerDelegate) {
  return MaterialPage(
    name: 'sigh-up',
    child: SignUpScreen(
      userRepository: userRepository,
      onSignUpSuccess: () {
        routerDelegate.pop();
      },
    ),
  );
}

class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';

  static String get quoteListPath => '${tabContainerPath}quotes';

  static String get profileMenuPath => '${tabContainerPath}user';

  static String get updateProfilePath => '$profileMenuPath/updateprofile';

  static String get signInPath => '${tabContainerPath}sign-in';

  static String get signUpPath => '${tabContainerPath}sign-up';

  static String get idPathParameter => 'id';

  static String quoteDetailsPath({
    int? quoteId,
  }) =>
      '$quoteListPath/${quoteId ?? ':$idPathParameter'}';
}
