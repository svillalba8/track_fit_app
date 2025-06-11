import 'package:flutter/material.dart';

import '../../routines/models/exercise_model.dart';

class EjerciciosPageView extends StatefulWidget {
  final bool isLoading;
  final List<Exercise> ejercicios;
  final PageController pageController;
  final int initialPage;
  final Function(int) onPageChanged;

  const EjerciciosPageView({
    super.key,
    required this.isLoading,
    required this.ejercicios,
    required this.pageController,
    required this.initialPage,
    required this.onPageChanged,
  });

  @override
  State<EjerciciosPageView> createState() => _EjerciciosPageViewState();
}

class _EjerciciosPageViewState extends State<EjerciciosPageView> {
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage;
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      widget.pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPageIndex < widget.ejercicios.length - 1) {
      widget.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.ejercicios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No tienes ejercicios todavía.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: widget.pageController,
              itemCount: widget.ejercicios.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
                widget.onPageChanged(index);
              },
              itemBuilder: (context, index) {
                final ejercicio = widget.ejercicios[index];
                return GestureDetector(
                  onTap: () {
                    // Navegar a rutina, pasando el ejercicio o rutina asociada
                    Navigator.of(context).pushNamed(
                      '/routines',
                      arguments: ejercicio,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ejercicio.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ejercicio.descripcion ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
              ),
              Text('${_currentPageIndex + 1} / ${widget.ejercicios.length}',
                  style: const TextStyle(fontSize: 14)),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _currentPageIndex < widget.ejercicios.length - 1 ? _goToNextPage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
