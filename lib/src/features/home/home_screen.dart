import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/constants/dimensions.dart';
import '../../common/widgets/center_widgets.dart';
import '../auth/controller/auth_controller.dart';
import '../dashboard/dashboard_screen.dart';

import './widgets/home_widgets.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ScrollController to move scroll position to current focused widget.
    final scrollController = useScrollController();
    final sidebarFSN = useFocusScopeNode();
    final contentScreenFSN = useFocusScopeNode();

    final List<FocusScopeNode> nodes = List.generate(
      4,
      (_) => useFocusScopeNode(),
    );

    // Add a user state to show suitable only the lists that is appropriate for
    // the current login status.
    final asyncAuth = ref.watch(authControllerProvider);

    return DashboardScreen(
      sidebarFSN: sidebarFSN,
      contentScreenFSN: contentScreenFSN,
      contentScreen: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FocusScope(
          node: contentScreenFSN,
          child: asyncAuth.when(
            data: (auth) {
              SchedulerBinding.instance.addPostFrameCallback(
                (_) {
                  final List<double> offsets = [
                    0.0,
                    0.0,
                    auth == null
                        ? 0.0
                        : scrollController.position.maxScrollExtent -
                            Dimensions.followingCategoryContainerSize.height +
                            100.0,
                    scrollController.position.maxScrollExtent,
                  ];

                  for (int i = 0; i < nodes.length; i++) {
                    final node = nodes[i];
                    node.addListener(
                      () {
                        if (node.hasFocus) {
                          scrollController.animateTo(
                            offsets[i],
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    );
                  }
                },
              );

              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeScreenHeader(
                      headerFSN: nodes[0],
                      sidebarFSN: sidebarFSN,
                      belowFSN: auth == null ? nodes[2] : nodes[1],
                    ),
                    if (auth != null)
                      HomeFollowingLives(
                        listFSN: nodes[1],
                        sidebarFSN: sidebarFSN,
                        aboveFSN: nodes[0],
                        belowFSN: nodes[2],
                      ),
                    HomePopularLives(
                      autofocus: auth == null ? true : false,
                      listFSN: nodes[2],
                      sidebarFSN: sidebarFSN,
                      aboveFSN: auth == null ? nodes[0] : nodes[1],
                      belowFSN: nodes[3],
                    ),
                    if (auth != null)
                      HomeFollowingCategories(
                        listFSN: nodes[3],
                        sidebarFSN: sidebarFSN,
                        aboveFSN: nodes[2],
                      ),
                  ],
                ),
              );
            },
            error: (error, stackTrace) => const CenteredText(text: '로그인 에러'),
            loading: () => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
