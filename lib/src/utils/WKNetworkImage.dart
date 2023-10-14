import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WKNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isCircular;
  final bool isCircularUsingPrivateToken;
  final VoidCallback? onImageEvicted;
  final bool isEvict;
  final Color? alphaColor;
  final Color? color;
  final Color? backColor;
  final double opacity;
  final isOverlay;
  final Widget? defaultWidget;
  final AssetImage? placeHolder;
  final Alignment alignment;
  final bool showBorder;
  final bool? usePublicToken;

  const WKNetworkImage(
    this.url, {
    Key? key,
    this.width,
    this.height,
    this.fit,
    this.isCircular = false,
    this.isCircularUsingPrivateToken = false,
    this.isEvict = false,
    this.onImageEvicted,
    this.alphaColor,
    this.opacity = 0.2,
    this.color,
    this.isOverlay = false,
    this.backColor,
    this.defaultWidget,
    this.placeHolder,
    this.alignment = Alignment.center,
    this.showBorder = true,
    this.usePublicToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return placeHolder == null
          ? Image.asset(
              'assets/images/placeholder.png',
            )
          : Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                  image: DecorationImage(
                      image: placeHolder ?? AssetImage(""), fit: fit)),
            );
    }
//    NetworkImage provider =
//        NetworkImage(url, headers: HttpRequest.defaultHeaders);
    Map<String, String> requestHeaders = Map<String, String>();

    NetworkImage provider = NetworkImage(url ?? "", headers: requestHeaders);

    CachedNetworkImage networkImage = CachedNetworkImage(
      imageUrl: url ?? "",
      httpHeaders: Map<String, String>(),
      fit: fit,
      errorWidget: (context, url, error) => defaultWidget ?? SizedBox(),
      alignment: alignment,
    );
    if (isEvict) evictImage(provider);

    if (isCircular)
      return Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            child: Center(child: defaultWidget),
          ),
          new Container(
            width: width,
            height: height,
            decoration: new BoxDecoration(
              color: backColor ?? Colors.black,
              borderRadius: new BorderRadius.all(new Radius.circular(150.0)),
              image: defaultWidget == null
                  ? DecorationImage(image: provider, fit: fit)
                  : null,
              border: showBorder
                  ? new Border.all(
                      color: Colors.black,
                      width: 0.0,
                    )
                  : null,
            ),
            child: defaultWidget != null ? networkImage : null,
          ),
        ],
      );
    else if (isCircularUsingPrivateToken) {
      return Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            child: Center(child: defaultWidget),
          ),
          new Container(
            width: width,
            height: height,
            decoration: new BoxDecoration(
              color: backColor ?? Colors.black,
              borderRadius: new BorderRadius.all(new Radius.circular(150.0)),
              image: defaultWidget == null
                  ? DecorationImage(image: provider, fit: fit)
                  : null,
              border: showBorder
                  ? new Border.all(
                      color: Colors.black,
                      width: 0.0,
                    )
                  : null,
            ),
            child: url != null
                ? FadeInImage(
                    placeholder: placeHolder ?? AssetImage(""),
                    imageErrorBuilder: defaultWidget != null
                        ? (_, __, ___) => (defaultWidget ?? SizedBox())
                        : null,
                    image: NetworkImage(
                      url ?? "",
                      headers: requestHeaders,
                    ),
                    width: width,
                    height: height,
                    fit: fit,
                    alignment: alignment,
                  )
                : defaultWidget != null
                    ? networkImage
                    : null,
          ),
        ],
      );
    } else if (isOverlay) {
      Color colorOverlay;
      if (alphaColor == null)
        colorOverlay = Colors.black;
      else
        colorOverlay = alphaColor!;
      return new Container(
        width: width,
        height: height,
        decoration: new BoxDecoration(
          image: new DecorationImage(
              image: provider,
              fit: fit,
              colorFilter: new ColorFilter.mode(
                  colorOverlay.withOpacity(opacity), BlendMode.dstATop),
              alignment: alignment),
        ),
      );
    }

    networkImage = CachedNetworkImage(
      imageUrl: url ?? "",
      httpHeaders: Map<String, String>(),
      fit: fit,
      placeholder: placeHolder != null
          ? (context, string) {
              return Image(image: placeHolder ?? AssetImage(""));
            }
          : null,
      errorWidget: (context, url, error) => defaultWidget ?? SizedBox(),
      alignment: alignment,
    );

    return placeHolder == null
        ? ExcludeSemantics(
            child: Image(
              image: FadeInImage(
                image: NetworkImage(
                  url ?? "",
                  headers: requestHeaders,
                ),
                placeholder: AssetImage(
                  'assets/images/placeholder.png',
                ),
              ).image,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              color: color,
            ),
          )
        : FadeInImage(
            placeholder: placeHolder ?? AssetImage(""),
            imageErrorBuilder: defaultWidget != null
                ? (_, __, ___) => (defaultWidget ?? SizedBox())
                : null,
            image: NetworkImage(
              url ?? "",
              headers: requestHeaders,
            ),
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
          );
  }

  void evictImage(NetworkImage provider) {
    provider.evict().then<void>((bool success) {
      if (success && onImageEvicted != null) {
        onImageEvicted!();
      }
    });
  }
}
