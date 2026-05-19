import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/talent_work_model.dart';
import 'portfolio_item_card.dart';

class PortfolioSection extends StatelessWidget {
  final List<TalentWorkModel> works;

  const PortfolioSection({super.key, required this.works});

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: works.length,
        padding: EdgeInsets.symmetric(horizontal: 0),
        separatorBuilder: (context, index) => 16.horizontalSpace,
        itemBuilder: (context, index) {
          return PortfolioItemCard(work: works[index]);
        },
      ),
    );
  }
}
