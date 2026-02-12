import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';

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
              Text(
                S.of(context)!.filter,
                style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(S.of(context)!.specificCloudType,
              style: TextStyle(fontWeight: FontWeight.w600,fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize)),
          SizedBox(height: 10),
          ...cloudTypes.map(
                (type) => CheckboxListTile(
              dense: true,
              title: Text(type.label(context),style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize)),
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
          Text(S.of(context)!.sortByTime,
              style: TextStyle(fontWeight: FontWeight.w600,fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,)),
          SizedBox(height: 10),

          DropdownButtonFormField<bool>(
            initialValue: latest,
            items: [
              DropdownMenuItem(value: true, child: Text(S.of(context)!.latest,style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize))),
              DropdownMenuItem(value: false, child: Text(S.of(context)!.oldest,style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize))),
            ],
            onChanged: (v) => setState(() => latest = v!),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                widget.onApply(selectedTypes, latest);
                Navigator.pop(context);
              },
              child: Text(S.of(context)!.applyFilter, style: TextStyle(fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
