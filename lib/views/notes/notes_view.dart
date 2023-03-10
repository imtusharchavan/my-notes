import 'package:flutter/material.dart';
import 'package:mynotes/components/nav_bar.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/views/notes/notes_grid_view.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  var viewType = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NabBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.white10,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (viewType == 0) {
                        viewType = 1;
                      } else {
                        viewType = 0;
                      }
                  });
                },
                icon: viewType == 0 ? const Icon(Icons.grid_view_outlined) : const Icon(Icons.list_outlined)
              ),
            ],
          ),
        ],
        body:
        viewType == 0
        ? StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        )
        : StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesGridView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createUpdateNoteRoute);
        },
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18))),
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 4,
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18))),
        ),
        color: Colors.grey.shade200,
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.check_box_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.brush_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.mic_none_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.insert_photo_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
