import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/shared/presentation/widgets/infinite_draggable_slider.dart';
import '../../../magazines_details/presentation/screens/magazines_details_screen.dart';
import '../widgets/all_editions_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.enableEntryAnimation = false,
    this.initialIndex = 0,
  });

  final bool enableEntryAnimation;
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Magazine> magazines = Magazine.fakeMagazinesValues;
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openMagazineDetail(
    BuildContext context,
    int index,
  ) {
    setState(() => currentIndex = index);
    MagazinesDetailsScreen.push(
      context,
      magazines: magazines,
      index: currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ViceUIConsts.gradientDecoration,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _AppBar(),
        body: Column(
          children: [
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(ViceIcons.search),
                ),
              ),
            ),
            SizedBox(height: 20),
            const Text(
              'THE ARCHIVE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),

            // Infinite Draggable Slider
            Expanded(
              
                child: Container(
                  // color: Colors.red.withOpacity(.4),
                  child: InfiniteDraggableSlider(
                    itemCount: Magazine.fakeMagazinesValues.length,
                    itemBuilder: (context, index) => MagazineCoverImage(magazine: Magazine.fakeMagazinesValues[index],),
                  
                  ),
                )),

            // Infinite Draggable Slider END..............

            SizedBox(height: 72),
            SizedBox(
              height: 140,
              child: AllEditionsListView(magazines: magazines),
            ),
            SizedBox(height: 12),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.home),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.settings),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.share),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(ViceIcons.heart),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _AppBar extends StatelessWidget implements PreferredSize {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      clipBehavior: Clip.none,
      title: Image.asset(
        'assets/img/vice/vice-logo.png',
        height: 30,
        color: Colors.white,
      ),
      actions: [
        const MenuButton(),
      ],
    );
  }

  @override
  Widget get child => this;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
