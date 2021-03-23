import 'dart:html';

import 'package:example_web/main.dart';
import 'package:example_web/widgets/entry_list.dart';
import 'package:flutter_web/material.dart';

import 'create_entry_bar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = DatabaseProvider.provide(context);
    final headerTheme = Theme.of(context).textTheme.title;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moor Web'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Moor web'),
                    content: const Text(
                        'Simple demonstration of moor web: This whole page '
                        'is a offline-capable Flutter app using sql.js to '
                        'store data!'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Moor'),
                        onPressed: () {
                          window.open('https://moor.simonbinder.eu/', 'Moor');
                        },
                      ),
                      FlatButton(
                        child: const Text('sql.js'),
                        onPressed: () {
                          window.open(
                              'https://github.com/kripken/sql.js/', 'sql.js');
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: CreateEntryBar(),
                ),
                SliverToBoxAdapter(
                  child: Text('In progress', style: headerTheme),
                ),
                SliverEntryList(
                  entries: db.incompleteEntries(),
                ),
                SliverToBoxAdapter(
                  child: Text('Complete', style: headerTheme),
                ),
                SliverEntryList(
                  entries: db.newestDoneEntries(),
                ),
                SliverToBoxAdapter(
                  child: StreamBuilder<List<int>>(
                    builder: (context, snapshot) {
                      final hiddenCount = snapshot?.data?.single ?? 0;

                      return Text('Not showing $hiddenCount older entries');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
