import 'package:flutter/material.dart';
import 'skeleton.dart';

class SkeletonMovieCard extends StatelessWidget {
  const SkeletonMovieCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(
            width: 180,
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 8),
          const Skeleton(
            width: 140,
            height: 20,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Skeleton(
                width: 60,
                height: 16,
              ),
              const SizedBox(width: 8),
              const Skeleton(
                width: 40,
                height: 16,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Skeleton(
            width: 40,
            height: 16,
          ),
        ],
      ),
    );
  }
} 