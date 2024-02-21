
import 'package:highcharts_demo/data/respnse/status.dart';



class ApiResponse<T> {
  Status? status;
  T? data;
  String? messages;

  ApiResponse(this.status, this.data, this.messages);

  ApiResponse.loading() : status = Status.LOADING;

  ApiResponse.completed(this.data) : status = Status.COMPLETED;

  ApiResponse.error(this.messages) : status = Status.ERROR;

  @override
  String toString() {
    return "Status: $status\n Message:$messages\n Data:$data";
  }

}
