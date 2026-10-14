import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

/// GET /docs/openapi.json — serves the full OpenAPI 3.0 spec
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final spec = {
    'openapi': '3.0.3',
    'info': {
      'title': 'E-Commerce API',
      'version': '1.0.0',
      'description':
          'REST API for the e-commerce backend built with Dart Frog + MongoDB. '
              'Payments powered by ABA PayWay (KHQR).',
      'contact': {'name': 'Dev Team'},
    },
    'servers': [
      {'url': 'http://localhost:8080', 'description': 'Local development'},
    ],
    'tags': [
      {'name': 'Auth', 'description': 'User registration and login'},
      {'name': 'Products', 'description': 'Product catalogue and sale prices'},
      {'name': 'Payments', 'description': 'ABA PayWay KHQR checkout'},
    ],
    'paths': {
      // ── Auth ────────────────────────────────────────────────────────────
      '/auth/register': {
        'post': {
          'tags': ['Auth'],
          'summary': 'Register a new user',
          'requestBody': {
            'required': true,
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/RegisterRequest'},
                'example': {
                  'name': 'Dara Chan',
                  'email': 'dara@example.com',
                  'password': 'secret123',
                },
              }
            }
          },
          'responses': {
            '201': _ok('Account created', '#/components/schemas/UserResponse'),
            '400': _err('Validation error'),
          }
        }
      },
      '/auth/login': {
        'post': {
          'tags': ['Auth'],
          'summary': 'Login and receive a token',
          'requestBody': {
            'required': true,
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/LoginRequest'},
                'example': {
                  'email': 'dara@example.com',
                  'password': 'secret123',
                },
              }
            }
          },
          'responses': {
            '200': _ok('Login successful', '#/components/schemas/TokenResponse'),
            '401': _err('Invalid credentials'),
          }
        }
      },

      // ── Products ─────────────────────────────────────────────────────────
      '/products': {
        'get': {
          'tags': ['Products'],
          'summary': 'List all products',
          'responses': {
            '200': _ok('Product list', '#/components/schemas/ProductListResponse'),
          }
        },
        'post': {
          'tags': ['Products'],
          'summary': 'Add a new product',
          'requestBody': {
            'required': true,
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/ProductInput'},
              }
            }
          },
          'responses': {
            '201': _ok('Product created', '#/components/schemas/ProductResponse'),
            '400': _err('Bad request'),
          }
        }
      },
      '/products/{id}': {
        'get': {
          'tags': ['Products'],
          'summary': 'Get a product by ID',
          'parameters': [_pathParam('id', 'Product ID')],
          'responses': {
            '200': _ok('Product found', '#/components/schemas/ProductResponse'),
            '404': _err('Product not found'),
          }
        }
      },
      '/products/{id}/sale': {
        'patch': {
          'tags': ['Products'],
          'summary': 'Set or remove a sale price',
          'parameters': [_pathParam('id', 'Product ID')],
          'requestBody': {
            'required': true,
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/SalePriceRequest'},
                'examples': {
                  'set_sale': {
                    'summary': 'Set a sale price',
                    'value': {
                      'sale_price': 29.99,
                      'sale_start': '2026-10-14',
                      'sale_end': '2026-10-31',
                    },
                  },
                  'remove_sale': {
                    'summary': 'Remove sale price',
                    'value': {'sale_price': null},
                  },
                },
              }
            }
          },
          'responses': {
            '200': _ok('Sale price updated', '#/components/schemas/ProductResponse'),
            '400': _err('Validation error'),
            '404': _err('Product not found'),
          }
        }
      },
      '/products/sale': {
        'get': {
          'tags': ['Products'],
          'summary': 'List products currently on sale',
          'responses': {
            '200': _ok('On-sale products', '#/components/schemas/ProductListResponse'),
          }
        }
      },

      // ── Payments ─────────────────────────────────────────────────────────
      '/payments': {
        'post': {
          'tags': ['Payments'],
          'summary': 'Create an ABA PayWay KHQR checkout session',
          'requestBody': {
            'required': true,
            'content': {
              'application/json': {
                'schema': {r'$ref': '#/components/schemas/CreatePaymentRequest'},
                'example': {
                  'order_id': 'ORD-001',
                  'customer_id': 'CUST-001',
                  'currency': 'USD',
                  'firstname': 'Dara',
                  'lastname': 'Chan',
                  'email': 'dara@example.com',
                  'phone': '0123456789',
                },
              }
            }
          },
          'responses': {
            '201': _ok('Checkout session created', '#/components/schemas/PaymentCreatedResponse'),
            '400': _err('Validation error'),
            '404': _err('Order not found'),
            '502': _err('PayWay gateway error'),
          }
        }
      },
      '/payments/callback': {
        'post': {
          'tags': ['Payments'],
          'summary': 'ABA PayWay server-to-server webhook (called by PayWay)',
          'description':
              'PayWay POSTs here after every payment status change. '
              'Returns `{"status":"success"}` to stop PayWay retrying.',
          'requestBody': {
            'content': {
              'application/x-www-form-urlencoded': {
                'schema': {'type': 'object'},
              }
            }
          },
          'responses': {
            '200': {
              'description': 'Acknowledged',
              'content': {
                'application/json': {
                  'example': {'status': 'success'},
                }
              }
            }
          }
        }
      },
      '/payments/{paymentId}': {
        'get': {
          'tags': ['Payments'],
          'summary': 'Poll payment status',
          'parameters': [_pathParam('paymentId', 'Payment ID (e.g. PAY1728912345678)')],
          'responses': {
            '200': _ok('Payment status', '#/components/schemas/PaymentStatusResponse'),
            '404': _err('Payment not found'),
          }
        }
      },
    },

    // ── Reusable schemas ────────────────────────────────────────────────────
    'components': {
      'schemas': {
        'RegisterRequest': {
          'type': 'object',
          'required': ['name', 'email', 'password'],
          'properties': {
            'name': {'type': 'string', 'example': 'Dara Chan'},
            'email': {'type': 'string', 'format': 'email'},
            'password': {'type': 'string', 'minLength': 6},
          }
        },
        'LoginRequest': {
          'type': 'object',
          'required': ['email', 'password'],
          'properties': {
            'email': {'type': 'string', 'format': 'email'},
            'password': {'type': 'string'},
          }
        },
        'UserResponse': {
          'type': 'object',
          'properties': {
            'success': {'type': 'boolean'},
            'message': {'type': 'string'},
            'data': {
              'type': 'object',
              'properties': {
                'id': {'type': 'string'},
                'name': {'type': 'string'},
                'email': {'type': 'string'},
                'created_at': {'type': 'string', 'format': 'date-time'},
              }
            }
          }
        },
        'TokenResponse': {
          'type': 'object',
          'properties': {
            'success': {'type': 'boolean'},
            'message': {'type': 'string'},
            'data': {
              'type': 'object',
              'properties': {'token': {'type': 'string'}},
            }
          }
        },
        'ProductInput': {
          'type': 'object',
          'required': ['product_id', 'product_name', 'category_id', 'supplier_id', 'price', 'stock'],
          'properties': {
            'product_id': {'type': 'string'},
            'product_name': {'type': 'string'},
            'category_id': {'type': 'string'},
            'supplier_id': {'type': 'string'},
            'price': {'type': 'number', 'format': 'double'},
            'stock': {'type': 'integer'},
            'description': {'type': 'string'},
            'sku': {'type': 'string'},
            'discount_percent': {'type': 'number'},
          }
        },
        'SalePriceRequest': {
          'type': 'object',
          'properties': {
            'sale_price': {'type': 'number', 'nullable': true, 'example': 29.99},
            'sale_start': {'type': 'string', 'format': 'date', 'example': '2026-10-14'},
            'sale_end': {'type': 'string', 'format': 'date', 'example': '2026-10-31'},
          }
        },
        'ProductResponse': {
          'type': 'object',
          'properties': {
            'success': {'type': 'boolean'},
            'message': {'type': 'string'},
            'data': {r'$ref': '#/components/schemas/Product'},
          }
        },
        'ProductListResponse': {
          'type': 'object',
          'properties': {
            'success': {'type': 'boolean'},
            'count': {'type': 'integer'},
            'data': {
              'type': 'array',
              'items': {r'$ref': '#/components/schemas/Product'},
            },
          }
        },
        'Product': {
          'type': 'object',
          'properties': {
            'product_id': {'type': 'string'},
            'product_name': {'type': 'string'},
            'price': {'type': 'number'},
            'sale_price': {'type': 'number', 'nullable': true},
            'is_on_sale': {'type': 'boolean'},
            'effective_price': {'type': 'number'},
            'savings_percent': {'type': 'number'},
            'stock': {'type': 'integer'},
            'rating': {'type': 'number'},
          }
        },
        'CreatePaymentRequest': {
          'type': 'object',
          'required': ['order_id', 'customer_id'],
          'properties': {
            'order_id': {'type': 'string'},
            'customer_id': {'type': 'string'},
            'currency': {'type': 'string', 'enum': ['USD', 'KHR'], 'default': 'USD'},
            'firstname': {'type': 'string'},
            'lastname': {'type': 'string'},
            'email': {'type': 'string', 'format': 'email'},
            'phone': {'type': 'string'},
          }
        },
        'PaymentCreatedResponse': {
          'type': 'object',
          'properties': {
            'success': {'type': 'boolean'},
            'data': {
              'type': 'object',
              'properties': {
                'payment_id': {'type': 'string'},
                'amount': {'type': 'number'},
                'currency': {'type': 'string'},
                'qr_string': {'type': 'string', 'description': 'KHQR string to render as QR'},
                'abapay_deeplink': {'type': 'string', 'description': 'Deep link for ABA mobile app'},
                'checkout_qr_url': {'type': 'string', 'description': 'Hosted PayWay checkout page URL'},
              }
            }
          }
        },
        'PaymentStatusResponse': {
          'type': 'object',
          'properties': {
            'success': {'type': 'boolean'},
            'data': {
              'type': 'object',
              'properties': {
                'payment_id': {'type': 'string'},
                'order_id': {'type': 'string'},
                'status': {
                  'type': 'string',
                  'enum': ['pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded'],
                },
                'amount': {'type': 'number'},
                'currency': {'type': 'string'},
                'paid_at': {'type': 'string', 'format': 'date-time', 'nullable': true},
                'transaction_id': {'type': 'string', 'nullable': true},
              }
            }
          }
        },
        'ErrorResponse': {
          'type': 'object',
          'properties': {
            'success': {'type': 'boolean', 'example': false},
            'error': {'type': 'string'},
          }
        },
      }
    }
  };

  return Response(
    body: jsonEncode(spec),
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  );
}

// ── Helpers ─────────────────────────────────────────────────────────────────

Map<String, dynamic> _ok(String description, String schemaRef) => {
      'description': description,
      'content': {
        'application/json': {
          'schema': {r'$ref': schemaRef},
        }
      }
    };

Map<String, dynamic> _err(String description) => {
      'description': description,
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/ErrorResponse'},
        }
      }
    };

Map<String, dynamic> _pathParam(String name, String description) => {
      'name': name,
      'in': 'path',
      'required': true,
      'description': description,
      'schema': {'type': 'string'},
    };

