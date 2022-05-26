import 'package:json_annotation/json_annotation.dart';
part 'get_flows.g.dart';

const defaultObject = {};

@JsonSerializable()
class GetFlows {
  final String appNumber;
  final String version;
  final String processDefinitionId;
  final String processId;
  final Events events;
  final FlowAction action;
  final Map<String, Flows> flows;
  final Map<String, List<List<Layout>>> layouts;
  final Map<String, List<Map<String, dynamic>>> data;

  GetFlows(
      {required this.appNumber,
      required this.version,
      required this.processDefinitionId,
      required this.processId,
      required this.events,
      required this.flows,
      required this.action,
      required this.layouts,
      required this.data});

  factory GetFlows.fromJson(Map<String, dynamic> data) =>
      _$GetFlowsFromJson(data);

  Map<String, dynamic> toJson() => _$GetFlowsToJson(this);
}

@JsonSerializable()
class Events {
  final List<String> flows;
  final Map<String, dynamic> data;

  Events({required this.flows, required this.data});

  factory Events.fromJson(Map<String, dynamic> data) => _$EventsFromJson(data);
  Map<String, dynamic> toJson() => _$EventsToJson(this);

  @override
  String toString() {
    return "Flows : ${flows.toString()} \n Data : ${data.toString()}";
  }
}

@JsonSerializable()
class FlowAction {
  final String type;
  final ActionValue value;

  FlowAction({required this.type, required this.value});

  factory FlowAction.fromJson(Map<String, dynamic> data) =>
      _$FlowActionFromJson(data);
  Map<String, dynamic> toJson() => _$FlowActionToJson(this);

  @override
  String toString() {
    return "FlowAction \n\n Type : ${type.toString()} \n\n Value : ${value.toString()}";
  }
}

@JsonSerializable()
class ActionValue {
  final String id;
  final String name;
  final List<String>? params;

  ActionValue({required this.id, required this.name, this.params});

  factory ActionValue.fromJson(Map<String, dynamic> data) =>
      _$ActionValueFromJson(data);
  Map<String, dynamic> toJson() => _$ActionValueToJson(this);

  @override
  String toString() {
    return "id : $id , name : $name , params : ${params.toString()}";
  }
}

@JsonSerializable()
class Flows {
  final String? title;
  final String? subtitle;
  final String? flow;
  final String? requireAppBar;
  final WidgetAction? onBack;
  final WidgetAction? onLoad;
  final WidgetAction? onUnload;
  final List<List<Layout>> layout;
  final ActionMenu? action_menu;
  final String? analytic_id;
  final String? analytic_event_metadata;
  final List<String>? native_analytic_types;
  final String? native_analytic_event_name;
  final String? native_analytic_event_action;

  Flows({
    required this.title,
    this.subtitle,
    required this.layout,
    this.action_menu,
    this.onBack,
    this.onLoad,
    this.onUnload,
    this.flow,
    this.requireAppBar,
    this.analytic_id,
    this.analytic_event_metadata,
    this.native_analytic_event_name,
    this.native_analytic_event_action,
    this.native_analytic_types
  });

  factory Flows.fromJson(Map<String, dynamic> data) => _$FlowsFromJson(data);
  Map<String, dynamic> toJson() => _$FlowsToJson(this);
}

@JsonSerializable()
class ActionMenu {
  final String icon;
  final String title;
  final WidgetAction? action;

  ActionMenu({required this.icon, required this.title, this.action});

  factory ActionMenu.fromJson(Map<String, dynamic> data) =>
      _$ActionMenuFromJson(data);
  Map<String, dynamic> toJson() => _$ActionMenuToJson(this);
}

@JsonSerializable()
class Layout {
  final String component;
  final String id;
  final int width;
  final Params? params;
  final Map<String, dynamic>? validation;
  final WidgetAction? action;
  final WidgetStyle? style;
  final WidgetAction? onTap;
  final WidgetAction? onChange;
  final String? analytic_id;
  final String? analytic_event_metadata;

  Layout({
    required this.component,
    required this.id,
    this.analytic_id,
    this.analytic_event_metadata,
    required this.params,
    this.action,
    this.validation,
    required this.width,
    this.style,
    this.onTap,
    this.onChange,
  });

  factory Layout.fromJson(Map<String, dynamic> data) => _$LayoutFromJson(data);
  Map<String, dynamic> toJson() => _$LayoutToJson(this);
}

@JsonSerializable()
class ValidationRule {
  final ValidationRuleValue? minLength;
  final ValidationRuleValue? maxLength;
  final ValidationRuleValue? regex;
  final ValidationRuleValue? required;
  final ValidationRuleValue? compareValue;

  ValidationRule(
      {this.minLength,
      this.maxLength,
      this.regex,
      this.required,
      this.compareValue});

  factory ValidationRule.fromJson(Map<String, dynamic> data) =>
      _$ValidationRuleFromJson(data);
  Map<String, dynamic> toJson() => _$ValidationRuleToJson(this);
}

@JsonSerializable()
class ValidationRuleValue {
  final String message;
  final dynamic value;

  ValidationRuleValue({required this.value, required this.message});

  factory ValidationRuleValue.fromJson(Map<String, dynamic> data) =>
      _$ValidationRuleValueFromJson(data);
  Map<String, dynamic> toJson() => _$ValidationRuleValueToJson(this);
}

