import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

import '../constants/styles.dart';
import 'optimized_image.dart';

class CircleAvatarProfileImage extends StatelessWidget {
  const CircleAvatarProfileImage({
    super.key,
    this.radius = 15.0,
    this.hasBorder = false,
    this.profileImageUrl,
    this.fit = BoxFit.cover,
  });

  final double radius;
  final bool hasBorder;
  final String? profileImageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return (profileImageUrl == null || profileImageUrl!.isEmpty)
        ? CircleAvatar(
            radius: radius,
            backgroundColor: Colors.black54,
          )
        : profileImageUrl!.contains('.gif')
            ? Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        hasBorder ? AppColors.chzzkColor : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: Gif(
                    image: NetworkImage(profileImageUrl!),
                    height: radius * 2,
                    width: radius * 2,
                    fit: fit,
                    useCache: true,
                    autostart: Autostart.no,
                    placeholder: (context) => SizedBox(
                      height: radius * 2,
                      width: radius * 2,
                    ),
                  ),
                ),
              )
            : OptimizedCachedNetworkImage(
                imageUrl: profileImageUrl!,
                imageWidth: radius,
                imageBuilder: (_, imageProvider) {
                  return Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasBorder
                            ? AppColors.chzzkColor
                            : Colors.transparent,
                        width: 2.0,
                      ),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
  }
}
