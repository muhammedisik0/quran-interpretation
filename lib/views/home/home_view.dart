import 'package:flutter/material.dart';

import 'widgets/home_app_bar_widget.dart';
import 'widgets/page_navigation_bar_widget.dart';
import 'widgets/pdf_viewer_widget.dart';
import 'widgets/tools_box_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HomeAppBar(),
      body: SafeArea(child: PdfViewer()),
      bottomNavigationBar: PageNavigationBar(),
      floatingActionButton: ToolsBox(),
    );
  }
}
