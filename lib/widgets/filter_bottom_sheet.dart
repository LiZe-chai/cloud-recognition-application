import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Set<CloudType> initialCloudTypes;
  final bool initialSortLatest;
  final Function(Set<CloudType>, bool) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialCloudTypes,
    required this.initialSortLatest,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Set<CloudType> selectedTypes;
  late bool latest;

  final cloudTypes = CloudType.values;

  @override
  void initState() {
    super.initState();
    selectedTypes = {...widget.initialCloudTypes};
    latest = widget.initialSortLatest;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),
              const Text(
                'Filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text('Specific cloud type:',
              style: TextStyle(fontWeight: FontWeight.w600)),

          // ===== Multiple select =====
          ...cloudTypes.map(
                (type) => CheckboxListTile(
              dense: true,
              title: Text(type.label),
              value: selectedTypes.contains(type),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedTypes.add(type);
                  } else {
                    selectedTypes.remove(type);
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 12),
          const Text('Sort by Time',
              style: TextStyle(fontWeight: FontWeight.w600)),

          DropdownButtonFormField<bool>(
            initialValue: latest,
            items: const [
              DropdownMenuItem(value: true, child: Text('Latest')),
              DropdownMenuItem(value: false, child: Text('Oldest')),
            ],
            onChanged: (v) => setState(() => latest = v!),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                widget.onApply(selectedTypes, latest);
                Navigator.pop(context);
              },
              child: const Text('Apply filter'),
            ),
          ),
        ],
      ),
    );
  }
}
