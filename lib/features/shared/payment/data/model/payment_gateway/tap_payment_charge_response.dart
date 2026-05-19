class TapPaymentChargeResponse {
  final String id;
  final String object;
  final bool liveMode;
  final bool customerInitiated;
  final String apiVersion;
  final String method;
  final String status;
  final double amount;
  final String currency;
  final bool threeDSecure;
  final bool cardThreeDSecure;
  final bool saveCard;
  final String product;
  final String description;
  final TapPaymentMetadata? metadata;
  final Map<String, dynamic> order;
  final TapPaymentTransaction? transaction;
  final TapPaymentResponse? response;
  final TapPaymentReceipt? receipt;
  final TapPaymentCustomer? customer;
  final TapPaymentMerchant? merchant;
  final TapPaymentSource? source;
  final TapPaymentRedirect? redirect;
  final TapPaymentPost? post;
  final List<TapPaymentActivity> activities;
  final bool autoReversed;
  final TapPaymentIntent? intent;
  final String initiator;

  TapPaymentChargeResponse({
    required this.id,
    required this.object,
    required this.liveMode,
    required this.customerInitiated,
    required this.apiVersion,
    required this.method,
    required this.status,
    required this.amount,
    required this.currency,
    required this.threeDSecure,
    required this.cardThreeDSecure,
    required this.saveCard,
    required this.product,
    required this.description,
    this.metadata,
    required this.order,
    this.transaction,
    this.response,
    this.receipt,
    this.customer,
    this.merchant,
    this.source,
    this.redirect,
    this.post,
    required this.activities,
    required this.autoReversed,
    this.intent,
    required this.initiator,
  });

  factory TapPaymentChargeResponse.fromJson(Map<String, dynamic> json) {
    return TapPaymentChargeResponse(
      id: json['id'] as String? ?? '',
      object: json['object'] as String? ?? '',
      liveMode: json['live_mode'] as bool? ?? false,
      customerInitiated: json['customer_initiated'] as bool? ?? false,
      apiVersion: json['api_version'] as String? ?? '',
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      threeDSecure: json['threeDSecure'] as bool? ?? false,
      cardThreeDSecure: json['card_threeDSecure'] as bool? ?? false,
      saveCard: json['save_card'] as bool? ?? false,
      product: json['product'] as String? ?? '',
      description: json['description'] as String? ?? '',
      metadata: json['metadata'] != null
          ? TapPaymentMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      order: json['order'] as Map<String, dynamic>? ?? {},
      transaction: json['transaction'] != null
          ? TapPaymentTransaction.fromJson(json['transaction'] as Map<String, dynamic>)
          : null,
      response: json['response'] != null
          ? TapPaymentResponse.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      receipt: json['receipt'] != null
          ? TapPaymentReceipt.fromJson(json['receipt'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] != null
          ? TapPaymentCustomer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      merchant: json['merchant'] != null
          ? TapPaymentMerchant.fromJson(json['merchant'] as Map<String, dynamic>)
          : null,
      source: json['source'] != null
          ? TapPaymentSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      redirect: json['redirect'] != null
          ? TapPaymentRedirect.fromJson(json['redirect'] as Map<String, dynamic>)
          : null,
      post: json['post'] != null
          ? TapPaymentPost.fromJson(json['post'] as Map<String, dynamic>)
          : null,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => TapPaymentActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      autoReversed: json['auto_reversed'] as bool? ?? false,
      intent: json['intent'] != null
          ? TapPaymentIntent.fromJson(json['intent'] as Map<String, dynamic>)
          : null,
      initiator: json['initiator'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'live_mode': liveMode,
      'customer_initiated': customerInitiated,
      'api_version': apiVersion,
      'method': method,
      'status': status,
      'amount': amount,
      'currency': currency,
      'threeDSecure': threeDSecure,
      'card_threeDSecure': cardThreeDSecure,
      'save_card': saveCard,
      'product': product,
      'description': description,
      'metadata': metadata?.toJson(),
      'order': order,
      'transaction': transaction?.toJson(),
      'response': response?.toJson(),
      'receipt': receipt?.toJson(),
      'customer': customer?.toJson(),
      'merchant': merchant?.toJson(),
      'source': source?.toJson(),
      'redirect': redirect?.toJson(),
      'post': post?.toJson(),
      'activities': activities.map((e) => e.toJson()).toList(),
      'auto_reversed': autoReversed,
      'intent': intent?.toJson(),
      'initiator': initiator,
    };
  }

  /// Get the checkout URL from transaction
  String? get checkoutUrl => transaction?.url;

  /// Check if payment is initiated
  bool get isInitiated => status == 'INITIATED';

  /// Check if payment is successful
  bool get isSuccessful => status == 'CAPTURED' || status == 'AUTHORIZED';
}

class TapPaymentMetadata {
  final String? type;
  final String? userId;

  TapPaymentMetadata({
    this.type,
    this.userId,
  });

  factory TapPaymentMetadata.fromJson(Map<String, dynamic> json) {
    return TapPaymentMetadata(
      type: json['type'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'user_id': userId,
    };
  }
}

class TapPaymentTransaction {
  final String? timezone;
  final int? created;
  final String? url;
  final TapPaymentExpiry? expiry;
  final bool? asynchronous;
  final double? amount;
  final String? currency;
  final TapPaymentDate? date;

  TapPaymentTransaction({
    this.timezone,
    this.created,
    this.url,
    this.expiry,
    this.asynchronous,
    this.amount,
    this.currency,
    this.date,
  });

  factory TapPaymentTransaction.fromJson(Map<String, dynamic> json) {
    // Handle created as String or int
    int? created;
    if (json['created'] != null) {
      if (json['created'] is String) {
        created = int.tryParse(json['created'] as String);
      } else if (json['created'] is int) {
        created = json['created'] as int;
      } else if (json['created'] is num) {
        created = (json['created'] as num).toInt();
      }
    }
    
    return TapPaymentTransaction(
      timezone: json['timezone'] as String?,
      created: created,
      url: json['url'] as String?,
      expiry: json['expiry'] != null
          ? TapPaymentExpiry.fromJson(json['expiry'] as Map<String, dynamic>)
          : null,
      asynchronous: json['asynchronous'] as bool?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      date: json['date'] != null
          ? TapPaymentDate.fromJson(json['date'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timezone': timezone,
      'created': created,
      'url': url,
      'expiry': expiry?.toJson(),
      'asynchronous': asynchronous,
      'amount': amount,
      'currency': currency,
      'date': date?.toJson(),
    };
  }
}

class TapPaymentExpiry {
  final int? period;
  final String? type;

  TapPaymentExpiry({
    this.period,
    this.type,
  });

  factory TapPaymentExpiry.fromJson(Map<String, dynamic> json) {
    return TapPaymentExpiry(
      period: json['period'] as int?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'type': type,
    };
  }
}

class TapPaymentDate {
  final int? created;
  final int? transaction;

  TapPaymentDate({
    this.created,
    this.transaction,
  });

  factory TapPaymentDate.fromJson(Map<String, dynamic> json) {
    // Handle created and transaction as String or int
    int? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return int.tryParse(value);
      } else if (value is int) {
        return value;
      } else if (value is num) {
        return value.toInt();
      }
      return null;
    }
    
    return TapPaymentDate(
      created: parseTimestamp(json['created']),
      transaction: parseTimestamp(json['transaction']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created,
      'transaction': transaction,
    };
  }
}

class TapPaymentResponse {
  final String? code;
  final String? message;

  TapPaymentResponse({
    this.code,
    this.message,
  });

  factory TapPaymentResponse.fromJson(Map<String, dynamic> json) {
    return TapPaymentResponse(
      code: json['code'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

class TapPaymentReceipt {
  final bool? email;
  final bool? sms;

  TapPaymentReceipt({
    this.email,
    this.sms,
  });

  factory TapPaymentReceipt.fromJson(Map<String, dynamic> json) {
    return TapPaymentReceipt(
      email: json['email'] as bool?,
      sms: json['sms'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'sms': sms,
    };
  }
}

class TapPaymentCustomer {
  final String? firstName;
  final String? email;
  final TapPaymentPhone? phone;

  TapPaymentCustomer({
    this.firstName,
    this.email,
    this.phone,
  });

  factory TapPaymentCustomer.fromJson(Map<String, dynamic> json) {
    return TapPaymentCustomer(
      firstName: json['first_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] != null
          ? TapPaymentPhone.fromJson(json['phone'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'email': email,
      'phone': phone?.toJson(),
    };
  }
}

class TapPaymentPhone {
  final String? countryCode;
  final String? number;

  TapPaymentPhone({
    this.countryCode,
    this.number,
  });

  factory TapPaymentPhone.fromJson(Map<String, dynamic> json) {
    return TapPaymentPhone(
      countryCode: json['country_code'] as String?,
      number: json['number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_code': countryCode,
      'number': number,
    };
  }
}

class TapPaymentMerchant {
  final String? country;
  final String? currency;
  final String? id;

  TapPaymentMerchant({
    this.country,
    this.currency,
    this.id,
  });

  factory TapPaymentMerchant.fromJson(Map<String, dynamic> json) {
    return TapPaymentMerchant(
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'currency': currency,
      'id': id,
    };
  }
}

class TapPaymentSource {
  final String? object;
  final String? type;
  final String? paymentType;
  final String? channel;
  final String? id;
  final bool? onFile;
  final String? paymentMethod;

  TapPaymentSource({
    this.object,
    this.type,
    this.paymentType,
    this.channel,
    this.id,
    this.onFile,
    this.paymentMethod,
  });

  factory TapPaymentSource.fromJson(Map<String, dynamic> json) {
    return TapPaymentSource(
      object: json['object'] as String?,
      type: json['type'] as String?,
      paymentType: json['payment_type'] as String?,
      channel: json['channel'] as String?,
      id: json['id'] as String?,
      onFile: json['on_file'] as bool?,
      paymentMethod: json['payment_method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'type': type,
      'payment_type': paymentType,
      'channel': channel,
      'id': id,
      'on_file': onFile,
      'payment_method': paymentMethod,
    };
  }
}

class TapPaymentRedirect {
  final String? status;
  final String? url;

  TapPaymentRedirect({
    this.status,
    this.url,
  });

  factory TapPaymentRedirect.fromJson(Map<String, dynamic> json) {
    return TapPaymentRedirect(
      status: json['status'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'url': url,
    };
  }
}

class TapPaymentPost {
  final String? status;
  final String? url;

  TapPaymentPost({
    this.status,
    this.url,
  });

  factory TapPaymentPost.fromJson(Map<String, dynamic> json) {
    return TapPaymentPost(
      status: json['status'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'url': url,
    };
  }
}

class TapPaymentActivity {
  final String? id;
  final String? object;
  final int? created;
  final String? status;
  final String? currency;
  final double? amount;
  final String? remarks;
  final String? txnId;

  TapPaymentActivity({
    this.id,
    this.object,
    this.created,
    this.status,
    this.currency,
    this.amount,
    this.remarks,
    this.txnId,
  });

  factory TapPaymentActivity.fromJson(Map<String, dynamic> json) {
    // Handle created as String or int
    int? created;
    if (json['created'] != null) {
      if (json['created'] is String) {
        created = int.tryParse(json['created'] as String);
      } else if (json['created'] is int) {
        created = json['created'] as int;
      } else if (json['created'] is num) {
        created = (json['created'] as num).toInt();
      }
    }
    
    return TapPaymentActivity(
      id: json['id'] as String?,
      object: json['object'] as String?,
      created: created,
      status: json['status'] as String?,
      currency: json['currency'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      remarks: json['remarks'] as String?,
      txnId: json['txn_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'status': status,
      'currency': currency,
      'amount': amount,
      'remarks': remarks,
      'txn_id': txnId,
    };
  }
}

class TapPaymentIntent {
  final String? id;

  TapPaymentIntent({
    this.id,
  });

  factory TapPaymentIntent.fromJson(Map<String, dynamic> json) {
    return TapPaymentIntent(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

