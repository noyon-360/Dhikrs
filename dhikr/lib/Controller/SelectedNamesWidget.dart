import 'package:flutter/material.dart';
import 'package:dhikr/Controller/NameClass.dart';
import 'package:dhikr/ListOfAllName/ListOfAllNameInBangla.dart';

class SelectedNamesWidget extends StatelessWidget {
  final List<AllahName> selectedNames;
  final bool isEnglish;

  const SelectedNamesWidget({
    super.key,
    required this.selectedNames,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedNames.isEmpty) {
      return const Center(
        child: Text('Nothing selected'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: selectedNames.length,
        itemBuilder: (context, index) {
          final name = isEnglish
              ? selectedNames[index].name
              : allahNamesBangla
                  .firstWhere(
                      (element) => element.name == selectedNames[index].name)
                  .name;
          final meaning = isEnglish
              ? selectedNames[index].meaning
              : allahNamesBangla
                  .firstWhere(
                      (element) => element.name == selectedNames[index].name)
                  .meaning;

          return ListTile(
            title: Text(
              '$name - $meaning',
              style: const TextStyle(fontSize: 16.0),
            ),
          );
        },
      );
    }
  }
}
