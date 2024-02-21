class AppExceptions implements Exception {
  final String? message;
  final String? prefix;

  AppExceptions([this.message, this.prefix]);
}

class ApiFetchDataException extends AppExceptions {
  ApiFetchDataException([String? message]) : super(message ?? "Api Error");
}

class TimeOutError extends AppExceptions {
  TimeOutError([String? message]) : super(message ?? "Request Time Out Error");
}

class InternetException extends AppExceptions {
  InternetException([String? message]) : super(message ?? "No Internet");
}

class DataNotFound extends AppExceptions {
  DataNotFound([String? message]) : super(message ?? "Data not Found");
}

class InternetServerException extends AppExceptions {
  InternetServerException([String? message])
      : super(message ?? " Internet Server Error");

}
