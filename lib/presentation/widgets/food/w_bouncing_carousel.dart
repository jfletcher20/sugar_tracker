import 'package:sugar_tracker/data/models/m_food.dart';

import 'package:flutter/material.dart';

import 'dart:io';

class BouncingCarousel extends StatefulWidget {
  final List<Food> foods;
  const BouncingCarousel(this.foods, {super.key});

  @override
  State<BouncingCarousel> createState() => _BouncingCarouselState();
}

class _BouncingCarouselState extends State<BouncingCarousel> {
  CarouselController? carouselController;
  int _carouselIndex = 0;
  bool _carouselDirection = true;
  void startCarouselCoroutine(CarouselController controller) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_carouselDirection && _carouselIndex < widget.foods.length - 1) {
        _carouselIndex++;
        if (_carouselIndex >= widget.foods.length - 1) {
          _carouselDirection = false;
          _carouselIndex = widget.foods.length - 1;
        }
      } else if (!_carouselDirection && _carouselIndex > 0) {
        _carouselIndex--;
        if (_carouselIndex <= 0) {
          _carouselDirection = true;
          _carouselIndex = 0;
        }
      }
      controller.animateTo(_carouselIndex * (64 + 8),
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      startCarouselCoroutine(controller);
    });
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return const Icon(
      Icons.broken_image,
      size: 54,
      color: Colors.redAccent,
    );
  }

  @override
  void initState() {
    super.initState();
    carouselController = CarouselController();
    startCarouselCoroutine(carouselController!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: CarouselView.weighted(
        // itemExtent: 54,
        consumeMaxWeight: false,
        flexWeights: [
          for (int i = 0; i < widget.foods.length; i++) 0,
        ],
        controller: carouselController,
        itemSnapping: true,
        enableSplash: false,
        children: [
          ...widget.foods.map(
            (food) => Image.file(File(food.picture),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            }, errorBuilder: imageNotFound),
          ),
        ],
      ),
    );
  }
}
