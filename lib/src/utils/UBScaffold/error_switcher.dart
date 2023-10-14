import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';

import '../api_exception.dart';

class ErrorSwitcher extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message, subMessage;
  final dynamic error;

  const ErrorSwitcher({
    required this.onRetry,
    this.error,
    this.message,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return _GRErrorWidget(
      message: message ?? "",
      onRetry: onRetry,
      error: error,
    );
    // return _UBQErrorWidget(
    //   message: message,
    //   onRetry: onRetry,
    // );
  }
}

class _GRErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;
  final dynamic error;

  const _GRErrorWidget({
    Key? key,
    this.onRetry,
    this.message,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String messageToShow;
    if (error != null) {
      if ((error is APIException && error == APIException.connection) ||
          error == APIException.connection.message) {
        messageToShow = 'Connection error';
      } else {
        messageToShow = message ?? "";
      }
    } else {
      messageToShow = message ?? "";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              messageToShow,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * .5,
            child: RaisedButtonV2(
              onPressed: onRetry ?? () => null,
              label: Localization.of(context, 'retry'),
            ),
          ),
        ],
      ),
    );
  }
}