import 'package:dart_frog/dart_frog.dart';
import '../lib/database/Mongodb.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    await MongoDatabase.connect();

    return Response.json(
      body: {
        'success': true,
        'message': 'MongoDB connected successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'message': 'MongoDB connection failed',
        'error': e.toString(),
      },
    );
  }
}