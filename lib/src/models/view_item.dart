// lib/models/view_item.dart

class ViewItem {
  final int viewId;
  String viewTitle; // if you want it editable, keep it non-final
  final int viewTypeId;

  ViewItem({
    required this.viewId,
    required this.viewTitle,
    required this.viewTypeId,
  });

  factory ViewItem.fromJson(Map<String, dynamic> json) {
    return ViewItem(
      viewId: json['view_id'] as int,
      viewTitle: json['view_title'] as String,
      viewTypeId: json['view_type_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'view_id': viewId,
      'view_title': viewTitle,
      'view_type_id': viewTypeId,
    };
  }
}
