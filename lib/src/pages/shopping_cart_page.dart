import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/WKNetworkImage.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_summary.dart';

class ShoppingCartPage extends StatefulWidget {
  final HomeScreenController? homeScreenController;

  const ShoppingCartPage({
    Key? key,
    this.homeScreenController,
  }) : super(key: key);

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final SlidableController slidableController = SlidableController();

  var index = -1;
  Widget _cartItems() {
    index = -1;
    return Column(
        children: widget.homeScreenController!.productsLinks.map((x) {
      index += 1;
      return _item(index,
          isLastIndex:
              index == (widget.homeScreenController!.productsLinks.length) - 1);
    }).toList());
  }

  Widget _item(var index, {bool isLastIndex = false}) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      controller: slidableController,
      actionExtentRatio: 0.20,
      enabled: true,
      secondaryActions: <Widget>[
        SlideAction(
          color: LightColor.lightGrey.withAlpha(75),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ],
          ),
          onTap: () async {
            await showConfirmationBottomSheet(
              context: context,
              flare: 'assets/flare/pending.flr',
              title: Localization.of(
                context,
                'are_you_sure_you_want_to_remove_this_item_from_your_cart',
              ),
              confirmMessage: Localization.of(context, 'confirm'),
              confirmAction: () async {
                widget.homeScreenController!.productsTitles.removeAt(index);
                widget.homeScreenController!.productsLinks.removeAt(index);
                widget.homeScreenController!.productsQuantities.removeAt(index);
                widget.homeScreenController!.productsColors.removeAt(index);
                widget.homeScreenController!.productsSizes.removeAt(index);
                widget.homeScreenController!.productsPrices.removeAt(index);
                widget.homeScreenController!.productsImages.removeAt(index);

                widget.homeScreenController!.refreshView();

                setState(() {});
              },
              cancelMessage: Localization.of(context, 'cancel'),
            );
          },
        ),
      ],
      child: Container(
        margin: EdgeInsets.only(bottom: isLastIndex ? 0 : 36),
        height: 80,
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: () async {
                try {
                  bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
                  var url = widget.homeScreenController!.productsLinks[index];
                  if (isIOS) {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      print('Could not launch $url');
                      throw Exception('Could not launch $url');
                    }
                  } else {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      print('Could not launch $url');
                      throw Exception('Could not launch $url');
                    }
                  }
                } catch (e) {
                  print(e);
                  showErrorBottomsheet(
                    context,
                    'An error has occurred: $e',
                  );
                }
              },
              child: WKNetworkImage(
                ((widget.homeScreenController?.hideImage ?? true))
                    ? ""
                    : widget.homeScreenController!.productsImages[index],
                fit: BoxFit.contain,
                width: 60,
                height: 60,
                defaultWidget: Image.asset(
                  "assets/images/login_logo.png",
                  width: 60,
                  height: 60,
                ),
                placeHolder: AssetImage(
                  'assets/images/placeholder.png',
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: InkWell(
                  onTap: () async {
                    try {
                      bool isIOS =
                          Theme.of(context).platform == TargetPlatform.iOS;
                      var url =
                          widget.homeScreenController!.productsLinks[index];
                      if (isIOS) {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          print('Could not launch $url');
                          throw Exception('Could not launch $url');
                        }
                      } else {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          print('Could not launch $url');
                          throw Exception('Could not launch $url');
                        }
                      }
                    } catch (e) {
                      print(e);
                      showErrorBottomsheet(
                        context,
                        'An error has occurred: $e',
                      );
                    }
                  },
                  child: TitleText(
                    text: widget.homeScreenController!.productsTitles[index]
                                .toString()
                                .toLowerCase() ==
                            "product"
                        ? widget.homeScreenController!.productsLinks[index]
                        : widget.homeScreenController!.productsTitles[index],
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 0, 0, 255).withOpacity(0.9),
                  ),
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 2),
                    Container(
                      width: 150,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${Localization.of(context, 'color:')} ${isNotEmpty(widget.homeScreenController?.productsColors[index]) ? widget.homeScreenController?.productsColors[index] : Localization.of(context, 'not_specified')}",
                        maxLines: 1,
                        style: TextStyle(
                          // fontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Container(
                      width: 150,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${Localization.of(context, 'size:')} ${isNotEmpty(widget.homeScreenController?.productsSizes[index]) ? widget.homeScreenController?.productsSizes[index] : Localization.of(context, 'not_specified')}",
                        maxLines: 1,
                        style: TextStyle(
                          // fontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if ((widget.homeScreenController?.showProductPrice ??
                            false) &&
                        widget.homeScreenController?.productsPrices[index] !=
                            "0")
                      Row(
                        children: <Widget>[
                          TitleText(
                            text: '\$ ',
                            color: LightColor.red,
                            fontSize: 12,
                          ),
                          TitleText(
                            text: widget
                                .homeScreenController?.productsPrices[index],
                            fontSize: 14,
                          ),
                        ],
                      ),
                  ],
                ),
                trailing: Container(
                  width: 45,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: LightColor.lightGrey.withAlpha(150),
                      borderRadius: BorderRadius.circular(10)),
                  child: TitleText(
                    text:
                        'x${widget.homeScreenController?.productsQuantities[index]}',
                    fontSize: 12,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _price() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TitleText(
          text:
              '${widget.homeScreenController?.productsImages.length} ${(widget.homeScreenController?.productsImages.length ?? 0) > 1 ? "Items" : "Item"}',
          color: LightColor.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        TitleText(
          text: '\$${getPrice().toStringAsFixed(2)}',
          fontSize: 18,
        ),
      ],
    );
  }

  Widget _submitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 96.0),
      child: TextButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderSummaryScreen(
                homeScreenController: widget.homeScreenController!,
              ),
            ),
          );
          setState(() {});
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(LightColor.orange),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4),
          width: AppTheme.fullWidth(context) * .75,
          child: TitleText(
            text: Localization.of(context, 'continue_ss'),
            color: LightColor.background,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  double getPrice() {
    double price = 0;
    for (int i = 0;
        i < (widget.homeScreenController?.productsPrices.length ?? 0);
        i++) {
      price += num.tryParse(widget.homeScreenController?.productsPrices[i]
                  .replaceAll(',', '') ??
              "0")! *
          num.tryParse(widget.homeScreenController?.productsQuantities[i]
                  .replaceAll(',', '') ??
              "0")!;
    }

    return price;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.padding,
      child: (widget.homeScreenController?.productsLinks.isEmpty ?? true)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 75.0),
              child: Center(
                  child: Text(
                Localization.of(context, 'shopping_cart_empty'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              )),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _cartItems(),
                  Divider(
                    thickness: 1,
                    height: 70,
                  ),
                  if ((widget.homeScreenController?.showProductPrice ??
                          false) &&
                      getPrice().toStringAsFixed(2) != "0.00")
                    _price(),
                  SizedBox(height: 30),
                  _submitButton(context),
                ],
              ),
            ),
    );
  }
}
