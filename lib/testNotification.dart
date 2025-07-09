import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class DataChangeDemo extends StatefulWidget {
  @override
  _DataChangeDemoState createState() => _DataChangeDemoState();
}

class _DataChangeDemoState extends State<DataChangeDemo> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Change Notifications'),
      ),
      body: Column(
        children: [
          // Input form
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addItem,
                        child: Text('Add Item'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['title'] ?? 'No Title'),
                      subtitle: Text(data['description'] ?? 'No Description'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editItem(doc.id, data),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteItem(doc.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_titleController.text.isNotEmpty) {
      FirestoreService.addItem(
          _titleController.text, _descriptionController.text);
      _titleController.clear();
      _descriptionController.clear();
    }
  }

  void _editItem(String itemId, Map<String, dynamic> currentData) {
    _titleController.text = currentData['title'] ?? '';
    _descriptionController.text = currentData['description'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirestoreService.updateItem(
                  itemId, _titleController.text, _descriptionController.text);
              Navigator.pop(context);
              _titleController.clear();
              _descriptionController.clear();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String itemId) {
    FirestoreService.deleteItem(itemId);
  }
}
