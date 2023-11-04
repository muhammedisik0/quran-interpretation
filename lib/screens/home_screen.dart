import 'package:flutter/material.dart';
import 'package:kuran_meali/constants/path_constants.dart';
import 'package:kuran_meali/constants/route_constants.dart';
import 'package:kuran_meali/constants/snackbar_text_constants.dart';
import 'package:kuran_meali/constants/text_constants.dart';
import 'package:kuran_meali/widgets/pdf_viewer_widget.dart';
import 'package:kuran_meali/widgets/pin_icon_button_widget.dart';
import '../constants/color_constants.dart';
import '../widgets/add_icon_button_widget.dart';
import '../helpers/snackbar_helper.dart';
import '../models/note_model.dart';
import '../widgets/custom_icon_button_widget.dart';
import 'package:pdfx/pdfx.dart';

import '../constants/surah_constants.dart';
import '../helpers/dialog_helper.dart';
import '../models/surah_model.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PdfController pdfController;
  late Surah currentSurah;

  bool isPinned = true;

  @override
  void initState() {
    super.initState();
    createPdfController();
    currentSurah = Surah(StorageService.surahLatestRead, 0, 0);
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  void createPdfController() {
    pdfController = PdfController(
      document: PdfDocument.openAsset(PathConstants.pdfQuran),
      initialPage: StorageService.pageNumber,
    );
  }

  void detectSurah(int page) {
    final index = SurahConstants.listOfSurah.indexWhere((surah) {
      return page >= surah.startsFrom && page < surah.ends;
    });
    currentSurah = SurahConstants.listOfSurah[index];
  }

  void onPageChanged(int value) {
    detectSurah(value);
    isPinned = value == StorageService.pageNumber ? true : false;
    setState(() {});
  }

  void navigateToSettingsScreen() {
    Navigator.pushNamed(context, RouteConstants.settings);
  }

  void onPinIconButtonPressed() {
    isPinned = true;
    StorageService.pageNumber = pdfController.page;
    SnackBarHelper.showSnackBar(SnackBarTextConstants.pinnedPage);
    setState(() {});
  }

  Future<void> onAddIconButtonPressed() async {
    final result = await DialogHelper.showAddNoteDialog(context) as List;
    final isAdded = result.first;
    if (isAdded) {
      final note = result.last as Note;
      final listOfMyNotes = StorageService.listOfMyNotes;
      listOfMyNotes.add(note);
      StorageService.listOfMyNotes = listOfMyNotes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: body,
    );
  }

  AppBar get appBar {
    print('appbar--------');
    return AppBar(
      backgroundColor: ColorConstants.teal,
      title: Text('${currentSurah.name} ${TextConstants.surahOf}'),
      centerTitle: true,
      leading: settingsIconButton,
    );
  }

  Widget get settingsIconButton {
    return CustomIconButton(
      onPressed: navigateToSettingsScreen,
      icon: const Icon(Icons.menu),
    );
  }

  Widget get body {
    print('body');
    return Stack(
      alignment: Alignment.center,
      children: [
        pdfSection,
        Positioned(
          top: 10,
          right: 16,
          child: PinIconButton(
            onPressed: onPinIconButtonPressed,
            isPinned: isPinned,
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: pageNumber,
        ),
        Positioned(
          bottom: 64,
          right: 16,
          child: AddIconButton(onPressed: onAddIconButtonPressed),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: pageNavigationSection,
        ),
        Positioned(
          bottom: 27,
          child: allSurahButton,
        ),
      ],
    );
  }

  Widget get pdfSection {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: PdfView(
        onPageChanged: onPageChanged,
        controller: pdfController,
        scrollDirection:
            StorageService.scrollDirection ? Axis.vertical : Axis.horizontal,
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(color: ColorConstants.teal),
          ),
          pageLoaderBuilder: (_) {
            return const Center(
              child: CircularProgressIndicator(color: ColorConstants.lightTeal),
            );
          },
        ),
      ),
    );
  }

  Widget get pageNumber {
    return PdfPageNumber(
      controller: pdfController,
      builder: (context, loadingState, page, pagesCount) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: ColorConstants.lightTeal,
        ),
        child: Text(
          '$page/${pagesCount ?? 0}',
          style: const TextStyle(
            fontSize: 14,
            color: ColorConstants.black,
          ),
        ),
      ),
    );
  }

  Widget get pageNavigationSection {
    return Container(
      height: 56,
      color: ColorConstants.teal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          fivePagesBackIconButton,
          previousIconButton,
          const SizedBox(width: 20),
          nextIconButton,
          fivePagesForwardIconButton,
        ],
      ),
    );
  }

  Widget get previousIconButton {
    return CustomIconButton(
      onPressed: () {
        pdfController.previousPage(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 100),
        );
      },
      icon: const Icon(Icons.navigate_before),
    );
  }

  Widget get nextIconButton {
    return CustomIconButton(
      onPressed: () {
        pdfController.nextPage(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 100),
        );
      },
      icon: const Icon(Icons.navigate_next),
    );
  }

  Widget get fivePagesBackIconButton {
    return CustomIconButton(
      onPressed: () => pdfController.jumpToPage(pdfController.page - 5),
      icon: const Icon(Icons.keyboard_double_arrow_left),
    );
  }

  Widget get fivePagesForwardIconButton {
    return CustomIconButton(
      onPressed: () => pdfController.jumpToPage(pdfController.page + 5),
      icon: const Icon(Icons.keyboard_double_arrow_right),
    );
  }

  Widget get allSurahButton {
    return GestureDetector(
      onTap: () => DialogHelper.showSurahDialog(context, pdfController),
      child: CircleAvatar(
        radius: 31,
        backgroundColor: ColorConstants.white,
        child: CircleAvatar(
          radius: 28,
          backgroundColor: ColorConstants.teal,
          child: Image.asset(PathConstants.icQuran, width: 28),
        ),
      ),
    );
  }
}
