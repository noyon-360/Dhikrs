import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dhikr/Controller/CustomTranslationSelector.dart';
import 'package:dhikr/Controller/NameClass.dart';
import 'package:dhikr/Controller/Provider/AllahNamesProvider.dart';
import 'package:dhikr/Controller/Provider/CustomAddProvider.dart';
import 'package:dhikr/Controller/Provider/DhirkProvider.dart';
import 'package:dhikr/Controller/Provider/TimerProvider.dart';
import 'package:dhikr/Controller/Provider/UserSavedProvider.dart';
import 'package:dhikr/Helper/Color.dart';
import 'package:dhikr/ListOfAllName/Dhikrs.dart';
import 'package:dhikr/ListOfAllName/ListOfAllNameInBangla.dart';

class Listofdhikrs extends StatefulWidget {
  final bool isEmbedded;
  const Listofdhikrs({super.key, this.isEmbedded = false});

  @override
  State<Listofdhikrs> createState() => _ListofdhikrsState();
}

class _ListofdhikrsState extends State<Listofdhikrs>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isMobileDevice = false;

  final FocusNode _duaFocusNode = FocusNode();
  final FocusNode _translationFocusNode = FocusNode();

  // var customData;

  @override
  void initState() {
    super.initState();
    // bool isEmbedded = widget.isEmbedded;
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _searchController.addListener(_filterNames);
    _platformCheck();
    _duaFocusNode.addListener(_showLanguageSupportMessage);
    _translationFocusNode.addListener(_showLanguageSupportMessage);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  void _platformCheck() {
    if (Platform.isAndroid || Platform.isIOS) {
      _isMobileDevice = true;
    } else {
      _isMobileDevice = false;
    }
  }

  void _filterNames() {
    context.read<AllahNamesProvider>().filterNames(_searchController.text);
    context
        .read<DhikrProvider>()
        .filterDhikrs(_searchController.text); // Update for DhikrProvider
  }

  void _showLanguageSupportMessage() {
    String message = '';
    if (_duaFocusNode.hasFocus) {
      message = 'Only Arabic language is supported for Dhikr';
    } else if (_translationFocusNode.hasFocus) {
      message =
          'Only English and Bangla languages are supported for Translation';
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  //Todo: check isEnglishSelected are work properly or not, because isEnglishSelected in two area
  void _showAddDialog(bool isEnglishSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController customDhikr = TextEditingController();
        final TextEditingController customTranslation = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'Add Dhikr',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    focusNode: _duaFocusNode,
                    controller: customDhikr,
                    decoration: const InputDecoration(
                      labelText: 'Dhikr',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Colors.green),
                          ),
                      focusedBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Colors.green),
                          ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[ء-ي\s]')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _translationFocusNode,
                          controller: customTranslation,
                          decoration: const InputDecoration(
                            labelText: 'Translation',
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.green),
                                ),
                            focusedBorder: OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.green),
                                ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              isEnglishSelected
                                  ? RegExp(r'[a-zA-Z\s]')
                                  : RegExp(r'[ঀ-৿\s]'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      CustomTranslationSelector(
                        isEnglishSelected: isEnglishSelected,
                        onEnglishSelected: () {
                          setState(() {
                            isEnglishSelected = true;
                          });
                        },
                        onBanglaSelected: () {
                          setState(() {
                            isEnglishSelected = false;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final name = customDhikr.text;
                    final meaning = customTranslation.text;
                    if (name.isNotEmpty && meaning.isNotEmpty) {
                      // Save the new Dhikr using Provider
                      final entry = NameEntry(name: name, meaning: meaning);
                      Provider.of<CustomAddProvider>(context, listen: false)
                          .addName(entry);
                      customDhikr.clear();
                      customTranslation.clear();
                      // Clear fields and close dialog
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter Dhikr'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    // primary: Colors.white,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, NameEntry entry) {
    final TextEditingController customDhikr =
        TextEditingController(text: entry.name);
    final TextEditingController customTranslation =
        TextEditingController(text: entry.meaning);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Dhikr',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customDhikr,
                decoration: const InputDecoration(
                  labelText: 'Dhikr',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[ء-ي\s]')),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: customTranslation,
                decoration: const InputDecoration(
                  labelText: 'Translation',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final name = customDhikr.text;
                final meaning = customTranslation.text;
                if (name.isNotEmpty && meaning.isNotEmpty) {
                  Provider.of<CustomAddProvider>(context, listen: false)
                      .updateName(entry, name, meaning);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter Dhikr and Translation'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(
      BuildContext context, NameEntry entry, Offset offset) async {
    await showMenu(
      context: context,
      position:
          RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showEditDialog(
            context, entry); // You can handle isEnglishSelected appropriately
      } else if (value == 'delete') {
        Provider.of<CustomAddProvider>(context, listen: false)
            .removeName(entry);
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNames);

    // _searchController.removeListener(_checkSearchFieldEmpty);
    _searchController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();

    _duaFocusNode.removeListener(_showLanguageSupportMessage);
    _duaFocusNode.dispose();
    _translationFocusNode.removeListener(_showLanguageSupportMessage);
    _translationFocusNode.dispose();
    super.dispose();
  }

  Widget buildTranslationSelector(
      TimerProvider timerProvider, bool isEnglishSelected) {
    return CustomTranslationSelector(
      isEnglishSelected: isEnglishSelected,
      onEnglishSelected: () {
        setState(() {
          timerProvider.setTranslation(true);
        });
      },
      onBanglaSelected: () {
        setState(() {
          timerProvider.setTranslation(false);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allahNamesProvider = context.watch<AllahNamesProvider>();
    final customAddProvider = context.watch<CustomAddProvider>();
    final dhikrProvider = context.watch<DhikrProvider>();
    final timerProvider = context.watch<TimerProvider>();
    final userSaveDuaProvider = context.watch<UserSaveDuaProvider>();

    final isEnglishSelected = timerProvider.isEnglishSelected;

    Widget bodyContent = GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: _buildBody(isEnglishSelected, allahNamesProvider,
          customAddProvider, dhikrProvider, timerProvider, userSaveDuaProvider),
    );

    if (widget.isEmbedded) {
      return bodyContent;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("List of Dhikr's"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: buildTranslationSelector(timerProvider, isEnglishSelected),
            ),
          ],
        ),
        body: bodyContent,
        floatingActionButton: _isMobileDevice
            ? _tabController.index == 2
                ? FloatingActionButton(
                    backgroundColor: AppColors.primaryColor,
                    onPressed: () {
                      _showAddDialog(isEnglishSelected);
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  )
                : null
            : null,
      );
    }
  }

  Widget _buildBody(
      bool isEnglishSelected,
      AllahNamesProvider allahNamesProvider,
      CustomAddProvider customAddProvider,
      DhikrProvider dhikrProvider,
      TimerProvider timerProvider,
      UserSaveDuaProvider userSaveDuaProvider) {
    return _isMobileDevice
        ? _buildMobileBody(
            isEnglishSelected,
            allahNamesProvider,
            customAddProvider,
            dhikrProvider,
            timerProvider,
            userSaveDuaProvider)
        : _buildDesktopBody(
            isEnglishSelected,
            allahNamesProvider,
            customAddProvider,
            dhikrProvider,
            timerProvider,
            userSaveDuaProvider);
  }

  Widget _buildMobileBody(
      bool isEnglishSelected,
      AllahNamesProvider allahNamesProvider,
      CustomAddProvider customAddProvider,
      DhikrProvider dhikrProvider,
      TimerProvider timerProvider,
      UserSaveDuaProvider userSaveDuaProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isMobileDevice
            ? Container()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Switch Translation:'),
                          const SizedBox(width: 10),
                          buildTranslationSelector(
                              timerProvider, isEnglishSelected),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 2, 151, 9),
                          ),
                        ),
                        labelText: "Search",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryColor,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: '99 Names of Allah'),
            Tab(text: "Dhikr's"),
            Tab(
              text: "Saved",
            ),
            Tab(text: 'Selected'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDhikrListView(
                  isEnglishSelected, allahNamesProvider, userSaveDuaProvider),
              _buildDuasListView(
                  isEnglishSelected, dhikrProvider, userSaveDuaProvider),
              _buildSaveListView(isEnglishSelected, customAddProvider),
              // const Center(
              //   child: Text("nothing"),
              // ),
              // _buildCustomDhikrsTab(isEnglishSelected, nameProvider),
              // Center(
              //   child: SelectedNamesWidget(
              //     selectedNames: allahNamesProvider.getSelectedNames(),
              //     isEnglish: isEnglishSelected,
              //   ),
              // ),
              _savedDuasWidget(isEnglishSelected, allahNamesProvider,
                  dhikrProvider, customAddProvider, userSaveDuaProvider)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBody(
      bool isEnglishSelected,
      AllahNamesProvider allahNamesProvider,
      CustomAddProvider customAddProvider,
      DhikrProvider dhikrProvider,
      TimerProvider timerProvider,
      UserSaveDuaProvider userSaveDuaProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: const BoxDecoration(
            // borderRadius: BorderRadius.all(Radius.circular(10)),
            // color: Color.fromARGB(255, 243, 61, 61),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Switch Translation:'),
                      const SizedBox(width: 10),
                      buildTranslationSelector(
                          timerProvider, isEnglishSelected),
                    ],
                  ),
                ),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 2, 151, 9),
                      ),
                    ),
                    labelText: "Search",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryColor,
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: '99 Names of Allah'),
                    Tab(text: "Dhikr's"),
                    Tab(
                      text: "Saved",
                    ),
                    Tab(text: 'Selected'),
                  ],
                ),
                // const SizedBox(height: 20),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDhikrListView(isEnglishSelected, allahNamesProvider,
                      userSaveDuaProvider),
                  _buildDuasListView(
                      isEnglishSelected, dhikrProvider, userSaveDuaProvider),
                  _buildSaveListView(isEnglishSelected, customAddProvider),

                  // const Center(
                  //   child: Text("nothing"),
                  // ),
                  // _buildCustomDhikrsTab(isEnglishSelected, nameProvider),
                  // Center(
                  //   child: SelectedNamesWidget(
                  //     selectedNames: allahNamesProvider.getSelectedNames(),
                  //     isEnglish: isEnglishSelected,
                  //   ),
                  // ),
                  _savedDuasWidget(isEnglishSelected, allahNamesProvider,
                      dhikrProvider, customAddProvider, userSaveDuaProvider)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrListView(
      bool isEnglishSelected,
      AllahNamesProvider allahNamesProvider,
      UserSaveDuaProvider userSaveDuaProvider) {
    bool allSelected =
        allahNamesProvider.filteredNames.every((name) => name.isSelected);

    int totalSelected = allahNamesProvider.selectedNamesCount;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            totalSelected == 0
                ? Text("Select All")
                : Text("Total Selected $totalSelected"),
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      allahNamesProvider.deselectAllNames();
                      // Uncomment these if you want to include them
                      // dhikrProvider.deselectAllDhikrs();
                      // customAddProvider.deselectAllNames();
                    } else {
                      allahNamesProvider.selectAllNames();
                      // Uncomment these if you want to include them
                      // dhikrProvider.selectAllDhikrs();
                      // customAddProvider.selectAllNames();
                    }
                  });
                },
                icon: allSelected
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: allahNamesProvider.filteredNames.length,
            itemBuilder: (context, index) {
              var name = allahNamesProvider.filteredNames[index];
              var banglaName = allahNamesBangla
                  .firstWhere((element) => element.name == name.name);
              return Card(
                color: Colors.grey.shade200,
                child: CheckboxListTile(
                  activeColor: AppColors.primaryColor,
                  title: RichText(
                    text: TextSpan(
                      children: _highlightMatches(
                        isEnglishSelected ? name.name : banglaName.name,
                        isEnglishSelected ? name.meaning : banglaName.meaning,
                        _searchController.text,
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  value: name.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        allahNamesProvider.saveSelectedName(name);
                        // Provider.of<UserSaveDuaProvider>(context, listen: false)
                        //     .addDua(name.toNameEntry());
                      } else {
                        allahNamesProvider.removeSelectedName(name);
                        // Provider.of<UserSaveDuaProvider>(context, listen: false)
                        //     .removeDua(name.toNameEntry());
                      }
                      allahNamesProvider.toggleSelection(name, value ?? false);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDuasListView(bool isEnglishSelected, DhikrProvider dhikrProvider,
      UserSaveDuaProvider userSaveDuaProvider) {
    bool allSelected =
        dhikrProvider.filteredDhikrs.every((name) => name.isSelected);

    int totalSelected = dhikrProvider.selectedDhikrCount;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            totalSelected == 0
                ? Text("Select All")
                : Text("Total Selected $totalSelected"),
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      // allahNamesProvider.deselectAllNames();
                      // Uncomment these if you want to include them
                      dhikrProvider.deselectAllDhikrs();
                      // customAddProvider.deselectAllNames();
                    } else {
                      // allahNamesProvider.selectAllNames();
                      // Uncomment these if you want to include them
                      dhikrProvider.selectAllDhikrs();
                      // customAddProvider.selectAllNames();
                    }
                  });
                },
                icon: allSelected
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dhikrProvider.filteredDhikrs.length,
            itemBuilder: (context, index) {
              var dhikr = dhikrProvider.filteredDhikrs[index];
              var banglaDhikr = mostCommonDhikrBangla
                  .firstWhere((element) => element.name == dhikr.name);
              return Card(
                color: Colors.grey.shade200,
                child: CheckboxListTile(
                  activeColor: AppColors.primaryColor,
                  title: RichText(
                    text: TextSpan(
                      children: _highlightMatches(
                        isEnglishSelected ? dhikr.name : banglaDhikr.name,
                        isEnglishSelected ? dhikr.meaning : banglaDhikr.meaning,
                        _searchController.text,
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  value: dhikr.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        dhikrProvider.saveSelectedDhikr(dhikr);
                        // Provider.of<UserSaveDuaProvider>(context, listen: false)
                        //     .addDua(dhikr.toNameEntry());
                      } else {
                        dhikrProvider.removeSelectedDhikr(dhikr);
                        // Provider.of<UserSaveDuaProvider>(context, listen: false)
                        //     .removeDua(dhikr.toNameEntry());
                      }
                      dhikrProvider.toggleDhikrSelection(dhikr, value ?? false);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveListView(
    bool isEnglishSelected,
    CustomAddProvider customAddProvider,
  ) {
    final TextEditingController customDhikr = TextEditingController();
    final TextEditingController customTranslation = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isMobileDevice)
            TextField(
              focusNode: _isMobileDevice ? _duaFocusNode : null,
              controller: customDhikr,
              // onChanged: (value) {
              //   customDhikr = value;
              // },
              decoration: const InputDecoration(
                labelText: 'Dhikr',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                    // borderSide: BorderSide(color: Colors.green),
                    ),
                focusedBorder: OutlineInputBorder(
                    // borderSide: BorderSide(color: Colors.green),
                    ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[ء-ي\s]')),
              ],
            ),
          // const SizedBox(height: 5),
          if (!_isMobileDevice)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                'Input should be in Arabic characters.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          // const SizedBox(height: 10),
          if (!_isMobileDevice)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          focusNode:
                              _isMobileDevice ? _translationFocusNode : null,
                          controller: customTranslation,
                          // onChanged: (value) {
                          //   customTranslation = value;
                          // },
                          decoration: const InputDecoration(
                            labelText: 'Translation',
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.green),
                                ),
                            focusedBorder: OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.green),
                                ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              isEnglishSelected
                                  ? RegExp(r'[a-zA-Z\s]')
                                  : RegExp(r'[ঀ-৿\s]'),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 5),
                        if (!Platform.isAndroid && !Platform.isIOS)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              isEnglishSelected
                                  ? 'Input should be in English characters.'
                                  : 'Input should be in Bangla characters.',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // const SizedBox(width: 10),
                  if (_isMobileDevice)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: CustomTranslationSelector(
                        isEnglishSelected: isEnglishSelected,
                        onEnglishSelected: () {
                          setState(() {
                            isEnglishSelected = true;
                          });
                        },
                        onBanglaSelected: () {
                          setState(() {
                            isEnglishSelected = false;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          if (!_isMobileDevice)
            TextButton(
              onPressed: () {
                final name = customDhikr.text;
                final meaning = customTranslation.text;
                if (name.isNotEmpty && meaning.isNotEmpty) {
                  // Save the new Dhikr using Provider
                  final entry = NameEntry(name: name, meaning: meaning);
                  Provider.of<CustomAddProvider>(context, listen: false)
                      .addName(entry);
                  // Clear fields and close dialog
                  // Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter Dhikr'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                // primary: Colors.white,
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          Expanded(
            child: Consumer<CustomAddProvider>(
                builder: (context, customAddProvider, child) {
              final filteredCustomName =
                  customAddProvider.customNames.where((entry) {
                final searchText = _searchController.text.toLowerCase();
                return entry.name.toLowerCase().contains(searchText) ||
                    entry.meaning.toLowerCase().contains(searchText);
              }).toList();

              return Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: filteredCustomName.length,
                          itemBuilder: (context, index) {
                            var entry = filteredCustomName[index];
                            return GestureDetector(
                              onLongPress: () {
                                if (Platform.isAndroid || Platform.isIOS) {
                                  _showContextMenu(context, entry, Offset.zero);
                                }
                              },
                              onSecondaryTapDown: (details) {
                                if (!Platform.isAndroid && !Platform.isIOS) {
                                  _showContextMenu(
                                      context, entry, details.globalPosition);
                                }
                              },
                              child: Card(
                                color: Colors.grey.shade200,
                                child: CheckboxListTile(
                                  activeColor: AppColors.primaryColor,
                                  title: RichText(
                                    text: TextSpan(
                                        children: _highlightMatches(
                                            entry.name,
                                            entry.meaning,
                                            _searchController.text),
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black)),
                                  ),
                                  subtitle: const Text("time"),
                                  // value: customAddProvider.customNames
                                  //     .contains(entry),
                                  value: entry.isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      customAddProvider.toggleSelection(
                                          entry, value ?? false);
                                      if (value == true) {
                                        Provider.of<UserSaveDuaProvider>(
                                                context,
                                                listen: false)
                                            .addDua(entry);
                                      } else {
                                        Provider.of<UserSaveDuaProvider>(
                                                context,
                                                listen: false)
                                            .removeDua(entry);
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          })),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _savedDuasWidget(
    bool isEnglishSelected,
    AllahNamesProvider allahNamesProvider,
    DhikrProvider dhikrProvider,
    CustomAddProvider customAddProvider,
    UserSaveDuaProvider userSaveDuaProvider,
  ) {
    List<AllahName> selectedNames = allahNamesProvider.getSelectedNames();
    List<Dhikr> selectedDhikrs = dhikrProvider.getSelectedDhikrs();
    // List<NameEntry> userAddedList = userSaveDuaProvider.getSelectedSaved();
    List<NameEntry> customAddList = customAddProvider.getCustomSelectedNames();

    if (selectedNames.isEmpty &&
        selectedDhikrs.isEmpty &&
        customAddList.isEmpty) {
      return const Center(
        child: Text('No selected items'),
      );
    }

    final allItems = [...selectedNames, ...selectedDhikrs, ...customAddList];
    String name;
    String meaning;
    return Column(
      children: [
        // ElevatedButton(
        //   onPressed: () async {
        //     SharedPreferences prefs = await SharedPreferences.getInstance();
        //     await prefs.clear();
        //   },
        //   child: const Text('Delete Selected'),
        // ),
        Expanded(
          child: ListView.builder(
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              var item = allItems[index];

              if (item is AllahName) {
                name = isEnglishSelected
                    ? item.name
                    : allahNamesBangla
                        .firstWhere((element) => element.name == item.name)
                        .name;
                meaning = isEnglishSelected
                    ? item.meaning
                    : allahNamesBangla
                        .firstWhere((element) => element.name == item.name)
                        .meaning;
              } else if (item is Dhikr) {
                name = isEnglishSelected
                    ? item.name
                    : mostCommonDhikrBangla
                        .firstWhere((element) => element.name == item.name)
                        .name;
                meaning = isEnglishSelected
                    ? item.meaning
                    : mostCommonDhikrBangla
                        .firstWhere((element) => element.name == item.name)
                        .meaning;
              } else if (item is NameEntry) {
                name = item.name;
                meaning = item.meaning;
              } else {
                name = '';
                meaning = '';
              }

              return Card(
                color: Colors.grey.shade200,
                child: ListTile(
                  title: RichText(
                    text: TextSpan(
                        children: _highlightMatches(
                            name, meaning, _searchController.text),
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.black)),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deselect'),
                              content: const Text(
                                  'Are you sure you want to deselect this item?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    if (item is AllahName) {
                                      allahNamesProvider.toggleSelection(
                                          item, false);
                                    } else if (item is Dhikr) {
                                      dhikrProvider.toggleDhikrSelection(
                                          item, false);
                                    } else if (item is NameEntry) {
                                      customAddProvider.toggleSelection(
                                          item, false);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.remove_circle_outline)),
                ),
                // child: CheckboxListTile(
                //   title: Text(
                //     name,
                //     style:
                //         const TextStyle(fontSize: 16.0, color: Colors.black),
                //   ),
                //   subtitle: Text(
                //     meaning,
                //     style:
                //         const TextStyle(fontSize: 14.0, color: Colors.grey),
                //   ),
                //   value: isSelected,
                //   onChanged: (bool? value) {
                //     // // Uncheck the item and remove from the provider's list
                //     // if (item is AllahName) {
                //     //   allahNamesProvider.toggleSelection(
                //     //       item, value ?? false);
                //     // } else if (item is Dhikr) {
                //     //   dhikrProvider.toggleDhikrSelection(
                //     //       item, value ?? false);
                //     // } else if (item is NameEntry) {
                //     //   customAddProvider.toggleSelection(item, value ?? false);
                //     // }
                //     showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return AlertDialog(
                //           title: const Text('Confirm Deselect'),
                //           content: const Text(
                //               'Are you sure you want to deselect this item?'),
                //           actions: [
                //             TextButton(
                //               child: const Text('Cancel'),
                //               onPressed: () {
                //                 Navigator.of(context).pop();
                //               },
                //             ),
                //             TextButton(
                //               child: const Text('Yes'),
                //               onPressed: () {
                //                 if (item is AllahName) {
                //                   allahNamesProvider.toggleSelection(
                //                       item, false);
                //                 } else if (item is Dhikr) {
                //                   dhikrProvider.toggleDhikrSelection(
                //                       item, false);
                //                 } else if (item is NameEntry) {
                //                   customAddProvider.toggleSelection(
                //                       item, false);
                //                 }
                //                 Navigator.of(context).pop();
                //               },
                //             ),
                //           ],
                //         );
                //       },
                //     );
                //   },
                // ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<TextSpan> _highlightMatches(
    String name,
    String meaning,
    String query,
  ) {
    final List<TextSpan> spans = [];
    final nameLower = name.toLowerCase();
    final meaningLower = meaning.toLowerCase();
    final queryLower = query.toLowerCase();

    if (queryLower.isNotEmpty) {
      final queryRegExp =
          RegExp(RegExp.escape(queryLower), caseSensitive: false);

      // Highlight matches in the name
      final matchesName = queryRegExp.allMatches(nameLower);
      if (matchesName.isNotEmpty) {
        int lastMatchEnd = 0;
        for (final match in matchesName) {
          if (match.start > lastMatchEnd) {
            spans
                .add(TextSpan(text: name.substring(lastMatchEnd, match.start)));
          }
          spans.add(
            TextSpan(
              text: name.substring(match.start, match.end),
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          );
          lastMatchEnd = match.end;
        }
        if (lastMatchEnd < name.length) {
          spans.add(TextSpan(text: name.substring(lastMatchEnd)));
        }
      } else {
        spans.add(TextSpan(text: name));
      }

      spans.add(const TextSpan(text: ' - '));

      // Highlight matches in the meaning
      final matchesMeaning = queryRegExp.allMatches(meaningLower);
      if (matchesMeaning.isNotEmpty) {
        int lastMatchEnd = 0;
        for (final match in matchesMeaning) {
          if (match.start > lastMatchEnd) {
            spans.add(
                TextSpan(text: meaning.substring(lastMatchEnd, match.start)));
          }
          spans.add(
            TextSpan(
              text: meaning.substring(match.start, match.end),
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          );
          lastMatchEnd = match.end;
        }
        if (lastMatchEnd < meaning.length) {
          spans.add(TextSpan(text: meaning.substring(lastMatchEnd)));
        }
      } else {
        spans.add(TextSpan(text: meaning));
      }
    } else {
      spans.add(TextSpan(text: '$name - $meaning'));
      //   spans.add(TextSpan(text: name));
      //   spans.add(const TextSpan(text: ' - '));
      //   spans.add(TextSpan(text: meaning));
    }

    return spans;
  }
}
