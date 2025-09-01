import 'package:altera/common/errors/convert_message.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:altera/features/product/domain/entities/labelEntity/Label_entity.dart';
import 'package:altera/features/product/domain/usecases/get_labels_usecase.dart';

class LabelController extends GetxController {
  final GetLabelsUsecase getLabelsUsecase;
  
  LabelController({required this.getLabelsUsecase});
  
  final RxList<LabelEntity> labels = <LabelEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  
  final RxString searchQuery = ''.obs;
  final RxString selectedTipo = ''.obs;
  final RxString selectedUsuario = ''.obs;
  final RxList<LabelEntity> filteredLabels = <LabelEntity>[].obs;
  
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  
  final TextEditingController searchController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    loadLabels();
    
    searchQuery.listen((_) => filterLabels());
    selectedTipo.listen((_) => filterLabels());
    selectedUsuario.listen((_) => filterLabels());
    startDate.listen((_) => filterLabels());
    endDate.listen((_) => filterLabels());
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  Future<void> loadLabels() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final result = await getLabelsUsecase.getLabels();
      labels.value = result;
      filteredLabels.value = result;
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = cleanExceptionMessage(e);;
      labels.clear();
      filteredLabels.clear();
    } finally {
      isLoading.value = false;
    }
  }
  
  void filterLabels() {
    List<LabelEntity> filtered = labels.toList();
    
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((label) {
        final query = searchQuery.value.toLowerCase();
        return label.producto.toLowerCase().contains(query) ||
               label.usuario.nombre.toLowerCase().contains(query) ||
               label.usuario.usuario.toLowerCase().contains(query) ||
               label.tipo.tipo.toLowerCase().contains(query) ||
               label.id.toString().contains(query);
      }).toList();
    }
    
    if (selectedTipo.value.isNotEmpty) {
      filtered = filtered.where((label) {
        return label.tipo.tipo == selectedTipo.value;
      }).toList();
    }
    
    if (selectedUsuario.value.isNotEmpty) {
      filtered = filtered.where((label) {
        return label.usuario.nombre == selectedUsuario.value;
      }).toList();
    }
    
    if (startDate.value != null) {
      filtered = filtered.where((label) {
        return label.fechaHora.isAfter(startDate.value!) ||
               label.fechaHora.isAtSameMomentAs(startDate.value!);
      }).toList();
    }
    
    if (endDate.value != null) {
      filtered = filtered.where((label) {
        final endOfDay = DateTime(
          endDate.value!.year,
          endDate.value!.month,
          endDate.value!.day,
          23, 59, 59, 999
        );
        return label.fechaHora.isBefore(endOfDay) ||
               label.fechaHora.isAtSameMomentAs(endOfDay);
      }).toList();
    }
    
    filtered.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    
    filteredLabels.value = filtered;
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void updateSelectedTipo(String? tipo) {
    selectedTipo.value = tipo ?? '';
  }
  
  void updateSelectedUsuario(String? usuario) {
    selectedUsuario.value = usuario ?? '';
  }
  
  void updateStartDate(DateTime? date) {
    startDate.value = date;
  }
  
  void updateEndDate(DateTime? date) {
    endDate.value = date;
  }
  
  List<String> get uniqueTypes {
    final types = labels.map((label) => label.tipo.tipo).toSet().toList();
    types.sort();
    return types;
  }
  
  List<String> get uniqueUsers {
    final users = labels.map((label) => label.usuario.nombre).toSet().toList();
    users.sort();
    return users;
  }
  
  Future<void> refreshLabels() async {
    await loadLabels();
  }
  
  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedTipo.value = '';
    selectedUsuario.value = '';
    startDate.value = null;
    endDate.value = null;
    filteredLabels.value = labels.toList();
  }
  
  Map<String, int> get statistics {
    return {
      'total': labels.length,
      'filtered': filteredLabels.length,
      'types': uniqueTypes.length,
      'users': uniqueUsers.length,
    };
  }
  
  Map<String, int> get statisticsByType {
    final Map<String, int> typeStats = {};
    for (final label in filteredLabels) {
      typeStats[label.tipo.tipo] = (typeStats[label.tipo.tipo] ?? 0) + 1;
    }
    return typeStats;
  }
  
  Map<String, int> get statisticsByUser {
    final Map<String, int> userStats = {};
    for (final label in filteredLabels) {
      userStats[label.usuario.nombre] = (userStats[label.usuario.nombre] ?? 0) + 1;
    }
    return userStats;
  }
  
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}