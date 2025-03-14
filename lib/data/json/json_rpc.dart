class JsonRequest {
  var jsonrpc = '';
  var method = '';
  var params = {};

  JsonRequest(Map map) {
    jsonrpc = map['jsonrpc'];
    method = map['method'];
    params = map['params'];
  }

  factory JsonRequest.fromJson(Map<String, dynamic> json) {
    return JsonRequest(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'method': method,
      'params': params,
    };
  }
}