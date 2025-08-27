import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/curve_painter.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class PerfilLoading extends StatefulWidget {
  const PerfilLoading({Key? key}) : super(key: key);
  
  @override
  State<PerfilLoading> createState() => _PerfilLoadingState();
}

class _PerfilLoadingState extends State<PerfilLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: false);
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AdminColors.backgroundGradient,
          ),
        ),
        
        Positioned.fill(
          child: CustomPaint(
            painter: CurvePainter(),
          ),
        ),
        
        SafeArea(
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return _buildPerfilSkeleton(context);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildShimmerBox({required Widget child}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AdminColors.loaddingwithOpacity1,
               AdminColors.loaddingwithOpacity3,
                AdminColors.loaddingwithOpacity1
              ],
              stops: [
                _shimmerAnimation.value - 1,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  Widget _buildPerfilSkeleton(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            
            _buildProfileHeaderSkeleton(),
            
            SizedBox(height: 40),
            _buildPersonalInfoSkeleton(),
            
            SizedBox(height: 40),
            
            _buildSettingsSkeleton(),
            
            SizedBox(height: 40),
            
            _buildFooterSkeleton(),
            
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderSkeleton() {
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 75,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(0.5),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      width: 150,
                      height: 150,
                      color: AdminColors.loaddingwithOpacity1,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color:AdminColors.loaddingwithOpacity3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 20),
        
        _buildShimmerBox(
          child: Container(
            height: 24,
            width: 180,
            decoration: BoxDecoration(
              color:AdminColors.loadding,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        
        SizedBox(height: 10),
        
        _buildShimmerBox(
          child: Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color:AdminColors.loadding,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildPersonalInfoSkeleton() {
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              color: accentColor.withOpacity(0.5),
              size: 20,
            ),
            SizedBox(width: 10),
            _buildShimmerBox(
              child: Container(
                height: 16,
                width: 180,
                decoration: BoxDecoration(
                  color: AdminColors.loadding,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        _buildInfoItemSkeleton(),
        _buildInfoItemSkeleton(),
        _buildInfoItemSkeleton(),
        _buildInfoItemSkeleton(),
      ],
    );
  }

  Widget _buildInfoItemSkeleton() {
    final Color iconBgColor =AdminColors.loaddingwithOpacity1;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.circle,
              color: AdminColors.loaddingwithOpacity3,
              size: 20,
            ),
          ),
          
          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(
                  child: Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AdminColors.loadding,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                _buildShimmerBox(
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:AdminColors.loadding,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSkeleton() {
    final Color accentColor = AdminColors.colorAccionButtons;
    final Color bgColor =AdminColors.loaddingwithOpacity1;
    final Color borderColor = AdminColors.loaddingwithOpacity3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings_outlined,
              color: accentColor.withOpacity(0.5),
              size: 20,
            ),
            SizedBox(width: 10),
            _buildShimmerBox(
              child: Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: AdminColors.loadding,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_outlined,
                color: AdminColors.loaddingwithOpacity3,
                size: 22,
              ),
              SizedBox(width: 16),
              _buildShimmerBox(
                child: Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AdminColors.loadding,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSkeleton() {
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      children: [
        Divider(
          color: Colors.white24,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 16,
              color: accentColor.withOpacity(0.5),
            ),
            SizedBox(width: 8),
            _buildShimmerBox(
              child: Container(
                height: 14,
                width: 150,
                decoration: BoxDecoration(
                  color: AdminColors.loadding,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}