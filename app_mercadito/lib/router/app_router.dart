import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/home_feed_screen.dart';
import '../screens/register_screen.dart';
import '../screens/providers_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/market_analysis_screen.dart';
import '../screens/market_price_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/help_support_screen.dart';
import '../screens/negotiations_screen.dart';
import '../screens/negotiation_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/language_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/all_tasks_screen.dart';
import '../screens/reported_users_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/legal_policies_screen.dart';
import '../screens/coupons_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/provider_profile_screen.dart';
import '../screens/account_config_screen.dart';
import '../screens/active_devices_screen.dart';
import '../screens/two_factor_auth_screen.dart';
import '../screens/sms_verification_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/authenticator_verification_screen.dart';
import '../screens/my_reviews_screen.dart';
import '../screens/followed_sellers_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/favorite_providers_screen.dart';
import '../screens/pdf_preview_screen.dart';
import '../screens/select_role_screen.dart';
import '../screens/buyer_onboarding_screen.dart';
import '../screens/provider_onboarding_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/flash_offers_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/select-role',
      builder: (context, state) => const SelectRoleScreen(),
    ),
    GoRoute(
      path: '/buyer-onboarding',
      builder: (context, state) => const BuyerOnboardingScreen(),
    ),
    GoRoute(
      path: '/provider-onboarding',
      builder: (context, state) => const ProviderOnboardingScreen(),
    ),
    GoRoute(
      path: '/home-feed',
      builder: (context, state) => const HomeFeedScreen(),
    ),
    GoRoute(
      path: '/cart-screen',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/providers-screen',
      builder: (context, state) => const ProvidersScreen(),
    ),
    GoRoute(
      path: '/chat-list',
      builder: (context, state) => const ChatListScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        int currentIndex = 0;
        final path = state.uri.path;
        if (path.startsWith('/home')) {
          currentIndex = 0;
        } else if (path.startsWith('/cart')) {
          currentIndex = 1;
        } else if (path.startsWith('/providers')) {
          currentIndex = 2; // mercado
        } else if (path.startsWith('/favorites')) {
          currentIndex = 3;
        } else if (path.startsWith('/chats')) {
          currentIndex = 4;
        }
        
        return Scaffold(
          body: child,
          extendBody: true,
          bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeFeedScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  // When returning to home, it slides from the right, simulating 
                  // the chat screen hiding (exiting) to the left.
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/chats',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ChatListScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/cart',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CartScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/providers',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProvidersScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                child: child,
              );
            },
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/provider',
      pageBuilder: (context, state) {
        final provider = state.extra as Map<String, dynamic>;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ProviderProfileScreen(provider: provider),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/flash-offers',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const FlashOffersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/chat-detail',
      builder: (context, state) {
        final provider = state.extra as Map<String, dynamic>?;
        return ChatDetailScreen(provider: provider);
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/order-history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OrderHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/tasks',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const TasksScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/all-tasks',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AllTasksScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HelpSupportScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/market-analysis',
      builder: (context, state) => const MarketAnalysisScreen(),
    ),
    GoRoute(
      path: '/market-price-detail',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final item = extra['item'] as Map<String, dynamic>? ?? {};
        final product = extra['product'] as Map<String, dynamic>? ?? {};
        final isWholesale = extra['isWholesale'] as bool? ?? false;
        return CustomTransitionPage(
          key: state.pageKey,
          child: MarketPriceDetailScreen(
            item: item,
            product: product,
            isWholesale: isWholesale,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/language',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LanguageScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/alerts',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AlertsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/privacy',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PrivacyScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/reported-users',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ReportedUsersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/legal-policies',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LegalPoliciesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/coupons',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CouponsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/my-reviews',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyReviewsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/favorite-providers',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const FavoriteProvidersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/negotiations',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NegotiationsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/negotiation-detail',
      pageBuilder: (context, state) {
        final negotiation = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: NegotiationDetailScreen(negotiation: negotiation),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ChangePasswordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/account-config',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AccountConfigScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/active-devices',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ActiveDevicesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/2fa-config',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const TwoFactorAuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/2fa-sms',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SmsVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/2fa-email',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const EmailVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/2fa-authenticator',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AuthenticatorVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/followed-sellers',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const FollowedSellersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/product_detail',
      pageBuilder: (context, state) {
        final product = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: ProductDetailScreen(product: product),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/pdf_preview',
      pageBuilder: (context, state) {
        final negotiation = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: PdfPreviewScreen(negotiation: negotiation),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
              child: child,
            );
          },
        );
      },
    ),
  ],
);

