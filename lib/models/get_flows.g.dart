// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_flows.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetFlows _$GetFlowsFromJson(Map<String, dynamic> json) {
  return GetFlows(
    appNumber: json['appNumber'] as String,
    version: json['version'] as String,
    processDefinitionId: json['processDefinitionId'] as String,
    processId: json['processId'] as String,
    events: Events.fromJson(json['events'] as Map<String, dynamic>),
    flows: (json['flows'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, Flows.fromJson(e as Map<String, dynamic>)),
    ),
    action: FlowAction.fromJson(json['action'] as Map<String, dynamic>),
    layouts: (json['layouts'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => (e as List<dynamic>)
                  .map((e) => Layout.fromJson(e as Map<String, dynamic>))
                  .toList())
              .toList()),
    ),
    data: (json['data'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k,
          (e as List<dynamic>).map((e) => e as Map<String, dynamic>).toList()),
    ),
  );
}

Map<String, dynamic> _$GetFlowsToJson(GetFlows instance) => <String, dynamic>{
      'appNumber': instance.appNumber,
      'version': instance.version,
      'processDefinitionId': instance.processDefinitionId,
      'processId': instance.processId,
      'events': instance.events,
      'action': instance.action,
      'flows': instance.flows,
      'layouts': instance.layouts,
      'data': instance.data,
    };

