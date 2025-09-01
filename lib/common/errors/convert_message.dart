import 'dart:async';
import 'dart:io';

String convertMessageException({required dynamic error}) {
  switch (error) {
    case SocketException:
      return 'Servicio no disponible intente mas tarde';
    case TimeoutException:
      return 'La peticion tardo mas  de lo usual, intente de nuevo';
    default:
      return error.toString();
  }
}

String cleanExceptionMessage(dynamic e) {
  String message = e.toString();

  while (message.trim().startsWith("Exception:")) {
    message = message.trim().replaceFirst("Exception:", "").trim();
  }
  
  message = message.replaceAll("Exception:", "").trim();
  message = message.replaceAll("Error de conexión:", "").trim();
  
  if (message.isEmpty) {
    message = "Error al intentar conectarse con el servidor: revisa que esté encendido";
  }

  return message;
}
String formatErrorForAlert(String errorMessage) {
  if (errorMessage.length > 200) {
    List<String> lines = errorMessage.split('\n');
    if (lines.length > 1) {
      return '${lines.first}\n\nVer consola para más detalles.';
    } else {
      return '${errorMessage.substring(0, 200)}...';
    }
  }
  return errorMessage;
}