@JsonSerializable()
class Params {
  final String? title;
  final String? placeholder;
  final bool? isPartTitleNeedTobeShown;
  final bool? isOverLayShouldbeShownAbove;
  final bool? onTapRequestNeedToBeSend;
  final String? isTextInputRestrictionBasedOnRegex;
  final String? subTitle;
  final List<String>? options;
  final String? controlledBy;
  final bool? disabled;
  final String? hint;
  final String? info;
  final String? keyboardType;
  final List<PositionalParams>? left;
  final List<PositionalParams>? right;
  final String? themeStyle;
  final double? doubleValue;
  final int? intValue;
  final String? stringValue;
  final List<Map<String, dynamic>>? dynamicList;
  final List<Map<String, dynamic>>? defaultList;
  final String? clickableText;
  final String? visibleWhen;
  final String? disabledWhen;
  final bool? isAlignCenter;
  final bool? isOutLine;
  final String? bgColorName;
  final String? textColorName;
  final String? url;
  final bool? readOnly;
  final bool? isOnTapNeeded;
  final bool? isMask;
  final bool? isManualDetailsButtonRequired;
  final String? manualDetailsButtonTitle;
  final bool? isTypePDF;
  final String? autoFetchKey;
  final bool? isLoaderType;
  final String? uploadFlow;
  final bool? isLetterInCAP;
  final int? charLimit;
  final List<String>? native_analytic_types;
  final String? native_analytic_event_name;
  final String? native_analytic_event_action;
  final String? native_analytic_event_label;
  final List<String>? native_analytic_types_optional;
  final String? native_analytic_event_name_optional;
  final String? native_analytic_event_action_optional;

  Params(
      {this.title,
      this.subTitle,
      this.placeholder,
      this.isPartTitleNeedTobeShown,
      this.isOverLayShouldbeShownAbove,
      this.onTapRequestNeedToBeSend,
      this.isTextInputRestrictionBasedOnRegex,
      this.controlledBy,
      this.disabled,
      this.hint,
      this.info,
      this.left,
      this.options,
      this.right,
      this.keyboardType,
      this.themeStyle,
      this.doubleValue,
      this.intValue,
      this.stringValue,
      this.dynamicList,
      this.defaultList,
      this.clickableText,
      this.disabledWhen,
      this.visibleWhen,
      this.isAlignCenter,
      this.isOutLine,
      this.bgColorName,
      this.textColorName,
      this.url,
      this.readOnly,
      this.isOnTapNeeded,
      this.isMask,
      this.isManualDetailsButtonRequired,
      this.manualDetailsButtonTitle,
      this.isTypePDF,
      this.autoFetchKey,
      this.isLoaderType,
      this.uploadFlow,
      this.isLetterInCAP,
      this.charLimit,
      this.native_analytic_event_name,
      this.native_analytic_event_action,
      this.native_analytic_event_label,
      this.native_analytic_event_name_optional,
      this.native_analytic_event_action_optional,
      this.native_analytic_types,
      this.native_analytic_types_optional,
      });

  factory Params.fromJson(Map<String, dynamic> data) => _$ParamsFromJson(data);
  Map<String, dynamic> toJson() => _$ParamsToJson(this);
}

@JsonSerializable()
class PositionalParams {
  final String? component;
  final String? icon;
  final String? id;
  final String? value;
  final WidgetAction? action;

  PositionalParams(
      {this.component, this.icon, this.id, this.value, this.action});

  factory PositionalParams.fromJson(Map<String, dynamic> data) =>
      _$PositionalParamsFromJson(data);
  Map<String, dynamic> toJson() => _$PositionalParamsToJson(this);
}

@JsonSerializable()
class WidgetAction {
  final String api;
  final String? method;
  String type;
  final String? others;
  final String? postNavigate;
  final String? layoutId;
  final Map<String, String>? headerParameters;
  final Map<String, String>? queryParameters;
  final Map<String, dynamic>? bodyParameters;
  final List<List<Layout>>? layout;
  final List<ToCondition>? to;
  final String? analytic_id;
  final String? analytic_event_metadata;

  WidgetAction({
    required this.api,
    this.method,
    required this.type,
    this.headerParameters,
    this.to,
    this.queryParameters,
    this.layout,
    this.bodyParameters,
    this.postNavigate,
    this.layoutId,
    this.others,
    this.analytic_id,
    this.analytic_event_metadata,
  });

  factory WidgetAction.fromJson(Map<String, dynamic> data) =>
      _$WidgetActionFromJson(data);
  Map<String, dynamic> toJson() => _$WidgetActionToJson(this);
}

@JsonSerializable()
class ToCondition {
  final String? condition;
  final ToNested to;

  ToCondition({this.condition, required this.to});

  factory ToCondition.fromJson(Map<String, dynamic> data) =>
      _$ToConditionFromJson(data);
  Map<String, dynamic> toJson() => _$ToConditionToJson(this);
}

@JsonSerializable()
class WidgetPadding {
  final double? right;
  final double? top;
  final double? bottom;
  final double? left;

  WidgetPadding({this.top, this.right, this.bottom, this.left});

  factory WidgetPadding.fromJson(Map<String, dynamic> data) =>
      _$WidgetPaddingFromJson(data);
  Map<String, dynamic> toJson() => _$WidgetPaddingToJson(this);
}

@JsonSerializable()
class WidgetStyle {
  final WidgetPadding? padding;
  final String? textAlign;

  WidgetStyle({this.padding, this.textAlign});

  factory WidgetStyle.fromJson(Map<String, dynamic> data) =>
      _$WidgetStyleFromJson(data);
  Map<String, dynamic> toJson() => _$WidgetStyleToJson(this);
}

@JsonSerializable()
class ToNested {
  final String id;

  ToNested({required this.id});

  factory ToNested.fromJson(Map<String, dynamic> data) =>
      _$ToNestedFromJson(data);
  Map<String, dynamic> toJson() => _$ToNestedToJson(this);
}