Events _$EventsFromJson(Map<String, dynamic> json) {
  return Events(
    flows: (json['flows'] as List<dynamic>).map((e) => e as String).toList(),
    data: json['data'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$EventsToJson(Events instance) => <String, dynamic>{
      'flows': instance.flows,
      'data': instance.data,
    };

FlowAction _$FlowActionFromJson(Map<String, dynamic> json) {
  return FlowAction(
    type: json['type'] as String,
    value: ActionValue.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FlowActionToJson(FlowAction instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
    };

ActionValue _$ActionValueFromJson(Map<String, dynamic> json) {
  return ActionValue(
    id: json['id'] as String,
    name: json['name'] as String,
    params:
        (json['params'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$ActionValueToJson(ActionValue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'params': instance.params,
    };

Flows _$FlowsFromJson(Map<String, dynamic> json) {
  return Flows(
    title: json['title'] as String?,
    subtitle: json['subtitle'] as String?,
    layout: (json['layout'] as List<dynamic>)
        .map((e) => (e as List<dynamic>)
            .map((e) => Layout.fromJson(e as Map<String, dynamic>))
            .toList())
        .toList(),
    action_menu: json['action_menu'] == null
        ? null
        : ActionMenu.fromJson(json['action_menu'] as Map<String, dynamic>),
    onBack: json['onBack'] == null
        ? null
        : WidgetAction.fromJson(json['onBack'] as Map<String, dynamic>),
    onLoad: json['onLoad'] == null
        ? null
        : WidgetAction.fromJson(json['onLoad'] as Map<String, dynamic>),
    onUnload: json['onUnload'] == null
        ? null
        : WidgetAction.fromJson(json['onUnload'] as Map<String, dynamic>),
    flow: json['flow'] as String?,
    requireAppBar: json['requireAppBar'] as String?,
    analytic_id: json['analytic_id'] as String?,
    analytic_event_metadata: json['analytic_event_metadata'] as String?,
    native_analytic_event_name: json['native_analytic_event_name'] as String?,
    native_analytic_event_action:
        json['native_analytic_event_action'] as String?,
    native_analytic_types: (json['native_analytic_types'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
  );
}

Map<String, dynamic> _$FlowsToJson(Flows instance) => <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'flow': instance.flow,
      'requireAppBar': instance.requireAppBar,
      'onBack': instance.onBack,
      'onLoad': instance.onLoad,
      'onUnload': instance.onUnload,
      'layout': instance.layout,
      'action_menu': instance.action_menu,
      'analytic_id': instance.analytic_id,
      'analytic_event_metadata': instance.analytic_event_metadata,
      'native_analytic_types': instance.native_analytic_types,
      'native_analytic_event_name': instance.native_analytic_event_name,
      'native_analytic_event_action': instance.native_analytic_event_action,
    };

ActionMenu _$ActionMenuFromJson(Map<String, dynamic> json) {
  return ActionMenu(
    icon: json['icon'] as String,
    title: json['title'] as String,
    action: json['action'] == null
        ? null
        : WidgetAction.fromJson(json['action'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ActionMenuToJson(ActionMenu instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'title': instance.title,
      'action': instance.action,
    };

Layout _$LayoutFromJson(Map<String, dynamic> json) {
  return Layout(
    component: json['component'] as String,
    id: json['id'] as String,
    analytic_id: json['analytic_id'] as String?,
    analytic_event_metadata: json['analytic_event_metadata'] as String?,
    params: json['params'] == null
        ? null
        : Params.fromJson(json['params'] as Map<String, dynamic>),
    action: json['action'] == null
        ? null
        : WidgetAction.fromJson(json['action'] as Map<String, dynamic>),
    validation: json['validation'] as Map<String, dynamic>?,
    width: json['width'] as int,
    style: json['style'] == null
        ? null
        : WidgetStyle.fromJson(json['style'] as Map<String, dynamic>),
    onTap: json['onTap'] == null
        ? null
        : WidgetAction.fromJson(json['onTap'] as Map<String, dynamic>),
    onChange: json['onChange'] == null
        ? null
        : WidgetAction.fromJson(json['onChange'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LayoutToJson(Layout instance) => <String, dynamic>{
      'component': instance.component,
      'id': instance.id,
      'width': instance.width,
      'params': instance.params,
      'validation': instance.validation,
      'action': instance.action,
      'style': instance.style,
      'onTap': instance.onTap,
      'onChange': instance.onChange,
      'analytic_id': instance.analytic_id,
      'analytic_event_metadata': instance.analytic_event_metadata,
    };

ValidationRule _$ValidationRuleFromJson(Map<String, dynamic> json) {
  return ValidationRule(
    minLength: json['minLength'] == null
        ? null
        : ValidationRuleValue.fromJson(
            json['minLength'] as Map<String, dynamic>),
    maxLength: json['maxLength'] == null
        ? null
        : ValidationRuleValue.fromJson(
            json['maxLength'] as Map<String, dynamic>),
    regex: json['regex'] == null
        ? null
        : ValidationRuleValue.fromJson(json['regex'] as Map<String, dynamic>),
    required: json['required'] == null
        ? null
        : ValidationRuleValue.fromJson(
            json['required'] as Map<String, dynamic>),
    compareValue: json['compareValue'] == null
        ? null
        : ValidationRuleValue.fromJson(
            json['compareValue'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ValidationRuleToJson(ValidationRule instance) =>
    <String, dynamic>{
      'minLength': instance.minLength,
      'maxLength': instance.maxLength,
      'regex': instance.regex,
      'required': instance.required,
      'compareValue': instance.compareValue,
    };

ValidationRuleValue _$ValidationRuleValueFromJson(Map<String, dynamic> json) {
  return ValidationRuleValue(
    value: json['value'],
    message: json['message'] as String,
  );
}

Map<String, dynamic> _$ValidationRuleValueToJson(
        ValidationRuleValue instance) =>
    <String, dynamic>{
      'message': instance.message,
      'value': instance.value,
    };

Params _$ParamsFromJson(Map<String, dynamic> json) {
  return Params(
    title: json['title'] as String?,
    subTitle: json['subTitle'] as String?,
    placeholder: json['placeholder'] as String?,
    isPartTitleNeedTobeShown: json['isPartTitleNeedTobeShown'] as bool?,
    isOverLayShouldbeShownAbove: json['isOverLayShouldbeShownAbove'] as bool?,
    onTapRequestNeedToBeSend: json['onTapRequestNeedToBeSend'] as bool?,
    isTextInputRestrictionBasedOnRegex:
        json['isTextInputRestrictionBasedOnRegex'] as String?,
    controlledBy: json['controlledBy'] as String?,
    disabled: json['disabled'] as bool?,
    hint: json['hint'] as String?,
    info: json['info'] as String?,
    left: (json['left'] as List<dynamic>?)
        ?.map((e) => PositionalParams.fromJson(e as Map<String, dynamic>))
        .toList(),
    options:
        (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    right: (json['right'] as List<dynamic>?)
        ?.map((e) => PositionalParams.fromJson(e as Map<String, dynamic>))
        .toList(),
    keyboardType: json['keyboardType'] as String?,
    themeStyle: json['themeStyle'] as String?,
    doubleValue: (json['doubleValue'] as num?)?.toDouble(),
    intValue: json['intValue'] as int?,
    stringValue: json['stringValue'] as String?,
    dynamicList: (json['dynamicList'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList(),
    defaultList: (json['defaultList'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList(),
    clickableText: json['clickableText'] as String?,
    disabledWhen: json['disabledWhen'] as String?,
    visibleWhen: json['visibleWhen'] as String?,
    isAlignCenter: json['isAlignCenter'] as bool?,
    isOutLine: json['isOutLine'] as bool?,
    bgColorName: json['bgColorName'] as String?,
    textColorName: json['textColorName'] as String?,
    url: json['url'] as String?,
    readOnly: json['readOnly'] as bool?,
    isOnTapNeeded: json['isOnTapNeeded'] as bool?,
    isMask: json['isMask'] as bool?,
    isManualDetailsButtonRequired:
        json['isManualDetailsButtonRequired'] as bool?,
    manualDetailsButtonTitle: json['manualDetailsButtonTitle'] as String?,
    isTypePDF: json['isTypePDF'] as bool?,
    autoFetchKey: json['autoFetchKey'] as String?,
    isLoaderType: json['isLoaderType'] as bool?,
    uploadFlow: json['uploadFlow'] as String?,
    isLetterInCAP: json['isLetterInCAP'] as bool?,
    charLimit: json['charLimit'] as int?,
    native_analytic_event_name: json['native_analytic_event_name'] as String?,
    native_analytic_event_action:
        json['native_analytic_event_action'] as String?,
    native_analytic_event_label: json['native_analytic_event_label'] as String?,
    native_analytic_event_name_optional:
        json['native_analytic_event_name_optional'] as String?,
    native_analytic_event_action_optional:
        json['native_analytic_event_action_optional'] as String?,
    native_analytic_types: (json['native_analytic_types'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    native_analytic_types_optional:
        (json['native_analytic_types_optional'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
  );
}

Map<String, dynamic> _$ParamsToJson(Params instance) => <String, dynamic>{
      'title': instance.title,
      'placeholder': instance.placeholder,
      'isPartTitleNeedTobeShown': instance.isPartTitleNeedTobeShown,
      'isOverLayShouldbeShownAbove': instance.isOverLayShouldbeShownAbove,
      'onTapRequestNeedToBeSend': instance.onTapRequestNeedToBeSend,
      'isTextInputRestrictionBasedOnRegex':
          instance.isTextInputRestrictionBasedOnRegex,
      'subTitle': instance.subTitle,
      'options': instance.options,
      'controlledBy': instance.controlledBy,
      'disabled': instance.disabled,
      'hint': instance.hint,
      'info': instance.info,
      'keyboardType': instance.keyboardType,
      'left': instance.left,
      'right': instance.right,
      'themeStyle': instance.themeStyle,
      'doubleValue': instance.doubleValue,
      'intValue': instance.intValue,
      'stringValue': instance.stringValue,
      'dynamicList': instance.dynamicList,
      'defaultList': instance.defaultList,
      'clickableText': instance.clickableText,
      'visibleWhen': instance.visibleWhen,
      'disabledWhen': instance.disabledWhen,
      'isAlignCenter': instance.isAlignCenter,
      'isOutLine': instance.isOutLine,
      'bgColorName': instance.bgColorName,
      'textColorName': instance.textColorName,
      'url': instance.url,
      'readOnly': instance.readOnly,
      'isOnTapNeeded': instance.isOnTapNeeded,
      'isMask': instance.isMask,
      'isManualDetailsButtonRequired': instance.isManualDetailsButtonRequired,
      'manualDetailsButtonTitle': instance.manualDetailsButtonTitle,
      'isTypePDF': instance.isTypePDF,
      'autoFetchKey': instance.autoFetchKey,
      'isLoaderType': instance.isLoaderType,
      'uploadFlow': instance.uploadFlow,
      'isLetterInCAP': instance.isLetterInCAP,
      'charLimit': instance.charLimit,
      'native_analytic_types': instance.native_analytic_types,
      'native_analytic_event_name': instance.native_analytic_event_name,
      'native_analytic_event_action': instance.native_analytic_event_action,
      'native_analytic_event_label': instance.native_analytic_event_label,
      'native_analytic_types_optional': instance.native_analytic_types_optional,
      'native_analytic_event_name_optional':
          instance.native_analytic_event_name_optional,
      'native_analytic_event_action_optional':
          instance.native_analytic_event_action_optional,
    };

PositionalParams _$PositionalParamsFromJson(Map<String, dynamic> json) {
  return PositionalParams(
    component: json['component'] as String?,
    icon: json['icon'] as String?,
    id: json['id'] as String?,
    value: json['value'] as String?,
    action: json['action'] == null
        ? null
        : WidgetAction.fromJson(json['action'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PositionalParamsToJson(PositionalParams instance) =>
    <String, dynamic>{
      'component': instance.component,
      'icon': instance.icon,
      'id': instance.id,
      'value': instance.value,
      'action': instance.action,
    };

WidgetAction _$WidgetActionFromJson(Map<String, dynamic> json) {
  return WidgetAction(
    api: json['api'] as String,
    method: json['method'] as String?,
    type: json['type'] as String,
    headerParameters: (json['headerParameters'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    to: (json['to'] as List<dynamic>?)
        ?.map((e) => ToCondition.fromJson(e as Map<String, dynamic>))
        .toList(),
    queryParameters: (json['queryParameters'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    layout: (json['layout'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>)
            .map((e) => Layout.fromJson(e as Map<String, dynamic>))
            .toList())
        .toList(),
    bodyParameters: json['bodyParameters'] as Map<String, dynamic>?,
    postNavigate: json['postNavigate'] as String?,
    layoutId: json['layoutId'] as String?,
    others: json['others'] as String?,
    analytic_id: json['analytic_id'] as String?,
    analytic_event_metadata: json['analytic_event_metadata'] as String?,
  );
}

Map<String, dynamic> _$WidgetActionToJson(WidgetAction instance) =>
    <String, dynamic>{
      'api': instance.api,
      'method': instance.method,
      'type': instance.type,
      'others': instance.others,
      'postNavigate': instance.postNavigate,
      'layoutId': instance.layoutId,
      'headerParameters': instance.headerParameters,
      'queryParameters': instance.queryParameters,
      'bodyParameters': instance.bodyParameters,
      'layout': instance.layout,
      'to': instance.to,
      'analytic_id': instance.analytic_id,
      'analytic_event_metadata': instance.analytic_event_metadata,
    };

ToCondition _$ToConditionFromJson(Map<String, dynamic> json) {
  return ToCondition(
    condition: json['condition'] as String?,
    to: ToNested.fromJson(json['to'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ToConditionToJson(ToCondition instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'to': instance.to,
    };

WidgetPadding _$WidgetPaddingFromJson(Map<String, dynamic> json) {
  return WidgetPadding(
    top: (json['top'] as num?)?.toDouble(),
    right: (json['right'] as num?)?.toDouble(),
    bottom: (json['bottom'] as num?)?.toDouble(),
    left: (json['left'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$WidgetPaddingToJson(WidgetPadding instance) =>
    <String, dynamic>{
      'right': instance.right,
      'top': instance.top,
      'bottom': instance.bottom,
      'left': instance.left,
    };

WidgetStyle _$WidgetStyleFromJson(Map<String, dynamic> json) {
  return WidgetStyle(
    padding: json['padding'] == null
        ? null
        : WidgetPadding.fromJson(json['padding'] as Map<String, dynamic>),
    textAlign: json['textAlign'] as String?,
  );
}

Map<String, dynamic> _$WidgetStyleToJson(WidgetStyle instance) =>
    <String, dynamic>{
      'padding': instance.padding,
      'textAlign': instance.textAlign,
    };

ToNested _$ToNestedFromJson(Map<String, dynamic> json) {
  return ToNested(
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$ToNestedToJson(ToNested instance) => <String, dynamic>{
      'id': instance.id,
    };
