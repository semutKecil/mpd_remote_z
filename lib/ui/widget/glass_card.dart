
// class GlassCard extends StatelessWidget {
//   final Widget child;
//   final double borderRadius;
//   final bool radiusTopRight;
//   final bool radiusTopLeft;
//   final bool radiusBottomRight;
//   final bool radiusBottomLeft;
//   final bool borderTop;
//   final bool borderLeft;
//   final bool borderRight;
//   final bool borderBottom;
//   const GlassCard({
//     super.key,
//     required this.child,
//     this.radiusTopRight = true,
//     this.radiusTopLeft = true,
//     this.radiusBottomRight = true,
//     this.radiusBottomLeft = true,
//     this.borderTop = true,
//     this.borderLeft = true,
//     this.borderRight = true,
//     this.borderBottom = true,
//     this.borderRadius = 20,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var borderColor = Theme.of(
//       context,
//     ).colorScheme.onSurfaceVariant.withAlpha(100);
//     double borderWidth = 1;
//     return ClipRRect(
//       borderRadius: BorderRadius.only(
//         topLeft: radiusTopRight ? Radius.circular(borderRadius) : Radius.zero,
//         topRight: radiusTopLeft ? Radius.circular(borderRadius) : Radius.zero,
//         bottomLeft: radiusBottomLeft
//             ? Radius.circular(borderRadius)
//             : Radius.zero,
//         bottomRight: radiusBottomRight
//             ? Radius.circular(borderRadius)
//             : Radius.zero,
//       ),
//       child: SizedBox(
//         // decoration: BoxDecoration(
//         //   borderRadius: BorderRadius.only(
//         //     topLeft: radiusTopRight
//         //         ? Radius.circular(borderRadius)
//         //         : Radius.zero,
//         //     topRight: radiusTopLeft
//         //         ? Radius.circular(borderRadius)
//         //         : Radius.zero,
//         //     bottomLeft: radiusBottomLeft
//         //         ? Radius.circular(borderRadius)
//         //         : Radius.zero,
//         //     bottomRight: radiusBottomRight
//         //         ? Radius.circular(borderRadius)
//         //         : Radius.zero,
//         //   ),
//         //   color: Theme.of(
//         //     context,
//         //   ).colorScheme.surfaceContainerHigh.withAlpha(100),
//         //   border: BoxBorder.fromLTRB(
//         //     top: borderTop
//         //         ? BorderSide(width: borderWidth, color: borderColor)
//         //         : BorderSide.none,
//         //     left: borderLeft
//         //         ? BorderSide(width: borderWidth, color: borderColor)
//         //         : BorderSide.none,
//         //     right: borderRight
//         //         ? BorderSide(width: borderWidth, color: borderColor)
//         //         : BorderSide.none,
//         //     bottom: borderBottom
//         //         ? BorderSide(width: borderWidth, color: borderColor)
//         //         : BorderSide.none,
//         //   ),
//         //   // Border.all(
//         //   //   width: 2,
//         //   //   color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(20),
//         //   // ),
//         // ),
//         width: double.infinity,
//         height: double.infinity,
//         child: child,
//       ),
//     );
//   }
// }
