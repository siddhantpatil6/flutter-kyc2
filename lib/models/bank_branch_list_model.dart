import 'dart:convert';

BankBranchList bankListFromJson(String str) =>
    BankBranchList.fromJson(json.decode(str));

String bankListToJson(BankBranchList data) => json.encode(data.toJson());

class BankBranchList {
  BankBranchList({
    this.metadata,
    this.records,
  });

  Metadata? metadata;
  List<Record>? records;

  factory BankBranchList.fromJson(Map<String, dynamic> json) => BankBranchList(
        metadata: Metadata.fromJson(json["_metadata"]),
        records:
            List<Record>.from(json["records"].map((x) => Record.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_metadata": metadata!.toJson(),
        "records": List<dynamic>.from(records!.map((x) => x.toJson())),
      };
}

class Metadata {
  Metadata({
    this.page,
    this.pageSize,
    this.self,
    this.previous,
    this.next,
  });

  int? page;
  int? pageSize = 0;
  String? self;
  String? previous;
  String? next;

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        page: json["page"],
        pageSize: json["pageSize"],
        self: json["self"],
        previous: json["previous"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "pageSize": pageSize,
        "self": self,
        "previous": previous,
        "next": next,
      };
}

class Record {
  Record({
    this.bankCode,
    this.bank,
    this.ifsc,
    this.branch,
    this.address,
    this.city1,
    this.city2,
    this.state,
    this.std,
    this.phone,
    this.pincode,
  });

  String? bankCode;
  String? bank;

  String? ifsc;
  String? branch;
  String? address;
  String? city1;
  String? city2;
  String? state;
  String? std;
  String? phone;
  String? pincode;

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        bankCode: json["bankCode"],
        bank: json["bank"],
        ifsc: json["ifsc"],
        branch: json["branch"],
        address: json["address"],
        city1: json["city1"],
        city2: json["city2"],
        state: json["state"],
        std: json["std"],
        phone: json["phone"],
        pincode: json["pincode"],
      );

  Map<String, dynamic> toJson() => {
        "bankCode": bankCode,
        "bank": bank,
        "ifsc": ifsc,
        "branch": branch,
        "address": address,
        "city1": city1,
        "city2": city2,
        "state": state,
        "std": std,
        "phone": phone,
        "pincode": pincode,
      };
}
